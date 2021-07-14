({

    doInit: function(component, event, helper) {

         var environment = component.get('v.environmentType');
         //Checking if this component is being used in Lightning Community
         if (environment == 'Community') {
             
         	//Get all Parameters from current url
         	/*var qs = document.location.search;
         	qs = qs.split('+').join(' ');
            var params = {},
                tokens,
                re = /[?&]?([^=]+)=([^&]*)/g;
        
            while (tokens = re.exec(qs)) {
                params[decodeURIComponent(tokens[1])] = decodeURIComponent(tokens[2]);
            }
            */
             var myParam = location.search.split('InvoiceId=')[1];
             //Checking if ID is available from the parameter
             if(myParam !=null){
                console.log("myParam:"+myParam);
                var InvoiceId = myParam;
             } 
             else {
                //Redirecting to Error Page.
                var errorPg = $A.get("$Label.c.PaymentErrorPage");
                window.location = errorPg;//"/testing/s/errorinpayment";
             }
         // For Internal Pages, get the ID using OTB method
         } else if (environment == 'Standard') {
            // Setting Invoice Id with record value
            var InvoiceId = component.get("v.recordId");
        }
       
        var action = component.get("c.getInvoice"); 
        action.setParams({
            "invoiceId" : InvoiceId,
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                
                console.log("From server: " + JSON.stringify(response.getReturnValue()));
                console.log(response.getReturnValue());
                //console.log(response.getReturnValue()[0].Currency__c.toString());
                //console.log(response.getReturnValue()[0].Krow__Status__c);
                
                var invoice = component.get("v.invoice");
                invoice.push(response.getReturnValue());
                
                component.set("v.invoice", invoice);
                component.set("v.budgetAmount", response.getReturnValue()[0].Balance_Amount__c.toString());
                
                //If Invoice Status is PAID
                if(response.getReturnValue()[0].Status__c == "Paid"){
                    // Prepare a toast UI message
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Invoice is already Paid",
                        "message": "Invoice has been marked as Paid already",
                        "type": "info",
                    });
                    // Update the UI: close panel, show toast, refresh account page
                    $A.get("e.force:closeQuickAction").fire();
                    resultsToast.fire();
                    $A.get("e.force:refreshView").fire();
                }
                
                // If Amount is 0
                if(response.getReturnValue()[0].Invoice_Amount__c < 1){
                	// Prepare a toast UI message
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Amount shouldn't be less than 1",
                        "message": "Please add Invoice Amount First",
                        "type": "error",
                    });
                    // Update the UI: close panel, show toast, refresh account page
                    $A.get("e.force:closeQuickAction").fire();
                    resultsToast.fire();
                    $A.get("e.force:refreshView").fire();
                }
                
                
                console.log('amount setting');
                var currencyval = response.getReturnValue()[0].Currency__c;
                component.set("v.payment.amount", response.getReturnValue()[0].Balance_Amount__c.toString().trim().replace(",",""));
               	
                console.log('amount setting DONE');
                
                component.set("v.payment.invNotes", response.getReturnValue()[0].Description__c);
                
                console.log('invoice::'+currencyval);
                console.log('currtshow::'+component.get("v.payment.currency"));
                component.set("v.payment.currency", ""+currencyval);
                //console.log('v.payment.currency::'+component.get("v.payment.currency"));

                //console.log('CurrencyString::'+response.getReturnValue()[0].Currency__c.toString());
                //console.log(typeof response.getReturnValue()[0].Krow__Invoice_Total__c.toString());
               	var invNumber =  response.getReturnValue()[0].Name.toString();
                component.set("v.invoiceNumber", invNumber);
                console.log("invNum::"+invNumber);
                //console.log("opp name::"+response.getReturnValue()[0].CJ_Opportunity__r.Name);
               	if(response.getReturnValue()[0].CJ_Opportunity__c != null)
                	component.set("v.payment.oppName", response.getReturnValue()[0].CJ_Opportunity__r.Name);
                
            } else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        component.set("v.result", errors[0].message);  
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    clickCreate: function(component, event, helper) {
        var validExpense = component.find('expenseform').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        
        var validBalAmount = true;
        // If Amount is greater than Budget Amount
        var invAmount = parseFloat(component.get("v.paymment.amount"));
        var budgetAmn = parseFloat(component.get("v.budgetAmount"));
        if(invAmount > budgetAmn){
            // Prepare a toast UI message
            validBalAmount = false;
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "Amount shouldn't be greater than Remaining Balance Amount",
                "message": "Please add Invoice Amount with in Remaining Budget",
                "type": "error",
            });
            // Update the UI: close panel, show toast, refresh account page
            $A.get("e.force:closeQuickAction").fire();
            resultsToast.fire();
            $A.get("e.force:refreshView").fire();
        }
        
        // If we pass error checking, do some real work
        if(validExpense && validBalAmount){
            // Create the new expense
            var newPayment = component.get("v.payment");
            var Invoice = component.get("v.invoice");
            
            console.log("Payment: " + JSON.stringify(newPayment));
            helper.chargeCard(component, newPayment,Invoice);
        }
    }
})