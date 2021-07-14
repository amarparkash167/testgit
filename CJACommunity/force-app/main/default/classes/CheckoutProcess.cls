/*
@Name             : CheckoutProcess
@Author           : M Hamza Siddiqui @ CloudJunction
@Date             : 29 June, 2018
@Description      : This class is processing checkout with Stripe Payments.
@Parameters		  : All parameters should be of type STRING                      
*/
public class CheckoutProcess
{        
    public CheckoutProcess(){}

    //Invoice
    @AuraEnabled
    public static List<SObject> getInvoice(String invoiceId){
        /*List<SObject> invoice = [SELECT Id, Krow__Invoice_Total__c,Currency__c, Krow__Total_Tax_Amount__c, Krow__Status__c FROM Krow__Invoice__c where id=: invoiceId];
        */
        List<SObject> invoice = [SELECT Id, Amount__c,Currency__c,Balance_Amount__c,Invoice_Amount__c,Opportunity__c,Status__c, notes__c, Description__c, name, 
                                 			CJ_Opportunity__c,CJ_Opportunity__r.Name
                                 			FROM Customer_Invoice__c where id=: invoiceId];
        system.debug('Invoice ::'+invoice);
        return invoice;
    }
    
    //Update Invoice
    @AuraEnabled
    public static String updateInvoice(String invoiceId){        
        /*Krow__Invoice__c invoice = new Krow__Invoice__c();
        invoice.Id = invoiceId;
        invoice.Krow__Status__c = 'Paid';
        update invoice;*/
      	
        Customer_Invoice__c invoice = new Customer_Invoice__c();
        invoice.Id = invoiceId;
        invoice.Status__c = 'Paid';
        update invoice;
        return 'Success';
    }
    
    //CreateCharge
    //Parameters:card_number, exp_year, exp_month, cvc, amount, currency, description
    @AuraEnabled
    public static String getcreateCharge(string amount,String holderName,String card,String cvv,String year, String month, String curr, String description, string notes, string invoiceId){
        String DataToReturn;
        String Secret_Key = Label.StripeKey; //'sk_test_JXMctr4Q53Zev5QYDUrNsVUX'; // Replace it with Live_Key
    	Stripe request = new Stripe(Secret_Key);
        Payment_Transaction__c ptn = new Payment_Transaction__c();
        ptn.Amount_Paid__c = decimal.valueOf(amount);
        ptn.Mode_of_Payment__c = 'Credit Card';
        ptn.Payment_Date__c = date.today();
        ptn.Notes__c = notes;
        ptn.Customer_Invoice__c = invoiceID;
        ptn.Card_Holder_Name__c = holderName;
        StripeResponseModel response = request.createCharge(card, year, month, cvv, amount+'00', curr, description);
        if(!response.isError){
            //system.debug('Transaction ID :: ' + response.id);
            //system.debug('Transaction Fee :: ' + response.fee);
            ptn.Reference_Number__c = response.id;
            ptn.Status__c = 'Successful';
            DataToReturn = 'SUCCESS';
        }else{
            system.debug('Error Message :: ' + response.errorResponse.message);
            ptn.Status__c = 'Failed';
            DataToReturn = response.errorResponse.message;
            throw new AuraHandledException(response.errorResponse.message);
        }
        try{
            insert ptn;
        }
        catch(exception e)
        {
            system.debug('ptn insert exc::'+e.getMessage());
        }
        return DataToReturn;
    }
    
    /*
    //Create Customer
    //Parameters : card_number,exp_month,exp_year,cvc,name,addressLine1,addressLine2,zip,state,country,email,description
    public void createCustomer(){
        
        StripeResponseModel response = request.createCustomer('4242424242424242', '10','2023', '123', 'Aslam', '', '', '', '', 'PK', 'mhamzasite@gmail.com', 'test');
        if(!response.isError){
            system.debug('Customer ID :: ' + response.id);
        }else{
            system.debug('Error Message :: ' + response.errorResponse.message);
        }
    }
    //Create charge using customer
   	//Parameters: customerId, amount, currency,description
	public void createCustomerCharge(){    
        
        StripeResponseModel response = request.createCharge('cus_EPTWuvf7EXDb4g', '2000', 'usd', 'testing');
        if(!response.isError){
            system.debug('Transaction ID :: ' + response.id);
            system.debug('Transaction Fee :: ' + response.fee);
        }else{
            system.debug('Error Message :: ' + response.errorResponse.message);
        }
    }
    //RetrieveCustomer
    // Parameters: customerId    
    public void retrieveCustomer(){    
        
        StripeResponseModel response = request.retrieveCustomer('cus_D8aUdsTzmUQW5V');
        if(!response.isError){
            system.debug('Customer Country :: ' + response.card.country);
            system.debug('Customer Last4 CC :: ' + response.card.last4);
        }else{
            system.debug('Error Message :: ' + response.errorResponse.message);
        }
    }
    //CreateInvoice
    //Parameters: customerId, amount, currency,description
    public void createInvoice(){
        
        StripeResponseModel response = request.createInvoice('cus_EPTWuvf7EXDb4g', '2000', 'usd', 'test');
        if(!response.isError){
            system.debug('Invoice Id :: ' + response.id);
        }else{
            system.debug('Error Message :: ' + response.errorResponse.message);
        }
    }
    // RetrieveInvoice
    // Parameter : InvoiceId
    public void retrieveInvoice(){
        
        StripeResponseModel response = request.retreiveInvoice('ii_W19Xp6cxrqVABH');
        if(!response.isError){
            system.debug('Invoice Date :: ' + response.created);
        }else{
            system.debug('Error Message :: ' + response.errorResponse.message);
        }
    }
    // CreatePlan
    // Parameters: Name,Amount,Currency,Interval,PlanLabel
    public void createPlan(){
        
        StripeResponseModel response = request.createPlan('AMX_101', '2000', 'usd', 'month' , 'AMX Testing');
        if(!response.isError){
            system.debug('Plan Id :: ' + response.id);
        }else{
            system.debug('Error Message :: ' + response.errorResponse.message);
        }
    }
    // RetreivePlan
    // Parameter: PlanId
    public void retrievePlan(){
        
        StripeResponseModel response = request.retrievePlan('AMX_101');
        if(!response.isError){
            system.debug('Plan Label :: ' + response.name);
        }else{
            system.debug('Error Message :: ' + response.errorResponse.message);
        }
    }
*/
}