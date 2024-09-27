public with sharing class SponsorContributionTierHelper {
    
    public static void addTierBasedOnContribution(List<CAMPX__Sponsor__c> sponsors) {
        // List<CAMPX__Sponsor__c> sponsorsToUpdate = new List<CAMPX__Sponsor__c>();
        

        for (CAMPX__Sponsor__c sp : sponsors) {
            
            
            if (sp.CAMPX__ContributionAmount__c == null || sp.CAMPX__ContributionAmount__c <= 0 ) {
                sp.CAMPX__Tier__c = '';
            } else if (sp.CAMPX__ContributionAmount__c > 0 && sp.CAMPX__ContributionAmount__c < 1000) {
                sp.CAMPX__Tier__c = 'Bronze';
            } else if (sp.CAMPX__ContributionAmount__c >= 1000 && sp.CAMPX__ContributionAmount__c < 5000) {
                sp.CAMPX__Tier__c = 'Silver';
            } else if (sp.CAMPX__ContributionAmount__c >= 5000) {
                sp.CAMPX__Tier__c = 'Gold';
            }

            System.debug('Contribution is ' + sp.CAMPX__ContributionAmount__c + ' and tier is ' + sp.CAMPX__Tier__c);
        }

        // try {
        //     if (Schema.sObjectType.CAMPX__Sponsor__c.isUpdateable()) {
        //         update sponsorsToUpdate;
        //     } 
        // } catch (DmlException e) {
        //     System.debug('The following exception has occurred: ' + e.getMessage());            
        // }        
    }
}