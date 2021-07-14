/*
	Written By Sandhya Bajaj
*/

public with sharing class Timesheet_LWC {

    public static Map <String, List<Task__c>> tasksMap = new Map<String, List<Task__c>>();
    public static Map <String, List<Task__c>> deliverablesMap = new Map <String , List<Task__c>>();
    public static List<Task__c> allTask = new List<Task__c>([Select id, name, Deliverables__r.id, recordtype.name, project__c,project__r.name, project__r.id from task__c]);
    //Public static List<Timesheet_Detail__c> saveTimesheetDetail = new List<Timesheet_Detail__c>();
    Public static Map<String, List<Timesheet_Detail__c>> saveTimesheetDetailMap = new Map <String, List<Timesheet_Detail__c>>();
    //Public static Timesheet__c saveTimesheet = new Timesheet__c();
    public static Set<Project__c> projects;
    public static List<Task__c> deliverables = new List<Task__c>();
    public static List<Task__c> tasks = new List<Task__c>();
    public static List<Task__c> updateTasks = new List<Task__c>();
    //public static set<String> tasksId = new set<String> ();
    //public static Map<String, String> taskValues = new Map<String, String> (); 
        
    @AuraEnabled
    public static void submitRecords(List<List<Map<String,String>>> records, String TEDate , String action) {
        system.debug(records);
        system.debug('TS Date::'+TEDate);
        List<Timesheet_Detail__c> timesheetEntries = new List<Timesheet_Detail__c>();
        Timesheet__c timesheet = new Timesheet__c();
        timesheet.Resource__c = userinfo.getuserId();
        timesheet.Timesheet_Date__c = date.valueOf(TEDate);
        timesheet.External_ID__c = TEDate+'|'+userinfo.getuserId();
        
        
        try {
            upsert timesheet External_ID__c;
        } catch (DmlException e) {
            system.debug('Error:'+e);
        }
        system.debug('timesheet after insert :: ' + timesheet);
        
      
        for(List<Map<String,String>> listOfMap: records){
			system.debug(listOfMap);
             for(Map<String, String> metadata: listOfMap){
                 Timesheet_Detail__c td = new Timesheet_Detail__c();
                 td.Comments__c = metadata.get('description');
                 td.Timesheet__c = timesheet.id;
                 td.Actual_Hours__c = Decimal.valueOf(metadata.get('hours'));
                 td.Billable__c = metadata.containsKey('billable') && metadata.get('billable') == 'true'? true : false;
                 td.Skill_Type__c = metadata.containsKey('skilltype')? metadata.get('skilltype') : '';
                 System.debug(td.Skill_Type__c);

                 if(metadata.containsKey('tasks')){
                    string taskJSON = metadata.containsKey('tasks')? metadata.get('tasks') : '';
                    Map<String, String> taskjsonmap = (Map<String,String>) JSON.deserialize(taskJSON, Map<String,String>.class);
                    string taskID = taskjsonmap.get('id');
                    td.Task__c = taskjsonmap.get('id');
                    td.External_ID__c = taskjsonmap.get('id')+'|'+TEDate+'|'+userinfo.getuserId()+'!'+td.Billable__c +'|' + td.Skill_Type__c;
                    Task__c updateStatus = new Task__c();
                    updateStatus.id =taskjsonmap.get('id');
                    updateStatus.Status__c = metadata.get('type');
                     
                    updateTasks.add(updateStatus);
                    system.debug('Task Update :: '+ updateStatus);
                    system.debug('task id :: '+ td.Task__c);
                 }
                 
                 system.debug(td);
                 timesheetEntries.add(td);
                 system.debug(timesheetEntries);
             }
        }
        
        upsert timesheetEntries External_ID__c;

        Map<Id, Task__c> listOfTasksToUpdate = new Map<Id, Task__c>();
        

        for(Task__c task : updateTasks ){

            listOfTasksToUpdate.put(task.Id, task);

        }

        update listOfTasksToUpdate.values(); //Removing Task Updates, as this will be a flow on TS approval | Hamza - Oct 22,2019
        //Hamza - Dec 6 - Code Uncommented as decided this will be a manual process for TL to manage task statuses.
        
        if(action=='submit'){
            timesheet.Approval_Status__c ='Pending Approval';
            update timesheet;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<OptionWrapper> getTEStatus() {
        List<OptionWrapper> StatusList = new List<OptionWrapper>();
        Schema.DescribeFieldResult fieldResult = Task__c.Status__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
			StatusList.add(new OptionWrapper(pickListVal.getValue(),pickListVal.getLabel()));
		} 
         
        System.debug('list='+StatusList);
        return StatusList;
    }


    @AuraEnabled(cacheable=true)
    public static List<OptionWrapper> getProductInfo() {
        List<OptionWrapper> StatusList = new List<OptionWrapper>();
        Schema.DescribeFieldResult fieldResult = Timesheet_Detail__c.Skill_Type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
			StatusList.add(new OptionWrapper(pickListVal.getValue(),pickListVal.getLabel()));
		} 
         
        System.debug('list='+StatusList);
        return StatusList;
    }
        
   /*
    public static void populate_maps(){
        for(Task__c task : allTask){
            if(task.RecordType.name == 'Deliverable'){
                if(deliverablesMap.containsKey(task.project__r.id)){
                    List<Task__c> d = deliverablesMap.get(task.project__r.id);
                    d.add(task);
                    deliverablesMap.put(task.project__r.id, d);
                }else{
                    List<Task__c> d = new List<Task__c>();
                    d.add(task);
                    deliverablesMap.put(task.project__r.id, d);
                } 
            } else if(task.RecordType.name == 'Sub Task'){
                if(tasksMap.containsKey(task.Deliverables__r.id)){
                    List<Task__c> t = tasksMap.get(task.Deliverables__r.id);
                    t.add(task);
                    tasksMap.put(task.Deliverables__r.id, t);
                } else {
                    List<Task__c> t = new List<Task__c>();
                    t.add(task);
                    tasksMap.put(task.Deliverables__r.id, t);
                } 
            }
        }
    }
    
    @AuraEnabled(cacheable=true)
     public static List<OptionWrapper> getProjects() {
         // This method is like constructor
         List<OptionWrapper> projects_wrap = new List<OptionWrapper>();
    	 projects = new Set<Project__c>();
         
         for(Task__c projectData : allTask){    
            Project__c proj = new Project__c();
            proj.id = projectData.project__c;
            proj.Name = projectData.project__r.name;
            projects.add(proj);
         }
         
         for(Project__c proje : projects){
            projects_wrap.add(new OptionWrapper(proje.id, proje.name));
         }

        // Adding Data in Deliverable & Task Maps 

        
        system.debug('Deliverables::'+ deliverablesMap.keySet());
         
        return projects_wrap;

    }
    
    
    
    @AuraEnabled(cacheable=true)
     public static List<OptionWrapper> getDeliverables(String id) {
         populate_maps();
         List<OptionWrapper> deliverables = new List<OptionWrapper>();
         if(deliverablesMap.containsKey(id)){
             List<Task__c> de_data = deliverablesMap.get(id);
             system.debug('De Data::'+ de_data);
             for(Task__c del : de_data){
                deliverables.add(new OptionWrapper(del.id, del.Name));
             }
         }
         system.debug('Deliverables Mapp : '+deliverablesMap.keySet());
         system.debug('Deliverables::'+ deliverables);
         return deliverables;
    }
    @AuraEnabled(cacheable=true)
     public static List<OptionWrapper> getTasks(String id) {
         populate_maps();
         List<OptionWrapper> taskList = new List<OptionWrapper>();
         if(tasksMap.containsKey(id)){
             for(Task__c task : tasksMap.get(id)){
                taskList.add(new OptionWrapper(task.id, task.Name));
             }
         }
        return taskList;
    }
    */
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
}