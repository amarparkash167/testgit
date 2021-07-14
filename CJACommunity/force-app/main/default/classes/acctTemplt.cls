public  class acctTemplt{
  
    
    public Id timesheetId {get;set;}
    public Id OwnerID {get;set;}
    public List<Timesheet_Detail__c> gettimesheet_details()
    {
        List<Timesheet_Detail__c> timesheet_detail;
        System.debug('Timesheet ID::' + timesheetId );
        timesheet_detail = [Select Task__r.Deliverables__r.Project__r.Name, Task__r.Estimated_Hours__c,Task__r.Project__r.Name, Task__r.Deliverable_name__c, Task__r.Deliverables__r.Name , Task__r.Name , Actual_Hours__c, 	Task__r.Total_Hours_Logged__c , Billable__c , Comments__c FROM Timesheet_Detail__c  WHERE Timesheet__c =: timesheetId];
        System.debug('Timesheet Detail Entries::' + timesheet_detail );
        return  timesheet_detail;
     
    }
    
     public Timesheet__c gettimesheet()
    {
        Timesheet__c timesheet;
        System.debug('Timesheet ID::' + timesheetId );
        timesheet = [SELECT OwnerId, Timesheet_Date__c , Total_hours_logged__c from Timesheet__c where Id =: timesheetId LIMIT 1 ];
        System.debug('Timesheet Detail Entries::' + timesheet );
        OwnerId = timesheet.OwnerId;
        System.debug('Owner Id::' + OwnerId);
        return  timesheet;
     
    }
    
     public User getuser()
    {
        User user;
        System.debug('Owner ID::' + OwnerId );
        Timesheet__c timesheet = [SELECT OwnerId, Timesheet_Date__c , Total_hours_logged__c from Timesheet__c where Id =: timesheetId LIMIT 1 ];
        user = [Select Name , Manager.Name from User where Id =: timesheet.OwnerId LIMIT 1 ];
        System.debug('Timesheet Detail Entries::' +user );
        return  user;
     
    }

    
    public void testSystem(){
        
        system.debug('Testing');
    }
 
}