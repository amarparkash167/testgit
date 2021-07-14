global class EmailServiceforIssue implements Messaging.InboundEmailHandler{
    
/**
* 
* Description: This Class works as ApexEmail Service to create record in Ticket object via email.
* Author : M Hamza Siddiqui - CloudJunction
* Edited by : 
	- Mohsin Raza - CloudJunction | Date : 31-03-2020
    - Jerry Nazareth - CloudJunction | Date : 02-02-2021
	
* 
* 
**/
    
 
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope) 
    {
        
   		
       
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        String spamEmail = 'mailer-daemon';
        String CaseNumber = null; // Stores the subject case number
        List<String> ccAddresses = email.ccAddresses;
        List<Task> list_tasks =  new  List<Task> (); 
        List<Issue__c> list_tickets = new List<Issue__c>();
        List<String> listofCaseNumber = new List<String>();
        
        if(email.fromAddress != 'support@cloudjunction.cloud'){
            
            // Extract Case Number from Email Subject 
            // Re: CloudJunction Support : Ticket Agent is Assigned to your Ticket # 0107
            
            system.debug('Email Subject = ' + email.subject);
            
            if(email.subject.contains('Case #')){
                
                listofCaseNumber = email.subject.split('Case #');
                
            }else{
                
                listofCaseNumber = email.subject.split('Ticket #');
                
            }
            
            //List<String> listofCaseNumber = email.subject.split('Ticket #');
            
            system.debug('Case Number: ' + listofCaseNumber);
            
            if (listofCaseNumber.size()>=2) {
                CaseNumber = listofCaseNumber[1];
            }
            
            // Extract list of existing tickets if ticket # matches 
            
            if(CaseNumber!=null) {
                CaseNumber = CaseNumber.trim(); 
                system.debug('Case number in If Condition: ' + CaseNumber );
                
                list_tickets = [SELECT id ,Name, Contact__c, Email__c, OwnerId, Owner.Email, Status__c
                                FROM Issue__c 
                                WHERE Name =: CaseNumber    // Match ticket # in subject's ticket #
                                AND ( Status__c != 'Closed Resolved' OR Status__c != 'Closed Unresolved') 
                                limit 1] ;
                
                system.debug('List of existing tickets that match case number:' + list_tickets );
            }
            
            if ( list_tickets.size() > 0 && list_tickets.size() != NULL) {
                for (Issue__c i : list_tickets) {
                    
                    
                    
                   
                    // if EnhancedEmail Perm is enabled, create an EmailMessage object
                    EmailMessage emailMessage = new EmailMessage();
                    
                    // For cc'd emails
                    if (ccAddresses != null) {
                        String ccAddressString = '';
                        for (String s : ccAddresses) {
                            ccAddressString += s + '; ';
                        }
                        emailMessage.CcAddress = ccAddressString;
                        system.debug('cc addresses: ' + emailMessage.CcAddress );
                    }	
                    
                    emailMessage.status = '3'; // email was sent
                    emailMessage.relatedToId = (ID)i.Id; // related to ticket record
                    	system.debug( 'Ticket Id: ' + emailMessage.relatedToId);
                    emailMessage.fromAddress = email.fromAddress; // from address
                    	system.debug( 'from address: ' + email.fromAddress);
                    emailMessage.fromName = email.fromName; // from name
                    	system.debug( 'from name: ' + email.fromName);
                    emailMessage.BccIds.add(i.OwnerId);
                    emailMessage.subject = email.subject; // email subject
                    if(email.htmlBody !=  null) {
                        emailMessage.htmlBody = email.htmlBody.left(32000); // email body
                    } else if (email.plainTextBody !=  null) {
                        emailMessage.textBody = email.plainTextBody.left(32000); // email body
                    }
                    
                    insert emailMessage; 
                    	system.debug('Email message' + emailMessage);
                    
                    // Add Email Message Relation for id of the sender
                    EmailMessageRelation emr = new EmailMessageRelation();
                    emr.emailMessageId = emailMessage.id;
                    //emr.relationId = i.Contact__c; // The error occurs everytime an inbound email
                    								//	appears and the relationship is made with the contact lookup instead of catching 
                    								//	the from address.
                    emr.relationType = 'FromAddress';
                    emr.RelationAddress = email.fromAddress ;
                    insert emr;
                    system.debug('Email relation with contact: ' + emr);
                    
                    //AddEmailRelationship(emailMessage.Id, i.OwnerId, 'ToAddress');
                    EmailMessageRelation emr1 = new EmailMessageRelation();
                    emr1.emailMessageId = emailMessage.id;
                    emr1.relationId = i.OwnerId; // user id of the sender
                    emr1.relationType = 'ToAddress';
                    
                    insert emr1;
                    
                    system.debug('Inbound Email Logged: ' + emr1 );
                    
                    // Creates chatter post and notifies ticket owner for incoming email.
                    FeedItem post = new FeedItem();
                    post.ParentId = i.OwnerId ; //This is a different System Admin Id
                    post.CreatedById = System.Label.Wasim_Akram_UserId;
                    post.Body = 'You have a new customer email !';
                    post.Title = 'Customer Ticket Email';
                    post.LinkUrl = '/lightning/r/Issue__c/' + i.Id + '/view' ;
                    post.IsRichText = true;
                    insert post;
                    
                    if(i.Status__c == 'Waiting for Customer Review') {
                        i.Status__c = 'In-Progress';
                        update i;
                    }
                    system.debug('Notification logged: ' + post );
                    
                    handleAttachments(email, emailMessage.Id);
                }  
            } else {
                try {
                    Contact[] con = [Select id, accountId from contact where email =: email.fromAddress limit 1];
                    
                    //Check if Contact matches the email address
                    system.debug('contacts = '+con);
                    
                    if(!email.fromAddress.contains(spamEmail)) {
                        Issue__c i = new Issue__c();
                        i.Issue_Subject__c = email.subject;
                        if(email.plainTextBody !=  null) {
                            i.Issue_Detail__c = email.plainTextBody.left(32768);
                        }                        
                        i.Status__c = 'New';
                        i.Email__c = email.fromAddress;
                        
                        //Check 'from address'
                        system.debug('email from = '+ i.Email__c);
                        
                        if(con.size() > 0 && con != Null) {
                            i.Customer_Account__c = con[0].accountId;
                            i.Contact__c = con[0].id;
                        }
                        
                        insert i;
                        
                        // if EnhancedEmail Perm is enabled, create an EmailMessage object
                        EmailMessage emailMessage = new EmailMessage();
                        emailMessage.status = '0'; // email is New
                        emailMessage.relatedToId = (ID)i.Id; // related to ticket record
                        system.debug( 'Ticket Id: ' + emailMessage.relatedToId);
                        emailMessage.fromAddress = email.fromAddress; // from address
                        emailMessage.fromName = email.fromAddress; // from name
                        emailMessage.BccIds.add(i.OwnerId);
                        emailMessage.subject = email.subject; // email subject
                        if(email.htmlBody !=  null) {
                            emailMessage.htmlBody = email.htmlBody.left(32000); // email body
                        } else if (email.plainTextBody !=  null) {
                            emailMessage.textBody = email.plainTextBody.left(32000); // email body
                        }
                        insert emailMessage; // insert
                        
                        handleAttachments(email, i.Id);
                        handleAttachments(email, emailMessage.Id);
                    }
                }  catch (QueryException e) {
                    System.debug('Query Issue: ' + e);
                }                
            }            
        }
        result.success = true;
 		return result;
    }  
    
   
    /*
// Save attachments, if any
if(email.textAttachments.size() > 0 && email.textAttachments !=null ){
for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
Attachment attachment = new Attachment();

attachment.Name = tAttachment.fileName;
attachment.Body = Blob.valueOf(tAttachment.body);
attachment.ParentId = i.Id;
insert attachment;
}
}

//Save any Binary Attachment
if(email.binaryAttachments.size() > 0 && email.binaryAttachments !=null ){
for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
Attachment attachment = new Attachment();

attachment.Name = bAttachment.fileName;
attachment.Body = bAttachment.body;
attachment.ParentId = i.Id;
insert attachment;
}
}
//}
*/
    
  
    public static void handleAttachments(Messaging.InboundEmail email, Id parentId) {
        list<Attachment> attachments = new list<Attachment>();
        // Save any text attachments
        if(email.textAttachments != null && 
           email.textAttachments.size() > 0){
               for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {
                   Attachment attachment = new Attachment();
                   
                   attachment.Name = tAttachment.fileName;
                   attachment.Body = Blob.valueOf(tAttachment.body);
                   attachment.ParentId = parentId;
                   attachments.add(attachment);
               }
           }
        
        //Save any binary attachment
        if(email.binaryAttachments != null && 
           email.binaryAttachments.size() > 0) {
               for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {
                   Attachment attachment = new Attachment();
                   
                   attachment.Name = bAttachment.fileName;
                   attachment.Body = bAttachment.body;
                   attachment.ParentId = parentId;
                   attachments.add(attachment);
               }
           }
        
        if(attachments.size() > 0)
            insert attachments;
    } 
}