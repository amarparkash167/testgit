@isTest
public class GenerateInvoiceSchedulable_Test{
    public static TestMethod void testschedule() {
    
        Test.StartTest();
        GenerateInvoiceSchedulable sh1 = new GenerateInvoiceSchedulable(); 
        GenerateOnStaffInvoiceSchedulable sh2 = new GenerateOnStaffInvoiceSchedulable();
        String sch = '0 0 23 * * ?';
                system.schedule('Test check', sch, sh1);
        String sch1 = '0 0 21 * * ?';
                system.schedule('Onstaff Test', sch1, sh2);
        
        Test.stopTest();
    
    }
}