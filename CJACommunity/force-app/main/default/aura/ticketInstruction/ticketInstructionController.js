/*
@Name             : ticketInstructionController
@Author           : Muhammad Tiham Siddiqui @ CloudJunction Adivors
@Date             : 28 May, 2020
@Description      : Lightening Component Class for showing
*/

({
	doInit : function(component, event, helper) {
    //getting recordid from hasRecordID
    var TicketId = component.get("v.recordId");
   	//Set apex getAccount function
    var action = component.get("c.getTicket");
        console.log("TickedId = " + TicketId);
    //setting params for apex function
    action.setParams({
   		"TicketId" : component.get("v.recordId"),
    });
    
	//calling function
        action.setCallback(this, function(response){
            //getting state to check if success or error
            var state = response.getState();
            console.log('##RESPONSE1::'+JSON.stringify(response.getReturnValue()));
            //if success, set the account record from server to Component's account instance
            if (state == "SUCCESS"){
            	component.set("v.TicketIns", response.getReturnValue());
            }            
          else {
                // Show an alert if the state is incomplete or error
                alert('Error in getting data')
          }
        });
        $A.enqueueAction(action);
                
    }
})