@isTest
public class testSendEmail {
    
    static testMethod void myUnitTest(){
        
        Customer_Invoice__c invoice = new Customer_Invoice__c();
    	invoice.Amount__c = 24000;
        invoice.Invoice_Amount__c = 24000;
        
        Account acc = new Account();
        acc.name = 'Service Master';
        insert acc;
        
        Contact con = new Contact();
        con.firstName = 'John';
        con.lastName = 'Gavin';
        con.AccountId = acc.Id;
        con.email = 'danyal@cloudjunction.cloud';
        insert con;
        
        CJ_Opportunity__c opp = new CJ_Opportunity__c();
        opp.name = 'Service Master FSC Quickstart';
        opp.Account__c = acc.Id;
        insert opp;
        
        invoice.CJ_Opportunity__c = opp.Id;
        invoice.Billing_Contact__c = con.Id;
        invoice.Currency__c = 'CAD';
        insert invoice;
        
        //sendAnEmail email = sendAnEmail();
        sendAnEmail.getEmailContent(invoice.Id, 'Send Reminder');
        sendAnEmail.getEmailContent(invoice.Id, null);
        system.debug('EMail sender = ' + Label.emailFrom);
        String returnString = sendAnEmail.sendEmail(Label.emailFrom, con.email, 'zain@cloudjunction.cloud,sandhya@cloudjunction.cloud', 'hello', invoice.Id, 'Test Subject');
        system.assertEquals('The email was sent successfully.', returnString);
    }
}