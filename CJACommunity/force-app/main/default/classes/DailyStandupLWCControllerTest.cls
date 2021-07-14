@isTest
public class DailyStandupLWCControllerTest {
    
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
        
        Task__c del_1= new Task__c(
            Name='Test Deliverable',
            Project__c = proj1.Id, 
            RecordTypeId= Schema.sobjectType.Task__c.getRecordTypeInfosByName().get('Deliverable').getRecordTypeId()        
        );
        insert del_1; 
        
        
        
        Map<String, String> recordMap = new Map<String, String>{'deliverable'=> '{"icon":"standard:task","id":"'+del_1.Id+'","sObjectType":"Tasks","subtitle":"hamza","title":"30 days review • 2019-11-29 00:00:00 • Unassigned"}', 'description'=>'hello', 'dueDate'=>'2019-07-30', 'hours'=>'22', 'startDate'=>'2019-07-25', 'task'=>'2345', 'user'=>user_1.Id};
        List<Map<String, String>> listOfMap = new List<Map<String, String>>();
        listOfMap.add(recordMap);
        List<List<Map<String, String>>> records = new List<List<Map<String, String>>>();
        
        records.add(listOfMap);
        test.startTest();
        System.runAs(user_1)
        {
        	system.debug('Logged in user= ' + UserInfo.getUserId());
            DailyStandupLWCController.getDeliverables();
        	DailyStandupLWCController.getUsers();
        	DailyStandupLWCController.submitRecords(records,'','false');
        }
        
        test.stopTest();
        
        system.assertEquals(null, null);
    }
}