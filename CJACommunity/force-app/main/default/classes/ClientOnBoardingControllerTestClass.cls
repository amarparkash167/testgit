@isTest
public class ClientOnBoardingControllerTestClass {
    static testMethod void createClientRecordsSuccess(){
        
        Account account = new Account(Name = 'Test Account');
        
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact');
        
        Opportunity opp = new Opportunity(Name='Test Opp');
        
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('App sales').getRecordTypeId();
        
        
        ClientOnBoardingController.initializeObjects();
        
        String returnVal = ClientOnBoardingController.createClientRecords(account, contact, opp, 'test', 'test description');
        //system.assert(returnVal.contains('Success'));
        ClientOnBoardingController.getOpportunityRecordTypes();
        
    }
    static testMethod void createClientRecordsErrors(){
        Account account = new Account();
        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact');
        Contact contact1 = new Contact();
        Opportunity opp = new Opportunity(Name='Test Opp');
        Opportunity opp1 = new Opportunity();
        
        String returnVal1 = ClientOnBoardingController.createClientRecords(account, contact, opp, 'test', 'test description');
        String returnVal2 = ClientOnBoardingController.createClientRecords(account, contact1, opp1, '', 'test description');
        system.debug('Return Val = ' + returnVal1);
        system.assert(returnVal1.contains('failed'));
        system.assert(returnVal2.contains('failed'));
    }
}