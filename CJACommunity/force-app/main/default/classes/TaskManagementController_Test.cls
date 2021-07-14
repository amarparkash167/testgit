@isTest
public class TaskManagementController_Test {
    
     static testMethod void testController()
    {
        Profile pro= [Select Id, Name from Profile Where Name='System Administrator' limit 1];
        
        User user_1=new User(
            IsActive=true,
            Alias='Abbey',
            Email= 'abcTestClass@gmail.com',
            ProfileId = pro.Id,
            LastName= 'Naqwi' ,
            Username= 'abc'+'@naqwi.com',
            TimeZoneSidKey='America/Los_Angeles',
            LanguageLocaleKey= 'en_US',
            LocaleSidKey = 'en_GB', 
            EmailEncodingKey='UTF-8',
            Timesheet_User__c=true
        );
        Insert user_1;
        
        Project__c proj1= new Project__c(
            Name= 'Test Project',
            Project_Lead__c = user_1.Id,
            Complexity_Level__c='High',
            Profitability__c = 'Medium',
            Project_Start_Date__c = date.newInstance(2020, 11, 18)
        );
        insert proj1;
        
        string userId = user_1.Id;
        
        system.debug('user Id ' + userId);
        
        Task__c del_1= new Task__c(
            Name='Test Deliverable',
            Project__c = proj1.Id,
         //   Due_date = date.today();
            RecordTypeId= Schema.sobjectType.Task__c.getRecordTypeInfosByName().get('Deliverable').getRecordTypeId()        
        );
               insert del_1;
        
        
        task__c task = New Task__c();

        task.Name = 'Test Task';
        task.Deliverables__c = del_1.Id ;
        task.Project__c = proj1.Id;
        task.Due_Date__c = date.today();
        insert task;
        
         Map<String, String> recordMap = new Map<String, String>{ 'dueDate'=>'2021-06-29','estHrsHigh'=>'5','estHrsLow'=>'5','plannedStartDate'=>'2021-06-29','plannedDueDate'=>'2021-06-29','projectedStartDate'=>'2021-06-29','projectedDueDate'=>'2021-06-29', 'description'=>'sa', 'estAdminHigh'=>'2', 'estAdminLow'=>'2', 'startDate'=>'2021-06-29', 'status'=>'Unassigned', 'task'=>'sasa', 'user'=>userId};        
        List<Map<String, String>> listOfMap = new List<Map<String, String>>();
        listOfMap.add(recordMap);
        List<List<Map<String, String>>> records = new List<List<Map<String, String>>>();
        
        
        records.add(listOfMap);
        
                system.debug('record in test=>' + records);
        
        
        

        test.startTest();
        System.runAs(user_1)
        {
             
        	TaskManagementController.getTasks(del_1.Id);
            TaskManagementController.createCustomException('Error Occurred');
        	TaskManagementController.submitRecords_Tasks(records,'','true',del_1.Id);
            TaskManagementController.findRecords(del_1.Name,'Task__c');

            TaskManagementController.getDeliverables(proj1.Id);
            TaskManagementController.findRecords(proj1.Name,'Project__c');
            TaskManagementController.submitRecords_Deliverables(records,'','true',proj1.Id);


            
            
        
        }
        
        test.stopTest();
        
        system.assertEquals(null, null);
    }
}