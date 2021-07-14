//implements Metadata.DeployCallback
public class TimeSheetCal {
    
        
    //Map for ContractwithAssets
    public static Map<ID, List<ID>> mapofContrIdwithAssetslist = new Map<ID, List<ID>>();
    
    //Map for InvoiceLineItems
    public static Map<String, cjaInvoice__Invoice_Lineitem__c> mapofILI = new Map<String, cjaInvoice__Invoice_Lineitem__c>();
    
    //Map for ContractwithInvoices
    public static Map<Id, cjaInvoice__Customer_Invoice__c> mapofContrIdwithInvoice = new Map<Id, cjaInvoice__Customer_Invoice__c>();
    
    //Map for ContractwithInvoicesLineItems
    public static Map<ID, cjaInvoice__Invoice_Lineitem__c> mapofContrIdwithILI = new Map<ID, cjaInvoice__Invoice_Lineitem__c>();
    
    //Map for ContractwithInvoicesLineItems
    public static Map<ID, Contract> MapofContract = new Map<ID, Contract>();
    
    //Map for ContractwithAssets
    public static Map<String, Asset> mapofContrIdwithAssets = new Map<String, Asset>();
    
    //List for InvoiceLineItems
    public static List <cjaInvoice__Invoice_Lineitem__c> ListofInvoiceLineItems = new List <cjaInvoice__Invoice_Lineitem__c>();
    
    //Set for ContractIDs and Adding all IDs from Map key to CONT set
    Public static set<Contract> contIds = new set<Contract>();
    
    //Custom MetaData Type Date
    Public static Custom_Invoice__mdt datesMDT = [Select id, label, From__c, To__c, Invoice_Due_Date__c from Custom_Invoice__mdt where MasterLabel = 'Custom Invoice' limit 1 ];    

    //First of This Month
    //public static Date ThisMonth = datesMDT.From__c;
    //public static Date FirstOfThisMonth = date.today();
    
    //First of Previous Month
    //public static Date LastMonth = datesMDT.To__c;
    //public static Date FirstOfLastMonth = date.newInstance(Lastmonth.year(), lastmonth.month(), 1);
	//public static Date FirstOfLastMonth = datesMDT.To__c;
    
    public static void TimesheetCal(){
        
        System.debug('Start Date::' + datesMDT.From__c);
        System.debug('End Date::' + datesMDT.To__c);
        
        //Calling Method/Function
        CreateSubscription();
        
        System.debug('Map of Subscription ILI::' + mapofContrIdwithILI);
        
        //Query to fetch Actual hours, Deliverable, Project, OnStaff Contract, Deliverable's Asset Hourly Rate with Filters
        List<Timesheet_Detail__c> listofTimesheetEntries = [SELECT Task__r.Deliverables__r.Asset__r.Product2.Name, task__r.ticket__r.Name,Task__r.Deliverables__r.Asset__r.Product_Role__c, Task__r.Deliverables__r.Asset__r.PurchaseDate, Task__r.Deliverables__r.Asset__r.Free_Hours_per_Role__c, Task__r.Deliverables__r.Asset__r.Utilised_Hours__c, Actual_Hours__c, Task__r.Deliverables__c, Task__r.Project__r.Name, Task__r.Project__r.OnStaff_Contract__c, 
                                                            Task__r.Deliverables__r.Asset__r.Product_Plan__c,task__r.Project__r.Account__c,task__r.Project__r.Account__r.Name,Task__r.Project__r.OnStaff_Contract__r.AccountID,Task__r.Project__r.OnStaff_Contract__r.Account.cjaInvoice__Billing_Contact__c, Task__r.Project__r.CJ_Opportunity__c, Task__r.Project__r.OnStaff_Contract__r.Frequency__c, Task__r.Ticket__r.Ticket_Skill_Type__c,
                                                            Task__r.Deliverables__r.Asset__c, Task__r.Ticket__c, Task__r.Deliverables__r.Asset__r.Hourly_Rate_per_role__c, Task__r.Project__r.OnStaff_Contract__r.Subscription_Billing_Frequency__c,
                                                            Task__r.Project__r.OnStaff_Contract__r.Subscription_Billing_Date__c, Task__r.Project__r.OnStaff_Contract__r.Usage_Billing_Date__c, Task__r.Project__r.OnStaff_Contract__r.Subscription_Billing_Renewal_Date__c, Task__r.Project__r.OnStaff_Contract__r.Account.Name 
                                                            FROM Timesheet_Detail__c 
                                                            WHERE Task__r.Deliverables__r.Asset__c !=null AND task__r.project__r.OnStaff_Contract__r.status = 'Activated' AND 
                                                            Actual_Hours__c > 0 AND Task__r.Ticket__c != null AND Timesheet__r.Timesheet_Date__c >= :datesMDT.From__c AND 
                                                            Timesheet__r.Timesheet_Date__c < :datesMDT.To__c AND Task__r.Project__r.OnStaff_Contract__r.Usage_Billing_Date__c = :datesMDT.To__c  AND billable__c = TRUE];
        
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
                
        for(String ContAssId: mapofContrIdwithAssets.keySet()){
                       
            string[] parts;
            parts = ContAssId.split('-');
            system.debug(parts.size());            
            String ContID = parts[0];
            
            System.debug('Product Role::' + mapofContrIdwithAssets.get(ContAssId).Product_Role__c);
            
            cjaInvoice__Invoice_Lineitem__c lt = new  cjaInvoice__Invoice_Lineitem__c();
            lt.cjaInvoice__Invoice__c = mapofContrIdwithInvoice.get(ContID).Id;
            
            if(mapofContrIdwithAssets.get(ContAssId).Free_Hours_per_Role__c > 0 ){
                
                if(mapofContrIdwithAssets.get(ContAssId).Utilised_Hours__c <= mapofContrIdwithAssets.get(ContAssId).Free_Hours_per_Role__c){
                
                    if( mapofContrIdwithAssets.get(ContAssId).Utilised_Hours__c!=null)
                    
                	lt.cjaInvoice__quantity__c = mapofContrIdwithAssets.get(ContAssId).Utilised_Hours__c;
                
                }else{
                    
                     lt.cjaInvoice__quantity__c = mapofContrIdwithAssets.get(ContAssId).Free_Hours_per_Role__c;
                }
                lt.cjaInvoice__rate__c = mapofContrIdwithAssets.get(ContAssId).Hourly_Rate_per_role__c*-1;
            	lt.cjaInvoice__description__c =  lt.cjaInvoice__quantity__c + ' Free Hours of ' + mapofContrIdwithAssets.get(ContAssId).Product_Role__c + ' Time' ;
            
            	ListofInvoiceLineItems.add(lt);
                
            }
        }
        
        //Insert Values to Map
        try{
            insert ListofInvoiceLineItems;
        } catch(Exception e){
            
            System.debug('Exception in Update::' + e.getMessage());  
        }

        UpdateContractDate();
        ContIDwithDates();
        
        //Update MetaData Dates
        //UpdateConfig();
    }
    
    //Create InvoicesLineItems using Timesheet Details
    public static void CreateInvoiceLineItems(Timesheet_Detail__c td){
        //ID for Contract
        String ILIKey = td.task__r.ticket__c + '-' + td.Task__r.Deliverables__r.Asset__c + '-' + td.Task__r.Project__r.OnStaff_Contract__c;
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
            lineItems.cjaInvoice__Rate__c = td.Task__r.Deliverables__r.Asset__r.Hourly_Rate_per_role__c;
            lineItems.cjaInvoice__Description__c = 'Ticket #' + td.task__r.ticket__r.Name +' - Skill Type: '+ td.Task__r.Deliverables__r.Asset__r.Product_Role__c;
            mapofILI.put(ILIKey, lineItems);
            
            System.debug('Map of ILI::' + mapofILI);
        }
    }
    
    //Create Invoices using Timesheet Details
    public static void CreateInvoice(Timesheet_Detail__c td){
        if(!mapofContrIdwithInvoice.containsKey(td.Task__r.Project__r.OnStaff_Contract__c)){    
            cjaInvoice__Customer_Invoice__c Invoice = new cjaInvoice__Customer_Invoice__c();
            Invoice.cjaInvoice__Account__c = td.Task__r.Project__r.OnStaff_Contract__r.AccountID;
            Invoice.cjaInvoice__Billing_Contact__c = td.Task__r.Project__r.OnStaff_Contract__r.Account.cjaInvoice__Billing_Contact__c;
            //Invoice.cjaInvoice__Auto_Bill__c = true;
            Invoice.CJ_Opportunity__c = td.Task__r.Project__r.CJ_Opportunity__c;
            Invoice.cjaInvoice__Invoice_Date__c = datesMDT.To__c;
			System.debug('Invoice Date::' + Invoice.cjaInvoice__Invoice_Date__c);
            Invoice.cjaInvoice__Due_Date__c = datesMDT.Invoice_Due_Date__c;
			System.debug('Invoice Due Date::' + Invoice.cjaInvoice__Due_Date__c);
            Invoice.cjaInvoice__Currency__c = 'CAD';
            Invoice.cjaInvoice__Status__c = 'Draft';
            Invoice.cjaInvoice__Description__c = 'Salesforce Services Charges - '+ getPriorMonthName() + ' ' + getPriorYear();          //Invoice.cjaInvoice__Description__c = td.Task__r.Project__r.OnStaff_Contract__r.Account.Name +' OnStaff Admin '+ td.Task__r.Deliverables__r.Asset__r.Product_Plan__c + ' Plan';
            
            //Account Credit Card Status Logic
            if(Invoice.cjaInvoice__Account__r.cjaInvoice__Credit_Card_Authorization_Status__c == 'Active'){
                Invoice.cjaInvoice__Auto_Bill__c = true; 
            }else{
                Invoice.cjaInvoice__Auto_Bill__c = false;
            }
            
            mapofContrIdwithInvoice.put(td.Task__r.Project__r.OnStaff_Contract__c, Invoice);
            
            //Mapping for Contract Dates
            Contract cont = new Contract();
            cont.Id = td.Task__r.Project__r.OnStaff_Contract__c;
            cont.Usage_Billing_Date__c = td.Task__r.Project__r.OnStaff_Contract__r.Usage_Billing_Date__c;
            cont.Subscription_Billing_Date__c = td.Task__r.Project__r.OnStaff_Contract__r.Subscription_Billing_Date__c;
            cont.Subscription_Billing_Frequency__c = td.Task__r.Project__r.OnStaff_Contract__r.Subscription_Billing_Frequency__c;
            MapofContract.put(td.Task__r.Project__r.OnStaff_Contract__c, cont);
            
        }
    }
    
    //Create Subscription/Contract InvoicesLineItems
    public static void CreateSubscription(){
        List<Contract> listofContract = [SELECT Id, AccountId, Project__c, Subscription_Fees_Monthly__c,Pricebook2Id, Product_Plan__c, Subscription_Billing_Renewal_Date__c, Subscription_Billing_Frequency__c, Subscription_Billing_Date__c, Account.cjaInvoice__Billing_Contact__c, Usage_Billing_Date__c, Frequency__c FROM Contract WHERE Subscription_Billing_Renewal_Date__c = :datesMDT.To__c AND Status = 'Activated'];
        
        System.debug('List of Subscription Contracts::' + listofContract);
        
        for(Contract LoC: listofContract){
            
            CreateSubscriptionInvoice(LoC);
            
            if(mapofContrIdwithILI.get(LoC.Id)==null){
                integer frequencyInt = Integer.valueOf(LoC.Frequency__c);
 				               
               	DateTime dt = LoC.Subscription_Billing_Renewal_Date__c;
                System.debug('Full Month Name ===> '+dt.format('dd MMMM yyyy'));
                
                Integer subfrequencyInt = Integer.valueOf(LoC.Subscription_Billing_Frequency__c);
                DateTime nextdate = LoC.Subscription_Billing_Renewal_Date__c.addMonths(subfrequencyInt);
                DateTime dt2= nextdate.addMonths(frequencyInt).addDays(-1);
                System.debug('Full Next Month Name ===> '+dt2.format('dd MMMM yyyy'));
                
				//date dateCalforDesc = td.Project__r.OnStaff_Contract__r.Subscription_Billing_Renewal_Date__c.addmonths(td.Project__r.OnStaff_Contract__r.Frequency__c);
                
                cjaInvoice__Invoice_Lineitem__c lineItems = new cjaInvoice__Invoice_Lineitem__c();
                lineItems.cjaInvoice__Quantity__c = LoC.Subscription_Billing_Frequency__c;
                lineItems.cjaInvoice__Rate__c = LoC.Subscription_Fees_Monthly__c;
                //lineItems.cjaInvoice__Description__c = 'Subscription Charges for '+ dt.format('MMMM') + ' ('+ LoC.Subscription_Billing_Renewal_Date__c + '-' + LoC.Subscription_Billing_Date__c.addmonths(frequencyInt)+')';
                lineItems.cjaInvoice__Description__c = 'Subscription Charges of '+ dt.format('dd MMMM yyyy') + ' - ' + dt2.format('dd MMMM yyyy');
                
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
            Invoice.cjaInvoice__Invoice_Date__c = datesMDT.To__c;
            Invoice.cjaInvoice__Due_Date__c = datesMDT.Invoice_Due_Date__c;
            Invoice.cjaInvoice__Currency__c = 'CAD';
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
            if(cont.Subscription_Billing_Renewal_Date__c == datesMDT.To__c){
                cont.Subscription_Billing_Date__c = cont.Subscription_Billing_Renewal_Date__c;
            }
            
            MapofContract.put(ContractId, cont);
        }
        
        ContIDs();
        
        try{
            Update MapofContract.values();
        }catch(Exception e){
            
            System.debug('Exception in Update::' + e.getMessage());  
        }
    }
    
    public static void ContractwithAsset(Timesheet_Detail__c td){
        
        String ContAssetKey = td.Task__r.Project__r.OnStaff_Contract__c + '-' + td.Task__r.Deliverables__r.Asset__c;
        System.debug('Contract + Asset Key::' + ContAssetKey);
        
        //If ContAssetKey Exist
        if(mapofContrIdwithAssets.get(ContAssetKey)!=null){
            //Assignment of Assets
            Asset aset = mapofContrIdwithAssets.get(ContAssetKey);
            aset.Utilised_Hours__c += td.Actual_Hours__c;
            mapofContrIdwithAssets.put(ContAssetKey, aset);
            
            //If ContAssetKey does not Exist    
        }else{
            //Initialization of Assets
            Asset aset = new Asset();
            aset.Utilised_Hours__c = td.Actual_Hours__c;
            aset.PurchaseDate = td.Task__r.Deliverables__r.Asset__r.PurchaseDate;
            aset.Hourly_Rate_per_role__c = td.Task__r.Deliverables__r.Asset__r.Hourly_Rate_per_role__c;
            aset.Free_Hours_per_Role__c = td.Task__r.Deliverables__r.Asset__r.Free_Hours_per_Role__c;
            aset.Product_Role__c = td.Task__r.Deliverables__r.Asset__r.Product_Role__c;
            mapofContrIdwithAssets.put(ContAssetKey, aset);
            
            
            System.debug('Map of Assets with Contract::' + mapofContrIdwithAssets);
        }
    }
    
    public static void ContIDs(){
        
        List<Contract> ListofContract  = [SELECT Id, Usage_Billing_Date__c, BillingDate__c from Contract WHERE Id !=: mapofContrIdwithInvoice.keySet()];
        
        for(Contract cID: ListofContract){
            Contract contrat = cID;
            if(cID.Usage_Billing_Date__c == datesMDT.To__c){
            	contrat.Usage_Billing_Date__c = cID.Usage_Billing_Date__c.addmonths(1);
            }
                MapofContract.put(contrat.Id, contrat);
        }
    }
    
    public static void ContIDwithDates(){
        
        List<Asset> ListofAssetDates  = [SELECT Id, PurchaseDate, InstallDate, Frequency_Month_per_Role__c, Contract__r.Usage_Billing_Date__c, Contract__r.BillingDate__c from Asset WHERE PurchaseDate <=: datesMDT.To__c];
        
        for(Asset aset: ListofAssetDates){
            System.debug('For Loop:: '+aset);    
            //Asset aset = asetD;
			System.debug('Frequency Month Per Role:: '+ aset.Frequency_Month_per_Role__c);
            if(aset.Frequency_Month_per_Role__c != Null && aset.PurchaseDate != Null){
            	integer frequencyInt = Integer.valueOf(aset.Frequency_Month_per_Role__c);
                System.debug('Frequency Int:: '+frequencyInt);
                aset.PurchaseDate = aset.PurchaseDate.addMonths(frequencyInt);
                System.debug('Purchase Date:: '+aset.PurchaseDate); 
            }   
        }
        
        UPDATE ListofAssetDates;
    }
    
    /*
    
    public static void UpdateConfig(){
        List<Metadata.CustomMetadataValue> metadatafields = new List<Metadata.CustomMetadataValue>();
                
        //Updating Custom MetaData Fields
        metadatafields.add(createCustomMetadataField('To__c',datesMDT.To__c.addmonths(1)));
        metadatafields.add(createCustomMetadataField('From__c', datesMDT.From__c.addmonths(1)));
        metadatafields.add(createCustomMetadataField('Invoice_Due_Date__c', datesMDT.Invoice_Due_Date__c.addmonths(1)));
    

        upsertMetaData('Dates', 'Custom Invoice',metadatafields);
    }
    
     public static void upsertMetaData(String fullName, String Label,List<Metadata.CustomMetadataValue> fields){
        String nameSpacePrefix = '';
        
        // Set up custom metadata to be created in the subscriber org.
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        customMetadata.fullName = nameSpacePrefix + 'Custom_Invoice__mdt.'+fullName; //fullName;
        customMetadata.label = Label;
    
        /*Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
    	
        customMetadata.values.addAll(fields);

        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);
    
        // Setup deploy callback, MyDeployCallback implements
        // the Metadata.DeployCallback interface (code for this class not shown in this example)
        TimeSheetCal callback = new TimeSheetCal();
    
        // Enqueue custom metadata deployment
        // jobId is the deployment ID
        Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
        system.debug('JobID::'+jobId);
    }
    
   /* public static Metadata.CustomMetadataValue createCustomMetadataField(String field,Date fieldValue){
        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        customField.field = field;
        customField.value = fieldValue;
        return customField;
    }
    
    public void handleResult(Metadata.DeployResult result, Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            System.debug('Success: '+ result);
        } else {
            // Deployment was not successful
            System.debug('Fail: '+ result);
        }
    }
*/
    
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