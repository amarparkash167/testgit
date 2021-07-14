public class GenerateInvoiceSchedulable implements Schedulable{

    public void execute(SchedulableContext ctx) {
        
        System.debug('Generate Onstaff Invoice ');
		TimesheetCal.TimesheetCal();
        
    }        
    
}