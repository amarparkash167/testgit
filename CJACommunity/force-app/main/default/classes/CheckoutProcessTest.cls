@isTest(seealldata = true)
Private class CheckoutProcessTest {

static testmethod void unitTest(){
     	//DateTime dt = system.now(); 
        test.startTest();
      	/*Krow__Invoice__c invoice = new Krow__Invoice__c();

    	invoice.Krow__Currency__c = 'Draft';*/
    	//invoice.Krow__Invoice_Total__c = 500;
    	//
    	Customer_Invoice__c invoice = new Customer_Invoice__c();
    	invoice.Currency__c = 'CAD';
        invoice.Invoice_Amount__c = 500;
    	insert invoice;
    
        CheckoutProcess checkout = new CheckoutProcess();  	
        //DateTime dt = datetime.now();
        //mdt.getTimeZoneValue();
        //  mdt.getLocalDateTime(dt);

        CheckoutProcess.getInvoice(invoice.id);
      	CheckoutProcess.getcreateCharge('100','test invoice','4242424242424242','111','2035', '11', 'USD', 'Test Description','Test Notes', invoice.id);
    	CheckoutProcess.getcreateCharge('100','test invoice','4242424242424242','11','2001', '11', 'USD', 'Test Description','Test Notes', invoice.id);
        CheckoutProcess.updateInvoice(invoice.id);
    	test.stopTest();
}

}