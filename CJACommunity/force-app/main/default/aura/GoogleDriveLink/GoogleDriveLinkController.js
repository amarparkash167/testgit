({
    myAction : function(component, event, helper) {
        window.setTimeout(
            $A.getCallback(function() {
                var google_url = component.get("v.ProjRecord").CJA_Google_Drive_Link__c;
                
                if(google_url!=null){
                    console.log('Project Record::'+ component.get("v.ProjRecord").CJA_Google_Drive_Link__c);
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": google_url
                    });
                    urlEvent.fire();
                   
                    
                    
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.recordId"),
                        "slideDevName": "related"
                    });
                    
                    console.log(navEvt);
                    //alert(navEvt);
                    navEvt.fire();
                     document.getElementById("Accspinner").style.display = "none";
                    
                }
                else{
                    
                    component.set('v.detail', 'Drive link is not set. Contact to your salesforce administrator');
                    document.getElementById("Accspinner").style.display = "none";
                    
                }
            }), 5000
        );
        
        
        
    }
})