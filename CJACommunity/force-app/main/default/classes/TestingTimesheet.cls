@isTest
public class TestingTimesheet {

  
    static List<List<Map<String, String>>> records = new List<List<Map<String, String>>>();
    static List<Map<String,String>> recordList = new List<Map<String,String>>();
   	static Map<String,String> recordMap = new Map<String,String>();
    static Map<String,String> recordMap1 = new Map<String,String>();
    static List<Task__c> allTask = new List<Task__c>();
    public static Map <String, List<Task__c>> tasksMap = new Map<String, List<Task__c>>();
    public static Map <String, List<Task__c>> deliverablesMap = new Map <String , List<Task__c>>();
    
    
    
    
   
    @isTest
    static void testSaveRecord(){
       	Project__c project1 = new Project__c();
        project1.Name = 'Test Project';
        insert project1;
       
       	Task__c deliverable1 = new Task__c();
        deliverable1.Name = 'Test Deliverables';
        deliverable1.RecordTypeId = Schema.SObjectType.Task__c.getRecordTypeInfosByName().get('Deliverable').getRecordTypeId();
        deliverable1.Project__c = project1.Id;
        insert deliverable1;
        
        Task__c task = new Task__c();
       	task.Project__c = project1.Id;
        task.deliverables__c=deliverable1.Id;
        task.Name = 'Test task';
        task.Resource__c = UserInfo.getUserId();
        task.recordtypeId = Schema.SObjectType.Task__c.getRecordTypeInfosByName().get('Sub Task').getRecordTypeId();
        
        insert task;
        
        allTask.add(task);
        //allTask.add(deliverable1);
        
        Project__c project2 = new Project__c();
        project2.Name = 'Test Project 2';
        
        insert project2;
        
        Task__c deliverable2 = new Task__c();
        deliverable2.Name = 'Test Deliverable1';
        deliverable2.RecordTypeId = Schema.SObjectType.Task__c.getRecordTypeInfosByName().get('Deliverable').getRecordTypeId();
        deliverable2.Project__c = project2.Id;
        
        insert deliverable2;
        
        Task__c task1 = new Task__c();
        task1.Project__c = project2.id;
        task1.deliverables__c = deliverable2.Id;
        task1.Name = 'Test task1';
        task.Resource__c = UserInfo.getUserId();
        task1.recordtypeId = Schema.SObjectType.Task__c.getRecordTypeInfosByName().get('Sub Task').getRecordTypeId();
        insert task1;

        
        allTask.add(task1);
       // allTask.add(deliverable2);
        //Timesheet_LWC.populate_maps();
        //
        for(task__c t : allTask){
            String taskValue='{\"icon\":\"standard:task\",\"id\":\"' + t.id + '\",\"sObjectType\":\"Tasks\",\"subtitle\":\"'+ t.Project__r.name+'\",\"title\":\"'+ t.Name +' . '+ t.deliverables__r.name+'\"}';
            recordMap.put('tasks',taskValue);
            recordMap.put( 'type','Not Started');
            recordmap.put('billable','true');
            recordmap.put('hours','4');
            recordmap.put('description','Testing');
            recordMap1.put('tasks',taskValue);
            recordMap1.put( 'type','In Progress');
           	recordmap1.put('billable','false');
            recordmap1.put('hours','4');
            recordmap1.put('description','Testing');
        }
        
        recordList.add(recordMap);
        records.add(recordList);
        String tdate = '2019-12-11';
        String action = 'submit';
        Timesheet_LWC.submitRecords(records,tdate,action);
        //Timesheet_LWC.getDeliverables(deliverable2.id);
        //Timesheet_LWC.getTasks(task1.id);
        Timesheet_LWC.getTEStatus();
       	
    }
    
    @isTest
    static void testMapPopulate(){
        
        Project__c project1 = new Project__c();
        project1.Name = 'Test Project';
        insert project1;
       
        Task__c deliverable1 = new Task__c();
        deliverable1.Name = 'Test Deliverables';
        deliverable1.RecordTypeId = Schema.SObjectType.Task__c.getRecordTypeInfosByName().get('Deliverable').getRecordTypeId();
        deliverable1.Project__c = project1.Id;
        insert deliverable1;
        
        Task__c task = new Task__c();
        task.Project__c = project1.Id;
        task.Deliverables__c =deliverable1.Id;
        task.Name = 'Test task';
        //task.Project__r.name = project1.Name;
        task.recordtypeId = Schema.SObjectType.Task__c.getRecordTypeInfosByName().get('Sub Task').getRecordTypeId();
        
        insert task;
        
        allTask.add(task);
        allTask.add(deliverable1);
        
        Project__c project2 = new Project__c();
        project2.Name = 'Test Project 2';
        
        insert project2;
        
        Task__c deliverable2 = new Task__c();
        deliverable2.Name = 'Test Deliverable1';
        deliverable2.RecordTypeId = Schema.SObjectType.Task__c.getRecordTypeInfosByName().get('Deliverable').getRecordTypeId();
        deliverable2.Project__c = project2.Id;
        
        insert deliverable2;
        
        Task__c task1 = new Task__c();
        task1.Project__c = project2.id;
        task1.Deliverables__c =deliverable2.Id;
        task1.Name = 'Test task1';
        //task1.Project__r.name =project2.Name;
        task1.recordtypeId = Schema.SObjectType.Task__c.getRecordTypeInfosByName().get('Sub Task').getRecordTypeId();
        insert task1;

        
        allTask.add(task1);
        allTask.add(deliverable2);
        //Timesheet_LWC.populate_maps();
    }
    
    /*@isTest
    static void testGetProjects(){
        //List<OptionWrapper> projects_wrap = new List<OptionWrapper>();
        Timesheet_LWC.getProjects();
    }*/
    
}