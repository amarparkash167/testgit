public class MissingTimesheetsBatchable implements Database.Batchable<sObject>, Database.Stateful{
    
    List<Id> todayTimesheetUsers = new List<Id>();
    List<Id> outOfOfficeUsers = new List<Id>();
    List<Timesheet__c> missingTimesheets = new List<Timesheet__c>();
    DateTime timeSheetDate;
    
    public MissingTimesheetsBatchable (DateTime tsDate) {
        timeSheetDate = tsDate;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        List<Timesheet__c> todayTimesheets = [SELECT OwnerId 
                                              FROM Timesheet__c 
                                              where Timesheet_Date__c =: timeSheetDate.Date()];
        for(Timesheet__c t : todayTimesheets){
            todayTimesheetUsers.add(t.OwnerId);
        }
        
        List<OutOfOffice> outOfOfficeList = [SELECT UserId 
                                                FROM OutOfOffice 
                                                where IsEnabled = true 
                                                and StartDate <=: timeSheetDate
                                                and endDate >=: timeSheetDate];
        for(OutOfOffice oo : outOfOfficeList){
            outOfOfficeUsers.add(oo.UserId);
        }
        
        String query = 'select id from user where timesheet_user__c = true and isactive = true and id not in: outOfOfficeUsers and id not in: todayTimesheetUsers';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        for(sObject s : scope){
            Id userId = s.Id;
            Datetime et1 = DateTime.newInstance(Date.Today(), Time.newInstance(0, 0, 0, 0));
        	String e=et1.format('EEEE');
        	System.debug('After conversion present day======'+et1);
            if (!(e =='Saturday' || e =='Sunday'))
            	missingTimesheets.add(Timesheet_Controller.createTimesheet(userId, timeSheetDate.Date()));
        }
        system.debug('missingTimesheets in execute==> ' + missingTimesheets);
    }
    
    public void finish(Database.BatchableContext BC){
        system.debug('missingTimesheets in finish==> ' + missingTimesheets);
        if(!missingTimesheets.isEmpty()){
            upsert missingTimesheets External_ID__c;
        }
        system.debug('missingTimesheets in finish==> ' + missingTimesheets);

    }

}