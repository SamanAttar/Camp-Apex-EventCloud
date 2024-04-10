public with sharing class CampxSponsorTriggerHandler {

    private static final String STATUS_PENDING = 'Pending';
    private static final String STATUS_ACCEPTED = 'Accepted';

    public static void onBeforeInsert(List<CAMPX__Sponsor__c> newRecords) {
        setDefaultStatus(newRecords);
        validateEmailFieldIsEntered(newRecords);
        setSponsorTierBasedOnContributionAmount(newRecords, null);
        validateStatusChangeToAccepted(newRecords, null);
    }

    public static void onBeforeUpdate(List<CAMPX__Sponsor__c> newRecords, Map<Id,CAMPX__Sponsor__c> oldRecordsMap) {
        setSponsorTierBasedOnContributionAmount(newRecords, oldRecordsMap);
        validateStatusChangeToAccepted(newRecords, oldRecordsMap);
    }

    public static void onAfterInsert(List<CAMPX__Sponsor__c> newRecords) {
        updateEventGrossRevenueUponSponsorAcceptance(newRecords, null);
    }

    public static void onAfterUpdate(List<CAMPX__Sponsor__c> newRecords, Map<Id,CAMPX__Sponsor__c> oldRecordsMap) {
        updateEventGrossRevenueUponSponsorAcceptance(newRecords, oldRecordsMap);
    }

    private static void setDefaultStatus(List<CAMPX__Sponsor__c> newRecords) {
        for (CAMPX__Sponsor__c sponsor : newRecords) {
            if (String.isBlank(sponsor.CAMPX__Status__c)) {
                sponsor.CAMPX__Status__c = STATUS_PENDING;
            }
        }
    }

    private static void validateEmailFieldIsEntered(List<CAMPX__Sponsor__c> newRecords) {
        for (CAMPX__Sponsor__c sponsor : newRecords) {
            if (String.isBlank(sponsor.CAMPX__Email__c)) {
                sponsor.addError('A sponsor can not be created without an email address');
            }
        }
    }

    private static void setSponsorTierBasedOnContributionAmount(List<CAMPX__Sponsor__c> newRecords, Map<Id,CAMPX__Sponsor__c> oldRecordsMap) {
        for (CAMPX__Sponsor__c sponsor : newRecords) {
            if (oldRecordsMap == null || sponsor.CAMPX__ContributionAmount__c != oldRecordsMap.get(sponsor.Id).CAMPX__ContributionAmount__c) { 
                if (sponsor.CAMPX__ContributionAmount__c >= 5000) {
                    sponsor.CAMPX__Tier__c = 'Gold';
                } else if (sponsor.CAMPX__ContributionAmount__c >= 1000) {
                    sponsor.CAMPX__Tier__c = 'Silver';
                } else if (sponsor.CAMPX__ContributionAmount__c > 0) {
                    sponsor.CAMPX__Tier__c = 'Bronze';
                } else {
                    sponsor.CAMPX__Tier__c = '';
                }
            }
        }
    }

    private static void validateStatusChangeToAccepted(List<CAMPX__Sponsor__c> newRecords, Map<Id,CAMPX__Sponsor__c> oldRecordsMap) {
        for (CAMPX__Sponsor__c sponsor : newRecords) {
            if ((oldRecordsMap == null 
                || sponsor.CAMPX__Status__c  != oldRecordsMap.get(sponsor.Id).CAMPX__Status__c) 
                && sponsor.CAMPX__Status__c == STATUS_ACCEPTED 
                && String.isBlank(sponsor.CAMPX__Event__c)) { 
                    sponsor.addError('A Sponsor must be associated with an event before being Accepted.');
            }
        }
    }

    private static void updateEventGrossRevenueUponSponsorAcceptance(List<CAMPX__Sponsor__c> newRecords, Map<Id,CAMPX__Sponsor__c> oldRecordsMap) {
        Set<Id> eventIds = new Set<Id>();
        for (CAMPX__Sponsor__c sponsor : newRecords) {
            if (hasToRecalculateEventsGrossRevenue(sponsor, oldRecordsMap)) {
                eventIds.add(sponsor.CAMPX__Event__c);
            }
        }
        if (eventIds.size() > 0) {
            calculateEventGrossRevenue(eventIds);
        }
    }


    private static Boolean hasToRecalculateEventsGrossRevenue(CAMPX__Sponsor__c sponsor, Map<Id,CAMPX__Sponsor__c> oldRecordsMap) {
        return ((oldRecordsMap == null 
                    || sponsor.CAMPX__Status__c  != oldRecordsMap.get(sponsor.Id).CAMPX__Status__c
                    || sponsor.CAMPX__ContributionAmount__c  != oldRecordsMap.get(sponsor.Id).CAMPX__ContributionAmount__c) 
                    && sponsor.CAMPX__Status__c == STATUS_ACCEPTED)
                || (oldRecordsMap != null 
                    && sponsor.CAMPX__Status__c  != oldRecordsMap.get(sponsor.Id).CAMPX__Status__c
                    && oldRecordsMap.get(sponsor.Id).CAMPX__Status__c == STATUS_ACCEPTED)
                || (oldRecordsMap != null 
                    && sponsor.CAMPX__Event__c != oldRecordsMap.get(sponsor.Id).CAMPX__Event__c);
    }

    private static void calculateEventGrossRevenue(Set<Id> eventIds) {
        MAp<Id, CAMPX__Event__c> eventsToUpdateMap = new Map<Id,CAMPX__Event__c>();
        for (Id eventId : eventIds) {
            eventsToUpdateMap.put(eventId, new CAMPX__Event__c(Id=eventId, CAMPX__GrossRevenue__c=0));
        }

        List<AggregateResult> results = [
            SELECT SUM(CAMPX__ContributionAmount__c) Amount, CAMPX__Event__c Event, CAMPX__Status__c Status 
            FROM CAMPX__Sponsor__c 
            WHERE CAMPX__Event__c IN :eventIds 
            AND CAMPX__Status__c = :STATUS_ACCEPTED
            GROUP BY CAMPX__Event__c, CAMPX__Status__c];


        for (AggregateResult result : results) {
            Decimal amount = (Decimal) result.get('Amount');
            Id eventId = (Id) result.get('Event');
            if (eventId != null) {
                eventsToUpdateMap.put(eventId, new CAMPX__Event__c(Id=eventId, CAMPX__GrossRevenue__c=amount));
            }
         }

         update eventsToUpdateMap.values();

    }
}