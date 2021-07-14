public with sharing class Timesheet_Controller {
     
    
    public static Id timesheet_id {get;set;}
    public static Decimal timesheet_hours {get;set;}
    public static String approval_status {get;set;}
    public static Date timesheet_Date{get;set;}
    public static Boolean timesheet_user{get;set;}
    
    @AuraEnabled
    //to get the userId of active user.
    public static Id getActiveUser() {
        
        Id userId = UserInfo.getUserId();
        return userId;
        
    }
    
    @AuraEnabled
    public static String isActiveUser(Id RecordId){
        
        System.debug('Record Id::' + recordId);
        User user = [Select Timesheet_User__c from User where Id =: getActiveUser()];
        System.debug('User has timesheet' + user.Timesheet_User__c);
        timesheet_user=user.Timesheet_User__c;
        if(!user.Timesheet_User__c){
            System.debug('He ia not Timesheet User' + RecordId);
            return 'You are not authorized to Enter Timesheet, Contact your System Administration!!';
                }
        
        else{
            
            return checkTimesheetOwner(RecordId);
        }
    }
    
    @AuraEnabled
    //To get the manager of activeuser.
    public static Boolean hasManager(){
        
        User user = [Select ManagerId from User  where Id =: getActiveUser()];
        
        System.debug('USer has Manager' + user + '  ') ;
        if(user.ManagerId == null){
            
            System.debug('User has Manager : true' );
            return false;
        }        
        
        return true;
        
    }
    
    @AuraEnabled
    public static String checkTimesheetOwner(Id RecordId){
        
        //User user = [Select ManagerId from User  where Id =: getActiveUser()];
        if(RecordId != null){
            
            System.debug('Record Id not null::' + RecordId);
            List<Timesheet__c> timesheet_owner = [Select id from Timesheet__c where Id =: RecordId and OwnerId =: getActiveUser()];
            System.debug('USer has Timesheet' + timesheet_owner + '  ') ;
            if(timesheet_owner.isEmpty()){
                
                System.debug('User is trying to access someone else Manager : true' );
                return 'You are not authorized to access someone else Timesheet';
            }        
        }
        return null;
        
    }
    
    
    
    // get Dropdown Values from Task Status
    @AuraEnabled
    public static List<String> getStatus(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Task__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    } 
    
    
    
    // Pass String
    @AuraEnabled
    public static String passString(List<Timesheet_Detail__c> listofTimesheetDetail){
        
        try{
            
            List<Timesheet_Detail__c> loggedTimesheetDetail = new List<Timesheet_Detail__c>();
            //Type idArrType = Type.forName('List<Timesheet_Detail__c>');
            //List<Timesheet_Detail__c> listofTimesheetDetail = (List<Timesheet_Detail__c>) JSON.deserialize(name, idArrType);
            
            for(Timesheet_Detail__c timesheet_detail: listofTimesheetDetail ){
                if(timesheet_detail.Actual_Hours__c >0)
                    loggedTimesheetDetail.add(timesheet_detail);
                
            }
            
            System.debug('Logged Timesheet Detail::' + loggedTimesheetDetail);
            if(loggedTimesheetDetail.size()>0){
                
                insert loggedTimesheetDetail;
                System.debug('List of Logged Timesheet Detail has been updated');
            }
            
            return 'Return Timesheet Detail::' +  listofTimesheetDetail;
        }
        catch(Exception e){
            
            System.debug('Exception in Insertion::' + e.getMessage());
            return  e.getMessage();
        }
        
    }
     // Update Timesheet Detail
    @AuraEnabled
    public static String UpdateTimesheetDetail(List<Timesheet_Detail__c>  listofTimesheetDetail){
        
        try{
            
            
            //Type idArrType = Type.forName('List<Timesheet_Detail__c>');
            //List<Timesheet_Detail__c> listofTimesheetDetail = (List<Timesheet_Detail__c>) JSON.deserialize(timesheetDetail, idArrType);
            List<Task__c> listofTask = new List<Task__c>();
            List<Id> taskAssId = new List<Id>();
            
            // Update Timesheet Updated List of Task Assignment
            for(Timesheet_Detail__c taskAss: listofTimesheetDetail){
                
                Task__c updateTask = new Task__c(Id = taskAss.Task__c);
                updateTask.Status__c = taskAss.Task__r.status__c;
                updateTask.Comment__c = taskAss.Task__r.Comment__c;
                listofTask.add(updateTask);
                System.debug('List of Task Assignment::' + listofTask);
                taskAssId.add(taskAss.Task__c);
            }
            
            
            
            if(listofTimesheetDetail.size()>0){
                
                // listofTaskAssignment = [Select id, name from Task_Assignment__c where Id In:taskAssId ];
                update listofTask;
                System.debug('List of Updated Task Assignment ::' + listofTask);
                update listofTimesheetDetail;
                System.debug('List of Updated Timesheet Detail ::' +listofTimesheetDetail );
            }
            
            return 'Timesheet Detail Has been updated';
        }
        catch(Exception e){
            
            System.debug('Exception in Insertion::' + e.getMessage());
            return  e.getMessage();
        }
        
    }

    
    
    @AuraEnabled
    public static String UpdateTaskAss(List<Task__c> listofTaskAss){
        
        try{
            
            //Type idArrType = Type.forName('List<Task_Assignment__c>');
            //List<Task_Assignment__c> listofTaskAss = (List<Task_Assignment__c>) JSON.deserialize(taskAss, idArrType);
            
            if(listofTaskAss.size()>0){
                
                update listofTaskAss;
                System.debug('List of Updated Task Assignment ::' + listofTaskAss );
            }
            
            return 'Task Assignment Has been updated' + listofTaskAss;
        }
        catch(Exception e){
            
            System.debug('Exception in Insertion::' + e.getMessage());
            return  e.getMessage();
        }
        
    }
    
    @AuraEnabled
    public static Id getTimesheetId(Id recordId) {
        
        if(timesheet_user){
            
            System.debug('EDIT ID'+ recordId);
            List<Timesheet__c> listOftimesheet = new  List<Timesheet__c>();
            Timesheet__c timesheet = null;
            if(recordId!=null){
                listOftimesheet = [Select Id  , Total_hours_logged__c, Approval_Status__c, Timesheet_Date__c from Timesheet__c where Id =: recordId];
                
            }
            
            else{
                
                listOftimesheet = [Select Id  , Total_hours_logged__c, Approval_Status__c , Timesheet_Date__c from Timesheet__c where OwnerId =: getActiveUser() and Timesheet_Date__c = TODAY LIMIT 1];
            }
            if(listOftimesheet.isEmpty()){
                
                timesheet = createTimesheet(getActiveUser() , Date.today());
                insert timesheet;
                timesheet_id = timesheet.Id;
                timesheet_hours = 0;
                timesheet_Date = timesheet.Timesheet_Date__c;
                approval_status = timesheet.Approval_Status__c;
            }
            
            else{
                
                timesheet = listOftimesheet[0];
                timesheet_id = timesheet.Id;
                timesheet_hours = timesheet.Total_hours_logged__c;
                approval_status = timesheet.Approval_Status__c;
                timesheet_Date = timesheet.Timesheet_Date__c;
                System.debug('TIMESHEET ID::' + timesheet_id);
            }
            return timesheet.Id;
            
        }
        return null;
    }
    
    
    // Get List of Timesheet Detail already Updated 
    @AuraEnabled
    public static list<Timesheet_Detail__c> getTimesheetDetail(Id recordId) {
        
        // Initialize Timesheet Detail Resource Task Assignment Ids
        // 
        System.debug(recordId);
        
        if(timesheet_user){
            
            Id timesheet_id = getTimesheetId(recordId);
            List<Timesheet_Detail__c> listofTimesheetDetail = [Select Task__r.status__c, Task__r.Comment__c,Task__c, Task__r.Id, Task__r.Deliverables__r.Name, Task__r.Deliverables__r.Project__r.Name, Task__r.Name, Actual_Hours__c , billable__c, Comments__c ,Timesheet__c from Timesheet_Detail__c where Timesheet__c =: timesheet_id];
            System.debug('List of Timesheet Detail::' + listofTimesheetDetail);   
            
            return listofTimesheetDetail;
            
        }
        return null;
    }
    
    @AuraEnabled
    public static Decimal getTimesheetHours() {
        
        if(timesheet_user){
            return timesheet_hours;
        }
        return null;
    }
    @AuraEnabled
    public static Date getTimesheetDate() {
        
        if(timesheet_user){
            return timesheet_Date;
        }
        return null;
    }
    
    @AuraEnabled
    public static Boolean getApprovalStatus() {
        
        if(timesheet_user){
            if(approval_status == 'Pending Approval' || approval_status == 'Submitted' || approval_status == 'Approved' )
                return true;
            
            else
                return false;
        }
        return null;
    }
    
    //Use @AuraEnabled to enable client- and server-side access to the method
    @AuraEnabled
    public static list<Timesheet_Detail__c> getTask(Id recordId) {
        
        if(timesheet_user){
            
            //Id timesheet_id = timesheet; // getTimesheetId();
            
            // Get already exist Timesheet Detail Resource Task Assignment
            List<Id> taskIds = getTaskAssIds(recordId);
            
            List<Task__c> assigned_task_list = [Select id , Name, Deliverables__r.Name,Deliverables__r.Project__r.Name , Status__c , Comment__c from Task__c where Status__c!='Completed' and Resource__c=: getActiveUser() and Id Not In: taskIds ORDER by Name] ;
            List<Timesheet_Detail__c> listOftimesheetDetail = new List<Timesheet_Detail__c>();
            
            
            if(!assigned_task_list.isEmpty()){
                for(Task__c  task_list: assigned_task_list){
                    
                    System.debug('Task Assignment::' + task_list);
                    Timesheet_Detail__c timesheetDetail = new Timesheet_Detail__c();
                    timesheetDetail.Task__c = task_list.Id;
                    timesheetDetail.Actual_Hours__c = 0;
                    timesheetDetail.Comments__c = '';
                    timesheetDetail.billable__c = False;
                    timesheetDetail.Timesheet__c = timesheet_id;
                    //timesheetDetail.Resource_Task_Assignment__r.Task__r.Name = task_list.Task__r.Name;
                    //timesheetDetail.Resource_Task_Assignment__r.Task__r.Project__r.Name = task_list.Task__r.Project__r.Name;
                    listOftimesheetDetail.add(timesheetDetail);
                    
                    System.debug('Timesheet Detail::' + timesheetDetail);
                }
                
                System.debug('Timesheet Detail::' + listOftimesheetDetail);
            }
            return listOftimesheetDetail; 
            
        }
        return null;
    }
    
    @AuraEnabled
    public static list<Task__c> getTaskAssignment(Id recordId) {
        
        if(timesheet_user){
            
            // Get already exist Timesheet Detail Resource Task Assignment
            List<Id> taskIds = getTaskAssIds(recordId);
            
            List<Task__c> assigned_task_list = [Select id , Name, Deliverables__r.Name, Deliverables__r.Project__r.Name , Status__c , Comment__c from Task__c  where Status__c!='Completed' and Resource__c =: getActiveUser() and Id Not In: taskIds ORDER by Name] ;
            System.debug('All Task Assigned' + assigned_task_list);
            return assigned_task_list; 
            
        } return null;
    }
    
    @AuraEnabled
    public static String changeApprovalStatus(Id recordId){
        
        
        
        System.debug('Change Approval Status');
        try{
            Timesheet__c updateTimesheet = new Timesheet__c( ID = recordId);
            System.debug('Update Timesheet::' + updateTimesheet);
            
            updateTimesheet.Approval_Status__c = 'Pending Approval';
            update updateTimesheet;
            
            return 'succedd';
        }
        catch(Exception e){
            
            System.debug('Exception in Insertion::' + e.getMessage());
            return  e.getMessage();
        }
    }
    
    
    
    
    public static List<Id> getTaskAssIds (Id active_timesheet_id){
        
        if(timesheet_user){
            List<Id> taskIds = new List<Id>();        
            for(Timesheet_Detail__c timesheetDetail: getTimesheetDetail(active_timesheet_id)){
                
                taskIds.add(timesheetDetail.Task__r.Id);
                System.debug(' Task ::' + timesheetDetail.Task__r.Id + ' Task Name::' + timesheetDetail.Task__r.Name);
            }
            
            return taskIds;
        } 
        return null;
    }
    
    public static Timesheet__c createTimesheet(Id OwnerId, Date dtoday){
        // Hamza - Added ExternalID - 9/24/2019
        // Getting Proper format for Date
		DateTime dt = DateTime.newInstance(dtoday.year(), dtoday.month(), dtoday.day());
    
        //When Timesheet create by system.
        Timesheet__c timesheet = new Timesheet__c(OwnerId = OwnerId , Timesheet_Date__c = dtoday, Approval_Status__c = 'Not Submitted', External_ID__c = dt.format('YYYY-MM-dd')+'|'+OwnerId);
        
        return timesheet;       
        
    }
    
  
   
    
    public void testSystem(){
        
        System.debug('Testing');
    }


}