({
    doInit : function(component, event, helper) {
        //getting recordid from hasRecordID
        var ProjectId = component.get("v.recordId");
        //Set apex getProject function
        var action = component.get("c.getProject");
        console.log("Project ID = " + ProjectId);
        //setting params for apex function
        action.setParams({
            "ProjectId" : component.get("v.recordId"),
        });
        
        //calling function
        action.setCallback(this, function(response){
            //getting state to check if success or error
            var state = response.getState();
            console.log('##RESPONSE1::'+JSON.stringify(response.getReturnValue()));
            //if success, set the account record from server to Component's account instance
            if (state == "SUCCESS"){
                component.set("v.ProjectIns", response.getReturnValue());
            }            
            else {
                // Show an alert if the state is incomplete or error
                alert('Error in getting data')
            }
        });
        $A.enqueueAction(action);
        
    }
})