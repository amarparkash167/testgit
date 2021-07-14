public class Task_Edit_Controller {

   /* public class initializationWrapperForTaskPage {
        @AuraEnabled public List<Map<String,String>> all_taskStatus{get; set;}  
        @AuraEnabled public List<Map<String,String>> all_taskPriorities{get; set;} 
        @AuraEnabled public Task__c task{get; set;} 
        @AuraEnabled public Task__c DeliverableRec{get; set;} 
        //@AuraEnabled public Map<String, List<Task_Assignment__c>> taskAssignmentMap{get; set;} 
        @AuraEnabled public String SF_Base_Url{get; set;}        
    }
    
@AuraEnabled    
public static initializationWrapperForTaskPage getTaskRecordFromTaskPage(String taskId){
        try{    
            initializationWrapperForTaskPage obj= new initializationWrapperForTaskPage();
            
            obj.SF_Base_Url  = URL.getSalesforceBaseUrl().toString();
            
            List<Task__c> task= new List<Task__c>();
            task = [Select Id, Name, Deliverables__c, Status__c, Priority__c, Start_Date__c, Completion_Date__c, Due_Date__c,
                    Estimated_Hours__c,  Complete__c, Billable__c, Billable_Hours__c,Description__c From Task__c Where Id=: taskId];
            system.Debug('::task from Controller:  '+ task);

            List<Task__c> Deliverable= new List<Task__c>();
            
            //Map<String, List<Task_Assignment__c>> taskAssignments= new Map<String, List<Task_Assignment__c>>();
             
            //Set Deliverable 
            if(!task.isEmpty() && task.size()== 1){
               obj.task= task[0];
               
               //taskAssignments.put(task[0].Id, task[0].CJ_Task_Assignments__r); 
               //obj.taskAssignmentMap = taskAssignments; 
                
               Deliverable = [Select Id, Name , Project__c, Project__r.Name From Task__c Where Id =:task[0].Deliverables__c ]; 
               if(!Deliverable.isEmpty() && Deliverable.size()== 1) 
               obj.DeliverableRec = Deliverable[0]; 
                
                
            }
            
            // Get Task Status Picklist Value
            List<Map<String,String>> statusPicklist= new List<Map<String,String>>();
            Schema.DescribeFieldResult fieldResult= Task__c.Status__c.getDescribe();
            List<Schema.PicklistEntry> ple_Status= fieldResult.getPicklistValues();
            for(Schema.PicklistEntry ple1: ple_Status){
                statusPicklist.add(new Map<String, String>{'value' => ple1.label, 'label' => ple1.label});    
            }
            obj.all_taskStatus= statusPicklist;
            
            // Get Task Priority Picklist Value 
            List<Map<String,String>> priorityPicklist= new List<Map<String,String>>();
            Schema.DescribeFieldResult fieldResult1= Task__c.Priority__c.getDescribe();
            List<Schema.PicklistEntry> ple_Priority= fieldResult1.getPicklistValues();
            for(Schema.PicklistEntry ple2: ple_Priority){
            priorityPicklist.add(new Map<String, String>{'value' => ple2.label, 'label' => ple2.label});    
            }
            obj.all_taskPriorities= priorityPicklist;            
            
            
            return obj; 
        }
        catch(Exception ex){
            System.debug('::Deliverable Exception Message: '+ex.getMessage());
            System.debug('::Deliverable Exception TypeName: '+ex.getTypeName());
            System.debug('::Deliverable Exception LineNumber: '+ex.getLineNumber());
        }
        return null; 
    }        

    public class wrapperClass{
        @AuraEnabled public String upsertMessage{get; set;}
        @AuraEnabled public String taskId{get; set;}
        @AuraEnabled public String taskName{get; set;}
    }

    /*@AuraEnabled
    public static Map<String, List<Task_Assignment__c>> getTaskAssignmentsMap_One_Task(String taskId){
        Map<String, List<Task_Assignment__c>> task_Map_RTA= new Map<String, List<Task_Assignment__c>>();    
        List<Task__c> taskList= new List<Task__c>();  
        if(String.isBlank(taskId) == false){    
            taskList = [Select Id, Name, (Select Id, Name , Project_Resource__c ,Status__c, Start_Date__c, End_Date__c, Task__c, Estimated_Hour__c
                         from CJ_Task_Assignments__r) 
                        from Task__c Where Id =:taskId];    
            
            for(Task__c task:taskList){
                task_Map_RTA.put(task.Id, task.CJ_Task_Assignments__r);   
            }    
        }  
        system.Debug('::TaskAssignmentsMap: '+ task_Map_RTA);
        return task_Map_RTA;    
    }    
    
    @AuraEnabled
    public static String deleteTaskAssignments(List<Task_Assignment__c> taskAssign_Del_List){
        try{    
            String deleteMessages  = '';
            List<String> responseList= new List<String>();       
            System.Debug('::taskAssign_Del_List : '+ taskAssign_Del_List);    
            //Database.DeleteResult[] srList = Database.Delete(taskAssign_Del_List , false);    
            Set<Id> taskAssign_Ids =  new Set<Id>();
            if(taskAssign_Del_List != null && !taskAssign_Del_List.isEmpty()){
                
                taskAssign_Ids= (new Map<Id,Task_Assignment__c>(taskAssign_Del_List)).keySet();   
                
                List<Timesheet_Detail__c> timesheetDetail=  new List<Timesheet_Detail__c>(); 
                timesheetDetail = [Select Id, Name, Resource_Task_Assignment__c, Resource_Task_Assignment__r.Project_Resource__c from Timesheet_Detail__c Where 
                                   Resource_Task_Assignment__c IN: taskAssign_Ids];  
                Map<Id, Timesheet_Detail__c>  assignId_detail_Map= new Map<Id, Timesheet_Detail__c>();     
                for(Timesheet_Detail__c detail: timesheetDetail){
                    assignId_detail_Map.put(detail.Resource_Task_Assignment__r.Project_Resource__c, detail);    
                }
                
                List<Task_Assignment__c> deleteList= new List<Task_Assignment__c>();
                for(Task_Assignment__c assign: taskAssign_Del_List){
                Boolean flag= assignId_detail_Map.containsKey(assign.Id);
                    if(flag == false ){
                    deleteList.add(assign); 
                }
                }
                Database.DeleteResult[] drList= Database.Delete(deleteList ,false);
                
                Integer i=1;
                for(Database.DeleteResult dr: drList){
                    if(dr.isSuccess()){
                    responseList.add('Successfully deleted resource ');   
                    if(String.isBlank(deleteMessages) == false)    
                    deleteMessages = deleteMessages + ', \n ' + i+ ' :Successfully deleted resource ';    
                    else
                    deleteMessages = deleteMessages + i+ ': Successfully deleted resource ';    
                    }   
                    else{
                    responseList.add('Error in deleting resource '); 
                    if(String.isBlank(deleteMessages) == false)                         
                    deleteMessages = deleteMessages + ', \n ' + i+ ' :Error in deleting resource ';    
                    else
                    deleteMessages = deleteMessages + i+ ':Error in deleting resource '  ;
                    }
                    i++;
                }
            } 
            System.Debug('::deleteMessagest : '+ deleteMessages); 
            return deleteMessages;    
        }
        catch(Exception ex){
            System.Debug('::Delete TaskAssign Message: '+ ex.getMessage());
            System.Debug('::Delete TaskAssign Cause: '+ ex.getCause());
            System.Debug('::Delete TaskAssign LineNumber: '+ ex.getLineNumber()); 
        }       
        return '';    
    }         
    
    @AuraEnabled
    public static wrapperClass insertRTA(Task__c Task, String taskAssignmentList){
        String saveStatus= '';
        //Boolean insertFlag= false;
        
        wrapperClass obj1= new wrapperClass();
        obj1.upsertMessage= '';
        obj1.taskId= '';
        obj1.taskName= '';
        try{ 
            Type idArrType = Type.forName('List<Task_Assignment__c>');
            List<Task_Assignment__c> taskAssignments = (List<Task_Assignment__c>) JSON.deserialize(taskAssignmentList, idArrType);
            
            system.debug('::Task: '+ Task);

            if(String.isBlank(Task.Status__c) == false){
            Task.Status__c=  Task.Status__c.trim();   
            }    
            
             if(String.isBlank(Task.Id) == true){
                Task.Id=  null;   
                //insertFlag= true;
            }

            //Upsert Task
            Database.UpsertResult sr1= Database.Upsert(Task, Task__c.Id.getDescribe().getsObjectField(), false);
            
            if(!sr1.isSuccess()){
                for(Database.Error err: sr1.getErrors()){
                    system.debug('::Task -StatusCode: '+ err.getStatusCode());
                    system.debug('::Task -getMessage: '+ err.getMessage());
                    system.debug('::Task -getFields: '+ err.getFields());  
                }
               saveStatus = 'Error - Task and Task Assignment cannot be inserted'; 
               obj1.upsertMessage = saveStatus;  
               obj1.taskId = '';   
               system.debug('::Error insertRTA: '+ obj1); 
               return obj1; 
            } 
            else if(sr1.isSuccess()){
                //Set Wrapper Task Name
                obj1.taskName= Task.Name;
                obj1.taskId = sr1.getId();  
                
           
                system.debug('::TaskAssignments RTA: '+ taskAssignments);
                
                List<Task_Assignment__c> upsertList= new List<Task_Assignment__c>(); 
                
                String tempAssignId= '';
                for(Task_Assignment__c assign:taskAssignments){
                tempAssignId= '' + assign.Id;    
                if(String.isBlank(tempAssignId) == true || (String.isBlank(tempAssignId) == false && tempAssignId == '--New Task--'))    
                   assign.Task__c= sr1.getId();    
                   tempAssignId= '';
                    
                    if(String.isBlank(assign.Task__c) == true){
                    assign.Task__c  =  sr1.getId();    
                    }   
                    
                    if(String.isBlank(assign.Project_Resource__c) == false){
                    upsertList.add(assign);     
                    }
                }
                
            // Upsert TaskAssignment            
            Database.UpsertResult[] srList= Database.Upsert(upsertList, Task_Assignment__c.Id.getDescribe().getsObjectField(), false);
            saveStatus = 'Success - Task saved successfully\n';
            obj1.upsertMessage = saveStatus;  
            obj1.taskId = sr1.getId();      
            Integer assignCount = 1;
            for(Database.UpsertResult sr: srList){
                if(!sr.isSuccess()){
                    for(Database.Error err: sr.getErrors()){
                        system.debug('::Task Assignment-StatusCode: '+ err.getStatusCode());
                        system.debug('::Task Assignment-getMessage: '+ err.getMessage());
                        system.debug('::Task Assignment-getFields: '+ err.getFields());  
                    }
                 saveStatus = saveStatus + '\nTask Assignment-'+ assignCount + ' :error occured cannot be inserted/updated';    
                 obj1.upsertMessage = saveStatus;    
                }
                else{
                     saveStatus = saveStatus + '\nTask Assignment-'+ assignCount + ' :successfully inserted/updated'; 
                     obj1.upsertMessage = saveStatus; 
                }
                assignCount++; 
            } 
           
            }
        }
        catch(Exception ex){
            System.Debug('::Task Exception Message: '+ex.getMessage());
            System.Debug('::Task Exception LineNumber:'+ex.getLineNumber());
            System.Debug('::Task Exception TypeName:'+ex.getTypeName());
        }
        system.debug('::Wrapper obj: '+ obj1);  
        return obj1;
    } */
    
    public void testSystem(){
        System.debug('Testing');
    }

}