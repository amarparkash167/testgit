/*
* 
* Description: Controller for Email Template for Estimate Approval for OnStaff Ticket.
* Author : M Tiham Siddiqui - CloudJunction
* Date : 02-02-2021
* 
*/

public class TicketApproval_Controller {
    
    public Id ticketId {get;set;}
    
    public List<Task__c> getTasks(){
        List<Task__c> task;
        System.debug('Ticket ID::' + ticketId );
        task = [SELECT Id, Name, Estimated_Hours__c, Estimated_Hours_High__c, Ticket__r.Name FROM Task__c WHERE Ticket__c =: ticketId];
        System.debug('Tasks::' + task );
        return task;
        
    }
    
    public Issue__c getTicket(){
        Issue__c ticket;
        System.debug('Ticket ID::' + ticketId);
        ticket = [SELECT Id, Name, Issue_Subject__c, Owner.Name, Account__c, Contact__r.Name, Total_Estimated_Hours_formula__c, Total_Estimated_Hours_High__c, Field1__c, Total_Estimated_Revenue_High__c FROM Issue__c WHERE Id =: ticketId LIMIT 1 ];
        System.debug('Tickets ::' + ticket );
        return ticket;
        
    }
    
}