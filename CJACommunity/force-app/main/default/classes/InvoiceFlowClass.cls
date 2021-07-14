/**
* 
* Description: Getting From, To, Due Dates and Invoice Type from Flow.
* Author : M Tiham Siddiqui @ CloudJunction
* Created Date : 16-06-2020
* Last Modified Date : 22-06-2020
* Last Modified By : M Tiham Siddiqui @ CloudJunction
* 
**/

global class InvoiceFlowClass {
    
    /*An invocable variable used as input or output variables in the flow*/
    global class FlowInputs {
        
        @InvocableVariable
        public Date fromDate;
        
        @InvocableVariable
        public Date toDate;
        
        @InvocableVariable
        public Date dueDate;
        
        @InvocableVariable
        public String invoiceType;
        
        @InvocableVariable
        public String ticketId;
    }
    
    @InvocableMethod(label = 'Invoke Class')
    global static List <String> flowMethod(List <FlowInputs> requests) {
        
        Date frod;
        Date to;
        Date due;
        String type;
        String ticket_Id;
		List<String> result = new List<String>();
        
        for (FlowInputs requestObj: requests) {
            
            frod = requestObj.fromDate;
            to = requestObj.toDate;
            due = requestObj.dueDate;
            type = requestObj.invoiceType;
            ticket_Id = requestObj.ticketId;
            
            //Accessing the values from flow when record is inserted
            System.debug('From Date::' + requestObj.fromDate);
            System.debug('To Date::' + requestObj.toDate);
            System.debug('Due Date::' + requestObj.dueDate);  
            System.debug('Invoice Type::' + requestObj.invoiceType); 
            System.debug('Ticket Id::' + requestObj.ticketId); 
        }
        
        if(type == 'OnStaff'){
            OnstaffInvoiceGenerationbySubscription.generateOnstaffInvoice(frod, to, due);
        } else{
            result = TimesheetInvoice.generateWishListInvoices(type, ticket_Id, frod, to, due);
        } 
        
        
        return result;
    } 
}