public class accountTicket {
    
    @AuraEnabled
    public static Issue__c getTicket(string TicketId)
    {
        system.debug(TicketId);
        Issue__c ticket = new Issue__c();
        if(TicketId != null)
        {
            list<Issue__c> lstTicket = [SELECT Id,Name,Customer_Account__c,Customer_Account__r.Instructions_on_Ticket__c FROM Issue__c where id=: TicketId];
            
            if(lstTicket.size()>0)
                ticket = lstTicket[0];   
        }
        system.debug(ticket);
        return ticket; 
	}

}