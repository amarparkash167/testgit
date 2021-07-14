public class MissingTimesheetsSchedulable implements Schedulable{
    public void execute(SchedulableContext ctx) {
        
        datetime todayDateTime = datetime.now() ;
        Datetime et1 = DateTime.newInstance(Date.Today(), Time.newInstance(0, 0, 0, 0));
        String e=et1.format('EEEE');
        System.debug('After conversion present day======'+et1);
        
        
        
        System.debug('No of times it execute::' + et1);
        MissingTimesheetsBatchable b = new MissingTimesheetsBatchable(todayDateTime);
        Database.executeBatch(b, 50);
        
        
        
        
    }        
    
}