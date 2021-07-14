public with sharing class DailyStandupLWCController {
    
    static List<Task__c> listOfDeliverables = new List<Task__c>();
    static Map<Id,Task__c> mapOfDeliverables = new Map<Id,Task__c>();
    static List<User> listOfUsers = new List<User>();
    static Map<Id,User> mapOfUsers = new Map<Id,User>();
    
    public class OptionWrapper {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}
        
        public OptionWrapper(String value, String label) {
            this.label = label;
            this.value = value;
        }
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
    
    @AuraEnabled(cacheable=true)
    public static List<OptionWrapper> getDeliverables() {
        //Id deliverableRecordTypeId = Schema.SObjectType.Task__c.getRecordTypeInfosByName().get('Deliverable').getRecordTypeId();
        //List<Task__c> listOfDeliverables = [SELECT Id, Name, Project__r.Name FROM Task__c WHERE RecordTypeId =: deliverableRecordTypeId];
        populateData();
        List<OptionWrapper> deliverableList = new List<OptionWrapper>();
        if(listOfDeliverables.size() != null && listOfDeliverables.size() > 0){
            for(Task__c deliverable: listOfDeliverables){
                //system.debug('Deliverable pciklist value = ' + deliverable.Project__r.Name + deliverable.Name);
                deliverableList.add(new OptionWrapper(deliverable.id, deliverable.Project__r.Name + ' - ' + deliverable.Name));
            }
        }
        return deliverableList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<OptionWrapper> getUsers()
    {
        populateData();
        List<OptionWrapper> userWrapperList = new List<OptionWrapper>();
        if(listOfUsers.size() > 0)
        {
            for(User u: listOfUsers)
            {
                userWrapperList.add(new OptionWrapper(u.id, u.Name));
            }
        }
        system.debug('Users::'+userWrapperList);
        return userWrapperList;
    }
    
    //Edit Submit Button
    
    @AuraEnabled
    public static void submitRecords(List<List<Map<String,String>>> records, String chatterText, String ischatter) {
        populateData();
        system.debug('Record = ' + records);
        system.debug('ChatterText' + chatterText);
        system.debug('IsChatter' + ischatter);
        //system.debug('Map Values = ' + mapOfDeliverables);
        //Id deliverableRecordTypeId = Schema.SObjectType.Task__c.getRecordTypeInfosByName().get('Deliverable').getRecordTypeId();
        //Map<ID, Task__c> mapOfDeliverables = new Map<ID, Task__c>([SELECT Id, Name, Project__c, Project__r.Name FROM Task__c WHERE RecordTypeId =: deliverableRecordTypeId]);        
        //Map<ID, User> mapOfUsers = new Map<ID, User>([SELECT Id, Name, IsActive FROM User WHERE IsActive = true ORDER BY Name ASC]);
        List<Task__c> listOfTasks = new List<Task__c>();
        String chatterPostBody = '<p>{'+Label.ChatterPostGroup+'} </p>';
        for(List<Map<String,String>> listOfMap: records){
            for(Map<String, String> metadata: listOfMap){
                
                string taskJSON = metadata.containsKey('deliverable')? metadata.get('deliverable') : '';
                Map<String, String> taskjsonmap = (Map<String,String>) JSON.deserialize(taskJSON, Map<String,String>.class);
                system.debug('TaskMapID::'+ taskjsonmap.get('id'));
                Task__c task = new Task__c();
                // system.debug('Metadata = ' + metadata);
                task.Description__c = metadata.get('description');
                task.Estimated_Hours__c = decimal.valueOf(metadata.get('hours'));
                task.Name = metadata.get('task');
                task.Deliverables__c = taskjsonmap.get('id');
                //system.debug('Project = ' + mapOfDeliverables.get(metadata));
                task.project__c = mapOfDeliverables.get(taskjsonmap.get('id')).Project__c;
                // system.debug('User = ' + metadata.get('user'));
                task.Resource__c = metadata.get('user');
                task.Due_Date__c = Date.valueof(metadata.get('dueDate'));
                task.Start_Date__c = Date.valueof(metadata.get('startDate'));
                task.External_Task_ID__c = metadata.get('task')+'|'+taskjsonmap.get('id'); // external id : taskname|deliverableID
                task.RecordTypeId = Schema.SObjectType.Task__c.getRecordTypeInfosByName().get('Sub Task').getRecordTypeId();
                chatterPostBody += 
                    '<p></p><p><b>Project</b> => ' + mapOfDeliverables.get(taskjsonmap.get('id')).Project__r.Name + '</p>' + 
                    '<p><b>Deliverable</b>: ' + mapOfDeliverables.get(taskjsonmap.get('id')).Name + '</p>' + 
                    '<p><b>Task Name</b>: ' + metadata.get('task') + '</p>' + 
                    '<p><b>Task Description</b>: ' + metadata.get('description') + '</p>' + 
                    '<p><b>Task Assigned to</b>: {' + mapOfUsers.get(metadata.get('user')).id + '}</p>' + 
                    '<p><b>Estimated Hours</b>: ' + metadata.get('hours')+ '</p>' + 
                    '<p>-----------------------------------------</p><p></p>';
                listOfTasks.add(task);
            }
        }
        
        if(ischatter=='true'){
            
            ConnectApi.FeedItem fi = (ConnectApi.FeedItem) ConnectApiHelper.postFeedItemWithRichText(Network.getNetworkId(), 'me', chatterPostBody+chatterText);

            
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
        insert listOfTasks;
        //PageReference retURL = new PageReference('/' + chatterGroupRecord[0].Id);
        //retURL.setRedirect(true);
        //return retURL;
    }
}