@IsTest
public class TestTimesheetCal {
    
    //Custom MetaData Type Date
    Public static Custom_Invoice__mdt datesMDT = [Select id, label, From__c, To__c, Invoice_Due_Date__c from Custom_Invoice__mdt where MasterLabel = 'Custom Invoice' limit 1 ];    
    
    //First of This Month
    public static Date ThisMonth = datesMDT.To__c;
    
    //First of Previous Month
    public static Date LastMonth = datesMDT.From__c;
    
    @isTest
    public static void TimesheetCal(){
        
        // Creating Data
        // Creating PriceBook
        // PriceBook2 pb = new PriceBook2(
        //Name= 'Premium PriceBook',
        //Description = 'Testing PriceBook',
        //IsStandard = True
        //);
        //insert pb;
        
        //System.debug('PriceBookID:: '+pb.Id); 
        
        System.debug('From Date:: '+ThisMonth);
        System.debug('To Date:: '+LastMonth);
        System.debug('Invoice Due Date:: '+datesMDT.Invoice_Due_Date__c);
        
        // Product
        Product2 prod = new Product2();
        prod.Name = 'Salesforce Admin Time - Silver';
        prod.Free_Hours_per_Role__c = 3;
        prod.Product_Plan__c = 'Silver';
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
        con.RecordTypeId = Schema.sobjectType.Contact.getRecordTypeInfosByName().get('Standard Contact').getRecordTypeId();
        insert con;
        
        // Creating Contact
        Contact con1 = new Contact();
        con1.FirstName = 'Test';
        con1.LastName = 'Contact 2';
        con1.AccountId = acc.Id;
        con1.RecordTypeId = Schema.sobjectType.Contact.getRecordTypeInfosByName().get('Standard Contact').getRecordTypeId();
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
        
        System.debug('Contract1 Updated:: '+cont1.Id);
        
        System.debug('ContractID:: '+cont.Id);
        
        // Creating Project
        Project__c proj1= new Project__c(
            Name= 'Project-One',
            Account__c = acc.Id,
            Complexity_Level__c='High',
            OnStaff_Contract__c = cont.id,
            Profitability__c = 'Medium',
            RecordTypeId = Schema.sobjectType.Project__c.getRecordTypeInfosByDeveloperName().get('OnStaff_Admin').getRecordTypeId(),
            Project_Start_Date__c = date.newInstance(2020, 7, 18)
        );
        insert proj1;
        
        System.debug('ProjectID:: '+proj1.Id);
        
        // Asset
        Asset ass = new Asset();
        ass.Name = 'Test';
        ass.Hourly_Rate_per_role__c = 50;
        ass.Free_Hours_per_Role__c = 3;
        ass.Contract__c = cont.id;
        ass.Product2Id = prod.id;
        ass.Product_Plan__c = 'Silver';
        ass.Product_Role__c = 'Admin';
        ass.AccountId = acc.id;
        ass.PurchaseDate = ThisMonth;
        ass.Utilised_Hours__c = 3;
        insert ass;
        
        System.debug('AssetID:: '+ass.Id);
        
        
        // Deliverable
        Task__c del_1= new Task__c(
            Name='Deliverable-One',
            Project__c = proj1.Id,
            Asset__c = ass.id,
            RecordTypeId= Schema.sobjectType.Task__c.getRecordTypeInfosByName().get('Deliverable').getRecordTypeId()           
        );
        insert del_1;  
        
        System.debug('DeliverableID:: '+del_1.Id);
        
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
            Customer_Account__c = acc.Id,
            Email__c = 'abcTest_Ticket@gmail.com',
            project__c = proj1.Id,
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
            Deliverables__c = del_1.Id,
            Project__c = proj1.Id,
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
        
        TimesheetCal.TimesheetCal();
        
        System.debug('Ticket::' + ticket_1);
        
        //TimesheetInvoice.generateWishListInvoices('Yes');        
        
        
        OnstaffInvoiceGeneration.generateOnstaffInvoice();
        
       // TimesheetCal.UpdateConfig();
    }
  
/*    public static void testWishlistTimesheet(){
        
        TimesheetInvoice.generateWishListInvoices('Yes');        
        
    }*/
}