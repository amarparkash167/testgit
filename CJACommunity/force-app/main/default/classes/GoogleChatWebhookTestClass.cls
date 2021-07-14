@isTest
public class GoogleChatWebhookTestClass {
    
    static testMethod void testCallInvocableClass() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
		
        Account issue = new Account(Name = 'Company Test');
    	insert issue;
        
		//Issue__c issue = [Select Id from Issue__c limit 1];        
        //to makesure test class is cover, need to call invocable class directly, which in this scenario I need to instantiate
        // inner class 
        List<GoogleChatWebhook.GoogleChatData> listRequest = new List<GoogleChatWebhook.GoogleChatData>();
        GoogleChatWebhook.GoogleChatData req = new GoogleChatWebhook.GoogleChatData();
        
        req.recordId=issue.Id;
        req.webhookUrl='https://google.com';
        req.alertMessage='New Ticket Alert !';
        req.alertDetails='Alert Details Description';
   
        
        listRequest.add(req);
        
        //the call the method directly - here my method is updateQuote
        GoogleChatWebhook.sendChat(listRequest);
        
        Test.stopTest();
        
    }
}