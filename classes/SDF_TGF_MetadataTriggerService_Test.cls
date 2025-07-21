/**
 * @author Wenbo Zhou
 * @date 2021-05-16
 * @description This class is used to test SDF_TGF_MetadataTriggerService
 *
 * Originally from github.com/trailheadapps/apex-recipes
 */

@IsTest
private class SDF_TGF_MetadataTriggerService_Test {
    @IsTest
    static void testGetMetadataTriggers() {
        SDF_TGF_MetadataTriggerService mts = new SDF_TGF_MetadataTriggerService(
            'Invalid_Object__c'
        );
        Test.startTest();
        List<SDF_TGF_Trigger_Config__mdt> triggerConfigs = mts.getMetadataTriggers();
        Test.stopTest();

        System.assertEquals(
            triggerConfigs.size(),
            0,
            'Expected to find no metadata records'
        );
    }

    @IsTest
    static void testGetSObjectTypeNegative() {
        Boolean didCatchProperException = false;
        Test.startTest();
        try {
            SDF_TGF_MetadataTriggerService.getSObjectType();
        } catch (SDF_TGF_MetadataTriggerService.MetadataTriggerServiceException triggerEx) {
            if (
                triggerEx.getMessage()
                    .containsIgnoreCase(
                    'trigger.new && trigger.old are both null'
                )
                ) {
                didCatchProperException = true;
            }
        }
        Test.stopTest();
        System.assert(
            didCatchProperException,
            'executing this method in a unit test should result in an exception'
        );
    }
}