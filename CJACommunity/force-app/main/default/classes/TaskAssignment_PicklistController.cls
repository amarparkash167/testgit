public class TaskAssignment_PicklistController {
    /*
* Class Name:TaskAssignment_PicklistController
* Author: Farah Naqvi  
*/
   /* 
    @AuraEnabled
    public static Task__c getDeliverable(String deliverId){
        try{    
            List<Task__c> deliverSingleObject= new List<Task__c>();  
            deliverSingleObject = [Select Id, Name, Project__r.Name from Task__c Where Id=: deliverId limit 1];   
            
            if(!deliverSingleObject.isEmpty() && deliverSingleObject.size()== 1)
                return deliverSingleObject[0];
        }
        catch(Exception ex){
            System.debug('::Deliverable Exception Message: '+ex.getMessage());
            System.debug('::Deliverable Exception TypeName: '+ex.getTypeName());
            System.debug('::Deliverable Exception LineNumber: '+ex.getLineNumber());
        }
        return null; 
    }    
    
    @AuraEnabled 
    public static List<Map<String,String>> getPickListValuesIntoList(String parentId){
        
        List<Map<String,String>> pickListValuesList  = new List<Map<String,String>>();
        
        if(String.isBlank(parentId) == false){}    
        String soql= 'Select Id, Name From Task__c where Deliverables__c =\'' + parentId + '\'';
        system.Debug('::soql: '+ soql);
        for(Task__c task: Database.query(soql)){
            if(String.isBlank(task.Name) == false)
                pickListValuesList.add(new Map<String, String>{'value' => task.Id, 'label' => task.Name});
            // system.Debug('::Task Rec: '+ task);
        } 
        return pickListValuesList;      
    }
    
    @AuraEnabled
    public static Map<String, List<Task_Assignment__c>> getTaskAssignmentsMap(String DeliverableId){
        Map<String, List<Task_Assignment__c>> task_Map_RTA= new Map<String, List<Task_Assignment__c>>();    
        List<Task__c> taskList= new List<Task__c>();  
        if(String.isBlank(DeliverableId) == false){    
            taskList = [Select Id, Name, (Select Id, Name , Project_Resource__c ,Status__c, Start_Date__c, End_Date__c, Task__c from CJ_Task_Assignments__r) from Task__c Where Deliverables__c =:DeliverableId  ];    
            
            for(Task__c task:taskList){
                task_Map_RTA.put(task.Id, task.CJ_Task_Assignments__r);   
            }    
        }  
        
        return task_Map_RTA;    
    } 
    
    @AuraEnabled
    public static List<String> deleteTaskAssignments(List<Task_Assignment__c> taskAssign_Del_List){
        try{    
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
                
                for(Database.DeleteResult dr: drList){
                    if(dr.isSuccess()){
                    responseList.add('Successfully deleted resource ');    
                    }   
                    else{
                    responseList.add('Error in deleting resource ');  
                    }
                }
            } 
            return responseList;    
        }
        catch(Exception ex){
            System.Debug('::Delete TaskAssign Message: '+ ex.getMessage());
            System.Debug('::Delete TaskAssign Cause: '+ ex.getCause());
            System.Debug('::Delete TaskAssign LineNumber: '+ ex.getLineNumber()); 
        }       
        return null;    
    }     
    
    @AuraEnabled
    public static void insert_TaskAssignment(String taskAssignmentList, String taskId){
        try{    
            if(String.isBlank(taskId) == false && taskId != '--New Task--' && String.isBlank(taskAssignmentList) == false ){     
                
                Type idArrType = Type.forName('List<Task_Assignment__c>');
                List<Task_Assignment__c> taskAssignments = (List<Task_Assignment__c>) JSON.deserialize(taskAssignmentList, idArrType);    
                system.Debug('::Task Assignment: ' + taskAssignments);    
                
                if(taskAssignments != null && !taskAssignments.isEmpty()){  
                    
                    Set<String> projectResourceId= new Set<String>();  
                    
                    List<Task_Assignment__c> upsertTaskAssignList= new List<Task_Assignment__c>();   
                    
                    for(Task_Assignment__c assign: taskAssignments){
                        
                        if(!projectResourceId.contains(assign.Project_Resource__c)){
                            upsertTaskAssignList.add(assign);    
                        }
                        projectResourceId.add(assign.Project_Resource__c);    
                    }    
                    
                    Database.UpsertResult[] srList= Database.Upsert(upsertTaskAssignList, Task_Assignment__c.Id.getDescribe().getsObjectField(), false);
                    
                    for(Database.UpsertResult sr: srList){
                        if(!sr.isSuccess()){
                            for(Database.Error err: sr.getErrors()){
                                system.debug('::Task Assignment-StatusCode: '+ err.getStatusCode());
                                system.debug('::Task Assignment-getMessage: '+ err.getMessage());
                                system.debug('::Task Assignment-getFields: '+ err.getFields());  
                            }
                        }    
                    }
                }// Not null
            }
            // system.Debug('::--No Task Id--');
        }
        catch(Exception ex){
            System.Debug('::Task Assignment Exception Message: '+ex.getMessage());
            System.Debug('::Task Assignment LineNumber:'+ex.getLineNumber());
            System.Debug('::Task Assignment TypeName:'+ex.getTypeName());
        }
    }    
    
    @AuraEnabled
    public static String insertTask(Task__c Task){
        try{    
            system.Debug('::Task : ' + Task);    
            Database.UpsertResult sr= Database.Upsert(Task, Task__c.Id.getDescribe().getsObjectField(), false);
            
            if(!sr.isSuccess()){
                for(Database.Error err: sr.getErrors()){
                    system.debug('::Task -StatusCode: '+ err.getStatusCode());
                    system.debug('::Task -getMessage: '+ err.getMessage());
                    system.debug('::Task -getFields: '+ err.getFields());  
                }
                return 'Error';  
            } 
            else if(sr.isSuccess()){
                return 'Success';
            }
        }
        catch(Exception ex){
            System.Debug('::Task Exception Message: '+ex.getMessage());
            System.Debug('::Task Exception LineNumber:'+ex.getLineNumber());
            System.Debug('::Task Exception TypeName:'+ex.getTypeName());
        }
        return '';
    } 
/*    
    @AuraEnabled
    public static void insertRTA(Task__c Task, List<Task_Assignment__c> taskAssignmentList){
        try{ 
            //Upsert Task
            Database.UpsertResult sr1= Database.Upsert(Task, Task__c.Id.getDescribe().getsObjectField(), false);
            
            if(!sr1.isSuccess()){
                for(Database.Error err: sr1.getErrors()){
                    system.debug('::Task -StatusCode: '+ err.getStatusCode());
                    system.debug('::Task -getMessage: '+ err.getMessage());
                    system.debug('::Task -getFields: '+ err.getFields());  
                }
                
            } 
            
            // Upsert TaskAssignment            
            Database.SaveResult[] srList= Database.Insert(taskAssignmentList, false);
            
            for(Database.SaveResult sr: srList){
                if(!sr.isSuccess()){
                    for(Database.Error err: sr.getErrors()){
                        system.debug('::Task Assignment-StatusCode: '+ err.getStatusCode());
                        system.debug('::Task Assignment-getMessage: '+ err.getMessage());
                        system.debug('::Task Assignment-getFields: '+ err.getFields());  
                    }
                    
                }    
            }            
        }
        catch(Exception ex){
            System.Debug('::Task Exception Message: '+ex.getMessage());
            System.Debug('::Task Exception LineNumber:'+ex.getLineNumber());
            System.Debug('::Task Exception TypeName:'+ex.getTypeName());
        }
    } 
*/
    

    public void testSystem(){
        
        System.debug('Testing');
    }    
}