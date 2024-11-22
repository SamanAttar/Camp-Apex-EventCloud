public with sharing class CAMPX_Event_BfiTriggerHandler {

    public CAMPX_Event_BfiTriggerHandler() {
    
    }

private static void BeforeInserUpdateStatusToPlanning( List<CAMPX__Event__c> newRecords){

    for( CAMPX__Event__c record : newRecords)
    {

        record.CAMPX__Status__c = 'Planning';
        record.CAMPX__StatusChangeDate__c = Datetime.now();

    }
   

}

private static void beforeInsertNetRevenueFieldCheck(List<CAMPX__Event__c> newRecords){

    for(CAMPX__Event__c record : newRecords){

        if(record.CAMPX__GrossRevenue__c == null || record.CAMPX__TotalExpenses__c == null){
            record.CAMPX__NetRevenue__c = null;
        }
        else if (record.CAMPX__GrossRevenue__c != null && record.CAMPX__TotalExpenses__c != null)
        {
            record.CAMPX__NetRevenue__c = record.CAMPX__GrossRevenue__c - record.CAMPX__TotalExpenses__c;

        }

    }


}



public static void callingPrivateMethodsBeforeInsert(List<CAMPX__Event__c> newRecords)
{
    CAMPX_Event_BfiTriggerHandler.beforeInsertNetRevenueFieldCheck(newRecords);
    CAMPX_Event_BfiTriggerHandler.BeforeInserUpdateStatusToPlanning(newRecords); 
}

private static void beforeStatusUpdateCaptureDateTime(List<CAMPX__Event__c> editedRecords,Map<Id,CAMPX__Event__c> OldversionOfRecords){
    

    for(CAMPX__Event__c record : editedRecords){

        if(record.CAMPX__Status__c != OldversionOfRecords.get(record.Id).CAMPX__Status__c){

            record.CAMPX__StatusChangeDate__c = Datetime.now();

        }

        }
}

public static void callingPrivateMethodsBeforeUpdate(List<CAMPX__Event__c> editedRecords, Map<Id,CAMPX__Event__c> OldversionOfRecords){
    CAMPX_Event_BfiTriggerHandler.beforeStatusUpdateCaptureDateTime(editedRecords, OldversionOfRecords);
    CAMPX_Event_BfiTriggerHandler.beforeInsertNetRevenueFieldCheck(editedRecords);
}








}