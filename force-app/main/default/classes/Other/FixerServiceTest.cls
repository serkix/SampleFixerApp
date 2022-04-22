@isTest
public with sharing class FixerServiceTest {
    @TestSetup
    static void makeData(){
        TestDataFactory.createFixerCredentials();
    }

    @isTest
    public static void getRateTestNormal() {
        // GIVEN we have a fixer credentials in the system and a correct response
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('normalFixerResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        StaticResource expectedResource = [SELECT Id, Body FROM StaticResource WHERE Name = 'normalFixerResponse' LIMIT 1];
        String expectedBody = expectedResource.Body.toString();

        // WHEN trying to make request
        Test.startTest();
        string response = fixerService.getRate('EUR', 'USD');
        Test.stopTest();
        // THEN retrieved json should be the same as in static resource for rate retrieval
        System.assertEquals(expectedBody, response);
    }

    @isTest
    public static void getRateTestFixerError() {
        // GIVEN we have a fixer credentials in the system and fixer returns error response
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('errorFixerResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        // WHEN trying to make request
        AuraHandledException capturedException;
        Test.startTest();
        try {
            string response = fixerService.getRate('EUR', 'USD');
        } catch (AuraHandledException e) {
            capturedException = e;
        }
        Test.stopTest();
        
        //THEN AuraException should be thrown
        System.assertNotEquals(null, capturedException, 'Exception should be thrown');
    }

    @isTest
    public static void getRateTestAPIError() {
        // GIVEN we have a fixer credentials in the system and API callout fails
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('errorFixerResponse');
        mock.setStatusCode(418);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);

        // WHEN trying to make request
        AuraHandledException capturedException;
        Test.startTest();
        try {
            string response = fixerService.getRate('EUR', 'USD');
        } catch (AuraHandledException e) {
            capturedException = e;
        }
        Test.stopTest();
        
        //THEN AuraException should be thrown
        System.assertNotEquals(null, capturedException, 'Exception should be thrown');
    }
}
