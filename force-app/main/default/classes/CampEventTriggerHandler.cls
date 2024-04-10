public with sharing class CampEventTriggerHandler {

    private static final String STATUS_PLANNING = 'Planning';

    public static void onBeforeInsert(List<CAMPX__Event__c> newRecords) {
        setDefaultStatus(newRecords);
        calculateNetRevenue(newRecords);
    }

    public static void onBeforeUpdate(List<CAMPX__Event__c> newRecords, Map<Id,CAMPX__Event__c> oldRecordsMap) {
        updateStatusChangeDateAfterStatusChange(newRecords, oldRecordsMap);
        calculateNetRevenue(newRecords);
    }

    private static void setDefaultStatus(List<CAMPX__Event__c> newRecords) {
        for (CAMPX__Event__c event : newRecords) {
            event.CAMPX__Status__c = STATUS_PLANNING;
            event.CAMPX__StatusChangeDate__c = System.now();
        }
    }

    private static void updateStatusChangeDateAfterStatusChange(List<CAMPX__Event__c> newRecords, Map<Id,CAMPX__Event__c> oldRecordsMap) {
        for (CAMPX__Event__c event : newRecords) {
            if (event.CAMPX__Status__c != oldRecordsMap.get(event.Id).CAMPX__Status__c) {
                event.CAMPX__StatusChangeDate__c = System.now();
            }
        }
    }

    private static void calculateNetRevenue(List<CAMPX__Event__c> newRecords) {
        for (CAMPX__Event__c event : newRecords) {
            if (event.CAMPX__GrossRevenue__c == null || event.CAMPX__TotalExpenses__c == null) {
                event.CAMPX__NetRevenue__c = null;
            } else {
                event.CAMPX__NetRevenue__c = event.CAMPX__GrossRevenue__c - event.CAMPX__TotalExpenses__c;
            }
        }
    }
}