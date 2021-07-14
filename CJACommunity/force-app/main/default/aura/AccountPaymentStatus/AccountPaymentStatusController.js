({
	doInit : function(component, event, helper) {
    //getting recordid from hasRecordID
    var AccountId = component.get("v.recordId");
   	//Set apex getAccount function
    var action = component.get("c.getAccount");
        console.log("ACC ID = " + AccountId);
    //setting params for apex function
    action.setParams({
   "AccountId" : component.get("v.recordId"),
    });
    
	//calling function
        action.setCallback(this, function(response){
            //getting state to check if success or error
            var state = response.getState();
            console.log('##RESPONSE1::'+JSON.stringify(response.getReturnValue()));
            //if success, set the account record from server to Component's account instance
            if (state == "SUCCESS"){
            	component.set("v.AccountIns", response.getReturnValue());
            }            
          else {
                // Show an alert if the state is incomplete or error
                alert('Error in getting data')
          }
        });
        $A.enqueueAction(action);
                
    }
})