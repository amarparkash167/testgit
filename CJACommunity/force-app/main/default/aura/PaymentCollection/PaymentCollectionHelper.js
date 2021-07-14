({    
    chargeCard: function(component, payment,Invoice) {
        var environment = component.get('v.environmentType');
        var InvoiceId = component.get("v.recordId");
        if(InvoiceId == null)
            InvoiceId = location.search.split('InvoiceId=')[1];
        console.log("InvoiceId="+InvoiceId);
        var action = component.get("c.getcreateCharge");
        
        action.setParams({
            "amount": '' + payment.amount,
            "holderName": '' + payment.holderName,
            "card" : '' + payment.card,
            "cvv": '' + payment.cvv,
            "year": '' + payment.year,
            "month": '' + payment.month,
            "curr" : '' + payment.currency,
            "description": "Payment for Invoice :" + component.get("v.invoiceNumber"),
            "notes": payment.notes,
            "invoiceId" : InvoiceId,
            //"description": "Payment for Invoice :" + component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {

                console.log("From server: " + response.getReturnValue());
                
                if(response.getReturnValue() == "SUCCESS"){
                    //console.log(Invoice.Id);
                    //Updating Invoice Status to PAID
                    //this.updateInvoice(component);
                    
                    //Redirecting to Thankyou page if opened under community
                    if (environment == 'Community') {
                        // Redirect Community logic
                        //window.open('/testing/s/thankyou','_self');
                        var thanksPg = $A.get("$Label.c.PaymentThankyouPage");
                		//window.location = thanksPg;
                        console.log("thanksPg:"+thanksPg);
                        window.open(thanksPg,'_self');
                        
                    }else{
                        // Prepare a toast UI message
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "title": "Payment has been made Successfully",
                            "message": "Invoice has been updated",
                            "type": "success",
                        });
                        // Update the UI: close panel, show toast, refresh account page
                        $A.get("e.force:closeQuickAction").fire();
                        resultsToast.fire();
                        $A.get("e.force:refreshView").fire();
                    }
                } else {
                    console.log('Showing error');

                	//result.push(response.getReturnValue().toString());
                	component.set("v.result", getReturnValue().toString());  
                    
                    console.log(component.get("v.result"));
                }
            } else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                console.log("From server: " + response.getReturnValue());
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
    updateInvoice: function(component) {
        var action = component.get("c.updateInvoice");
        var InvoiceId = component.get("v.recordId");
        action.setParams({
            "invoiceId": InvoiceId,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
				//console.log()
            } else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
})