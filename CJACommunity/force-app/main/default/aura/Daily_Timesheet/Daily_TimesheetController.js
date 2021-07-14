({
    
    // function call on component Load
    doInit: function(component, event, helper) {
        
        console.log(component.get("v.recordId"));
        helper.initializeData(component, event);
        helper.taskList(component, event);
        //alert(component.get("v.timesheet_user"));
        
    },
    
    // function for save the Records 
    Save: function(component, event, helper) {
        
        helper.saveTimesheet(component, event);
         var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "related"
        });
        
        console.log(navEvt);
        //alert(navEvt);
        navEvt.fire();
        
        //helper.initializeData(component, event);
    },
   
    calculate : function(component, event, helper) {
        
        helper.calulateHours(component, event);
    } ,
    
    Submit: function(component, event, helper) {
        
        helper.saveTimesheet(component, event);
        //alert(component.get("v.manager_Id"));
        
        if(component.get("v.manager_Id")){  
            
            // Set Status of Task Values
            var st = component.get("c.changeApprovalStatus");
            st.setParams({ "recordId" : component.get("v.recordId") });
            st.setCallback(this, function(response){
                var st_status = response.getState();
                if (st_status === "SUCCESS") {
                    
                    console.log("#st_status=="+st_status);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        type: 'success',
                        "title": "Success!",
                        "message": "Timesheet has been updated successfully."
                    });
                    
                    toastEvent.fire();   
                    helper.initializeData(component, event);
                    helper.taskList(component, event);
                }
            });
            
            $A.enqueueAction(st);
            console.log("#st=="+st);
            
        }
        
        else{
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type: 'error',
                "title": "Error!",
                "message": "You are not assigned to any Manager. Contact to Administration for Detail!!"
            });
            toastEvent.fire();  
            
        }
    },
    
    cancel :function(component, event) {
        
        
        //alert(component.get("v.recordId"));
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "related"
        });
        
        console.log(navEvt);
        //alert(navEvt);
        navEvt.fire();
        
    }  
})