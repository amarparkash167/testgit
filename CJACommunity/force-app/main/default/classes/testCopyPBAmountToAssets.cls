@isTest
public class testCopyPBAmountToAssets {

   @isTest static void createTestRecords(){
    
        Account acc = new Account();
        acc.Name = 'Forthlane Financial Inc';
        insert acc;
        
        CJ_Opportunity__c CJOpp = new CJ_Opportunity__c();
        CJOpp.Name = 'Forthlane - FSC Setup';
        CJOpp.Close_Date__c = system.Today();
        CJOpp.Account__c = acc.Id;
        CJOpp.Amount__c = 234000;
        insert CJOpp;
        
        PriceBook2 pb = new PriceBook2();
        pb.Name = 'Standard Price Book';
        pb.IsActive = True;
        insert pb;
        
        Contract contr = new Contract();
        contr.Status = 'Draft';
        contr.AccountId = acc.Id;
        contr.Opportunity__c = CJOpp.Id;
        contr.Pricebook2Id = Test.getStandardPricebookId();
        contr.StartDate = system.today() - 80;
        contr.ContractTerm = 2;
        contr.Contract_Renewal__c = system.today()-80;
        contr.Contract_Renewal_Term_Months__c = 2;
        contr.Subscription_Billing_Date__c = system.today()-40;
        contr.Subscription_Billing_Frequency__c = 1;
        contr.Next_Billing_Contract_Date__c = system.today()-20;
        contr.Subscription_Fees_Monthly__c = 250;
        insert contr;
        
        
        Product2 pro = new Product2();
        pro.name = 'Silver Plan - Admin Role';
        pro.IsActive = True;
        insert pro;
        
        PriceBookEntry pbe = new PriceBookEntry();
        pbe.priceBook2Id = Test.getStandardPricebookId();
        pbe.Product2Id = pro.Id;
        pbe.UnitPrice = 150;
        pbe.UseStandardPrice = false;
        insert pbe;
        
        Asset asset = new Asset();
        asset.Name = 'Silver Plan - Admin Role';
        asset.contract__c = contr.id;
        asset.AccountId = acc.Id;
        asset.Product2Id = pro.Id;
        insert asset;
    }
}