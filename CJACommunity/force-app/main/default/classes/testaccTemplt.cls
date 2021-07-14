@isTest
public class testaccTemplt {


     @isTest 
    static void testtimesheet() {
 
        Project__c proj1= new Project__c(
            Name= 'Project-One',
            Complexity_Level__c='High',
            Profitability__c = 'Medium',
            Project_Start_Date__c = date.newInstance(2018, 10, 18)
        );
        insert proj1;
        
        Task__c del_1= new Task__c(
            Name='Deliverable-One',
            Project__c = proj1.Id
        );
        insert del_1;
        
        //TaskAssignment_PicklistController.getPickListValuesIntoList(del_1.Id);    
        
        Task__c task_1= new Task__c(
            Name='Task-One',
            Deliverables__c = del_1.Id,
            project__c = proj1.id
        );
        insert task_1;
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
        
        //Insert Project Resource        
        Project_Resource__c pr_1= new Project_Resource__c(
            Project_Role__c=  'Admin',
            User__c = user_1.Id    
        );
        insert pr_1;
        
        // Insert Task Assignment
        /*Task_Assignment__c task_Assign1= new Task_Assignment__c(
            Project_Resource__c =  pr_1.Id,
            Task__c =   task_1.Id
        );
        insert task_Assign1;*/
        

        Timesheet__c timesheet_1= new Timesheet__c(
            Name= 'Wasim Akram - 23-11-2018',
            Timesheet_Date__c = system.today(),
            Approval_Status__c = 'Approved'
        );
        insert timesheet_1;
        
        System.debug('Timesheet In Test Class::' + timesheet_1);
        Timesheet_Detail__c timesheetDetail_1 = new Timesheet_Detail__c(
            Timesheet__c = timesheet_1.Id
            //Resource_Task_Assignment__c = task_Assign1.Id   
        );
        insert timesheetDetail_1;
        
         acctTemplt acc = new  acctTemplt();
         acc.timesheetId = timesheet_1.Id;
         acc.gettimesheet_details();
         acc.gettimesheet();
         acc.getuser();
         acc.testSystem();
        
        
     }
}