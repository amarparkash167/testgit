@IsTest
public class OnstaffInvoiceGeneration_Test {
    //Custom MetaData Type Date
    Public static Custom_Invoice__mdt datesMDT = [Select id, label, From__c, To__c, Invoice_Due_Date__c from Custom_Invoice__mdt where MasterLabel = 'Custom Invoice' limit 1 ];    
    
    //First of This Month
    public static Date ThisMonth = datesMDT.To__c;
    
    //First of Previous Month
    public static Date LastMonth = datesMDT.From__c;
    
    @IsTest
    public static void Onstaff_InvoiceGeneration() {
        
        System.debug('From Date:: '+ThisMonth);
        System.debug('To Date:: '+LastMonth);
        System.debug('Invoice Due Date:: '+datesMDT.Invoice_Due_Date__c);
        
        // Product
        Product2 prod = new Product2();
        prod.Name = 'Salesforce Admin Time - Silver';
        prod.Free_Hours_per_Role__c = 3;
        prod.Product_Plan__c = 'Silver';
        prod.Product_Role__c = 'Admin';
        prod.IsActive = true;
        prod.ProductCode = 'Standard';
        prod.Frequency_Month_per_Role__c = 1;
        insert prod;
        
        System.debug('ProductID:: '+prod.Id);
        
        // Creating PriceBook Entry
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            IsActive = True,
            UnitPrice = 120
        );
        insert pbe;
        
        System.debug('PriceBookEntryID:: '+pbe.Id);
        
        // Creating Account
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        // Creating Account2
        Account acc1 = new Account();
        acc1.Name = 'Test Account 2';
        acc1.cjaInvoice__Credit_Card_Authorization_Status__c = 'Inactive';
        insert acc1;
        
        System.debug('AccountID:: '+acc.Id);
        
        // Creating Contact
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact 2';
        con.AccountId = acc.Id;
        con.RecordTypeId = Schema.sobjectType.Contact.getRecordTypeInfosByDeveloperName().get('Standard_Contact').getRecordTypeId();
        insert con;
        
        // Creating Contact
        Contact con1 = new Contact();
        con1.FirstName = 'Test';
        con1.LastName = 'Contact 2';
        con1.AccountId = acc.Id;
        con1.RecordTypeId = Schema.sobjectType.Contact.getRecordTypeInfosByDeveloperName().get('Standard_Contact').getRecordTypeId();
        insert con1;
        
        System.debug('ContactID:: '+con.Id);
        
        // Updating Account
        acc.cjaInvoice__Billing_Contact__c = con.Id;
        update acc;
        
        // Updating Account
        acc1.cjaInvoice__Billing_Contact__c = con1.Id;
        update acc1;
        
        System.debug('AccountID Updated:: '+acc.Id);
        
        // Contract
        Contract cont = new Contract();
        cont.AccountId = acc.Id;
        cont.Name = 'Test cont';
        cont.Status = 'Draft';
        cont.Subscription_Billing_Frequency__c = 3;
        cont.Subscription_Billing_Date__c = ThisMonth.addMonths(-3);
        cont.Usage_Billing_Date__c = ThisMonth;
        cont.Product_Plan__c = 'Silver';
        cont.Pricebook2Id = Test.getStandardPricebookId();
        insert cont;
        
        cont.status = 'Activated';
        update cont;
        
        System.debug('Contract Updated:: '+cont.Id);
        
        // Contract
        Contract cont1 = new Contract();
        cont1.AccountId = acc1.Id;
        cont1.Name = 'Test cont';
        cont1.Status = 'Draft';
        cont1.Subscription_Billing_Frequency__c = 3;
        cont1.Subscription_Billing_Date__c = ThisMonth.addMonths(-3);
        cont1.Usage_Billing_Date__c = ThisMonth;
        cont1.Product_Plan__c = 'Silver';
        cont1.Pricebook2Id = Test.getStandardPricebookId();
        insert cont1;
        
        cont1.status = 'Activated';
        update cont1;
        
        //Subscription
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__ListPrice__c = 100.00;
        sub.SBQQ__Account__c = acc1.Id;
        sub.SBQQ__Contract__c = cont1.Id;
        sub.SBQQ__Quantity__c = 1.00;
        sub.SBQQ__Product__c = prod.Id; 
        sub.Free_Hours_per_Role__c = 5;  
        sub.PurchaseDate__c = Date.newInstance(2021,6,1);  
        insert sub;
        
        //Asset
        Asset aset = new Asset();
        aset.Name = 'Test Account Asset';
        aset.AccountId = acc1.Id;
        aset.Contract__c = cont1.Id;
        aset.Product2Id = prod.Id;
        aset.Product_Plan__c = prod.Product_Plan__c; 
        aset.Product_Role__c = prod.Product_Role__c; 
        aset.Free_Hours_per_Role__c = 5;  
        aset.PurchaseDate = Date.newInstance(2021,6,1);  
        insert aset;
        
        System.debug('Contract1 Updated:: '+cont1.Id);
        
        System.debug('ContractID:: '+cont.Id);
        
        List<Contract> listofContract = [SELECT Id, AccountId, Project__c, Subscription_Fees_Monthly__c,Pricebook2Id, Product_Plan__c, Subscription_Billing_Renewal_Date__c, Subscription_Billing_Frequency__c, Subscription_Billing_Date__c, Account.cjaInvoice__Billing_Contact__c, Usage_Billing_Date__c, Frequency__c FROM Contract WHERE Subscription_Billing_Renewal_Date__c = :datesMDT.To__c AND Status = 'Activated'];
        
        System.debug('List of Subscription Contracts Test Class::' + listofContract);
        
        
        //Query to fetch Actual hours, Deliverable, Project, OnStaff Contract, Deliverable's Asset Hourly Rate with Filters
        List<Asset> listofAssets = [SELECT Product2.Name, Product_Role__c, PurchaseDate, Free_Hours_per_Role__c, Utilised_Hours__c
                                    , Contract__c, Product_Plan__c, AccountID, Account.cjaInvoice__Billing_Contact__c, 
                                    Contract__r.Frequency__c, Id, Hourly_Rate_per_role__c, Contract__r.Subscription_Billing_Frequency__c,
                                    Contract__r.Subscription_Billing_Date__c, Contract__r.Usage_Billing_Date__c
                                    ,Contract__r.Subscription_Billing_Renewal_Date__c, Contract__r.Account.Name 
                                    FROM Asset  
                                    WHERE Contract__r.status = 'Activated' 
                                    AND  Contract__r.Usage_Billing_Date__c = :datesMDT.To__c];
        
        System.debug('List of Assets Test Class::' + listofAssets);
        
        //Query to fetch Subscription
        List<SBQQ__Subscription__c> ListofSubscription = [SELECT Id, SBQQ__Product__r.Name, SBQQ__Product__r.Product_Role__c, SBQQ__Contract__c, SBQQ__Account__c, SBQQ__Account__r.cjaInvoice__Billing_Contact__c, 
                                                          SBQQ__Contract__r.Frequency__c, SBQQ__Contract__r.Subscription_Billing_Frequency__c, SBQQ__Contract__r.Usage_Billing_Date__c, Product_Role__c,
                                                          SBQQ__Contract__r.Subscription_Billing_Renewal_Date__c, SBQQ__Contract__r.Account.Name, SBQQ__ListPrice__c, PurchaseDate__c,
                                                          SBQQ__Subscription__c.Free_Hours_per_Role__c      
                                                          FROM SBQQ__Subscription__c 
                                                          WHERE SBQQ__Contract__r.status = 'Activated' 
                                                          AND SBQQ__Contract__r.Usage_Billing_Date__c = :datesMDT.To__c
                                                          AND SBQQ__Product__r.Product_Role__c != null];
        
        System.debug('List of Subscription Test Class::' + ListofSubscription);
        
        //Query Profile 
        Profile pro= [Select Id, Name from Profile Where Name='System Administrator' limit 1];
        System.debug('ProfileID:: '+pro.Id);
        
        // User aka Resource
        User user_1=new User(
            IsActive=true,
            Alias='Abbey',
            Email= 'abcTest_Timesheet@gmail.com',
            ProfileId = pro.Id,
            LastName= 'Kumari' ,
            Username= 'def'+'@naqwi.com',
            TimeZoneSidKey='America/Los_Angeles',
            LanguageLocaleKey= 'en_US',
            LocaleSidKey = 'en_GB', 
            EmailEncodingKey='UTF-8'
        );
        Insert user_1; 
        
        System.debug('UserID:: '+user_1.Id);
        
        
        Id RecordType = Schema.SObjectType.Issue__c.getRecordTypeInfosByDeveloperName().get('Customer_Issue').getRecordTypeId();
        
        
        // Ticket Record
        Issue__c ticket_1 = new Issue__c(
            Name__c = 'Test Ticket - 3-09-2020',
            Customer_Account__c = acc1.Id,
            Email__c = 'abcTest_Ticket@gmail.com',
            Admin_Hourly_Rate_M__c = 100.00, 
            Consultant_Hourly_Rate_Manual__c = 200.00, 
            Architect_Hourly_Rate_Manual__c = 300.00,
            In_Scope__c = 'Yes',
            RecordTypeId = RecordType,
            Rate_Type__c = 'Manual'
            
        );
        insert ticket_1;
        
        System.debug('TicketID:: '+ticket_1.Id);
        
        //Task Record
        Task__c task_1= new Task__c(
            Name='Task-One',
            Ticket__c = ticket_1.Id,
            RecordTypeId= Schema.sobjectType.Task__c.getRecordTypeInfosByName().get('Sub Task').getRecordTypeId(),
            Resource__c = user_1.id
        );
        insert task_1;
        
        System.debug('TaskID:: '+task_1.Id);
        
        // Timesheet Record
        datetime dt= system.now();
        Timesheet__c timesheet_1= new Timesheet__c(
            Name= 'Wasim Akram - 23-11-2018',
            Timesheet_Date__c = ThisMonth.addDays(-10),
            Approval_Status__c = 'Approved',
            External_ID__c = dt.format('YYYY-MM-dd')+'|'+userinfo.getuserId()
        );
        insert timesheet_1;
        
        System.debug('TimesheetID:: '+timesheet_1.Id);
        
        
        //Timesheet Entry Record
        System.debug('Timesheet In Test Class::' + timesheet_1);
        Timesheet_Detail__c timesheetDetail_1 = new Timesheet_Detail__c(
            Timesheet__c = timesheet_1.Id,
            Actual_Hours__c = 1,
            Task__c = task_1.Id,
            billable__c = true,
            skill_Type__c = 'Admin'
        );
        insert timesheetDetail_1;
        
        System.debug('TimesheetEntryID:: '+timesheetDetail_1.Id);
        
        
        //Query to fetch Actual hours, Deliverable, Project, OnStaff Contract, Deliverable's Asset Hourly Rate with Filters
        List<Timesheet_Detail__c> listofTimesheetEntries = [SELECT  task__r.ticket__r.Name, Actual_Hours__c,  
                                                            task__r.Ticket__r.Customer_Account__c,
                                                            task__r.Ticket__r.Customer_Account__r.Name
                                                            ,Task__r.Ticket__r.Customer_Account__r.cjaInvoice__Billing_Contact__c, 
                                                            Skill_Type__c, Task__r.Ticket__c 
                                                            FROM Timesheet_Detail__c 
                                                            WHERE Actual_Hours__c > 0 
                                                            AND Skill_Type__c !=null
                                                            AND Task__r.Ticket__r.RecordTypeId =: RecordType
                                                            AND Task__r.Ticket__c != null 
                                                            AND Timesheet__r.Timesheet_Date__c >= :datesMDT.From__c
                                                            AND Timesheet__r.Timesheet_Date__c < :datesMDT.To__c 
                                                            AND billable__c = TRUE];
        
        
        System.debug('List of Timesheet Details::' + listofTimesheetEntries );
        
       // OnstaffInvoiceGeneration.generateOnstaffInvoice();
        OnstaffInvoiceGenerationbySubscription.generateOnstaffInvoice();
    }
}