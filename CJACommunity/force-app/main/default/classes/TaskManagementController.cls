public without sharing class TaskManagementController {
  
    private final static Integer MAX_RESULTS = 10;
    private final static ID Task_RecordType = Schema.SObjectType.Task__c.getRecordTypeInfosByName().get('Sub Task').getRecordTypeId();
    private final static ID Deliverable_RecordType = Schema.SObjectType.Task__c.getRecordTypeInfosByName().get('Deliverable').getRecordTypeId();

    static List<Task__c> listOfDeliverables = new List<Task__c>();
    static Map<Id,Task__c> mapOfDeliverables = new Map<Id,Task__c>();
    static List<User> listOfUsers = new List<User>();
    static Map<Id,User> mapOfUsers = new Map<Id,User>();
      
    	@AuraEnabled
    public static List<Task__c> getTasks(string DeliverableId){
        
		List<Task__c>SubTaskList = [Select Id,Name,Actual_Hours__c, Start_Date__c,Due_Date__c,Description__c,Resource_Name__c,External_Task_ID__c,
                                   Resource__c,Estimated_Hours__c,Estimated_Admin_Hours_High__c,Estimated_Hours_Admin__c,Status__c from Task__c
                                   where Deliverables__c =: DeliverableId];
        
        
 //       system.debug('DeliverableId=> ' + timesheetEntries );
     //   return timesheetEntries;
     //   
        if(SubTaskList.size()>0){
        return SubTaskList;
        }   
        
        return null;
    }
    
     public static void populateData(){
        listofUsers = [SELECT Id, IsActive, ManagerId ,Name FROM User WHERE IsActive=true and Timesheet_User__c = true ORDER BY Name ASC];
        for(User u : listofUsers){
            mapOfUsers.put(u.Id, u);
            //listOfUsers.add(u);
        }
        
        String loggedInUserId = UserInfo.getUserId();
        User userRecord = mapOfUsers.get(loggedInUserId);
        system.debug('User record = ' + userRecord);
        Id deliverableRecordTypeId = Schema.SObjectType.Task__c.getRecordTypeInfosByName().get('Deliverable').getRecordTypeId();
        listofDeliverables = [SELECT Id, Name, Project__c, Project__r.Name, Project__r.Project_Lead__c FROM Task__c WHERE RecordTypeId =: deliverableRecordTypeId 
                              AND Project__r.Project_Status__c != 'Completed' AND Project__c != null 
                              ORDER by Project__r.Name ASC];
        system.debug('Deliverables = ' + listofDeliverables);
        if(listofDeliverables.size() > 0)
        {
            for(Task__c dev : listofDeliverables){
                mapOfDeliverables.put(dev.Id, dev);
            }
            
        }
        
    }
    
    
     @AuraEnabled
    public static void submitRecords_Tasks(List<List<Map<String,String>>> records, String chatterText, String ischatter, String deliverableId) {
        set<String> setofExtIds = new Set<String>();
        populateData();
        system.debug('Record = ' + records);
        system.debug('ChatterText' + chatterText);
        system.debug('IsChatter' + ischatter);
 
        List<Task__c> listOfTasks = new List<Task__c>();
        String chatterPostBody = '<p>{'+Label.ChatterPostGroup+'} </p>';
        for(List<Map<String,String>> listOfMap: records){
            for(Map<String, String> metadata: listOfMap){

                Task__c task = new Task__c();
                // system.debug('Metadata = ' + metadata);
                task.Id = string.valueOf(metadata.get('Id'));
                task.Name = metadata.get('task');
                task.Estimated_Admin_Hours_High__c = decimal.valueOf(metadata.get('estAdminHigh'));
                task.Estimated_Hours_Admin__c = decimal.valueOf(metadata.get('estAdminLow'));
                task.Description__c = metadata.get('description');
                task.Deliverables__c = deliverableId;
                task.Status__c = metadata.get('status');
                task.project__c = mapOfDeliverables.get(deliverableId).Project__c;
                task.Due_Date__c = Date.valueof(metadata.get('dueDate'));
                task.Start_Date__c = Date.valueof(metadata.get('startDate'));
                task.External_Task_ID__c = metadata.get('task')+'|'+deliverableId+'|'+metadata.get('user') ;
                task.Resource__c = metadata.get('user');
                task.RecordTypeId = Schema.SObjectType.Task__c.getRecordTypeInfosByName().get('Sub Task').getRecordTypeId();

                // external id : taskname|deliverableID
                // CODE to check duplicate External Ids
                
                // Check if this external ID exists in a set
                // If it does, which means there is a duplicate 
                if(setofExtIds.contains(task.External_Task_ID__c)){
                    // throw the exception i..e throw createCustomException('Exception');
                    throw createCustomException('Task with same NAME and RESOURCE cannot be created.');
                } else {
                    // Add externalId to a SET to check the other record in a loop
                	setofExtIds.add(task.External_Task_ID__c);
                }
             //   task.RecordTypeId = Schema.SObjectType.Task__c.getRecordTypeInfosByName().get('Sub Task').getRecordTypeId();
                
            /*    chatterPostBody += 
                    '<p></p><p><b>Project</b> => ' + mapOfDeliverables.get(deliverableId).Project__r.Name + '</p>' + 
                    '<p><b>Deliverable</b>: ' + mapOfDeliverables.get(deliverableId).Name + '</p>' + 
                    '<p><b>Task Name</b>: ' + metadata.get('task') + '</p>' + 
                    '<p><b>Task Description</b>: ' + metadata.get('description') + '</p>' + 
                    '<p><b>Task Assigned to</b>: {' + mapOfUsers.get(metadata.get('user')).id + '}</p>' + 
                    '<p><b>Estimated Admin Hours (LOW)</b>: ' + metadata.get('estAdminLow')+ '</p>' + 
                    '<p><b>Estimated Admin Hours (HIGHT)</b>: ' + metadata.get('estAdminHigh')+ '</p>' + 

                    '<p>-----------------------------------------</p><p></p>';*/
                listOfTasks.add(task);
            }
        }
        
        if(ischatter=='true'){
            
     //       ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithRichText(Network.getNetworkId(), 'me', chatterPostBody+chatterText);

            
            /*FeedItem postItem = new FeedItem();
            List<CollaborationGroup> chatterGroupRecord = [SELECT Id,Name From CollaborationGroup WHERE Name =: Label.ChatterPostGroup];
            if(chatterGroupRecord.size() > 0)
            {
                postItem.ParentId  = chatterGroupRecord[0].Id;
                postItem.Type = 'TextPost';
                postItem.Title = 'Daily Standup Notes';
                postItem.Body = chatterPostBody+chatterText;
                
                insert postItem;
            }
            else
            {
                // no group exists
            }*/
        }
        
        //Inserting Tasks
        Try{
        upsert listOfTasks;
        }
        
        catch (exception e){
            throw new AuraHandledException(e.getMessage());  
        }
        
        //PageReference retURL = new PageReference('/' + chatterGroupRecord[0].Id);
        //retURL.setRedirect(true);
        //return retURL;
    }
    
        public class CustomException extends Exception {}
    
    public static  CustomException createCustomException(String message) {
        CustomException ex = new CustomException(message);
        ex.setMessage(message);
        return ex;
    }
    
    @AuraEnabled
    public static List<Task__c> getDeliverables(string ProjectId){
        
		List<Task__c>DeliverableList = [Select Id,Name,Actual_Hours__c, Start_Date__c,Due_Date__c,Description__c,Resource_Name__c,External_Task_ID__c,
                                   Resource__c,Estimated_Hours__c,Estimated_Admin_Hours_High__c,Estimated_Hours_Admin__c,Status__c,
                                   Planned_Start_Date__c,Planned_Due_Date__c,Estimated_Hours_High__c ,Task_Due_Date__c,Task_Start_Date__c    
                                        from Task__c
                                   where Project__c =: ProjectId AND recordTypeId =: Deliverable_RecordType];
        
        
 //       system.debug('DeliverableId=> ' + timesheetEntries );
     //   return timesheetEntries;
     //   
        if(DeliverableList.size()>0){
        system.debug(DeliverableList);
        return DeliverableList;
        }   
        
        return null;
    }
    
    
    
   @AuraEnabled(cacheable=true)  
   public static List<sObject> findRecords(String searchKey, String objectName) {  
     
       List<sObject> sobjectList = New List<sObject>();
       string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';  
       
       IF(objectName == 'Task__c'){
       
         List<List<SObject>> searchResults = [FIND :searchKey IN ALL FIELDS RETURNING
            Task__c (Id, Name, DeliverableName__c,Deliverables__c, Project__c,ProjectName__c,Status__c,Resource_Name__c,Estimated_Hours__c WHERE recordtypeId=:Deliverable_RecordType and Status__c!='Completed' and Project__r.Stage__c != '15- Closed')
            LIMIT :MAX_RESULTS];  
       
       Task__c [] tasks = ((List<Task__c>) searchResults[0]);
       SYSTEM.debug('searched Tasks ' + tasks);
       sobjectList = tasks;    
       }
       
       else if(objectName == 'Project__c'){
       
         List<List<SObject>> searchProjectResults = [FIND :searchKey IN ALL FIELDS RETURNING
            Project__c (Id, Name, Account__c WHERE  Stage__c!='15- Closed')
            LIMIT :MAX_RESULTS];  
       
       Project__c [] projects = ((List<Project__c>) searchProjectResults[0]);
       SYSTEM.debug('searched Projects ' + projects);
       sobjectList = projects;    
       }
       
     return sobjectList;
        
   } 
    
      @AuraEnabled
    public static void submitRecords_Deliverables(List<List<Map<String,String>>> records, String chatterText, String ischatter, String ProjectId) {
        set<String> setofExtIds = new Set<String>();
        populateData();
        system.debug('Record = ' + records);
        system.debug('ChatterText' + chatterText);
        system.debug('IsChatter' + ischatter);
 
        List<Task__c> listOfDeliverables = new List<Task__c>();
        String chatterPostBody = '<p>{'+Label.ChatterPostGroup+'} </p>';
        for(List<Map<String,String>> listOfMap: records){
            for(Map<String, String> metadata: listOfMap){

                Task__c deliverable = new Task__c();
                // system.debug('Metadata = ' + metadata);
                deliverable.Id = string.valueOf(metadata.get('Id'));
                deliverable.Name = metadata.get('deliverable');
                deliverable.Estimated_Hours_High__c = decimal.valueOf(metadata.get('estHrsHigh'));
                deliverable.Estimated_Hours__c = decimal.valueOf(metadata.get('estHrsLow'));
                deliverable.Description__c = metadata.get('description');
                deliverable.Status__c = metadata.get('status');
                deliverable.project__c = ProjectId;//mapOfDeliverables.get(deliverableId).Project__c;
                deliverable.Planned_Due_Date__c = Date.valueof(metadata.get('plannedDueDate'));
                deliverable.Planned_Start_Date__c = Date.valueof(metadata.get('plannedStartDate'));
                deliverable.Task_Start_Date__c = Date.valueof(metadata.get('projectedStartDate'));
                deliverable.Task_Due_Date__c = Date.valueof(metadata.get('projectedDueDate'));             
                deliverable.RecordTypeId = Schema.SObjectType.Task__c.getRecordTypeInfosByName().get('Deliverable').getRecordTypeId();

             //   task.Deliverables__c = deliverableId;
               
          //      task.External_Task_ID__c = metadata.get('task')+'|'+deliverableId+'|'+metadata.get('user') ;
            //    task.Resource__c = metadata.get('user');

                // external id : taskname|deliverableID
                // CODE to check duplicate External Ids
                
                // Check if this external ID exists in a set
                // If it does, which means there is a duplicate 
           /*     if(setofExtIds.contains(task.External_Task_ID__c)){
                    // throw the exception i..e throw createCustomException('Exception');
                    throw createCustomException('Task with same NAME and RESOURCE cannot be created.');
                } else {
                    // Add externalId to a SET to check the other record in a loop
                	setofExtIds.add(task.External_Task_ID__c);
                }*/
             //   task.RecordTypeId = Schema.SObjectType.Task__c.getRecordTypeInfosByName().get('Sub Task').getRecordTypeId();
                
            /*    chatterPostBody += 
                    '<p></p><p><b>Project</b> => ' + mapOfDeliverables.get(deliverableId).Project__r.Name + '</p>' + 
                    '<p><b>Deliverable</b>: ' + mapOfDeliverables.get(deliverableId).Name + '</p>' + 
                    '<p><b>Task Name</b>: ' + metadata.get('task') + '</p>' + 
                    '<p><b>Task Description</b>: ' + metadata.get('description') + '</p>' + 
                    '<p><b>Task Assigned to</b>: {' + mapOfUsers.get(metadata.get('user')).id + '}</p>' + 
                    '<p><b>Estimated Admin Hours (LOW)</b>: ' + metadata.get('estAdminLow')+ '</p>' + 
                    '<p><b>Estimated Admin Hours (HIGHT)</b>: ' + metadata.get('estAdminHigh')+ '</p>' + 

                    '<p>-----------------------------------------</p><p></p>';*/
                listOfDeliverables.add(deliverable);
            }
        }
        
        if(ischatter=='true'){
            
     //       ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithRichText(Network.getNetworkId(), 'me', chatterPostBody+chatterText);

            
            /*FeedItem postItem = new FeedItem();
            List<CollaborationGroup> chatterGroupRecord = [SELECT Id,Name From CollaborationGroup WHERE Name =: Label.ChatterPostGroup];
            if(chatterGroupRecord.size() > 0)
            {
                postItem.ParentId  = chatterGroupRecord[0].Id;
                postItem.Type = 'TextPost';
                postItem.Title = 'Daily Standup Notes';
                postItem.Body = chatterPostBody+chatterText;
                
                insert postItem;
            }
            else
            {
                // no group exists
            }*/
        }
        
        //Inserting Tasks
        Try{
        upsert listOfDeliverables;
        }
        
        catch (exception e){
            throw new AuraHandledException(e.getMessage());  
        }
        
        //PageReference retURL = new PageReference('/' + chatterGroupRecord[0].Id);
        //retURL.setRedirect(true);
        //return retURL;
    }
    
    
}