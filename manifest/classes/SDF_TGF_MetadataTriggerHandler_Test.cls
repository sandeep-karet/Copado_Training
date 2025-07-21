/**
 * @author Wenbo Zhou
 * @date 2021-05-16
 * @description This class is used to test SDF_TGF_MetadataTriggerHandler
 */

@IsTest
public with sharing class SDF_TGF_MetadataTriggerHandler_Test {
    private static final String HANDLER_DUMMY = 'DummyHandler';

    /**
     * @description Mocks the metadata trigger service object
     */
    class MetadataTriggerServiceStubProvider implements System.StubProvider {
        /**
         * @description Stub provider's handle method call
         * @param stubbedObject stubbed source object
         * @param stubbedMethodName object's caller name
         * @param returnType return type of the method
         * @param listOfParamTypes a list of parameter types
         * @param listOfParamNames a list of parameter names
         * @param listOfArgs a list of arguments that are passed in to the method
         *
         * @return return the stubbed / mock return object.
         */
        @SuppressWarnings('PMD.ExcessiveParameterList')
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName,
            Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames,
            List<Object> listOfArgs) {

            if (stubbedMethodName == 'getMetadataTriggers') {
                return new List<SDF_TGF_Trigger_Config__mdt>{
                    new SDF_TGF_Trigger_Config__mdt(
                        Class__c = HANDLER_DUMMY,
                        Enabled__c = true,
                        Order__c = 1,
                        Object__c = 'Contact'
                    )
                };
            }

            // if you call a class that is stubbed, and not specify the stub implementation
            // above, it will default return a null
            return null;
        }
    }

    /**
     * @description Test metadata trigger without handlers
     */
    @IsTest
    static void testMetadataTriggerHandlerNoOppWithoutRecordsPositive() {
        SDF_TGF_MetadataTriggerHandler handler = new SDF_TGF_MetadataTriggerHandler(
            new SDF_TGF_MetadataTriggerService('NotExist__c')
        );

        handler.setTriggerContext('after update', true);

        Test.startTest();
        handler.run();
        Test.stopTest();

        System.assertEquals(
            null,
            handler.activeHandler,
            'Expected the activeHandler Property to be null, as no handlers were returned.'
        );
    }

    @IsTest
    static void testExecutesSampleHandlerWhenMdtIsReturnedPositive() {
        SDF_TGF_MetadataTriggerService mockMetadataTriggerSvc
            = (SDF_TGF_MetadataTriggerService) Test.createStub(
                SDF_TGF_MetadataTriggerService.class,
                new SDF_TGF_MetadataTriggerHandler_Test.MetadataTriggerServiceStubProvider()
            );

        SDF_TGF_MetadataTriggerHandler handler = new SDF_TGF_MetadataTriggerHandler(
            mockMetadataTriggerSvc
        );
        handler.setTriggerContext('after update', true);

        Test.startTest();
        String targetClassName = '';
        try {
            handler.run();
        } catch (SDF_TGF_MetadataTriggerHandler.MetadataTriggerHandlerException ex) {
            targetClassName = ex.getMessage()
                .substringAfter(SDF_TGF_MetadataTriggerHandler.CLASS_UNABLE_INSTANTIATE_ERR);
        }
        Test.stopTest();

        System.assertEquals(
            HANDLER_DUMMY,
            targetClassName,
            'Expected the activeHandler Property to be: ' + HANDLER_DUMMY
        );
    }
}