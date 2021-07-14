public class AttachtoParent_Handler {
    
    public AttachtoParent_Handler(List<Attachment> Attach)
    {
        if(Attach != null && Attach.size() > 0){
            for (Attachment a : Attach){
                String parentIdString = String.valueof(a.parentId);
                // Making sure if the attachment is from the Task
                if (parentIdString.substring(0,3) == '00T'){
                    // Getting Parent Object Id
                    task parent = [SELECT Id,WhatId FROM Task WHERE Id = :a.parentId]; 
                    if (parent.WhatId  != null){
                        Attachment body = [SELECT Body FROM Attachment WHERE Id = :a.Id];
                        // Adding same attachment to Parent Object Record Id. 
                        //-----------------------------------------------
                        ContentVersion contentVersion = new ContentVersion();
                        contentVersion.ContentLocation = 'S'; //S is to show that the document is in salesforce while E would be for an external file
                        contentVersion.PathOnClient = a.Name;
                        contentVersion.Title = a.Name;
                        contentVersion.VersionData  = a.Body;
                        insert contentVersion;
                        
                        // First get the content document Id from ContentVersion
                        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;
                        //Create ContentDocumentLink
						ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                        contentDocumentLink.ContentDocumentId = contentDocumentId;
                        contentDocumentLink.LinkedEntityId = parent.WhatId;
                        system.debug('parent id = ' + parent.WhatId);
                        contentDocumentLink.ShareType = 'I'; // Inferred permission
                        contentDocumentLink.Visibility = 'InternalUsers';
                        insert contentDocumentLink;
                        
                    }
                }
            }
        }	
    }
}