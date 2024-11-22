public with sharing class CAMPX_Sponsor_TriggerHandler {

        public CAMPX_Sponsor_TriggerHandler() {

    }

    public static void updateTierBasedOnContributionBeforeInsert(List<CAMPX__Sponsor__c> newRecords){

        for(CAMPX__Sponsor__c record : newRecords){
            if(record.CAMPX__ContributionAmount__c == null || record.CAMPX__ContributionAmount__c <= 0){
                record.CAMPX__Tier__c = '';
            }
            else if( record.CAMPX__ContributionAmount__c < 1000){
                record.CAMPX__Tier__c = 'Bronze';
            }
            else if(record.CAMPX__ContributionAmount__c < 5000){
                record.CAMPX__Tier__c = 'Silver';
            }
            else if( record.CAMPX__ContributionAmount__c >= 5000){
                record.CAMPX__Tier__c = 'Gold';
            }
        }
    }

    public static void updateSponsorStatusToPendingBeforeUpdate(List<CAMPX__Sponsor__c> newRecords)
    {
        for( CAMPX__Sponsor__c record : newRecords){

            if(String.isBlank(record.CAMPX__Email__c)){
                record.addError('A sponsor can not be created without an email address', false);
            }

            if(String.isBlank(record.CAMPX__Status__c )){
                record.CAMPX__Status__c = 'Pending';
            }

            if(String.isBlank(record.CAMPX__Event__c) && record.CAMPX__Status__c == 'Accepted'){
            //    record.addError('A Sponsor must be associated with an event before being Accepted.', false);

            }

                  }

    }


    /*Afrer Save Record update on CAMPX__Event__c's CAMPX__GrossRevenue__c field 
when CAMPX__Sponsor__c record is updated to have an "Accepted"  on CAMPX__Status__c, 
the system should account for the sponsor's CAMPX__ContributedAmount__c */

public static void afterUpdateAccountContributionOnGrossRevenue(List<CAMPX__Sponsor__c> sponsorRecords){

    List<CAMPX__Event__c> tobeUpdatedEventRecordsWithGrossAmount = new List<CAMPX__Event__c>();
    Set<Id> parentEventIds = new Set<Id> ();

//Get the parent event ids
    for(CAMPX__Sponsor__c gettingParentsEventsOnly : sponsorRecords)
    {

        parentEventIds.add(gettingParentsEventsOnly.CAMPX__Event__r.Id);
    }

    List<CAMPX__Event__c> parentEventRecords =  [ select Id,CAMPX__GrossRevenue__c,(select Id, CAMPX__Status__c,CAMPX__Event__c,CAMPX__ContributionAmount__c FROM CAMPX__SPONSORS__r) FROM  CAMPX__Event__c ];


   /* for every sponsor record in every event check if status is accepted and contribution money !- null then 
    update event's gross amount as gross amount = gross amount + that particualar sponsors contributed amount */


    for ( CAMPX__Event__c indvidualParentEvent : parentEventRecords){

        Decimal sumofEachChildSponsorsContributionAmount = 0.0;

        for ( CAMPX__Sponsor__c indvidualchildsponsorRecord : indvidualParentEvent.CAMPX__Sponsors__r){

            if( indvidualchildsponsorRecord.CAMPX__Event__c != null && indvidualchildsponsorRecord.CAMPX__Status__c == 'Accepted' && indvidualchildsponsorRecord.CAMPX__ContributionAmount__c != null){

sumofEachChildSponsorsContributionAmount += indvidualchildsponsorRecord.CAMPX__ContributionAmount__c;
            }
        }
        indvidualParentEvent.CAMPX__GrossRevenue__c = sumofEachChildSponsorsContributionAmount;
        tobeUpdatedEventRecordsWithGrossAmount.add(indvidualParentEvent);


    }


   update tobeUpdatedEventRecordsWithGrossAmount;
    
   
}


public static void afterStatusUpdateGrossRevenueChange(List<CAMPX__Sponsor__c> statusChangedSponsorRecords, Map<Id, CAMPX__Sponsor__c> oldStatusedSponsorRecords) {

    Set<Id> eventIdsToUpdate = new Set<Id>();  // To track events whose gross revenue needs updating
    List<CAMPX__Sponsor__c> sponsorsToUpdate = new List<CAMPX__Sponsor__c>();  // To handle status changes

    // Loop through each sponsor whose status or event lookup changed
    for (CAMPX__Sponsor__c changedSponsor : statusChangedSponsorRecords) {

        // Get the old sponsor record for comparison
        CAMPX__Sponsor__c oldSponsor = oldStatusedSponsorRecords.get(changedSponsor.Id);

        // 1. Check if the event lookup has changed
        if (changedSponsor.CAMPX__Event__c != oldSponsor.CAMPX__Event__c) {
            // Add the old event to the set of events to update (remove amount contribution from Events Gross)
            if (oldSponsor.CAMPX__Event__c != null) {
                eventIdsToUpdate.add(oldSponsor.CAMPX__Event__c);
            }

            // Add the new event to the set of events to update (add contribution if accepted)
            if (changedSponsor.CAMPX__Event__c != null) {
                eventIdsToUpdate.add(changedSponsor.CAMPX__Event__c);
            // } else if(changedSponsor.CAMPX__Event__c == null && changedSponsor.CAMPX__Status__c == 'Accepted') {
            //     // If the sponsor is no longer linked to an event and is still accepted, change the status to avoid validation rule failure
            //         changedSponsor.CAMPX__Status__c = 'Pending';  // Change status from Accepted to Pending to satisfy validation
            //         sponsorsToUpdate.add(changedSponsor);
                
             }
        }

        // 2. Check if the sponsor's status changed from "Accepted" to "Cancelled" or "Pending"
        if (oldSponsor.CAMPX__Status__c == 'Accepted' &&
           (changedSponsor.CAMPX__Status__c == 'Cancelled' || changedSponsor.CAMPX__Status__c == 'Pending')) {
            // Add the current event to update its gross revenue (remove contribution)
            if (changedSponsor.CAMPX__Event__c != null) {
                eventIdsToUpdate.add(changedSponsor.CAMPX__Event__c);
            }
        }

        // 3. Check if the sponsor's status changed from any other status to "Accepted"
        if ((oldSponsor.CAMPX__Status__c == 'Cancelled' || oldSponsor.CAMPX__Status__c == 'Pending' || oldSponsor.CAMPX__Status__c == 'Rejected') &&
            changedSponsor.CAMPX__Status__c == 'Accepted') {
            // Add the current event to update its gross revenue (add contribution)
            if (changedSponsor.CAMPX__Event__c != null) {
                eventIdsToUpdate.add(changedSponsor.CAMPX__Event__c);
            }
        }
    }

    // Update sponsors whose status was changed to avoid validation rule failure
    if (!sponsorsToUpdate.isEmpty()) {
        update sponsorsToUpdate;  // Updates status to avoid breaking the validation rule
    }

    // Now update the gross revenue of all impacted events
    List<CAMPX__Event__c> eventsToUpdate = [SELECT Id, CAMPX__GrossRevenue__c, 
                                            (SELECT Id, CAMPX__ContributionAmount__c, CAMPX__Status__c 
                                             FROM CAMPX__Sponsors__r) 
                                            FROM CAMPX__Event__c 
                                            WHERE Id IN :eventIdsToUpdate];

    for (CAMPX__Event__c eventRecord : eventsToUpdate) {
        Decimal newGrossRevenue = 0;

        // Recalculate the gross revenue by summing the contribution of all "Accepted" sponsors
        for (CAMPX__Sponsor__c sponsor : eventRecord.CAMPX__Sponsors__r) {
            if (sponsor.CAMPX__Status__c == 'Accepted' && sponsor.CAMPX__ContributionAmount__c != null && sponsor.CAMPX__Event__c != null) {
                newGrossRevenue += sponsor.CAMPX__ContributionAmount__c;
            }
            else if (sponsor.CAMPX__Status__c == 'Accepted' && sponsor.CAMPX__ContributionAmount__c != null && sponsor.CAMPX__Event__c == null){

                newGrossRevenue = newGrossRevenue - sponsor.CAMPX__ContributionAmount__c;
            }
        }

        // Update the event's gross revenue
        eventRecord.CAMPX__GrossRevenue__c = newGrossRevenue;
    }

    // Update the events with the new gross revenue
    update eventsToUpdate;
}



}




