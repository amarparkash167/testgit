@isTest
public class AttachtoParent_Handler_Test {

    static testMethod void testAttachments()
    {
        Account acc = new Account();
        acc.Name = 'Test User';
        insert acc;
        
    	Task task=new Task();
        task.WhatId = acc.Id;
        insert task;
        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=task.id;
        insert attach;
        List<ContentDocumentLink> documents = [Select ContentDocumentId From ContentDocumentLink where LinkedEntityId =: task.WhatId];
        //system.debug('document parentid = ' + documents);
    	System.assertEquals(1, documents.size());
    }
}