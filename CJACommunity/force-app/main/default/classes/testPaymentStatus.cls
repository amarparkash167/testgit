@istest
public class testPaymentStatus {
    @istest static void CreateAccount(){
        
        Account acc = new Account();
        acc.Name = 'CJA Test Account - AHAD';
        acc.Payment_status__c = 'Pending';
        
        insert acc;
       
        Project__c pro = new Project__c();
        pro.Name = 'CJA Test Project - AHAD';
        
        insert pro;
        
        AccountList.getAccount(acc.Id);
        AccountList.getProject(pro.Id);
    }

}