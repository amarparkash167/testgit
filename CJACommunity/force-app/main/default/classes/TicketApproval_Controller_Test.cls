/**
* 
* Description: Test Class for TicketApproval_Controller.
* Author : M Tiham Siddiqui - CloudJunction
* Date : 04-02-2021
* 
**/

@isTest
public class TicketApproval_Controller_Test {
    
    static testMethod void myUnitTest() {
        
        //Test Data - Ticket
        Issue__c ticket = new Issue__c();
        ticket.Issue_Subject__c = 'Email Messge Test';
        ticket.Admin_Time_Estimated__c = 5.00;
        ticket.Admin_Hours_Estimated_High__c = 10.00;
        
        INSERT ticket;
        
        //Test Data - Task
        Task__c task = new Task__c();
        task.Name = 'Test Task 1';
        task.Ticket__c = ticket.Id;
        task.Estimated_Hours__c = 5.00;
        task.Estimated_Hours_High__c = 10.00;
        
        INSERT task;
        
        Test.startTest();
        
        TicketApproval_Controller ticketApp = new TicketApproval_Controller();
        
        ticketApp.ticketId = ticket.Id;
        ticketApp.getTasks();
        ticketApp.getTicket();
        
        Test.stopTest();
        
    }
}