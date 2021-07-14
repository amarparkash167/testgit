@isTest
public class Test_TaskAssignment {

    static testMethod void myUnitTest(){
        
       //createTestData();                                                                             
       TaskAssignment_PicklistController tp = new TaskAssignment_PicklistController();
        tp.testSystem();
      
    }
/*    
    public static void createTestData(){
    // Create Project Record

    Project__c proj1= new Project__c(
        Name= 'Project-1',
        Complexity_Level__c='High',
        Profitability__c = 'Medium',
        Project_Start_Date__c = date.newInstance(2018, 11, 18)
    );
    insert proj1;
    
    Task__c del_1= new Task__c(
            Name='Deliverable-1',
            Project__c = proj1.Id
    );
    insert del_1;
    
    //Get Deliverable ID
    TaskAssignment_PicklistController.getDeliverable(del_1.Id);
    
    //Get Task_Assignments Map   
    TaskAssignment_PicklistController.getTaskAssignmentsMap(del_1.Id);    
        
    TaskAssignment_PicklistController.getPickListValuesIntoList(del_1.Id);    
        
    Task__c task_1= new Task__c(
    Name='Task-1',
    Deliverables__c =    del_1.Id
    );
        
   TaskAssignment_PicklistController.insertTask(task_1);         
  
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

  // Insert Task Assignment
  Task_Assignment__c task_Assign1= new Task_Assignment__c(
   Project_Resource__c =  pr_1.Id,
   Task__c =   task_1.Id
  );
  insert task_Assign1; 
        
  List<Task_Assignment__c> taskAssignmentList= new List<Task_Assignment__c>();        
  taskAssignmentList.add(task_Assign1);        
 
        String strSobjects= '[';  
        String midString = '';

        for(Task_Assignment__c assign1: taskAssignmentList){
        if(String.isBlank(midString) == false)    
        midString = ',' + JSON.serialize(assign1);   
        else if(String.isBlank(midString) == true)
        midString = midString + JSON.serialize(assign1);    
        }
        strSobjects = strSobjects + midString+ ']';
  //Insert Task Assignments
  TaskAssignment_PicklistController.insert_TaskAssignment(strSobjects, task_1.Id);           
        
  //Delete Task Assignments 
  TaskAssignment_PicklistController.deleteTaskAssignments(taskAssignmentList);
    }
*/
}