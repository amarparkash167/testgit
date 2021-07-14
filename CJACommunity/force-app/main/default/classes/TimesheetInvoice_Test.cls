@IsTest
public class TimesheetInvoice_Test {
    
    public static Custom_Invoice__mdt datesMDT = new Custom_Invoice__mdt();//[Select id, label, From__c, To__c, Invoice_Due_Date__c from Custom_Invoice__mdt where MasterLabel = 'Custom Invoice' limit 1 ]; 
    
    
    @isTest
    public static void TimesheetInvoiceTesting(){
        
        
    datesMDT.From__c = System.today().addDays(-30);
    datesMDT.To__c = System.today();
    datesMDT.Invoice_Due_Date__c = System.today().addDays(7);
        
        // Creating Account
        Account acc = new Account(
            Name = 'Test Account'
        );
        insert acc;
        
        // Creating Contact
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact 2',
            AccountId = acc.Id,
            RecordTypeId = Schema.sobjectType.Contact.getRecordTypeInfosByName().get('Standard Contact').getRecordTypeId()
        );
        insert con;
        
        // Updating Account
        acc.cjaInvoice__Billing_Contact__c = con.Id;
        acc.cjaInvoice__Credit_Card_Authorization_Status__c = 'Active';
        acc.cjaInvoice__Customer_ID__c = '123';
        
        update acc;
        
        Id RecordType = Schema.SObjectType.Issue__c.getRecordTypeInfosByName().get('Wishlist Item / Enhancement Request').getRecordTypeId();
        
        // Ticket Record
        Issue__c ticket_1 = new Issue__c(
            Name__c = 'Test Ticket (Yes) - 22-12-2020',
            Customer_Account__c = acc.Id,
            In_Scope__c = 'Yes - Billable',
            RecordTypeId = RecordType,
            Admin_Hourly_Rate_M__c = 100.00, 
            Consultant_Hourly_Rate_Manual__c = 200.00, 
            Architect_Hourly_Rate_Manual__c = 300.00
        );
        insert ticket_1;
        system.debug('ticket_1=='+[select id, In_Scope__c,Admin_Hourly_Rate_M__c,
                                   Consultant_Hourly_Rate_Manual__c ,
                                   Architect_Hourly_Rate_Manual__c from issue__c where id=: ticket_1.id]);
        
        // Ticket Record
        Issue__c ticket_2 = new Issue__c(
            Name__c = 'Test Ticket (No) - 22-12-2020',
            Customer_Account__c = acc.Id,
            In_Scope__c = 'No - Billable',
            Wishlist_Item__c = 'Future Wishlist Item',
            RecordTypeId = RecordType,
            Admin_Hourly_Rate_M__c = 100.00, 
            Consultant_Hourly_Rate_Manual__c = 200.00, 
            Architect_Hourly_Rate_Manual__c = 300.00,
            Resolution_Date__c = System.today().addDays(-5)
        );
        insert ticket_2;
        
        // Ticket Record
        Issue__c ticket_3 = new Issue__c(
            Name__c = 'Test Ticket (No) - 22-02-2021',
            Customer_Account__c = acc.Id,
            In_Scope__c = 'Yes - Non-Billable',
            Wishlist_Item__c = 'Change Request',
            RecordTypeId = RecordType,
            Admin_Hourly_Rate_M__c = 100.00, 
            Consultant_Hourly_Rate_Manual__c = 200.00, 
            Architect_Hourly_Rate_Manual__c = 300.00,
            Resolution_Date__c = System.today().addDays(-5) //- datesMDT.To__c.addDays(+5)
            
        );
        insert ticket_3;
        
        
        
        //Task Record
        Task__c task_1= new Task__c(
            Name='Task-One',
            Ticket__c = ticket_1.Id,
            RecordTypeId= Schema.sobjectType.Task__c.getRecordTypeInfosByName().get('Sub Task').getRecordTypeId()
        );
        insert task_1;
        
        system.debug('ticket_1 after task =='+[select id, In_Scope__c,Admin_Hourly_Rate_M__c,
                                               Consultant_Hourly_Rate_Manual__c ,
                                               Architect_Hourly_Rate_Manual__c from issue__c where id=: ticket_1.id]);
        
        //Task Record
        Task__c task_2 = new Task__c(
            Name='Task-Two',
            Ticket__c = ticket_2.Id,
            RecordTypeId= Schema.sobjectType.Task__c.getRecordTypeInfosByName().get('Sub Task').getRecordTypeId()
        );
        insert task_2;
        
        //Task Record
        Task__c task_3 = new Task__c(
            Name='Task-Three',
            Ticket__c = ticket_3.Id,
            RecordTypeId= Schema.sobjectType.Task__c.getRecordTypeInfosByName().get('Sub Task').getRecordTypeId()
        );
        insert task_3;
        
        // Timesheet Record
        datetime dt= system.now();
        Timesheet__c timesheet_1= new Timesheet__c(
            Name= 'Wasim Akram - 22-12-2020',
            Timesheet_Date__c = datesMDT.To__c.addDays(-5),
            Approval_Status__c = 'Approved',
            External_ID__c = dt.format('YYYY-MM-dd')+'|'+userinfo.getuserId()
        );
        insert timesheet_1;
        
        //System.debug('TimesheetID:: '+timesheet_1.Id);
        list<Timesheet_Detail__c> lstTSD = new list<Timesheet_Detail__c>();
        
        //Timesheet Entry Record
        //System.debug('Timesheet In Test Class::' + timesheet_1);
        Timesheet_Detail__c timesheetDetail_1 = new Timesheet_Detail__c(
            Timesheet__c = timesheet_1.Id,
            Actual_Hours__c = 1,
            Task__c = task_1.Id,
            Skill_Type__c = 'Admin',
            billable__c = true
        );
        //insert timesheetDetail_1;
        
        //Timesheet Entry Record
        //System.debug('Timesheet In Test Class::' + timesheet_1);
        Timesheet_Detail__c timesheetDetail_2 = new Timesheet_Detail__c(
            Timesheet__c = timesheet_1.Id,
            Actual_Hours__c = 2,
            Task__c = task_1.Id,
            Skill_Type__c = 'Consultant',
            billable__c = true
        );
        //insert timesheetDetail_2;
        
        //Timesheet Entry Record
        //System.debug('Timesheet In Test Class::' + timesheet_1);
        Timesheet_Detail__c timesheetDetail_3 = new Timesheet_Detail__c(
            Timesheet__c = timesheet_1.Id,
            Actual_Hours__c = 3,
            Task__c = task_1.Id,
            Skill_Type__c = 'Architect',
            billable__c = true
        );
        //insert timesheetDetail_3;
        lstTSD.add(timesheetDetail_1);
        lstTSD.add(timesheetDetail_2);
        lstTSD.add(timesheetDetail_3);
        
        insert lstTSD;
        system.debug('ticket_1 after TSD =='+[select id, In_Scope__c,Admin_Hourly_Rate_M__c,
                                              Consultant_Hourly_Rate_Manual__c ,
                                              Architect_Hourly_Rate_Manual__c from issue__c where id=: ticket_1.id]);
        /*System.debug('datesMDT::' + datesMDT.To__c.addDays(-5));
System.debug('Ticket::' + ticket_2);
System.debug('Ticket 1::' + ticket_1);
System.debug('Task::' + task_2);

System.debug('Task 1::' + task_1); */
        
        
        /* System.debug('TimeSheet Details 1::' + timesheetDetail_1);
System.debug('TimeSheet Details 2::' + timesheetDetail_2);
System.debug('TimeSheet Details 3::' + timesheetDetail_3);*/
        System.debug('lstTSD::' + lstTSD);
        
        datetime dt1= system.now().addDays(-7);
        
        // Timesheet Record2
        Timesheet__c timesheet_2= new Timesheet__c(
            Name= 'Wasim Akram - 22-05-2021',
            Timesheet_Date__c = datesMDT.To__c.addDays(-7),
            Approval_Status__c = 'Approved',
            External_ID__c = dt1.format('YYYY-MM-dd')+'|'+userinfo.getuserId()
        );
        insert timesheet_2;
        
        //System.debug('TimesheetID:: '+timesheet_2.Id);
        list<Timesheet_Detail__c> lstaTSD = new list<Timesheet_Detail__c>();
        //Timesheet Entry Record
        //System.debug('Timesheet In Test Class::' + timesheet_1);
        Timesheet_Detail__c timesheetDetail_4 = new Timesheet_Detail__c(
            Timesheet__c = timesheet_2.Id,
            Actual_Hours__c = 1,
            Task__c = task_2.Id,
            Skill_Type__c = 'Admin',
            billable__c = false
        );
        //insert timesheetDetail_1;
        
        //Timesheet Entry Record
        //System.debug('Timesheet In Test Class::' + timesheet_1);
        Timesheet_Detail__c timesheetDetail_5 = new Timesheet_Detail__c(
            Timesheet__c = timesheet_2.Id,
            Actual_Hours__c = 2,
            Task__c = task_2.Id,
            Skill_Type__c = 'Consultant',
            billable__c = false
        );
        //insert timesheetDetail_2;
        
        //Timesheet Entry Record
        //System.debug('Timesheet In Test Class::' + timesheet_1);
        Timesheet_Detail__c timesheetDetail_6 = new Timesheet_Detail__c(
            Timesheet__c = timesheet_2.Id,
            Actual_Hours__c = 3,
            Task__c = task_2.Id,
            Skill_Type__c = 'Architect',
            billable__c = true
        );
        
        //Timesheet Entry Record
        //System.debug('Timesheet In Test Class::' + timesheet_1);
        Timesheet_Detail__c timesheetDetail_7 = new Timesheet_Detail__c(
            Timesheet__c = timesheet_2.Id,
            Actual_Hours__c = 3,
            Task__c = task_1.Id,
            Skill_Type__c = 'Architect',
            billable__c = true
        );
        
        //insert timesheetDetail_3;
        lstaTSD.add(timesheetDetail_4);
        lstaTSD.add(timesheetDetail_5);
        lstaTSD.add(timesheetDetail_6);
        lstaTSD.add(timesheetDetail_7);
        
        insert lstaTSD;
        system.debug('ticket_2 after TSD =='+[select id, In_Scope__c,Admin_Hourly_Rate_M__c,
                                              Consultant_Hourly_Rate_Manual__c ,
                                              Architect_Hourly_Rate_Manual__c from issue__c where id=: ticket_2.id]);
        
        System.debug('lstaTSD::' + lstaTSD);
        
        
        datetime dt2= system.now().addDays(-6);
        
        // Timesheet Record2
        Timesheet__c timesheet_3= new Timesheet__c(
            Name= 'Wasim Akram - 22-05-2021',
            Timesheet_Date__c = datesMDT.To__c.addDays(-6),
            Approval_Status__c = 'Approved',
            External_ID__c = dt2.format('YYYY-MM-dd')+'|'+userinfo.getuserId()
        );
        insert timesheet_3;
        
        //System.debug('TimesheetID:: '+timesheet_3.Id);
        list<Timesheet_Detail__c> lstbTSD = new list<Timesheet_Detail__c>();
        //Timesheet Entry Record
        //System.debug('Timesheet In Test Class::' + timesheet_1);
        Timesheet_Detail__c timesheetDetail_8 = new Timesheet_Detail__c(
            Timesheet__c = timesheet_3.Id,
            Actual_Hours__c = 1,
            Task__c = task_3.Id,
            Skill_Type__c = 'Admin',
            billable__c = true
        );
        //insert timesheetDetail_1;
        
        //Timesheet Entry Record
        //System.debug('Timesheet In Test Class::' + timesheet_1);
        Timesheet_Detail__c timesheetDetail_9 = new Timesheet_Detail__c(
            Timesheet__c = timesheet_3.Id,
            Actual_Hours__c = 2,
            Task__c = task_3.Id,
            Skill_Type__c = 'Admin',
            billable__c = false
        );
        //insert timesheetDetail_2;
        
        
        
        //insert timesheetDetail_3;
        lstbTSD.add(timesheetDetail_8);
        lstbTSD.add(timesheetDetail_9);
        
        insert lstbTSD;
        system.debug('ticket_3 after TSD =='+[select id, In_Scope__c,Admin_Hourly_Rate_M__c,
                                              Consultant_Hourly_Rate_Manual__c ,
                                              Architect_Hourly_Rate_Manual__c from issue__c where id=: ticket_3.id]);
        
        System.debug('lstbTSD::' + lstbTSD);
        
        
        /*
system.debug('lstFromSOQL='+ [SELECT Skill_Type__c, 
Actual_Hours__c,
Admin_Hourly_Rate_M__c,
Task__r.Ticket__r.Customer_Account__c,
Task__r.Ticket__r.Customer_Account__r.cjaInvoice__Billing_Contact__c,
Task__r.Ticket__r.Customer_Account__r.cjaInvoice__Credit_Card_Authorization_Status__c,
Task__r.Ticket__r.Name,
Task__r.Ticket__r.Admin_Hourly_Rate_M__c, 
Task__r.Ticket__r.Consultant_Hourly_Rate_Manual__c, 
Task__r.Ticket__r.Architect_Hourly_Rate_Manual__c 
FROM Timesheet_Detail__c 
WHERE Task__r.Ticket__r.RecordTypeId =: RecordType
AND Task__r.Ticket__c != null ]);  
//AND Admin_Hourly_Rate_From_Task__c > 0]);
//AND Task__r.Ticket__r.Consultant_Hourly_Rate_Manual__c > 0
//AND Task__r.Ticket__r.Architect_Hourly_Rate_Manual__c > 0]);
*/
        
        // Timesheet Details in Test Class
        
        List<Task__c> listOfTasks = [Select Ticket__r.Customer_Account__c,
                                     Ticket__r.Customer_Account__r.cjaInvoice__Billing_Contact__c,
                                     Ticket__r.Customer_Account__r.cjaInvoice__Credit_Card_Authorization_Status__c,
                                     Ticket__r.Name,
                                     Ticket__r.Admin_Hourly_Rate_M__c, 
                                     Ticket__r.Consultant_Hourly_Rate_Manual__c, 
                                     Ticket__r.Architect_Hourly_Rate_Manual__c 
                                     from Task__c];
        
        //System.debug('List of Tasks::' +listOfTasks );
        
        List<Timesheet_Detail__c> listofTimesheetDetails = [SELECT Skill_Type__c, 
                                                            Actual_Hours__c,
                                                            Task__r.Ticket__r.Customer_Account__c,
                                                            Task__r.Ticket__r.Customer_Account__r.cjaInvoice__Billing_Contact__c,
                                                            Task__r.Ticket__r.Customer_Account__r.cjaInvoice__Credit_Card_Authorization_Status__c,
                                                            Task__r.Ticket__r.Name,
                                                            Task__r.Ticket__r.Admin_Hourly_Rate_M__c, 
                                                            Task__r.Ticket__r.Consultant_Hourly_Rate_Manual__c, 
                                                            Task__r.Ticket__r.Architect_Hourly_Rate_Manual__c 
                                                            FROM Timesheet_Detail__c 
                                                            WHERE Task__r.Ticket__r.In_Scope__c =: 'Yes' 
                                                            AND 
                                                            billable__c = true];
        /*AND Task__r.Ticket__r.RecordTypeId =: RecordType
AND Task__r.Ticket__c != null  
AND Task__r.Ticket__r.Admin_Hourly_Rate_M__c > 0
AND Task__r.Ticket__r.Consultant_Hourly_Rate_Manual__c > 0
AND Task__r.Ticket__r.Architect_Hourly_Rate_Manual__c > 0
];*/
        
        System.debug('Timesheet Details in test Class::' + listofTimesheetDetails);
        
        InvoiceFlowClass.FlowInputs fInput = new InvoiceFlowClass.FlowInputs();
        
        fInput.fromDate =   datesMDT.From__c;
        fInput.toDate = datesMDT.To__c;
        fInput.dueDate = datesMDT.Invoice_Due_Date__c;
        
        fInput.invoiceType = 'Billable';
        
        fInput.ticketId = '';
        
        List<InvoiceFlowClass.FlowInputs> lstFI = new List<InvoiceFlowClass.FlowInputs>();
        
        lstFI.add(fInput);
        
        InvoiceFlowClass.flowMethod(lstFI);
        
        //TimesheetInvoice.generateWishListInvoices('Additional Cost');        
        TimesheetInvoice.generateWishListInvoices('Billable' , null , datesMDT.From__c,datesMDT.To__c,datesMDT.Invoice_Due_Date__c); 
        TimesheetInvoice.generateWishListInvoices('Non-Billable' , null , datesMDT.From__c,datesMDT.To__c,datesMDT.Invoice_Due_Date__c);
        TimesheetInvoice.generateWishListInvoices(null , ticket_2.Id, datesMDT.From__c,datesMDT.To__c,datesMDT.Invoice_Due_Date__c); 
        
    }
}