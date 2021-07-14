public class AccountList {

    @AuraEnabled
    public static Account getAccount(string AccountId)
    {
        system.debug(AccountId);
        Account acc = new Account();
        if(AccountId != null)
        {
            list<Account> lstAccount = [SELECT Id,Name,Payment_status__c FROM Account where id=: AccountId];
            
            if(lstAccount.size()>0)
                acc = lstAccount[0];
           
                
        }
        system.debug(acc);
        return acc; 
}

@AuraEnabled
    public static Project__c getProject(string ProjectId)
    {
        system.debug(ProjectId);
        Project__c pro = new Project__c();
        if(ProjectId != null)
        {
            list<Project__c> lstProject = [SELECT Id,Name,Payment_status__c FROM Project__c where id=: ProjectId];
            
            if(lstProject.size()>0)
                pro = lstProject[0];
           
                
        }
        system.debug(pro);
        return pro;
    }
}