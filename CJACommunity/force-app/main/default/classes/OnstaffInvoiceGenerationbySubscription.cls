/*
============================================================
Description: This class creates Invoice and InvoiceLineItems by using Contract and Subscription. 
Author: M Tiham Siddiqui @ CloudJunction
Mentor/Supervisor: Zain Abbas and Manisha Kumari
Created Date: 21-05-2021
Last Modified Date: 10-06-2021
============================================================
*/

    public class OnstaffInvoiceGenerationbySubscription {
    
    //Map for ContractwithSubscriptions
    public static Map<ID, List<ID>> mapofContrIdwithSubscriptionlist = new Map<ID, List<ID>>();
    
    //Map for InvoiceLineItems
    public static Map<String, cjaInvoice__Invoice_Lineitem__c> mapofILI = new Map<String, cjaInvoice__Invoice_Lineitem__c>();
    
    //Map for ContractwithInvoices
    public static Map<Id, cjaInvoice__Customer_Invoice__c> mapofContrIdwithInvoice = new Map<Id, cjaInvoice__Customer_Invoice__c>();
    
    //Map for ContractwithInvoicesLineItems
    public static Map<ID, cjaInvoice__Invoice_Lineitem__c> mapofContrIdwithILI = new Map<ID, cjaInvoice__Invoice_Lineitem__c>();
    
    //Map for ContractwithInvoicesLineItems
    public static Map<ID, Contract> MapofContract = new Map<ID, Contract>();
    
    //Map for ContractwithAssets
    public static Map<String, SBQQ__Subscription__c> mapofContrIdwithSubscriptions = new Map<String, SBQQ__Subscription__c>();
    
    //List for InvoiceLineItems
    public static List <cjaInvoice__Invoice_Lineitem__c> ListofInvoiceLineItems = new List <cjaInvoice__Invoice_Lineitem__c>();
    
    //Set for ContractIDs and Adding all IDs from Map key to CONT set
    Public static set<Contract> contIds = new set<Contract>();
    
    // Map of Asset with AccountId + Skill Type
    Public static Map<String, SBQQ__Subscription__c> MapOfSubscriptionwithAccId = new Map<String, SBQQ__Subscription__c>();
    
    //Custom MetaData Type Date
    //Public static Custom_Invoice__mdt datesMDT = [Select id, label, From__c, To__c, Invoice_Due_Date__c from Custom_Invoice__mdt where MasterLabel = 'Custom Invoice' limit 1 ];    
    
    Public static date fromDate;  
    Public static date toDate;
    Public static date dueDate;
        
    //Entry Point
    public static void generateOnstaffInvoice(Date From_Date, Date To_Date, Date due_date){
    	
        fromDate = From_Date;
        toDate = To_Date;  
        dueDate = due_date;
        
        System.debug('From_Date:: ' + From_Date);
        System.debug('To_Date:: ' + To_Date);
        System.debug('due_date:: ' + due_date);
        
        System.debug('fromDate:: ' + fromDate);
        System.debug('toDate:: ' + toDate);
        System.debug('dueDate:: ' + dueDate);
        
        Id RecordType = Schema.SObjectType.Issue__c.getRecordTypeInfosByDeveloperName().get('Customer_Issue').getRecordTypeId();
        
        //System.debug('Start Date::' + fromDate);
        //System.debug('End Date::' + toDate);
        
        getMapofSubsWithAcc();
        
        //Calling Method/Function
        CreateSubscription();
        
        System.debug('Map of Subscription ILI::' + mapofContrIdwithILI);
        
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
                                                            AND Timesheet__r.Timesheet_Date__c >= :fromDate
                                                            AND Timesheet__r.Timesheet_Date__c < :toDate 
                                                            AND billable__c = TRUE];
        
        System.debug('List of Timesheet Details::' + listofTimesheetEntries);
        
        //For Loop for Timesheet Detail Query
        for(Timesheet_Detail__c td: listofTimesheetEntries){
            
            //Calling Methods/Functions
            CreateInvoice(td);
            CreateInvoiceLineItems(td);
            ContractwithAsset(td);
            //UpdateConfig();
            //System.debug('Actual Hours: ' + td.Actual_Hours__c +' Asset: ' + td.Task__r.Deliverables__r.Asset__c +' Asset Hourly Rate: ' + td.Task__r.Deliverables__r.Asset__r.Hourly_Rate_per_role__c);
        }
        
        //Insert Values to Map
        try{
            insert mapofContrIdwithInvoice.values();
            System.debug('mapofContrIdwithInvoice::' + mapofContrIdwithInvoice);
        }catch(Exception e){
            System.debug('Exception in Update::' + e.getMessage());  
        }
        
        for(String ContractID: mapofContrIdwithInvoice.keyset()){
            //if subscription_ILI contains contrId
            if(mapofContrIdwithILI.get(ContractID)!=null){
                
                System.debug('Map of Subscription ILI exist::' + ContractID);
                cjaInvoice__Invoice_Lineitem__c lt = mapofContrIdwithILI.get(ContractID);
                lt.cjaInvoice__Invoice__c = mapofContrIdwithInvoice.get(ContractID).Id;
                mapofContrIdwithILI.put(ContractID, lt);
                
                ListofInvoiceLineItems.add(lt);
                System.debug('Map of Contract Invoice Item of ' + ContractID + ' -- '+ mapofContrIdwithILI);
                System.debug('Map of Contract Invoice Item' + mapofContrIdwithILI);
                
            }
        }
        
        for(String ContractID: mapofILI.keyset()){
            //Spliting the ILIKey to get Contract ID
            string[] parts;
            parts = ContractID.split('-');
            system.debug(parts.size());            
            String ContID = parts[2];
            
            //Getting Invoice ID using Contract ID
            ID invID = mapofContrIdwithInvoice.get(ContID).ID;
            cjaInvoice__Invoice_Lineitem__c lineItems = mapofILI.get(ContractID);
            lineItems.cjaInvoice__Invoice__c = invID;
            ListofInvoiceLineItems.add(lineItems);
            mapofILI.put(ContractID, lineItems);
            
            System.debug('Contract Id::' + contId);
            System.debug(mapofContrIdwithILI.get(ContID));
            System.debug(mapofContrIdwithILI.keyset());
            
            //if subscription_ILI contains contrId
        }
        
        for(String ContSubId: mapofContrIdwithSubscriptions.keySet()){
            
            string[] parts;
            parts = ContSubId.split('-');
            system.debug(parts.size());            
            String ContID = parts[0];
            
            System.debug('Subscription ID::' + mapofContrIdwithSubscriptions.get(ContSubId));
            System.debug('Product::' + mapofContrIdwithSubscriptions.get(ContSubId).SBQQ__Product__c);
			//System.debug('Skill Type::' + mapofContrIdwithSubscriptions.get(ContSubId).Skill_Type__c);
            System.debug('Product Role::' + mapofContrIdwithSubscriptions.get(ContSubId).Product_Role__c);
            
            cjaInvoice__Invoice_Lineitem__c lt = new  cjaInvoice__Invoice_Lineitem__c();
            lt.cjaInvoice__Invoice__c = mapofContrIdwithInvoice.get(ContID).Id;
            
            if(mapofContrIdwithSubscriptions.get(ContSubId).Free_Hours_per_Role__c > 0){
                
                if(mapofContrIdwithSubscriptions.get(ContSubId).Utilised_Hours__c <= mapofContrIdwithSubscriptions.get(ContSubId).Free_Hours_per_Role__c){
                    
                    lt.cjaInvoice__quantity__c = mapofContrIdwithSubscriptions.get(ContSubId).Utilised_Hours__c;
                    
                }else{
                    
                    lt.cjaInvoice__quantity__c = mapofContrIdwithSubscriptions.get(ContSubId).Free_Hours_per_Role__c;
                }
                lt.cjaInvoice__rate__c = mapofContrIdwithSubscriptions.get(ContSubId).SBQQ__ListPrice__c*-1;
                lt.CurrencyIsoCode = mapofContrIdwithSubscriptions.get(ContSubId).SBQQ__Account__r.CurrencyIsoCode;
                lt.cjaInvoice__description__c =  lt.cjaInvoice__quantity__c + ' Free Hours of ' + mapofContrIdwithSubscriptions.get(ContSubId).Product_Role__c + ' Time' ;
                
				System.debug('lt.CurrencyIsoCode :: ' + lt.CurrencyIsoCode);
				System.debug('lt.cjaInvoice__description__c:: ' + lt.cjaInvoice__description__c);
                
                ListofInvoiceLineItems.add(lt);
                
            }
        }
        
        //Insert Values to Map
        try{
            insert ListofInvoiceLineItems;
        } catch(Exception e){
            
            System.debug('Exception in Insert::' + e.getMessage());  
        }
        
        UpdateContractDate();
        ContIDwithDates();
        
        //Update MetaData Dates
        //UpdateConfig();
    }
    
    // Get Map of Asset with Acc Id and Skill Type
    public static void getMapofSubsWithAcc(){
        
        System.debug('toDate (202):: ' + toDate);
        
        //Query to fetch Actual hours, Deliverable, Project, OnStaff Contract, Deliverable's Asset Hourly Rate with Filters
        List<SBQQ__Subscription__c> ListofSubscription = [SELECT Id, SBQQ__Product__r.Name, SBQQ__Product__r.Product_Role__c, SBQQ__Contract__c, SBQQ__Account__c, SBQQ__Account__r.cjaInvoice__Billing_Contact__c, 
                                                          SBQQ__Contract__r.Frequency__c, SBQQ__Contract__r.Subscription_Billing_Frequency__c, SBQQ__Contract__r.Usage_Billing_Date__c, Product_Role__c,
                                                          SBQQ__Contract__r.Subscription_Billing_Renewal_Date__c, SBQQ__Contract__r.Account.Name, SBQQ__ListPrice__c, PurchaseDate__c,
                                                          SBQQ__Subscription__c.Free_Hours_per_Role__c, CurrencyIsoCode, SBQQ__Account__r.CurrencyIsoCode      
                                                          FROM SBQQ__Subscription__c 
                                                          WHERE SBQQ__Contract__r.status = 'Activated' 
                                                          AND SBQQ__Contract__r.Usage_Billing_Date__c = :toDate
                                                          AND SBQQ__Product__r.Product_Role__c != null];
        
        
        System.debug('List of Subscription::' + ListofSubscription);
        
        for(SBQQ__Subscription__c subscription: ListofSubscription){
            
            MapOfSubscriptionwithAccId.put(subscription.SBQQ__Account__c + '-' + subscription.SBQQ__Product__r.Product_Role__c, subscription);
            System.debug('MapOfSubscriptionwithAccId Key:: ' + subscription.SBQQ__Account__c + '-' + subscription.SBQQ__Product__r.Product_Role__c);
			System.debug('subscription:: ' + subscription);
            System.debug('MapOfSubscriptionwithAccId:: ' + MapOfSubscriptionwithAccId);
        }
        
        system.debug('MapOfSubscriptionwithAccId::' + MapOfSubscriptionwithAccId);
        
    }
    
    //Create InvoicesLineItems using Timesheet Details
    public static void CreateInvoiceLineItems(Timesheet_Detail__c td){
        //ID for Contract
        
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c();
        
        System.debug('MapOfSubscriptionwithAccId.get:: ' + td.Task__r.Ticket__r.Customer_Account__c + '-' +td.Skill_Type__c);
        
        if(MapOfSubscriptionwithAccId.get(td.Task__r.Ticket__r.Customer_Account__c + '-' +td.Skill_Type__c)!=null){
            
            subscription = MapOfSubscriptionwithAccId.get(td.Task__r.Ticket__r.Customer_Account__c + '-' +td.Skill_Type__c);
            
            String ILIKey = td.task__r.ticket__c + '-'  + subscription.Id + '-'  + subscription.SBQQ__Contract__c;
            System.debug('ILI Key::' + ILIKey);
            
            //If ILIKey Exist
            if(mapofILI.get(ILIKey)!=null){
                //Assignment of Invoice Items
                cjaInvoice__Invoice_Lineitem__c lineItems = mapofILI.get(ILIKey);
                lineItems.cjaInvoice__Quantity__c += td.Actual_Hours__c;
                mapofILI.put(ILIKey, lineItems);
                
                //If ILIKey does not Exist    
            }else{
                //Initialization of Invoice Items
                cjaInvoice__Invoice_Lineitem__c lineItems = new cjaInvoice__Invoice_Lineitem__c();
                system.debug(td.Actual_Hours__c);
                lineItems.cjaInvoice__Quantity__c = td.Actual_Hours__c;
                lineItems.cjaInvoice__Rate__c = subscription.SBQQ__ListPrice__c;
                //lineItems.CurrencyIsoCode =	lineItems.cjaInvoice__Invoice__r.CurrencyIsoCode;
                lineItems.CurrencyIsoCode = subscription.SBQQ__Account__r.CurrencyIsoCode;
                lineItems.cjaInvoice__Description__c = 'Ticket #' + td.task__r.ticket__r.Name +' - Skill Type: '+ subscription.Product_Role__c;
                mapofILI.put(ILIKey, lineItems);
                
                System.debug('Map of ILI::' + mapofILI);
            }
        }
    }
    
    //Create Invoices using Timesheet Details
    public static void CreateInvoice(Timesheet_Detail__c td){
        
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c();
        if(MapOfSubscriptionwithAccId.get(td.Task__r.Ticket__r.Customer_Account__c + '-' +td.Skill_Type__c)!=null){
            
            subscription = MapOfSubscriptionwithAccId.get(td.Task__r.Ticket__r.Customer_Account__c + '-' +td.Skill_Type__c);
            
            if(!mapofContrIdwithInvoice.containsKey(subscription.SBQQ__Contract__c)){    
                cjaInvoice__Customer_Invoice__c Invoice = new cjaInvoice__Customer_Invoice__c();
                Invoice.cjaInvoice__Account__c = subscription.SBQQ__Account__c;
                Invoice.cjaInvoice__Billing_Contact__c = subscription.SBQQ__Account__r.cjaInvoice__Billing_Contact__c;
                //Invoice.cjaInvoice__Auto_Bill__c = true;
                //Invoice.CJ_Opportunity__c = td.Task__r.Project__r.CJ_Opportunity__c;
                Invoice.cjaInvoice__Invoice_Date__c = toDate;
                System.debug('Invoice Date::' + Invoice.cjaInvoice__Invoice_Date__c);
                Invoice.cjaInvoice__Due_Date__c = dueDate;
                System.debug('Invoice Due Date::' + Invoice.cjaInvoice__Due_Date__c);
                //Invoice.cjaInvoice__Currency__c = 'CAD';
                Invoice.cjaInvoice__Currency__c = subscription.SBQQ__Account__r.CurrencyIsoCode;
                Invoice.cjaInvoice__Status__c = 'Draft';
                //Invoice.cjaInvoice__Description__c = 'Subscription Charges for '+ td.Project__r.OnStaff_Contract__r.Frequency__c +' months Ticket # '+ td.Task__r.Ticket__r.Name + ' - Skill Type: '+ td.Task__r.Ticket__r.Ticket_Skill_Type__c + ' - Product Role: '+ td.Task__r.Deliverables__r.Asset__r.Product_Role__c;
                //Invoice.cjaInvoice__Description__c = subscription.SBQQ__Account__r.Name +' OnStaff Admin '+ subscription.SBQQ__Product__r.Product_Plan__c + ' Plan';
                Invoice.cjaInvoice__Description__c =  'Salesforce Services Charges - '+ getPriorMonthName() + ' ' + getPriorYear();
                
                //Account Credit Card Status Logic
                if(Invoice.cjaInvoice__Account__r.cjaInvoice__Credit_Card_Authorization_Status__c == 'Active'){
                    Invoice.cjaInvoice__Auto_Bill__c = true; 
                }else{
                    Invoice.cjaInvoice__Auto_Bill__c = false;
                }
                
                mapofContrIdwithInvoice.put(subscription.SBQQ__Contract__c, Invoice);
                
                //Mapping for Contract Dates
                Contract cont = new Contract();
                cont.Id = subscription.SBQQ__Contract__c;
                cont.Usage_Billing_Date__c = subscription.SBQQ__Contract__r.Usage_Billing_Date__c;
                cont.Subscription_Billing_Date__c = subscription.SBQQ__Contract__r.Subscription_Billing_Date__c;
                cont.Subscription_Billing_Frequency__c = subscription.SBQQ__Contract__r.Subscription_Billing_Frequency__c;
                MapofContract.put(subscription.SBQQ__Contract__c, cont);
                
            }          
        }       
    }
    
    //Create Subscription/Contract InvoicesLineItems
    public static void CreateSubscription(){
        List<Contract> listofContract = [SELECT Id, AccountId, Project__c, CurrencyIsoCode, Subscription_Fees_Monthly__c, Pricebook2Id, Product_Plan__c, Subscription_Billing_Renewal_Date__c, Subscription_Billing_Frequency__c, Subscription_Billing_Date__c, Account.cjaInvoice__Billing_Contact__c, Usage_Billing_Date__c, Frequency__c, Account.CurrencyIsoCode FROM Contract WHERE Subscription_Billing_Renewal_Date__c = :toDate AND Status = 'Activated'];
        
        System.debug('List of Subscription Contracts::' + listofContract);
        
        for(Contract LoC: listofContract){
            
            CreateSubscriptionInvoice(LoC);
            
            if(mapofContrIdwithILI.get(LoC.Id)==null){
                integer frequencyInt = Integer.valueOf(LoC.Frequency__c);
                
                DateTime dt = LoC.Subscription_Billing_Renewal_Date__c;
                System.debug('dt(319):: '+dt);
                System.debug('Full Month Name ===> '+dt.format('dd MMMM ,yyyy'));
                
                DateTime nextdate = LoC.Subscription_Billing_Renewal_Date__c;
                DateTime dt2= nextdate.addMonths(frequencyInt).addDays(-1);
                System.debug('Full Next Month Name ===> '+dt2.format('dd MMMM ,yyyy'));
                
                //date dateCalforDesc = td.Project__r.OnStaff_Contract__r.Subscription_Billing_Renewal_Date__c.addmonths(td.Project__r.OnStaff_Contract__r.Frequency__c);
                
                cjaInvoice__Invoice_Lineitem__c lineItems = new cjaInvoice__Invoice_Lineitem__c();
                lineItems.cjaInvoice__Quantity__c = LoC.Subscription_Billing_Frequency__c;
                lineItems.cjaInvoice__Rate__c = LoC.Subscription_Fees_Monthly__c;
                lineItems.CurrencyIsoCode = LoC.Account.CurrencyIsoCode;
                //lineItems.cjaInvoice__Description__c = 'Subscription Charges for '+ dt.format('MMMM') + ' ('+ LoC.Subscription_Billing_Renewal_Date__c + '-' + LoC.Subscription_Billing_Date__c.addmonths(frequencyInt)+')';
                lineItems.cjaInvoice__Description__c = 'Subscription Charges of '+ dt.format('dd MMMM, yyyy') + ' - ' + dt2.format('dd MMMM, yyyy');
                
                mapofContrIdwithILI.put(LoC.Id, lineItems); 
                System.debug('Map of Contract Invoice Item' + mapofContrIdwithILI);
            }
        }
    }
    
    //Create Subscription/Contract Invoices
    public static void CreateSubscriptionInvoice(Contract LoC){
        if(!mapofContrIdwithInvoice.containsKey(LoC.Id)){
            cjaInvoice__Customer_Invoice__c Invoice = new cjaInvoice__Customer_Invoice__c();
            Invoice.cjaInvoice__Account__c = LoC.AccountID;
            Invoice.cjaInvoice__Billing_Contact__c = LoC.Account.cjaInvoice__Billing_Contact__c;
            //Invoice.cjaInvoice__Auto_Bill__c = true;
            //Invoice.cjaInvoice__Opportunity__c = LoC.Task__r.Project__r.OnStaff_Contract__r.;
            Invoice.cjaInvoice__Invoice_Date__c = toDate;
            Invoice.cjaInvoice__Due_Date__c = dueDate;
            Invoice.CurrencyIsoCode = LoC.Account.CurrencyIsoCode;
            Invoice.cjaInvoice__Currency__c = LoC.Account.CurrencyIsoCode;
            Invoice.cjaInvoice__Status__c = 'Draft';
            Invoice.cjaInvoice__Description__c = 'Salesforce Services Charges - '+ getPriorMonthName() + ' ' + getPriorYear();
            
            //Account Credit Card Status Logic
            if(Invoice.cjaInvoice__Account__r.cjaInvoice__Credit_Card_Authorization_Status__c == 'Active'){
                Invoice.cjaInvoice__Auto_Bill__c = true; 
            }else{
                Invoice.cjaInvoice__Auto_Bill__c = false;
            }
            
            mapofContrIdwithInvoice.put(LoC.Id, Invoice);
            
            //Mapping for Contract Dates
            MapofContract.put(LoC.id, LoC);
            
            System.debug('Subscription Invoice Line Item::' + mapofContrIdwithInvoice);
        }
    }
    
    public static void UpdateContractDate(){
        
        //Updating Contract Dates
        for(Id ContractID: MapofContract.keySet()){
            Contract cont = MapofContract.get(ContractId);
            cont.Usage_Billing_Date__c = cont.Usage_Billing_Date__c.addmonths(1);
            if(cont.Subscription_Billing_Renewal_Date__c == toDate){
                cont.Subscription_Billing_Date__c = cont.Subscription_Billing_Renewal_Date__c;
            }
            
            MapofContract.put(ContractId, cont);
        }
        
        ContIDs();
        
        System.debug('Contract to be Updated::' + MapofContract.values());
        
        try{
            Update MapofContract.values();
        }catch(Exception e){
            
            System.debug('Exception in Update::' + e.getMessage());  
        }
    }
    
    public static void ContractwithAsset(Timesheet_Detail__c td){
        
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c();
        if(MapOfSubscriptionwithAccId.get(td.Task__r.Ticket__r.Customer_Account__c + '-' +td.Skill_Type__c)!=null){
            
            subscription = MapOfSubscriptionwithAccId.get(td.Task__r.Ticket__r.Customer_Account__c + '-' +td.Skill_Type__c);
            
            String ContSubKey = subscription.SBQQ__Contract__c + '-' + subscription.Id;
            System.debug('Contract + Subscription Key::' + ContSubKey);
            
            //If ContAssetKey Exist
            if(mapofContrIdwithSubscriptions.get(ContSubKey)!=null){
                //Assignment of Subscription
                SBQQ__Subscription__c sub = mapofContrIdwithSubscriptions.get(ContSubKey);
                sub.Utilised_Hours__c += td.Actual_Hours__c;
                System.debug('Subcription Putting Into Map::' + sub);
                mapofContrIdwithSubscriptions.put(ContSubKey, sub);
                
                //If ContAssetKey does not Exist    
            }else{
                //Initialization of Subscription
                SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
                sub.Utilised_Hours__c = td.Actual_Hours__c;
                sub.PurchaseDate__c = subscription.PurchaseDate__c;
                sub.SBQQ__ListPrice__c = subscription.SBQQ__ListPrice__c;
                sub.Free_Hours_per_Role__c = subscription.Free_Hours_per_Role__c;
                sub.Product_Role__c = subscription.Product_Role__c;
                sub.CurrencyIsoCode = subscription.SBQQ__Account__r.CurrencyIsoCode;
                //sub.Skill_Type__c = subscription.Skill_Type__c;
                mapofContrIdwithSubscriptions.put(ContSubKey, sub);
                
                System.debug('Map of Subscriptions with Contract::' + mapofContrIdwithSubscriptions);
                
            }
        } 
    }
    
    public static void ContIDs(){
        
        System.debug('ToDate (444):: '+ toDate);
        
        List<Contract> ListofContract  = [SELECT Id, Usage_Billing_Date__c, BillingDate__c from Contract WHERE Id !=: mapofContrIdwithInvoice.keySet() and Usage_Billing_Date__c!=null];
        
        for(Contract cID: ListofContract){
            Contract contrat = cID;
            System.debug('Usage Billing Date:: ' + cID.Usage_Billing_Date__c + 'ToDate::' + toDate);
            
            if(cID.Usage_Billing_Date__c == toDate){
                System.debug('Usage Billing Date:: ' + cID.Usage_Billing_Date__c);
				System.debug('Usage Billing Date Add Months:: ' + cID.Usage_Billing_Date__c.addmonths(1));
                contrat.Usage_Billing_Date__c = cID.Usage_Billing_Date__c.addmonths(1);
            }
            MapofContract.put(contrat.Id, contrat);
        }
    }
    
    public static void ContIDwithDates(){
        
        //List<Asset> ListofAssetDates  = [SELECT Id, PurchaseDate, InstallDate, Frequency_Month_per_Role__c, Contract__r.Usage_Billing_Date__c, Contract__r.BillingDate__c from Asset WHERE PurchaseDate <=: toDate];
        
        List<SBQQ__Subscription__c> ListofSubDates  = [SELECT Id, PurchaseDate__c, Frequency_Month_per_Role__c from SBQQ__Subscription__c WHERE PurchaseDate__c <=: toDate and SBQQ__Contract__r.Usage_Billing_Date__c =: toDate];
        
        if(ListofSubDates.size() > 0){
            for(SBQQ__Subscription__c sub: ListofSubDates){
                System.debug('For Loop:: '+ sub);    
                //Asset aset = asetD;
                System.debug('Frequency Month Per Role:: '+ sub.Frequency_Month_per_Role__c);
                if(sub.Frequency_Month_per_Role__c != Null && sub.PurchaseDate__c != Null){
                    integer frequencyInt = Integer.valueOf(sub.Frequency_Month_per_Role__c);
                    System.debug('Frequency Int:: '+frequencyInt);
                    sub.PurchaseDate__c = sub.PurchaseDate__c.addMonths(frequencyInt);
                    System.debug('Purchase Date:: '+sub.PurchaseDate__c); 
                }   
            }
        }
        
        if(ListofSubDates.size() > 0){
            try{
                UPDATE ListofSubDates;
            }catch(Exception e){
                System.debug('Subscription Dates Update Error:: ' + e.getMessage());
            }
        } else {
            System.debug('ListofSubDates is null:: ' +  ListofSubDates.size());
        }
    }
    
     public static String getPriorMonthName(){
        
        Date dt = Date.today().addMonths(-1);
        Integer d = dt.day();
        Integer mo = dt.month();
        Integer yr = dt.year();
        
        Datetime DtTym = Datetime.newInstance(yr, mo, d);
        String str = DtTym.format('MMMMM');
        System.debug('Month : ' + str);
        return str;
    }
    
    public static Integer getPriorYear(){
        
        Date dt = Date.today().addMonths(-1);
        Integer d = dt.day();
        Integer mo = dt.month();
        Integer yr = dt.year();
        
        return yr;
    }
    
}