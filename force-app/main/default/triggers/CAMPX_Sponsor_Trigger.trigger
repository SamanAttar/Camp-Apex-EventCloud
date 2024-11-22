trigger CAMPX_Sponsor_Trigger on CAMPX__Sponsor__c (before insert, before update,after insert, after update) {


    switch on Trigger.operationType {
        when BEFORE_INSERT {
            CAMPX_Sponsor_TriggerHandler.updateSponsorStatusToPendingBeforeUpdate(Trigger.new);
            CAMPX_Sponsor_TriggerHandler.updateTierBasedOnContributionBeforeInsert(Trigger.new);


            
        }
        when BEFORE_UPDATE{
            CAMPX_Sponsor_TriggerHandler.updateSponsorStatusToPendingBeforeUpdate(Trigger.new);
        }

        when AFTER_INSERT{
            CAMPX_Sponsor_TriggerHandler.afterUpdateAccountContributionOnGrossRevenue(Trigger.new);
        }

        when AFTER_UPDATE{
            CAMPX_Sponsor_TriggerHandler.afterUpdateAccountContributionOnGrossRevenue(Trigger.new);
            CAMPX_Sponsor_TriggerHandler.afterStatusUpdateGrossRevenueChange(Trigger.new, Trigger.oldMap);
        }
   
   
      
    }

}