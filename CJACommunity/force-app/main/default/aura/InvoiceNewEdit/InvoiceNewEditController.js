({
	doInit : function(component, event, helper) {
        //getting recordid from hasRecordID
        var InvoiceId = component.get("v.recordId");
		//Set apex getInvoice function
        var action = component.get("c.getInvoice");
        //setting params for apex function
        action.setParams({
            "invoiceId" : InvoiceId,
        });
        //calling function
        action.setCallback(this, function(response){
            //getting state to check if success or error
            var state = response.getState();
            console.log('##RESPONSE1::'+JSON.stringify(response.getReturnValue()));
            //if success, set the invoice record from server to Component's invoice instance
            if (state == "SUCCESS"){
            	component.set("v.InvoiceIns", response.getReturnValue());
            }
            //To autopopulate Opportunity lookup because has recordID is having opportunity ID
            if(response.getReturnValue().Id == null)
            {
                var recID = component.get("v.recordId");
                component.set("v.Title","New Invoice");
            	component.set("v.InvoiceIns.CJ_Opportunity__c", recID);
                // Set Invoice Date - By Farah Naqvi
                component.set("v.InvoiceIns.Invoice_Date__c", $A.localizationService.formatDate(new Date(), "YYYY-MM-DD")); 
                console.log('::Date: '+ $A.localizationService.formatDate(new Date(), "YYYY MM DD"));     
            }
            else
                component.set("v.Title","Edit Invoice");
        });
        
        //set aoex getInvoiceLIs function to get LIs of invoice
        var action2 = component.get("c.getInvoiceLIs");
        //setting params for apex function
        action2.setParams({
            "invoiceId" : InvoiceId, 
        });
        //calling function
        action2.setCallback(this, function(response){
            //checking state if success, assign LI list from server to component's LI list
            var state = response.getState();
            console.log('##RESPONSE2::'+JSON.stringify(response.getReturnValue()));
        	if(state == "SUCCESS"){
            	component.set("v.InvoiceLIs", response.getReturnValue());
                helper.calInvTotal(component, event);
            }
        
        });
        $A.enqueueAction(action);
    	$A.enqueueAction(action2);
        
	},
    
    
    // function for create new object Row in Contact List 
    addNewRow: function(component, event, helper) {
        // call the comman "createObjectData" helper method for add new Object Row to List  
        helper.createObjectData(component, event);
        console.log("#List::"+component.get("v.InvoiceLIs"));
    },
 
    // function for delete the row 
    removeDeletedRow: function(component, event, helper) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        //var index = event.getParam("indexVar");
        var index = event.target.dataset.index;
        console.log("#index="+index);
        //getting list of all values to be update/insert
        var AllRowsList = component.get("v.InvoiceLIs");
        //getting list of all values to be deleted from database as well not only from UI
        var RemovedRowsList = component.get("v.RemovedInvoiceLIs");
        //add into existing list the indexed element going to be removed
        RemovedRowsList.push(AllRowsList[index]);
        //set into components list to send over apex controller
        component.set("v.RemovedInvoiceLIs", RemovedRowsList);
        console.log('#v.RemovedInvoiceLIs='+component.get("v.RemovedInvoiceLIs"));
        //removing from insert/update list of values from splice method
        AllRowsList.splice(index, 1);
        // set the component list after remove selected row element  
        component.set("v.InvoiceLIs", AllRowsList);
        console.log("#List::"+component.get("v.InvoiceLIs"));
        helper.calInvTotal(component, event);
    },
      
    calculateTotal: function(component, event, helper) {
    	helper.calInvTotal(component, event);
    },
    
    cancelBtn: function(component, event, helper) {
    	var InvoiceId = component.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
        if(InvoiceId != null && InvoiceId != '')
        {
            urlEvent.setParams({
            "url": "/lightning/r/Customer_Invoice__c/"+InvoiceId+"/view"
        	});
        }
        else
        {
            
        }
        
        urlEvent.fire();
    },
    
    saveInv :function(component, event, helper){
      
      
        //var action = component.get("c.upsertInvoiceAndLineItems");
        var invoiceIns = component.get("v.InvoiceIns");
        //var listLis = component.get("v.InvoiceLIs");
        //var listRem = component.get("v.RemovedInvoiceLIs");
        
        // Change stringfy - By Manisha
        
        
        var list_Lis = new Array();
		var InvoiceLI= component.get("v.InvoiceLIs");
        var list_Rem = new Array();
		var RemInvoice = component.get("v.RemovedInvoiceLIs");
        
        
        console.log("List Line item" +InvoiceLI);
        console.log("Remaining Line ITem" +RemInvoice);
        
       
        
		for (var i= 0 ; i < InvoiceLI.length ; i++){
            list_Lis.push(InvoiceLI[i]);
        }
        
        var listLis =JSON.stringify(list_Lis);
                

		for (var i= 0 ; i < RemInvoice.length ; i++){
            list_Rem.push(RemInvoice[i]);
        }
        
        var listRem =JSON.stringify(list_Rem);
        
        console.log("List Line item String" +listLis);
        console.log("Remaining Line ITem String" +listRem);              
        
        
        console.log('invoiceIns=='+invoiceIns);
        console.log('listLis=='+listLis);
        console.log('listRem=='+listRem);
        //Call helper method to validate data
        if(helper.validateRequired(component, event)){
            var oppId = JSON.stringify(component.get("v.InvoiceIns.CJ_Opportunity__c"));
            oppId = oppId.replace('[','').replace(']','').replace('\"', '').replace('\"', '');
            component.set("v.InvoiceIns.CJ_Opportunity__c",oppId);
            var conId = JSON.stringify(component.get("v.InvoiceIns.Billing_Contact__c"));
            conId = conId.replace('[','').replace(']','').replace('\"', '').replace('\"', '');
            component.set("v.InvoiceIns.Billing_Contact__c",conId);
             var action = component.get("c.upsertInvoiceAndLineItems");
            action.setParams({
                "inv" : invoiceIns,//component.get("v.InvoiceIns"),
                "ListInvoice" : listLis,//component.get("v.InvoiceLIs"),
                "RemListInvoice" : listRem //component.get("v.RemovedInvoiceLIs")
            });
            action.setCallback(this, function(response){
            var state = response.getState();
            console.log("#state::"+state);
            console.log("#Opp::"+JSON.stringify(component.get("v.InvoiceIns.CJ_Opportunity__c")));   
            if (state == "SUCCESS"){
                var invID = JSON.stringify(response.getReturnValue());
				invID = invID.replace('\"', '').replace('\"', '');                
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    mode: 'sticky',
                    title: 'Invoice has been saved Successfully',
                    message: 'Invoice has been saved',
                    type:'success',
                    messageTemplate: '{1} to access Invoice Record',
            		messageTemplateData: ['Salesforce', {
                								url: '/lightning/r/Customer_Invoice__c/'+invID+'/view',
                								label: 'Click Here',
            							}]
                });
                // Update the UI: close panel, show toast, refresh account page
                $A.get("e.force:closeQuickAction").fire();
                resultsToast.fire();
                $A.get("e.force:refreshView").fire();
                //window.open('/lightning/r/Customer_Invoice__c/'+invID+'/view');
                /*var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": "/lightning/r/Customer_Invoice__c/"+invID+"/view"
                });
                urlEvent.fire();*/
            }
            if (state == "ERROR"){
            	var errors = action.getError();
            	var msg = JSON.stringify(response.getReturnValue());
                //Showing message on DIV
                component.set("v.ErrorMsg", errors[0].message);
                            }
        });
      }
        $A.enqueueAction(action);
        
    },
    
})