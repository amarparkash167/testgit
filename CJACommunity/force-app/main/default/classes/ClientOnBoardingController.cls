public class ClientOnBoardingController {
    
    public class objectsWrapper
    {
        @AuraEnabled Account acc {get; set;}
        @AuraEnabled Contact con {get; set;}
        @AuraEnabled Opportunity opp {get; set;}
        //@AuraEnabled List<String> subjects {get; set;}
        
        //public objectsWrapper(Account a, Contact c, Opportunity o, List<String> s)
        public objectsWrapper(Account a, Contact c, Opportunity o)
        {
            this.acc = a;
            this.con = c;
            this.opp = o;
            //this.subjects = s;
        }
    }
    
    @AuraEnabled
    public static objectsWrapper initializeObjects()
    {
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Task.Subject.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for( Schema.PicklistEntry pickListVal : ple){
      pickListValuesList.add(pickListVal.getLabel());
    } 
        //return new objectsWrapper(new Account(), new Contact(), new CJ_Opportunity__c(), pickListValuesList);
        return new objectsWrapper(new Account(), new Contact(), new Opportunity());
    }
    
     @AuraEnabled
    public static Map<String,String> getOpportunityRecordTypes()
    {
        Map<String,String> recordTypeMap = new Map<String,String>();
        Schema.DescribeSObjectResult R = Opportunity.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
        
        for(RecordType rec : [SELECT Id,  Name, DeveloperName, Description FROM RecordType WHERE SobjectType = 'Opportunity']) {
            recordTypeMap.put(rec.Id, rec.Name);
            system.debug('recordtype' + recordtypemap);
        }
        return recordTypeMap;
    }   

    
    
    
    
    
    
    /*@AuraEnabled
    public static List<String> getStages()
    {
        List<String> pickListValuesList= new List<String>();
    Schema.DescribeFieldResult fieldResult = CJ_Opportunity__c.StageName__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for( Schema.PicklistEntry pickListVal : ple){
      pickListValuesList.add(pickListVal.getLabel());
    }     
    return pickListValuesList;
    }
*/
     
    @AuraEnabled
    /*public static String createClientRecords(String accountName, 
                                             String contactFirstName, 
                                             String contactLastName, 
                                             String opportunityName,
                                             String selectedStage,
                                             Date opportunityCloseDate
                                             )
*/
    
    
    
    
    public static String createClientRecords(Account account, 
                                             Contact contact,
                                             Opportunity opportunity,
                                             String selectedSubject,
                                             String description
                                             )
    {
        system.debug('Account Name = ' + account);
        system.debug('Contact Name = ' + contact);
        system.debug('Opportunity Name = ' + opportunity);
        //Account acc = new Account();
        //acc.Name = account.Name;
        try
        {
            insert account;
        } 
        catch (Exception e) 
        {
            system.debug('Error = ' + e.getMessage());
            return e.getMessage();
        }
        
        //Contact con = new Contact(FirstName = contact.FirstName, LastName = contact.LastName, AccountId = acc.Id);
        contact.AccountId = account.Id;
        opportunity.AccountId = account.Id;
        opportunity.Referring_AE__c = account.Current_AE__c;
       //----created by ariba opportunity.RecordTypeId = 
        Task tsk = new Task(Subject = selectedSubject, Description = description);
        system.debug('Task ===> ' + tsk);
        
        //CJ_Opportunity__c opp = new CJ_Opportunity__c(Name = opportunityName, Account__c = acc.Id, StageName__c = selectedStage, Close_Date__c = opportunityCloseDate);
        try
        {
            insert contact;
            insert opportunity;
            tsk.Subject = selectedSubject;
            tsk.Description = description;
            tsk.WhatId = opportunity.Id;
            tsk.Status = 'Completed';
            tsk.ActivityDate = date.today();
            insert tsk;
            
        } 
        catch (Exception e) 
        {
            system.debug('Error = ' + e.getMessage());
            return e.getMessage();
        }
        return 'Success!' + account.Id;
    }
}