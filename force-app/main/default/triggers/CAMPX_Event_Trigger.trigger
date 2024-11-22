trigger CAMPX_Event_Trigger on CAMPX__Event__c (before insert, before update) {

    switch on Trigger.operationType {
        when BEFORE_INSERT {
            CAMPX_Event_BfiTriggerHandler.callingPrivateMethodsBeforeInsert(Trigger.new);


        }
    }
        switch on Trigger.operationType {
            when BEFORE_UPDATE {
                CAMPX_Event_BfiTriggerHandler.callingPrivateMethodsBeforeUpdate(Trigger.new, Trigger.oldMap);
            }



}
}