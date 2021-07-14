@isTest
public class Test_Task_Edit_Controller {

    static testMethod void unitTest(){   
    
    Task_Edit_Controller obj= new Task_Edit_Controller(); 
        obj.testSystem();
        
    /*Project__c proj1= new Project__c(
        Name= 'Project-1',
        Complexity_Level__c='High',
        Profitability__c = 'Medium',
        Project_Start_Date__c = date.newInstance(2018, 11, 18)
    );
    insert proj1;
    
    Task__c del_1= new Task__c(
            Name='Deliverables-1',
            Project__c = proj1.Id,
            RecordTypeId= Schema.sobjectType.Task__c.getRecordTypeInfosByName().get('Deliverables').getRecordTypeId()
    );
    insert del_1;    
    
    Task__c task_1= new Task__c(
    Name='Task-1',
    Project__c = proj1.Id,     
    Deliverables__c = del_1.Id,
    RecordTypeId= Schema.sobjectType.Task__c.getRecordTypeInfosByName().get('Sub Task').getRecordTypeId()
    );
    insert task_1;    

  //Query Profile 
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
  EmailEncodingKey='UTF-8'
  );
  Insert user_1;        
        
  //Insert Project Resource        
  Project_Resource__c pr_1= new Project_Resource__c(
  Project_Role__c=  'Admin',
  User__c = user_1.Id    
  );
  insert pr_1;

  // Insert Task Assignment - 1
 /* Task_Assignment__c task_Assign1= new Task_Assignment__c(
   Project_Resource__c =  pr_1.Id,
   Task__c =   task_1.Id
  );
  //insert task_Assign1;  
  
  //List<Task_Assignment__c> taskAssignments_Insert = new List<Task_Assignment__c>();    
  //taskAssignments_Insert.add(task_Assign1); 
        
  String strSobjects= '[';  
  String midString = '';

  for(Task_Assignment__c assign1: taskAssignments_Insert){
     if(String.isBlank(midString) == false)    
        midString = ',' + JSON.serialize(assign1);   
        else if(String.isBlank(midString) == true)
        midString = midString + JSON.serialize(assign1);    
  }
  strSobjects = strSobjects + midString+ ']';        
        
    //Task_Edit_Controller.insertRTA(task_1, strSobjects);  
      
    //Task_Edit_Controller.getTaskRecordFromTaskPage(task_1.Id);    
        
    //Task_Edit_Controller.getTaskAssignmentsMap_One_Task(task_1.Id);   
    
    Task__c task_2= new Task__c(
    Name='Task-2',
    Project__c = proj1.Id,    
    Deliverables__c =  del_1.Id,
    RecordTypeId= Schema.sobjectType.Task__c.getRecordTypeInfosByName().get('Sub Task').getRecordTypeId()
    );  
    insert task_2;    
        
    // Insert Task Assignment - 2
    /*Task_Assignment__c task_Assign2= new Task_Assignment__c(
     Project_Resource__c =  pr_1.Id,
     Task__c =   task_2.Id  
    );
    insert task_Assign2;  */  
        
    //List<Task_Assignment__c> deleteTaskAssignments=new List<Task_Assignment__c>();    
    //deleteTaskAssignments.add(task_Assign2);    
        
    //Task_Edit_Controller.deleteTaskAssignments(deleteTaskAssignments);    
   
    }    
   
}