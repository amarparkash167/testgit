/*
Developer: Danyal Naim

Description : This is used to send email to customer invoice contact with invoice pdf attached

Created Date: 7/16/2019
*/


public class sendAnEmail
{
    public class EmailWrapper
    {
        @AuraEnabled String emailBody {get; set;}
        @AuraEnabled String emailSender {get; set;}
        @AuraEnabled String emailRecipient {get; set;}
        @AuraEnabled String emailSubject {get; set;}
        
        public EmailWrapper(String emailSender, String emailRecipient, String emailBody, String emailSubject)
        {
            this.emailSender = emailSender;
            this.emailRecipient = emailRecipient;
            this.emailBody = emailBody;
            this.emailSubject = emailSubject;
        }
    }
    
    @AuraEnabled
    public static EmailWrapper getEmailContent(String qID, String buttonClicked)
    {
        user u = [select id, name, email from user where id=: userInfo.getUserId()];
        EmailWrapper returnWrapper = new EmailWrapper('', '', '', '');
        String templateName;
        if(buttonClicked == 'Send Reminder')
        {
            templateName = Label.Invoice_Reminder_Template_Name;
        }
        else
        {
            templateName = Label.Invoice_Email_Template_Name;
        }
        Customer_Invoice__c invoice = [Select name, id, Billing_Contact__r.Id, Billing_Contact__r.email, Billing_Contact__r.name, Opportunity__c, Invoice_Amount__c, Due_Date__c, Invoice_Date__c, Opportunity__r.Account.Name , description__c from Customer_Invoice__c where id =: qID];
        returnWrapper.emailSender = Label.emailFrom; //u.email;//Label.emailFrom;
        returnWrapper.emailRecipient = invoice.Billing_Contact__r.email;
        
         
        EmailTemplate templateId = [Select id, Body, Subject from EmailTemplate where name ='Invoice Reminder Template'];
        system.debug('Email Subject = ' + templateId.Subject);
        /*Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(invoice.Billing_Contact__r.Id );
        message.setTemplateId(templateId.Id );
        message.setWhatId(qId);   
        message.setBccSender(false);
        message.setUseSignature(false);
        message.setReplyTo(returnWrapper.emailSender);
        message.setSenderDisplayName('CloudJunction Advisors');
        message.setSaveAsActivity(false); 
        
        
        system.debug('Email html body = '  + testMessage.getHtmlBody());
        */
        //Messaging.SingleEmailMessage testMessage = Messaging.renderStoredEmailTemplate(templateId.id, invoice.Billing_Contact__r.Id, qID);
        //system.debug('SUBJECT ==========> ' + testMessage.getSubject());
        //returnWrapper.emailSubject = testMessage.getSubject();
        String htmlBody = '<p> </p>'; //testMessage.getHtmlBody();
        String brLessString = htmlBody.replaceAll('<p>', '\n');
        //system.debug('New String = ߘᠧ + brLessString);
        String plainTextBody = brLessString.stripHtmlTags(); 
        
        returnWrapper.emailBody = htmlBody;
        
        //system.debug('Email wrapper = ' + returnWrapper);
        
        return returnWrapper;
    }
    
    @AuraEnabled
    public static String sendEmail(String emailSender, String emailRecipient, String emailCcAddresses, String emailBody, String invoiceId, String subject)
    {
        //system.debug('EMAIL BODY = ' + emailBody);
        //system.debug('Email CC Addresses = ' + emailCcAddresses);
        
        List<String> listOfCcAddresses = new List<String>();
        if(emailCcAddresses != null)
        {
            listOfCcAddresses = emailCcAddresses.split(',');
        }
        //system.debug('CC ADDRESSES = ' + listOfCcAddresses[0]);
        Customer_Invoice__c invoice = [Select name , id , Billing_Contact__c, Billing_Contact__r.Id , Billing_Contact__r.email , Billing_Contact__r.name , Opportunity__c , Invoice_Amount__c,   Due_Date__c, Invoice_Date__c, Opportunity__r.Account.Name , description__c from Customer_Invoice__c where id =: invoiceId];

        PageReference pdf = Page.InvoicePDFVfpage1;
        
        //System.debug('PDF TESTING' + pdf);
        
        pdf.getParameters().put('InvId',invoiceId);
        
        Blob body;
        try {
            body = pdf.getContentAsPDF();
        } 
        catch (VisualforceException e) {
            body = Blob.valueOf('Missing Text');
        }
        
        attachment attach = new attachment();
        
        try{
            attach.Body = body;
            attach.Name = 'Invoice' +system.TODAY()+'.pdf';
            attach.IsPrivate = false;
        }catch(exception e){}       
        //system.debug('SYA :: qID check after :: ' + invoiceId); 
        //system.debug('SYA :: contact.Email :: '+ emailSender);
        
        // E-Mail Attachment Code      
        Messaging.EmailFileAttachment attach2 = new Messaging.EmailFileAttachment();
        attach2.setContentType('application/pdf');
        attach2.setFileName(invoice.name+'.pdf');
        attach2.setInline(false);
        attach2.Body = body;
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =: emailSender];
        
        //Create the email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setCcAddresses(listOfCcAddresses);
        email.setHtmlBody(emailBody);
        email.setTargetObjectId(invoice.Billing_Contact__r.Id );
        email.setWhatId(invoiceId);
        email.setBccSender(false);
        email.setUseSignature(false);
        email.setReplyTo(emailSender);
        //email.setSenderDisplayName('CloudJunction Advisors');
        email.setSaveAsActivity(false);
        email.optOutPolicy = 'FILTER';
        email.setSubject(subject);
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { attach2 });
        if ( owea.size() > 0 ) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {email};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) {
            //System.debug('The email was sent successfully.');
            return 'The email was sent successfully.';
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
            return 'The email failed to send';
        }
        
    }
    
}