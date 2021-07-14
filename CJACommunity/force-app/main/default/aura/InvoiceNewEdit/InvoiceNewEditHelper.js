({
	createObjectData: function(component, event) {
        // get the LineItemsList from component and add(push) New Object to List  
        var RowItemList = component.get("v.InvoiceLIs");
        RowItemList.push({
            'sobjectType': 'Invoice_Lineitem__c',
            'Description__c': '',
            'Amount__c': '0.00'
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.InvoiceLIs", RowItemList);
    },
    // helper function for check if first Name is not null/blank on save  
    validateRequired: function(component, event) {
        var isValid = true;
        var allLIs = component.get("v.InvoiceLIs");
        for (var indexVar = 0; indexVar < allLIs.length; indexVar++) {
            if (allLIs[indexVar].Amount__c < '1' || allLIs[indexVar].Amount__c == '') {
                isValid = false;
               	
                //Showing message on DIV
                component.set("v.ErrorMsg","Amount should not be less than 1!");
            }
            else if (allLIs[indexVar].Description__c == '') {
                isValid = false;
                //Showing message on DIV
                component.set("v.ErrorMsg","Please enter the description");
            }
        }
        var invoice = component.get("v.InvoiceIns");
        console.log(invoice);
        if(invoice.Invoice_Date__c > invoice.Due_Date__c)
        {
            isValid = false;
            //Showing message on DIV
            component.set("v.ErrorMsg","Due Date should greater than Invoice Date");
        }
        else if(invoice.Billing_Contact__c == null)
        {
            isValid = false;
           //Showing message on DIV
            component.set("v.ErrorMsg","Billing Contact is Required");
        }

        
        return isValid;
    },
    //this method is rolling up all LIs amount and apply tax on it
    calInvTotal: function(component, event){
        var allLIs = component.get("v.InvoiceLIs");
        var invoice = component.get("v.InvoiceIns");
        var LITotal = 0.0;
        var invTotal = 0.0;
        var tax1 = 0.0;
        var tax2 = 0.0;
        var tax3 = 0.0
        //looping on all LIs
        for (var indexVar = 0; indexVar < allLIs.length; indexVar++){
            if(allLIs[indexVar].Amount__c != '')
            	LITotal+=parseFloat(allLIs[indexVar].Amount__c);			//getting total of all LIs

        }
        //checking if Tax percents are not null then apply tax percents
        if(invoice.Tax_Amount_Percent_1__c != null && invoice.Tax_Amount_Percent_1__c != '')
           tax1 =  parseFloat((invoice.Tax_Amount_Percent_1__c*LITotal)/100);
        if(invoice.Tax_Amount_Percent_2__c != null && invoice.Tax_Amount_Percent_2__c != '')
           tax2 =  parseFloat((invoice.Tax_Amount_Percent_2__c*LITotal)/100);
        if(invoice.Tax_Amount_Percent_3__c != null && invoice.Tax_Amount_Percent_3__c != '')
           tax3 =  parseFloat((invoice.Tax_Amount_Percent_3__c*LITotal)/100);
        
        //Adding all amounts to rollup on invoice
        invTotal+= parseFloat(LITotal+tax1+tax2+tax3);
        //setting invoice Total attribute of component
        component.set("v.InvoiceTotal",invTotal);
        //setting invoice amount field of invoice with total amount
        component.set("v.InvoiceIns.Invoice_Amount__c",invTotal);
        console.log("#LITotal="+invTotal);
        //setting invoice LI total without Taxes
        component.set("v.LiTotalWOtax",LITotal);
        //setting invoice Tax 1 total
        component.set("v.Tax1Total",tax1);
        //setting invoice Tax 2 total
        component.set("v.Tax2Total",tax2);
        //setting invoice Tax 3 total
        component.set("v.Tax3Total",tax3);
    },
})