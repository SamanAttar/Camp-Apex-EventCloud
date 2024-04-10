trigger CampxEventTrigger on CAMPX__Event__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            CampEventTriggerHandler.onBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            CampEventTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}