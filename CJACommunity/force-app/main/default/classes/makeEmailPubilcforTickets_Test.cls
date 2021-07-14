/**
* 
* Description: Test Class for makeEmailPubilcforTickets.
* Author : M Tiham Siddiqui - CloudJunction
* Date : 21-01-2021
* 
**/

@isTest
private class makeEmailPubilcforTickets_Test {

    static testMethod void myUnitTest() {
        //Insert test case record
        Issue__c c = new Issue__c();
        c.Issue_Subject__c = 'Email Messge Test';  
        insert c;

        //Insert emailmessage for case
        EmailMessage email = new EmailMessage();
        email.FromAddress = 'test@abc.org';
        email.Incoming = True;
        email.ToAddress= 'test@xyz.org';
        email.Subject = 'Test email';
        email.HtmlBody = 'Test email body';
        email.RelatedToId = c.Id;
        insert email;
    }
}