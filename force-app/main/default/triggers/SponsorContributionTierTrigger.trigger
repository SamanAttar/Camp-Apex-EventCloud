trigger SponsorContributionTierTrigger on CAMPX__Sponsor__c (before insert, before update) {
  
  SponsorContributionTierHelper.addTierBasedOnContribution(Trigger.new);
  
}