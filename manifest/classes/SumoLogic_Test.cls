@isTest
public class SumoLogic_Test {
    @isTest
    static void SubmitSumoLog(){
        Test.setMock(HttpCalloutMock.class, new SumoLogicHttpMockImpl());
        Integer responseCode = SumoLogic.PostLog('00Tf400001k3Rwu', 'MockTest', 'MockMe', -1);
        System.assertEquals(200, responseCode);
    }
}