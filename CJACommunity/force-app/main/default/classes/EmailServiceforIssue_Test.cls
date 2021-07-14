@IsTest
public class EmailServiceforIssue_Test {
    /* Test Class EmailService which creates Issue via email */
    
    static testMethod void testCreateIssueFrmEmail() 
    {
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        
        
        Account acc = new Account(Name = 'testAcc1');
        insert acc;
        Contact con = new Contact(FirstName='abcd', LastName = 'test' ,  AccountId = acc.id, email = 'karachi@gmail.com' );
        insert con;
                
        email.subject = 'Session Case # 1021'  ;
        email.plainTextBody = 'Issue Description From Email';
        email.fromAddress = 'karachi@gmail.com';
        
      
        
        EmailServiceforIssue creatI = new EmailServiceforIssue();
        //creatI.handleInboundEmail(email, env );
        Messaging.InboundEmailResult result = creatI.handleInboundEmail(email, env);
        System.assertEquals( result.success , true);   
        
        List<User> usr = [SELECT id ,Name, IsActive, UserRole.Name  FROM user where IsActive = true 
                          And UserRole.Name = 'Salesforce Administrator' Limit 1];
        
        GoogleChatWebhook.skipCallout = true;
        test.startTest();
        system.runAs(usr[0])
        {
            Issue__c issue = new Issue__c ( Status__c = 'New', Issue_Subject__c = 'Test Subject Ticket # 1029'  , Email__c = con.Email, OwnerId = usr[0].id );
            system.debug(issue.OwnerId);
            
            insert issue;
            
            System.debug('Issue::' + issue);
            
            issue.OwnerId = usr[0].id;
            update issue;
            
            /*Attachment attachment = new Attachment();
            
            attachment.Name='Unit Test Attachment'; 
            Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
            attachment.body=bodyBlob; 
            attachment.parentId= issue.Id;
            insert attachment;*/
            
            List<Issue__c> list_issue = [SELECT id, Name, Contact__c, Email__c, OwnerId, Status__c
                                         FROM Issue__c 
                                         WHERE id =: issue.id limit 1]; 
            
            
            email.subject = 'Ticket Agent is Assigned to your Ticket # ' + list_issue[0].Name ;
            email.plainTextBody = 'Issue Description From Email';
            email.fromAddress = 'karachi@gmail.com';
            
            System.debug('Email Subject::' +email.subject);
            
            EmailServiceforIssue creatI2 = new EmailServiceforIssue();
            //creatI.handleInboundEmail(email, env );
            Messaging.InboundEmailResult result2 = creatI2.handleInboundEmail(email, env);
            system.debug('Issues' + [SELECT id, Name, Contact__c, Email__c, OwnerId, Status__c
                                     FROM Issue__c 
                                     WHERE id =: issue.id limit 1]);
            System.assertEquals( result2.success , true);
        }
        // Create email log for Existing Ticket
        
        
        
        test.stopTest();
        
    }
}