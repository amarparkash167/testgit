({
    // common reusable function for toggle sections
    toggleSection : function(component, event, helper) {
        // dynamically get aura:id name from 'data-auraId' attribute
        var sectionAuraId = event.target.getAttribute("data-auraId");
        // get section Div element using aura:id
        var sectionDiv = component.find(sectionAuraId).getElement();
        /* The search() method searches for 'slds-is-open' class, and returns the position of the match.
         * This method returns -1 if no match is found.
        */
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        
        // -1 if 'slds-is-open' class is missing...then set 'slds-is-open' class else set slds-is-close class to element
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    },
    
    doInit: function(component, event, helper)
    {
         
        var apexFunction = component.get("c.initializeObjects");
        console.log("Selected Subject = " + component.get("v.selectedSubject"));
        apexFunction.setParams({});
        apexFunction.setCallback(this, function(response)
                                 {
                                     var status = response.getState();
                                     if(status === "SUCCESS")
                                     {
                                         var ret = response.getReturnValue();
                                         component.set("v.account", ret.acc);
                                         component.set("v.con", ret.con);
                                         component.set("v.con.FirstName", " ");
                                         component.set("v.opp", ret.opp);
                                         //component.set("v.selectedSubject", "Call");
                                         //component.set("v.subjectList", ret.subjects);
                                     }
                                 });
        $A.enqueueAction(apexFunction);
    },
    /*doInit: function(component, event, helper)
    {
        //var apexFunction = component.get("c.getStages");
        
        apexFunction.setParams({});
        apexFunction.setCallback(this, function(response)
                                 {
                                     var status = response.getState();
                                     if(status === "SUCCESS")
                                     {
                                         console.log("Function Return value = " + response.getReturnValue());
                                         var ret = response.getReturnValue();
                                         component.set("v.selectedStage", "1. Identifying/Exploring");
                                         component.set("v.opportunityStages", ret);
                                         
                                     }
                                 });
        $A.enqueueAction(apexFunction);
    },
    */
    
   Init: function(component, event, helper) {        
        helper.getRecordTypePicklist(component, event);
    },
    handleRecordOnChange : function(component, event, helper) {
        var recordtypeId = component.get("v.RecordTypeId");
        //alert(recordtypeId);
    },
    
    
    
    createClientObjects : function(component, event, helper)
    {
        console.log('Account name = ' + component.get("v.account.Name"));
        component.set("v.Spinner", "true");
        var apexFunction = component.get("c.createClientRecords");
        
        apexFunction.setParams({ "account" : component.get("v.account"),
                                "contact" : component.get("v.con"),
                                "opportunity" : component.get("v.opp"),
                                "selectedSubject" : component.get("v.selectedSubject"),
                                "description" : component.get("v.description")});
        /*apexFunction.setParams({ "accountName" : component.get("v.accountName"),
                                "contactFirstName" : component.get("v.contactFirstName"),
                                "contactLastName" : component.get("v.contactLastName"),
                                "opportunityName" : component.get("v.opportunityName"),
                                "selectedStage" : component.get("v.selectedStage"),
                                "opportunityCloseDate" : component.get("v.opportunityCloseDate")});
        */
        apexFunction.setCallback(this, function(response)
                                 {
                                     //console.log('Opp Name = ' + component.get("v.opportunityName"));
                                     var status = response.getState();
                                     if(status === "SUCCESS")
                                     {
                                         console.log("Function Return value = " + response.getReturnValue());
                                         var ret = response.getReturnValue();
                                         var retMsg = ret.split('!')[0];
                                         var acctId = ret.split('!')[1];
                                         console.log("Return MSG =====> " + retMsg);
                                         console.log("Account ID =====> " + acctId);
                                         if(retMsg === "Success"){
                                             var toastEvent = $A.get("e.force:showToast");
                                             toastEvent.setParams({
                                                 "title": "Success!",
                                                 "message": retMsg,
                                                 "type": "success"
                                             });
                                             //component.set("v.Spinner", false);
                                             toastEvent.fire();
                                             
                                             var evt = $A.get("e.force:navigateToSObject");
                                             evt.setParams({
                                                 recordId: acctId
                                             });
                                             evt.fire();
                                         }
                                         else{
                                             //console.log("function status :: "+ functionStatus);
                                             var toastEvent1 = $A.get("e.force:showToast");
                                             toastEvent1.setParams({
                                                 "title": "Error!",
                                                 "message": 'Please check all the fields and try again, contact System Administrator if problem persist \n ' + ret,
                                                 "type": "error"
                                             });
                                             toastEvent1.fire();
                                         }
                                     }
                                     component.set("v.Spinner", "false");
                                     
                                 });
        $A.enqueueAction(apexFunction);
    }
})