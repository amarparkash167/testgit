public class InvoiceNewEditCntr {
    
    @AuraEnabled public static Customer_Invoice__c CusInvoice {get; set;}
    @AuraEnabled public static CJ_Opportunity__c CJOpp {get; set;}
    @AuraEnabled public static InvoiceNewEditCntr classObj {get; set;}
    public static set<string> ExistingInvLIs;
    public InvoiceNewEditCntr(){}
    
    @AuraEnabled
    public static Customer_Invoice__c getInvoice(string invoiceId)
    {
        Customer_Invoice__c CustInvoice = new Customer_Invoice__c();
        if(invoiceId != null)
        {
            list<Customer_Invoice__c> lstInvoice = [SELECT Id, Amount__c,Currency__c,Balance_Amount__c,Invoice_Amount__c,Opportunity__c,
                                                    Status__c, notes__c, name, CJ_Opportunity__c,CJ_Opportunity__r.Name,
                                                    Tax_1__c, Tax_2__c, Tax_3__c, Tax_Amount_Percent_1__c, Tax_Amount_Percent_2__c,
                                                    Tax_Amount_Percent_3__c, Invoice_Date__c, Due_Date__c, Description__c, Billing_Contact__c, 
                                                    Account__c
                                                    FROM Customer_Invoice__c where id=: invoiceId];
            
            if(lstInvoice.size()>0)
                CustInvoice = lstInvoice[0];
           
                
        }
        
        return CustInvoice;
    }
    
    
    @AuraEnabled
    public static list<Invoice_Lineitem__c> getInvoiceLIs(string invoiceId)
    {
        list<Invoice_Lineitem__c> lstIli = new list<Invoice_Lineitem__c>();
        ExistingInvLIs = new set<string>();
        if(invoiceId != null)
        {
            lstIli = [select id, name, Amount__c, Description__c, Invoice__c from Invoice_Lineitem__c
                      where Invoice__c =: invoiceId order by createdDate ASC];
            
            if(lstIli.size() > 0){
                for(Invoice_Lineitem__c ili :lstIli)
                    ExistingInvLIs.add(ili.id);
            }
            system.debug('#ExistingInvLIs='+ExistingInvLIs);
            
        }
        if(lstIli.size() < 1)
        {
            Invoice_Lineitem__c ili = new Invoice_Lineitem__c();
            ili.Amount__c = 0.0;
            ili.Description__c='';
            lstIli.add(ili);
            
            
        }
        
        return lstIli;
    }
    
    
    @AuraEnabled
    public static string upsertInvoiceAndLineItems(Customer_Invoice__c inv, String ListInvoice, String RemListInvoice)//list<Invoice_Lineitem__c> Listli, list<Invoice_Lineitem__c> RemListli)
    {
     system.Debug(':: inv: '+ inv);
     system.Debug(':: inv.Invoice_Date__c: '+ inv.Invoice_Date__c);   
        /* Code added By Manisha */
        
        List<Invoice_Lineitem__c> Listli = new List<Invoice_Lineitem__c>();
        List<Invoice_Lineitem__c> RemListli = new List<Invoice_Lineitem__c>();
        System.debug('LIST LI::' + ListInvoice);
        System.debug('REM LIST LI::' + RemListInvoice);
        
        
        Type idArrType = Type.forName('List<Invoice_Lineitem__c>');
        if(ListInvoice != null)
        Listli = (List<Invoice_Lineitem__c>) JSON.deserialize(ListInvoice, idArrType);
        if(RemListInvoice != null)
        RemListli = (List<Invoice_Lineitem__c>) JSON.deserialize(RemListInvoice, idArrType);
         /* Code End here -  By Manisha*/
       
        System.debug('LIST ::' + Listli);
        System.debug('LIST Rem::' + RemListli);
        
        list<Invoice_Lineitem__c> listLIToUps = new list<Invoice_Lineitem__c>();
        list<Invoice_Lineitem__c> listToRemove = new list<Invoice_Lineitem__c>();
        system.debug('#inside save method==');
        string msg = 'Success';
        try{
            
            system.debug('inv='+inv);
            upsert inv;
            msg = inv.id;
        }
        Catch(AuraHandledException e)
        {
            msg = 'Error: ' + e.getMessage();
            system.debug('#inv update='+e.getMessage());
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
        
        if(Listli.size() > 0){
            for(Invoice_Lineitem__c li: Listli){
                li.invoice__c = inv.id;
                listLIToUps.add(li);
            }
        }
        
        if(RemListli !=null && RemListli.size() > 0)
        {
            getInvoiceLIs(inv.id);
            listToRemove = getRemoveLIs(RemListli);
        }
        system.debug('#Remove list='+listToRemove);
        
        if(listLIToUps.size()>0){
            try{
                upsert listLIToUps;
            }
            catch(AuraHandledException ex){
                msg = 'Error: ' + ex.getMessage();
                system.debug('#invLI update='+ex.getMessage());
                throw new AuraHandledException('Error: ' + ex.getMessage());
            }
        }
        
        if(listToRemove.size() > 0)
        {
            try
            {
                delete listToRemove;
            }
            catch(AuraHandledException e)
            {
                msg = 'Error: ' + e.getMessage();
                system.debug('#invLi delete='+e.getMessage());
                throw new AuraHandledException('Error: ' + e.getMessage());
            }
        }
        return msg;     
    }
    
    public static list<Invoice_Lineitem__c> getRemoveLIs(list<Invoice_Lineitem__c> lstLIs)
    {
        system.debug('##ExistingInvLIs='+ExistingInvLIs);
        list<Invoice_Lineitem__c> listToReturn = new list<Invoice_Lineitem__c>();
        for(Invoice_Lineitem__c li :lstLIs)
            if(li.id != null && ExistingInvLIs.contains(li.id))
            listToReturn.add(li);
        
        return listToReturn;
    }
    
}