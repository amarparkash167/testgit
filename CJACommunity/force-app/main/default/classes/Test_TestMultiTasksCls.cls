@isTest
public class Test_TestMultiTasksCls {

    static testMethod void myUnitTest(){
    
    Project__c proj1= new Project__c(
        Name= 'Unassigned Project',
        Complexity_Level__c='High',
        Profitability__c = 'Medium',
        Project_Start_Date__c = date.newInstance(2018, 11, 18)
    );
    insert proj1;
    
    Task__c del_1= new Task__c(
            Name='Unassigned Deliverable',
            Project__c = proj1.Id, 
            RecordTypeId= Schema.sobjectType.Task__c.getRecordTypeInfosByName().get('Deliverable').getRecordTypeId()        
    );
    insert del_1;    
    
    Task__c task_1= new Task__c(
    Name='Task-1',
    Project__c = proj1.Id,     
    Deliverables__c = del_1.Id, 
    RecordTypeId= Schema.sobjectType.Task__c.getRecordTypeInfosByName().get('Sub Task').getRecordTypeId() 
    );
    //insert task_1;    

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

   Task__c task_2= new Task__c(
    Name='Task-2',
    Project__c = proj1.Id,    
    Deliverables__c =  del_1.Id
    );  
    //insert task_2;  
    
   Task__c task_3= new Task__c(
    Name='Task-3',
    Description__c= 'Test Task'
    );          

 List<Task__c> taskList= new List<Task__c>();  
    taskList.add(task_3);    
    //taskList.add(task_1);
    //taskList.add(task_2);
            

  /*      
  String strSobjects= '[';  
  String midString = '';

   for(Task__c t1: taskList){
     if(String.isBlank(midString) == false)    
        midString = ',' + JSON.serialize(t1);   
        else if(String.isBlank(midString) == true)
        midString = midString + JSON.serialize(t1);    
  }
  strSobjects = strSobjects + midString+ ']';        
  */
        
  TestMultiTasksCls.onLoad(del_1.Id);        
  TestMultiTasksCls.lstTMT(JSON.serialize(taskList));      
  TestMultiTasksCls.getDeliverables(proj1.Id);    
    }    
    
}