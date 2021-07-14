public class TimesheetInvoice {
    
    //Testing List
    public static List<String> listofInt = new List<String>();
    
    //Map for AccID+TicketNo+SkillType Against ActualHours
    public static Map<String, Decimal> mapofAccTkSkwithTotalhrs = new Map<String, Decimal>();
    
    //Map for Ticket
    public static Map<String, Issue__c> mapofTicket = new Map<String, Issue__c>();
    
    //Map for Invoice
    public static Map<String, cjaInvoice__Customer_Invoice__c> mapofInvoice = new Map<String, cjaInvoice__Customer_Invoice__c>();
    
    //Map for InvoiceLineItems with totalAmount 
    public static Map<String, cjaInvoice__Invoice_Lineitem__c> mapofInvoiceLineItemswithTotalAmount = new Map<String, cjaInvoice__Invoice_Lineitem__c>();
    
    //Map for InvoicewithTotalDiscount
    public static Map<String, Decimal> mapofInvoicewithTotalDiscount = new Map<String, Decimal>();
    
    //List for InvoiceLineItems
    public static List<cjaInvoice__Invoice_Lineitem__c> ListofInvoiceLineItems = new List<cjaInvoice__Invoice_Lineitem__c>();
    
    //List for MergeLineItems 
    public static List<cjaInvoice__Invoice_Lineitem__c> ListofMergeInvoiceLineItems = new List<cjaInvoice__Invoice_Lineitem__c>();
    
    //Custom MetaData Type Date
    public static Custom_Invoice__mdt datesMDT = new  Custom_Invoice__mdt();//[Select id, label, From__c, To__c, Invoice_Due_Date__c from Custom_Invoice__mdt where MasterLabel = 'Custom Invoice' limit 1 ];    
    
    public static List<Timesheet_Detail__c> listofTimesheetDetails = new List<Timesheet_Detail__c>();
    
    public static String Scope = '';
    
    public static String TicketId = '';
    
    public static List<String> generateWishListInvoices(String Scope, String TicketId , Date fromDate , Date to, Date due){
        
        datesMDT.From__c = fromDate;
        datesMDT.To__c = to;
        datesMDT.Invoice_Due_Date__c = due;
        
        
        TimesheetInvoice.Scope = Scope;
        TimesheetInvoice.TicketId = TicketId;
        
        Id RecordType = Schema.SObjectType.Issue__c.getRecordTypeInfosByName().get('Wishlist Item / Enhancement Request').getRecordTypeId();
        
        System.debug('RecordID::' + RecordType);
        
        System.debug('Metdata Key::' + datesMDT);
        
        //AND Timesheet__r.Timesheet_Date__c < :datesMDT.To__c
        
        if(scope == 'Billable'  && ticketId == null){
            
            System.debug('Billable');    
            
            listofTimesheetDetails = [SELECT Skill_Type__c, 
                                      Actual_Hours__c,
                                      Task__r.Ticket__r.Customer_Account__c,
                                      Task__r.Ticket__r.Customer_Account__r.cjaInvoice__Billing_Contact__c,
                                      Task__r.Ticket__r.Customer_Account__r.cjaInvoice__Credit_Card_Authorization_Status__c,
                                      Task__r.Ticket__r.Name,
                                      Task__r.Ticket__r.Admin_Hourly_Rate_M__c, 
                                      Task__r.Ticket__r.Consultant_Hourly_Rate_Manual__c,
                                      Task__r.Ticket__r.Total_Invoiced_Amount__c,
                                      Task__r.Ticket__r.Architect_Hourly_Rate_Manual__c,
                                      Task__r.Ticket__r.CurrencyIsoCode
                                      FROM Timesheet_Detail__c 
                                      WHERE (Task__r.Ticket__r.In_Scope__c =: 'Yes - Billable' OR Task__r.Ticket__r.In_Scope__c =: 'No - Billable')
                                      AND Task__r.Ticket__r.Wishlist_Item__c !=: 'Time & Material' 
                                      AND Task__r.Ticket__r.Wishlist_Item__c !=: 'Time & Material' 
                                      AND Task__r.Ticket__r.Invoice_Type__c =: 'Auto-Generate'
                                      AND billable__c = true 
                                      AND Task__r.Ticket__r.RecordTypeId =: RecordType 
                                      AND Task__r.Ticket__c != null
                                      AND Task__r.Ticket__r.Admin_Hourly_Rate_M__c != null
                                      AND Task__r.Ticket__r.Consultant_Hourly_Rate_Manual__c != null
                                      AND Task__r.Ticket__r.Architect_Hourly_Rate_Manual__c != null
                                      AND Timesheet__r.Timesheet_Date__c >= :datesMDT.From__c
                                      AND Timesheet__r.Timesheet_Date__c < :datesMDT.To__c 
                                     ];
            
            System.debug('Timesheet Details::' + listofTimesheetDetails );
            
            
        }
        
        else if(scope == 'Non-Billable' && ticketId == null){
            
            System.debug('Non Billable' + scope); 
            
            listofTimesheetDetails = [SELECT Skill_Type__c, 
                                      Actual_Hours__c,
                                      Task__r.Ticket__r.Customer_Account__c,
                                      Task__r.Ticket__r.Customer_Account__r.cjaInvoice__Billing_Contact__c,
                                      Task__r.Ticket__r.Customer_Account__r.cjaInvoice__Credit_Card_Authorization_Status__c,
                                      Task__r.Ticket__r.Name,
                                      Task__r.Ticket__r.Admin_Hourly_Rate_M__c, 
                                      Task__r.Ticket__r.Total_Invoiced_Amount__c,
                                      Task__r.Ticket__r.Consultant_Hourly_Rate_Manual__c, 
                                      Task__r.Ticket__r.Architect_Hourly_Rate_Manual__c,
                                      Task__r.Ticket__r.CurrencyIsoCode
                                      FROM Timesheet_Detail__c 
                                      WHERE (Task__r.Ticket__r.In_Scope__c =: 'Yes - Non-Billable' OR Task__r.Ticket__r.In_Scope__c =: 'No - Non-Billable')
                                      AND Task__r.Ticket__r.Wishlist_Item__c !=: 'Time & Material'
                                      AND billable__c = true 
                                      AND Task__r.Ticket__r.RecordTypeId =: RecordType 
                                      AND Task__r.Ticket__c != null
                                      AND Task__r.Ticket__r.Admin_Hourly_Rate_M__c != null
                                      AND Task__r.Ticket__r.Invoice_Type__c =: 'Auto-Generate'
                                      AND Task__r.Ticket__r.Consultant_Hourly_Rate_Manual__c != null
                                      AND Task__r.Ticket__r.Architect_Hourly_Rate_Manual__c != null
                                      AND Task__r.Ticket__r.Resolution_Date__c >=: datesMDT.From__c 
                                      AND Task__r.Ticket__r.Resolution_Date__c <: datesMDT.To__c ];
            
            System.debug('Timesheet Details::' + listofTimesheetDetails );
            
        }
        
        else if(scope == null && TicketId != null){
            
            listofTimesheetDetails = [SELECT Skill_Type__c, 
                                      Actual_Hours__c,
                                      Task__r.Ticket__r.Customer_Account__c,
                                      Task__r.Ticket__r.Customer_Account__r.cjaInvoice__Billing_Contact__c,
                                      Task__r.Ticket__r.Customer_Account__r.cjaInvoice__Credit_Card_Authorization_Status__c,
                                      Task__r.Ticket__r.Name,
                                      Task__r.Ticket__r.Total_Invoiced_Amount__c,
                                      Task__r.Ticket__r.Admin_Hourly_Rate_M__c, 
                                      Task__r.Ticket__r.Consultant_Hourly_Rate_Manual__c, 
                                      Task__r.Ticket__r.Architect_Hourly_Rate_Manual__c,
                                      Task__r.Ticket__r.CurrencyIsoCode
                                      FROM Timesheet_Detail__c 
                                      WHERE Task__r.Ticket__c =: TicketId
                                      AND billable__c = true 
                                      AND Task__r.Ticket__r.RecordTypeId =: RecordType 
                                      AND Task__r.Ticket__c != null
                                      AND Task__r.Ticket__r.Admin_Hourly_Rate_M__c != null
                                      AND Task__r.Ticket__r.Wishlist_Item__c !=: 'Time & Material'
                                      AND Task__r.Ticket__r.Invoice_Type__c !=: 'Auto-Generate'
                                      AND Task__r.Ticket__r.Consultant_Hourly_Rate_Manual__c != null
                                      AND Task__r.Ticket__r.Architect_Hourly_Rate_Manual__c != null
                                      AND Task__r.Ticket__r.Resolution_Date__c >=: datesMDT.From__c 
                                      AND Task__r.Ticket__r.Resolution_Date__c <: datesMDT.To__c ];
            
            System.debug('Timesheet Details::' + listofTimesheetDetails );
            
        }
        /*
        else if(scope == 'Time & Material'){
            
            listofTimesheetDetails = [SELECT Skill_Type__c, 
                                      Actual_Hours__c,
                                      Task__r.Ticket__r.Customer_Account__c,
                                      Task__r.Ticket__r.Customer_Account__r.cjaInvoice__Billing_Contact__c,
                                      Task__r.Ticket__r.Customer_Account__r.cjaInvoice__Credit_Card_Authorization_Status__c,
                                      Task__r.Ticket__r.Name,
									  Task__r.Ticket__r.Total_Invoiced_Amount__c,
                                      Task__r.Ticket__r.Admin_Hourly_Rate_M__c, 
                                      Task__r.Ticket__r.Consultant_Hourly_Rate_Manual__c, 
                                      Task__r.Ticket__r.Architect_Hourly_Rate_Manual__c 
                                      FROM Timesheet_Detail__c 
                                      WHERE (Task__r.Ticket__r.In_Scope__c =: 'Yes - Billable' OR Task__r.Ticket__r.In_Scope__c =: 'No - Billable')
                                      AND Task__r.Ticket__r.Wishlist_Item__c =: 'Time & Material'
                                      AND billable__c = true 
                                      AND Task__r.Ticket__r.RecordTypeId =: RecordType 
                                      AND Task__r.Ticket__c != null
                                      AND Task__r.Ticket__r.Admin_Hourly_Rate_M__c != null
                                      AND Task__r.Ticket__r.Consultant_Hourly_Rate_Manual__c != null
                                      AND Task__r.Ticket__r.Architect_Hourly_Rate_Manual__c != null];
            
            System.debug('Timesheet Details::' + listofTimesheetDetails );
            generateTMInvoice(listofTimesheetDetails);

            listofTimesheetDetails = new List<Timesheet_Detail__c>();
			            
        }
        */
        
        for(Timesheet_Detail__c td: listofTimesheetDetails){
 
            System.debug('Skill Type::' + td.Skill_Type__c + ' Account::' 
                         + td.Task__r.Ticket__r.Customer_Account__c + ' Actual Hours::' + td.Actual_Hours__c 
                         + ' Name::' + td.Task__r.Ticket__r.Name + ' Admin Hours Rate::' 
                         + td.Task__r.Ticket__r.Admin_Hourly_Rate_M__c + ' Consultant Hours Rate::' 
                         + td.Task__r.Ticket__r.Consultant_Hourly_Rate_Manual__c 
                         + ' Architect Hours Rate::' + td.Task__r.Ticket__r.Architect_Hourly_Rate_Manual__c);
            createMap(td);
            createTicketMap(td);
            CreateInvoice(td);
        }
        
        
        
        insertInvoices();
        
        for(String keyofAccTkSk : mapofAccTkSkwithTotalhrs.keyset()){
            CreateInvoiceLineItems(keyofAccTkSk); 
        }
        
        if(Scope == 'Non-Billable'){
            mergeDiscountedInvoiceLineItems();
        }
        
        System.debug('MapofInvoices::' + mapofInvoice);
        insertDiscountedInvoiceLineItems();
        System.debug('ListofInvoiceLineItems::' + ListofInvoiceLineItems);
        
        listofInt.add('' + mapofInvoice.size());
        
        return listofInt;
        
    }
    
    public static void createMap(Timesheet_Detail__c td){
        
        String key = td.Task__r.Ticket__r.Name + '-' + td.Task__r.Ticket__r.Customer_Account__c + '-' + td.Skill_Type__c;
        System.debug('Key::' + key);
        
        if(mapofAccTkSkwithTotalhrs.get(Key)!=null){
            Decimal totalHrs = td.Actual_Hours__c + mapofAccTkSkwithTotalhrs.get(key);
            mapofAccTkSkwithTotalhrs.put(Key, totalhrs);
        }else{
            mapofAccTkSkwithTotalhrs.put(Key, td.Actual_Hours__c);
        }
    }
    
    public static void createTicketMap(Timesheet_Detail__c td){
        
        if(td.Task__r.Ticket__c != null){
            
            Issue__c ticket = new Issue__c();
            ticket.Id = td.Task__r.Ticket__c;
            ticket.Admin_Hourly_Rate_M__c = td.Task__r.Ticket__r.Admin_Hourly_Rate_M__c;
            ticket.Consultant_Hourly_Rate_Manual__c =  td.Task__r.Ticket__r.Consultant_Hourly_Rate_Manual__c; 
            ticket.Architect_Hourly_Rate_Manual__c = td.Task__r.Ticket__r.Architect_Hourly_Rate_Manual__c; 
            ticket.Customer_Account__c = td.Task__r.Ticket__r.Customer_Account__c;
            ticket.Total_Invoiced_Amount__c = td.Task__r.Ticket__r.Total_Invoiced_Amount__c;
            //ticket.name = td.Task__r.Ticket__r.Name;
            
            mapofTicket.put(td.Task__r.Ticket__r.Name, ticket);
            
        }
    }
    
    //Create Invoices using Timesheet Details
    public static void CreateInvoice(Timesheet_Detail__c td){
        
        if(td.Task__r.Ticket__r.Customer_Account__c != null){
            cjaInvoice__Customer_Invoice__c invoice = new cjaInvoice__Customer_Invoice__c();
            invoice.cjaInvoice__Account__c = td.Task__r.Ticket__r.Customer_Account__c;
            invoice.cjaInvoice__Billing_Contact__c = td.Task__r.Ticket__r.Customer_Account__r.cjaInvoice__Billing_Contact__c;
            invoice.cjaInvoice__Due_Date__c = datesMDT.Invoice_Due_Date__c;
            invoice.cjaInvoice__Invoice_Date__c = datesMDT.To__c;
            invoice.CurrencyIsoCode = td.Task__r.Ticket__r.CurrencyIsoCode;
            
            if(scope == 'Billable'){
                
                invoice.cjaInvoice__Description__c = 'Wishlist / Enhancements - Service Charges ' + getPriorMonthName()+' '+ getPriorYear();
                
            }
            else if(scope == 'Non-Billable'){
                
                invoice.cjaInvoice__Description__c = '100% Discount - Wishlist / Enhancements ' + getPriorMonthName()+' '+ getPriorYear();
                
                
            }
            else if(scope == null && TicketId !=null){
                
                invoice.cjaInvoice__Description__c = 'Wishlist / Enhancements Ticket #'+ td.Task__r.Ticket__r.Name  +' - Service Charges May 2021';
                
            }
            
            if(td.Task__r.Ticket__r.Customer_Account__r.cjaInvoice__Credit_Card_Authorization_Status__c == 'Active'){
                invoice.cjaInvoice__Auto_Bill__c = True;
            }
            
            mapofInvoice.put(td.Task__r.Ticket__r.Customer_Account__c, invoice);
        }
        
    }
    
    //Create Invoice Line Items using Timesheet Details
    public static void CreateInvoiceLineItems(String key){ 
        
        //Spliting the ILIKey to get Contract ID
        string[] parts;
        parts = key.split('-');
        system.debug(parts.size());            
        String ticketKey = parts[0];
        String accKey = parts[1];
        String skillKey = parts[2];
        
        System.debug('Account Key::' + accKey);
        System.debug('Ticket Key::' + ticketKey);
        System.debug('Skill Key::' + skillKey);
        
        cjaInvoice__Invoice_Lineitem__c lineItems = new  cjaInvoice__Invoice_Lineitem__c();
        System.debug('MapofInvoice with ID (126):: '+ mapofInvoice.get(accKey).Id);
        lineItems.cjaInvoice__Invoice__c = mapofInvoice.get(accKey).Id;
        
        Issue__c ticket = new  Issue__c();            
        ticket = mapofTicket.get(ticketKey);
        
        lineItems.cjaInvoice__Quantity__c = mapofAccTkSkwithTotalhrs.get(key);
        lineItems.cjaInvoice__Description__c = 'Ticket #' +ticketKey+' - Skill Type: '+skillKey;
        lineItems.CurrencyIsoCode = mapofInvoice.get(accKey).CurrencyIsoCode;
        lineItems.Ticket__c = ticket.Id;
        
        if(skillKey == 'Admin'){
            lineItems.cjaInvoice__Rate__c = ticket.Admin_Hourly_Rate_M__c;             
        } else if(skillKey == 'Consultant'){
            lineItems.cjaInvoice__Rate__c = ticket.Consultant_Hourly_Rate_Manual__c;
        } else if(skillKey == 'Architect'){
            lineItems.cjaInvoice__Rate__c = ticket.Architect_Hourly_Rate_Manual__c;
        }
        
        //Add into List;
        ListofInvoiceLineItems.add(lineItems);
        
        totalDiscountAmount(lineItems);
    }
    
    public static void totalDiscountAmount(cjaInvoice__Invoice_Lineitem__c ILI){
        
        if(mapofInvoiceLineItemswithTotalAmount.get(ILI.cjaInvoice__Invoice__c) != null){
            
            cjaInvoice__Invoice_Lineitem__c IL = mapofInvoiceLineItemswithTotalAmount.get(ILI.cjaInvoice__Invoice__c);
            System.debug('Total Amount in MAP::' + mapofInvoiceLineItemswithTotalAmount.get(ILI.cjaInvoice__Invoice__c).cjaInvoice__Rate__c);
            Decimal totalAmount = mapofInvoiceLineItemswithTotalAmount.get(ILI.cjaInvoice__Invoice__c).cjaInvoice__Rate__c;
            System.debug('Existed Value::' + totalAmount);
            Decimal amountToAdd = (ILI.cjaInvoice__Quantity__c * ILI.cjaInvoice__Rate__c)*-1;
            System.debug('Amount to Add::' + amountToAdd);   
            Decimal TotalDiscountedAmount = totalAmount+ amountToAdd;
            
            System.debug('Total Discounted Amount::' + TotalDiscountedAmount);
            IL.cjaInvoice__Rate__c  =  TotalDiscountedAmount;
            
            mapofInvoiceLineItemswithTotalAmount.put(ILI.cjaInvoice__Invoice__c, IL);
            
            System.debug('Data in Map::' + mapofInvoiceLineItemswithTotalAmount );
            System.debug('Size of Map::' + mapofInvoiceLineItemswithTotalAmount.size());
            
        }else{
            
            cjaInvoice__Invoice_Lineitem__c IL = new cjaInvoice__Invoice_Lineitem__c();
            IL.cjaInvoice__Rate__c  = ((ILI.cjaInvoice__Quantity__c * ILI.cjaInvoice__Rate__c) * -1); 
            IL.cjaInvoice__Quantity__c = 1;
            IL.cjaInvoice__Description__c = '100% Courtesy Discount';
            IL.cjaInvoice__Invoice__c = ILI.cjaInvoice__Invoice__c;
            IL.CurrencyIsoCode = ILI.CurrencyIsoCode;
            
            System.debug('mapofInvoiceLineItemswithTotalAmount Invoice ID'+ IL.cjaInvoice__Invoice__c);
            
            mapofInvoiceLineItemswithTotalAmount.put(ILI.cjaInvoice__Invoice__c, IL);       
            
            System.debug('Data in Map::' + mapofInvoiceLineItemswithTotalAmount );
            System.debug('Size of Map::' + mapofInvoiceLineItemswithTotalAmount.size());
            
        }   
    }
    
    public static void mergeDiscountedInvoiceLineItems(){
        
        
        System.debug('ListofInvoiceLineItems' + ListofInvoiceLineItems);
        
        //ListofMergeInvoiceLineItems.addAll(ListofInvoiceLineItems);
        if(!mapofInvoiceLineItemswithTotalAmount.isEmpty()){
            
            System.debug('ILI to Deduct::' + mapofInvoiceLineItemswithTotalAmount.values());
            ListofInvoiceLineItems.addAll(mapofInvoiceLineItemswithTotalAmount.values());
        }
        
        /*
System.debug('Merge ILI::' + ListofInvoiceLineItems);
System.debug('Size Of MERGEList Before Insert::' + ListofMergeInvoiceLineItems.size());
System.debug('Size Of LIST Before Insert::' + ListofInvoiceLineItems.size());
System.debug('Size Of MAP Before Insert::' + mapofInvoiceLineItemswithTotalAmount.size());
//System.debug('Merge Map of ILI::' + mapofInvoiceLineItemswithTotalAmount + ' Size::' + mapofInvoiceLineItemswithTotalAmount.size());

ListofMergeInvoiceLineItems.addAll(ListofInvoiceLineItems);
ListofMergeInvoiceLineItems.add(mapofInvoiceLineItemswithTotalAmount.values());

//ListofInvoiceLineItems.add(mapofInvoiceLineItemswithTotalAmount.values());

System.debug('Merge ILI::' + ListofInvoiceLineItems);
System.debug('Size Of List After Insert::' + ListofMergeInvoiceLineItems.size());
System.debug('Data in Merge List::' + ListofMergeInvoiceLineItems);
//System.debug('Merge Map of ILI::' + mapofInvoiceLineItemswithTotalAmount + ' Size::' + mapofInvoiceLineItemswithTotalAmount.size());
*/   
    }
    
    public static void insertInvoices(){
        
        System.debug('MapofInvoices::' + mapofInvoice);
        
        //trycatch insert invoices
        try{
            INSERT mapofInvoice.values();
            System.debug('mapofInvoices::' + mapofInvoice);
        }catch(Exception e){
            System.debug('Inserting Invoices ERROR::' + e.getMessage());
        }
    }
    
    public static void insertDiscountedInvoiceLineItems(){
        system.debug('Invoice LIne Items to Insert' + ListofInvoiceLineItems);
        
        system.debug('Invoice LIne Items to Insert Size::' + ListofInvoiceLineItems.size());
        
        //trycatch insert invoiceLineItems
        try{
            INSERT ListofInvoiceLineItems;
            //INSERT ListofInvoiceLineItems;
            System.debug('ListofILI::' + ListofInvoiceLineItems);
        }catch(Exception e){
            System.debug('Inserting LIST InvoiceLineItems ERROR::' + e.getMessage());
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
    
    /*
    public static void generateTMInvoice(List<Timesheet_Detail__c> listOfTD){
        
        Map<String, List<cjaInvoice__Invoice_Lineitem__c>> MapofInvoiceLineItems = new Map<String, List<cjaInvoice__Invoice_Lineitem__c>>();
        
        for(Timesheet_Detail__c td: listOfTD){
            
            createMap(td);
            createTicketMap(td);
            CreateInvoice(td);
            
        }
        
        MapofInvoiceLineItems = getMapOfILI();
        
    }
    
    public static Map<String, List<cjaInvoice__Invoice_Lineitem__c>> getMapOfILI(){
        
        
        ListofInvoiceLineItems = new List<cjaInvoice__Invoice_Lineitem__c>();
        
         Map<String, List<cjaInvoice__Invoice_Lineitem__c>> MapofInvoiceLineItems = new Map<String, List<cjaInvoice__Invoice_Lineitem__c>>();
      	 Map<String, Decimal> mapOfTicketTA = new Map<String, Decimal>();
        
          for(String key: mapofAccTkSkwithTotalhrs.keySet()){
            
                string[] parts;
                parts = key.split('-');
                system.debug(parts.size());            
                String ticketKey = parts[0];
                String accKey = parts[1];
                String skillKey = parts[2];
              	Decimal totalAmount = 0;
                  
                Issue__c ticket = new  Issue__c();            
                ticket = mapofTicket.get(ticketKey);
                
                if(skillKey == 'Admin'){
                        totalAmount = ticket.Admin_Hourly_Rate_M__c * mapofAccTkSkwithTotalhrs.get(key);             
                    } else if(skillKey == 'Consultant'){
                        totalAmount = ticket.Consultant_Hourly_Rate_Manual__c * mapofAccTkSkwithTotalhrs.get(key);
                    } else if(skillKey == 'Architect'){
                        totalAmount = ticket.Architect_Hourly_Rate_Manual__c * mapofAccTkSkwithTotalhrs.get(key);
                    }
                    
              
              if(mapofAccTkSkwithTotalhrs.get(key)!=null){
                  
                   if(mapOfTicketTA.get(ticketKey)>0){
                    
                       System.debug('Ticket Key::' + mapOfTicketTA.get(ticketKey));
                    	mapOfTicketTA.put( ticketKey, mapOfTicketTA.get(ticketKey)+totalAmount);    
                   }
                   else{
                       System.debug('Ticket Key::' + mapOfTicketTA.get(ticketKey));
                    mapOfTicketTA.put( ticketKey, totalAmount);     
                    
                }
              }
          }
        
        // Insert Invoice
          insert mapofInvoice.values();
        
          for(String key: mapofAccTkSkwithTotalhrs.keySet()){
            
            if(mapofAccTkSkwithTotalhrs.get(key)!=null){
                
                string[] parts;
                parts = key.split('-');
                system.debug(parts.size());            
                String ticketKey = parts[0];
                String accKey = parts[1];
                String skillKey = parts[2];
                
                System.debug('Account Key::' + accKey);
                System.debug('Ticket Key::' + ticketKey);
                System.debug('Skill Key::' + skillKey);
                
                    cjaInvoice__Invoice_Lineitem__c lineItems = new  cjaInvoice__Invoice_Lineitem__c();
                    System.debug('MapofInvoice with ID (126):: '+ mapofInvoice.get(accKey).Id);
                    lineItems.cjaInvoice__Invoice__c = mapofInvoice.get(accKey).Id;
                    
                    Issue__c ticket = new  Issue__c();            
                    ticket = mapofTicket.get(ticketKey);
                    
                if(ticket.Total_Invoiced_Amount__c < mapOfTicketTA.get(ticketKey) ){
                
                    	System.debug('Ticket Key::' + mapofAccTkSkwithTotalhrs.get(key));
                        lineItems.cjaInvoice__Quantity__c = mapofAccTkSkwithTotalhrs.get(key);
                        lineItems.cjaInvoice__Description__c = 'Ticket #' +ticketKey+' - '+skillKey;
                        lineItems.Ticket__c = ticket.Id;
                        
                        if(skillKey == 'Admin'){
                            lineItems.cjaInvoice__Rate__c = ticket.Admin_Hourly_Rate_M__c; 
                            
                        } else if(skillKey == 'Consultant'){
                            lineItems.cjaInvoice__Rate__c = ticket.Consultant_Hourly_Rate_Manual__c;
                        } else if(skillKey == 'Architect'){
                            lineItems.cjaInvoice__Rate__c = ticket.Architect_Hourly_Rate_Manual__c;
                        }
                        
                    
                   ListofInvoiceLineItems.add(lineItems);
                   }
            }
        }
        
          	
        
         System.debug('Map of Invoice::' + mapOfInvoice);	
        
          // Deduct Upfront Amount
          for(String ticketKey: mapOfTicketTA.keySet()){
                
               cjaInvoice__Invoice_Lineitem__c lineItems = new  cjaInvoice__Invoice_Lineitem__c();
               System.debug(mapofTicket + 'Map for that key::' + mapofTicket.get(ticketKey));
               System.debug('MapofInvoice with ID (126):: '+ mapofInvoice.get(mapofTicket.get(ticketKey).Customer_Account__c).Id);
                    
               Issue__c ticket = new  Issue__c();            
               ticket = mapofTicket.get(ticketKey);
                    System.debug('Ticket Total::' + mapOfTicketTA.get(ticketKey) + 'Total Invoiced Amount::' + ticket.Total_Invoiced_Amount__c);
 	             if(ticket.Total_Invoiced_Amount__c < mapOfTicketTA.get(ticketKey) ){
                
                     
                     System.debug('Deduct Upfront Amount::' + ticket.Total_Invoiced_Amount__c);
                        lineItems.cjaInvoice__Quantity__c = 1;
                        lineItems.cjaInvoice__Description__c = 'Deduct Upfront Amount #' +ticketKey;
						lineItems.cjaInvoice__Invoice__c =  mapofInvoice.get(mapofTicket.get(ticketKey).Customer_Account__c).Id;                        
                        lineItems.cjaInvoice__Rate__c = ticket.Total_Invoiced_Amount__c * -1;
                     	ListofInvoiceLineItems.add(lineItems);
          			}
          }	
        
        insert ListofInvoiceLineItems;
        return MapofInvoiceLineItems;
    }*/
    
}