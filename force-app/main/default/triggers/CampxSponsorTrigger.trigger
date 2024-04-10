trigger CampxSponsorTrigger on CAMPX__Sponsor__c (before insert, before update, after insert, after update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            CampxSponsorTriggerHandler.onBeforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            CampxSponsorTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            CampxSponsorTriggerHandler.onAfterInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            CampxSponsorTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}