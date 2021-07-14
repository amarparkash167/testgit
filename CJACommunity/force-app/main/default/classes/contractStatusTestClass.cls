/* test class for contractStatusCheck trigger*/

@isTest
public class contractStatusTestClass 
{   
    //this method tests that when one active contract exists, the other cant be marked active
    @isTest static void contractFail() 
    {
        Account accFail = new Account();
        accFail.Name = 'accFail';
        insert accFail;
        
        //contract to be failed
        Contract conFail = new Contract();
        conFail.Status = 'Draft';
        conFail.Product_Plan__c = 'Silver';
        conFail.StartDate = Date.newInstance(2021,03,09);
        conFail.ContractTerm = 2;
        conFail.AccountId = accFail.Id;
        
        //creating an active contract first so the trigger gives error on creating another active contract
        Contract conActive = new Contract();
        conActive.Status = 'Draft';
        conActive.Product_Plan__c = 'Silver';
        conActive.StartDate = Date.newInstance(2021,02,09);
        conActive.ContractTerm = 3;
        conActive.AccountId = accFail.Id;
        
        //inserting contract as draft since we cant create a contract as active
        insert conActive;
        //updating the contract to active to test the trigger.
        conActive.Status = 'Activated';
        update conActive;
        insert conFail;
 
        Test.startTest();
        conFail.Status = 'Activated';
        update conFail;
        Test.stopTest();
    }
    
    
    //testing that the contract does not give any errors when only one active contract exist
    @isTest static void contractPass()
    {
        
        Account accPass = new Account();
        accPass.Name = 'accPass';
        insert accPass;
        
        Contract conPass = new Contract();
        conPass.Status = 'Draft';
        conPass.Product_Plan__c = 'Silver';
        conPass.StartDate = Date.newInstance(2021,02,09);
        conPass.ContractTerm = 2;
        conPass.AccountId = accPass.Id;
        insert conPass;
        
        Test.startTest();
        conPass.Status = 'Activated';
        update conPass;
        Test.stopTest();
           
        
    }
    
    //in the case of data loading if no active contracts exist and while updating, sf user tries to make two contracts active
    //then only one contract is allowed to be activated and for the other, an error is shown
    @isTest static void contractPartialPass()
    {
        Account acc = new Account();
        acc.Name = 'partialPass';
        insert acc;
        
        Contract conPassed = new Contract();
        conPassed.Product_Plan__c = 'Silver';
        conPassed.AccountId = acc.Id;
        conPassed.Status = 'Draft';
        conPassed.StartDate = Date.newInstance(2021,02,09);
        conPassed.ContractTerm = 2;
        
        Contract conFailed = new Contract();
        conFailed.Product_Plan__c = 'Silver';
        conFailed.AccountId = acc.Id;
        conFailed.Status = 'Draft';
        conFailed.StartDate = Date.newInstance(2021,03,10);
        conFailed.ContractTerm = 3;
        
        //inserting both contracts
        insert conPassed;
        insert conFailed;
        
        Test.startTest();
        conPassed.Status = 'Activated';
        conFailed.Status = 'Activated';
        update conPassed;
        update conFailed;  
        Test.stopTest();
    }
}