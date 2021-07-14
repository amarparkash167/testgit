public class GenerateOnStaffInvoiceSchedulable implements Schedulable{

    public void execute(SchedulableContext ctx) {
        
        System.debug('Generate Onstaff Invoice: Wishlist');
		TimesheetInvoice.generateWishListInvoices('Additional Cost');
        TimesheetInvoice.generateWishListInvoices('Yes');
        OnstaffInvoiceGeneration.generateOnstaffInvoice();
        
    }        
    
}