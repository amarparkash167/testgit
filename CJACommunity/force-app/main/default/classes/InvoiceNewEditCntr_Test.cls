@isTest
private class InvoiceNewEditCntr_Test {
    
    static testMethod void unitTest1()
    {
        Account a = new account();
        a.Name = 'Test Customer';
        insert a;
        
        CJ_Opportunity__c opp = new CJ_Opportunity__c();
        opp.name = 'Test Opp';
        opp.Account__c = a.id;
        opp.StageName__c = '3. Discovery';
        insert opp;
        
        Customer_Invoice__c inv = new Customer_invoice__c();
        inv.CJ_Opportunity__c = opp.id;
        inv.Invoice_Date__c = date.today();
        inv.Due_Date__c = date.today().addDays(10);
        inv.Invoice_Amount__c = 1000;
        inv.Currency__c = 'CAD';
        insert inv;
        
        Invoice_Lineitem__c li1 = new Invoice_Lineitem__c();
        li1.Amount__c = 200;
        li1.Description__c = 'Test li1';
        li1.Invoice__c = inv.id;
        
        
        Invoice_Lineitem__c li2 = new Invoice_Lineitem__c();
        li2.Amount__c = 200;
        li2.Description__c = 'Test li1';
        li2.Invoice__c = inv.id;
        
        
        list<Invoice_Lineitem__c> listLi = new list<Invoice_Lineitem__c>();
        listLi.add(li1);
        //listLi.add(li2);
        insert listLi;
        
        list<Invoice_Lineitem__c> RemlistLi = new list<Invoice_Lineitem__c>();
        RemlistLi.add(li2);
        
        InvoiceNewEditCntr.getInvoice(inv.id);
        InvoiceNewEditCntr.getInvoiceLIs(inv.id);
        
        
        String ListInvoice= JSON.serialize(listli); 
        String RemListInvoice= JSON.serialize(RemlistLi); 
        
        InvoiceNewEditCntr.upsertInvoiceAndLineItems(inv, ListInvoice, RemListInvoice);
        
        PageReference pRef = Page.InvoicePDFVfpage1;
        pRef.getParameters().put('InvId', String.valueOf(inv.id));
        Test.setCurrentPage(pRef);
        InvoicePDFController1 obj = new InvoicePDFController1();
    }
    
    static testMethod void unitTest2()
    {
        Account a = new account();
        a.Name = 'Test Customer';
        insert a;
        
        CJ_Opportunity__c opp = new CJ_Opportunity__c();
        opp.name = 'Test Opp';
        opp.Account__c = a.id;
        opp.StageName__c = '3. Discovery';
        insert opp;
        
        Customer_Invoice__c inv = new Customer_invoice__c();
        inv.CJ_Opportunity__c = opp.id;
        inv.Invoice_Date__c = date.today();
        inv.Due_Date__c = date.today().addDays(10);
        inv.Invoice_Amount__c = 1000;
        inv.Currency__c = 'CAD';
        insert inv;
        
        list<Invoice_Lineitem__c> listLi = new list<Invoice_Lineitem__c>();
        list<Invoice_Lineitem__c> RemlistLi = new list<Invoice_Lineitem__c>();
        
        InvoiceNewEditCntr.getInvoice(inv.id);
        InvoiceNewEditCntr.getInvoiceLIs(inv.id);
        
         String ListInvoice= JSON.serialize(listli); 
        String RemListInvoice= JSON.serialize(RemlistLi); 
        
        InvoiceNewEditCntr.upsertInvoiceAndLineItems(inv, ListInvoice, RemListInvoice);
        //InvoiceNewEditCntr.upsertInvoiceAndLineItems(inv, listLi, RemlistLi);
        
        
    }
    
    static testMethod void unitTest3(){
        Account a = new account();
        a.Name = 'Test Customer';
        insert a;
        
        CJ_Opportunity__c opp = new CJ_Opportunity__c();
        opp.name = 'Test Opp';
        opp.Account__c = a.id;
        opp.StageName__c = '3. Discovery';
        insert opp;
        
        Customer_Invoice__c inv = new Customer_invoice__c();
        inv.CJ_Opportunity__c = opp.id;
        inv.Invoice_Date__c = date.today();
        inv.Due_Date__c = date.today().addDays(10);
        inv.Invoice_Amount__c = 1000;
        inv.Tax_1__c = 'tax 1';
        inv.Tax_2__c = 'tax 2';
        inv.Tax_3__c = 'tax 3';
        inv.Tax_Amount_Percent_1__c = 10;
        inv.Tax_Amount_Percent_2__c = 10;
        inv.Tax_Amount_Percent_3__c = 10;
        inv.Currency__c = 'CAD';
        insert inv;
        
        Invoice_Lineitem__c li1 = new Invoice_Lineitem__c();
        li1.Amount__c = 200;
        li1.Description__c = 'Test li1';
        li1.Invoice__c = inv.id;
        
        
        Invoice_Lineitem__c li2 = new Invoice_Lineitem__c();
        li2.Amount__c = 200;
        li2.Description__c = 'Test li1';
        li2.Invoice__c = inv.id;
        
        
        list<Invoice_Lineitem__c> listLi = new list<Invoice_Lineitem__c>();
        listLi.add(li1);
        //listLi.add(li2);
        insert listLi;
        
        list<Invoice_Lineitem__c> RemlistLi = new list<Invoice_Lineitem__c>();
        RemlistLi.add(li2);
        
        PageReference pRef = Page.InvoicePDFVfpage1;
        pRef.getParameters().put('InvId', String.valueOf(inv.id));
        Test.setCurrentPage(pRef);
        
        InvoicePDFController1 obj = new InvoicePDFController1();
    }
    
}