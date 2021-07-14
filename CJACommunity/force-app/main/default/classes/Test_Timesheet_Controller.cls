@isTest
public class Test_Timesheet_Controller {
    
   
    public Project__c listofProject;
    public Task__c listofDeliverables;
    public Task__c listoftasks;
    public Task_Assignment__c listoftaskAss;
    public Project_Resource__c listofProjectRes;
    public Timesheet__c listofTimesheet;
    public Timesheet_Detail__c listofTimesheetDetail;
    public User myUser;
    
    
    static testMethod void myUnitTest(){
        //Temporary Comment 9th Jan by Farah
        createTestData(); 
        //Timesheet_Controller.fakeTest();
    }
    
    public static void createTestData(){
        // Create Project Record
        
        Project__c proj1= new Project__c(
            Name= 'Project-One',
            Complexity_Level__c='High',
            Profitability__c = 'Medium',
            Project_Start_Date__c = date.newInstance(2018, 10, 18)
        );
        insert proj1;
        
        Task__c del_1= new Task__c(
            Name='Deliverable-One',
            Project__c = proj1.Id,
            RecordTypeId= Schema.sobjectType.Task__c.getRecordTypeInfosByName().get('Deliverable').getRecordTypeId()           
        );
        insert del_1;
        
        //TaskAssignment_PicklistController.getPickListValuesIntoList(del_1.Id);    
        
       
        //TaskAssignment_PicklistController.insertTask(task_1);         
        
        //Query Profile 
        Profile pro= [Select Id, Name from Profile Where Name='System Administrator' limit 1];
        
        User user_1=new User(
            IsActive=true,
            Alias='Abbey',
            Email= 'abcTest_Timesheet@gmail.com',
            ProfileId = pro.Id,
            LastName= 'Kumari' ,
            Username= 'def'+'@naqwi.com',
            TimeZoneSidKey='America/Los_Angeles',
            LanguageLocaleKey= 'en_US',
            LocaleSidKey = 'en_GB', 
            EmailEncodingKey='UTF-8'
        );
        Insert user_1;   
        
         Task__c task_1= new Task__c(
            Name='Task-One',
            Deliverables__c = del_1.Id,
            Project__c = proj1.Id,
            RecordTypeId= Schema.sobjectType.Task__c.getRecordTypeInfosByName().get('Sub Task').getRecordTypeId(),
            Resource__c = user_1.id
        );
        insert task_1;
        
        //Insert Project Resource        
       /* Project_Resource__c pr_1= new Project_Resource__c(
            Project_Role__c=  'Admin',
            User__c = user_1.Id    
        );
        insert pr_1;
        
        // Insert Task Assignment
        Task_Assignment__c task_Assign1= new Task_Assignment__c(
            Project_Resource__c =  pr_1.Id,
            Task__c =   task_1.Id
        );
        insert task_Assign1; 
        
        List<Task_Assignment__c> taskAssignmentListForJson= new List<Task_Assignment__c>();      
        taskAssignmentListForJson.add(task_Assign1);
        
        String taskAssignmentList= JSON.serialize(taskAssignmentListForJson);      
        
        Timesheet_Controller.UpdateTaskAss(taskAssignmentListForJson);*/
        datetime dt= system.now();
        Timesheet__c timesheet_1= new Timesheet__c(
            Name= 'Wasim Akram - 23-11-2018',
            Timesheet_Date__c = system.today(),
            Approval_Status__c = 'Approved',
            External_ID__c = dt.format('YYYY-MM-dd')+'|'+userinfo.getuserId()
        );
        insert timesheet_1;
        
        System.debug('Timesheet In Test Class::' + timesheet_1);
        Timesheet_Detail__c timesheetDetail_1 = new Timesheet_Detail__c(
            Timesheet__c = timesheet_1.Id,
            Task__c = task_1.Id   
        );
        insert timesheetDetail_1;
        
        List<Timesheet_Detail__c> timesheetDetailList=  new List<Timesheet_Detail__c>();      
        timesheetDetailList.add(timesheetDetail_1);      
        
        String str= JSON.serialize(timesheetDetailList);
        
        Timesheet_Controller.UpdateTimesheetDetail(timesheetDetailList);       
        
        Timesheet_Controller.passString(timesheetDetailList);          
        

        Timesheet_Controller.getActiveUser();
        Timesheet_Controller.hasManager();
        Timesheet_Controller.isActiveUser(timesheetDetail_1.id);
        Timesheet_Controller.isActiveUser(null);
        Timesheet_Controller.getStatus();
        Timesheet_Controller.UpdateTaskAss(new List<Task__c>());  
        Timesheet_Controller.getApprovalStatus();
        Timesheet_Controller.getTask(Timesheet_Controller.getTimesheetId(null)); 
        Timesheet_Controller.getTimesheetHours();           
        Timesheet_Controller.getTaskAssignment(Timesheet_Controller.getTimesheetId(null)); 
        Timesheet_Controller.getTimesheetDate();
        
        Timesheet_Controller.createTimesheet(UserInfo.getUserId(), system.Today()); 
        Timesheet_Controller.getTask(Timesheet_Controller.getTimesheetId(timesheet_1.Id)); 
        Timesheet_Controller.getTimesheetHours();           
        Timesheet_Controller.getTaskAssignment(Timesheet_Controller.getTimesheetId(timesheet_1.Id)); 
        Timesheet_Controller.getTimesheetDate();
        
        Timesheet_Controller.changeApprovalStatus(timesheet_1.Id);  
        Timesheet_Controller.getTimesheetDetail(timesheet_1.Id);  
        Timesheet_Controller.getTimesheetId(timesheet_1.Id);  
        
        
        //List<Task_Assignment__c> taskAssignmentList= new List<Task_Assignment__c>();        
        //taskAssignmentList.add(task_Assign1);        
        
        //TaskAssignment_PicklistController.insert_TaskAssignment(taskAssignmentList); 
              
        
    }  
 
   
}