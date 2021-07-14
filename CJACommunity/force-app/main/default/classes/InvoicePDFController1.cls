//Primary controller for the Invoice PDF

public class InvoicePDFController1 {
    
    public Map<Customer_Invoice__c , List<Invoice_Lineitem__c> > InvoiceLITMapLinetems{get;  set;}
    public List<Invoice_Lineitem__c> InvoiceLines {get;set;}
    public List<Payment_Transaction__c> PaymentTransaction {get;set;}
    public list<Invoice_Tax__c> listOfTaxes {get; set;}
    
    public Customer_Invoice__c[]  Invoice{get; set;}
    public Decimal InvoieLineTotal{get;  set;}
    public Date dates {get;set;}
    public String dat{get;set;}
    public String CJAddress {get;set;}
    public Decimal Tax1Amount{get;set;}
    public Decimal Tax2Amount{get;set;}
    public Decimal Tax3Amount{get;set;}
    
    public string dispBankData {get;set;}
    
    public InvoicePDFController1 (){
        try{
            CJAddress =Label.CJA_Address; 
            String InvoiceId= '';
            Tax1Amount = 0.0;
            Tax2Amount = 0.0;
            Tax3Amount = 0.0;
                
            InvoiceId= apexpages.currentPage().getParameters().get('InvId');
          
            InvoiceLines = new List<Invoice_Lineitem__c>();
            
            system.Debug('::Invoice Id: '+ InvoiceId);
            
            Invoice = new  Customer_Invoice__c[]{};
                
            Invoice=[Select id, name, Amount__c,CJ_Opportunity__c,CJ_Opportunity__r.Account_Address__c,CJ_Opportunity__r.Account_Name__c,Total_Line_Item_Amount__c,Amount_Paid_Rollup__c,
                     CreatedById,Currency__c,Balance_Amount__c,Description__c,Due_Date__c,Invoice_Amount__c,Invoice_Date__c,Notes__c,Opportunity__c,Status__c, createddate,
                     Tax_1__c,Tax_2__c,Tax_3__c,Tax_Amount_Percent_1__c,Tax_Amount_Percent_2__c,Tax_Amount_Percent_3__c from Customer_Invoice__c where id=:InvoiceId];
            
            InvoiceLines= [Select id, name, Amount__c,Description__c,Invoice__c from Invoice_Lineitem__c where Invoice__c =:InvoiceId];
            
            PaymentTransaction =[Select id,name,Amount_Paid__c,Customer_Invoice__c,Mode_of_Payment__c,Notes__c,Payment_Date__c,Reference_Number__c,Status__c from Payment_Transaction__c where Customer_Invoice__c =:InvoiceId];
            
            listOfTaxes = [select id, name, Tax__r.name, Amount__c, TaxPercent__c from Invoice_Tax__c where Customer_Invoice__c =:InvoiceId];
            
            system.Debug('::InvoiceLines: '+ InvoiceLines);
            
            if(Invoice[0].Tax_Amount_Percent_1__c != null)
                Tax1Amount = (Invoice[0].Total_Line_Item_Amount__c * Invoice[0].Tax_Amount_Percent_1__c)/100;
            if(Invoice[0].Tax_Amount_Percent_2__c != null)
                Tax2Amount = (Invoice[0].Total_Line_Item_Amount__c * Invoice[0].Tax_Amount_Percent_2__c)/100;
            if(Invoice[0].Tax_Amount_Percent_3__c != null)
                Tax3Amount = (Invoice[0].Total_Line_Item_Amount__c * Invoice[0].Tax_Amount_Percent_3__c)/100;
            
            if(Invoice.size() > 0){
                DateTime dt = Invoice[0].createdDate;
                dates = date.newinstance(dT.year(), dT.month(), dT.day());
                
                dat = dT.month()+ '-' + dT.day()+ '-' +dT.year();
            }
        }
        catch(Exception Ex){
            system.Debug('::Exception LineNumber: '+ex.getLineNumber());
            system.Debug('::Exception Message: ' +ex.getMessage());
            system.Debug('::Exception Cause: '+ex.getCause());
            system.Debug('::Exception Type Name:  '+ex.getTypeName());
        }
    }
}