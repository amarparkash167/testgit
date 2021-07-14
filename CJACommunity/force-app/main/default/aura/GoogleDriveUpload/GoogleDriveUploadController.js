({
    myAction : function(component, event, helper) {
        window.setTimeout(
            $A.getCallback(function() {
                  var google_url = component.get("v.ProjRecord").CJA_Google_Drive_Link__c;
        //console.log('Project Id::+' googleId.Id);
        //
        if(google_url!=null){
            console.log('Project Record::'+ component.get("v.ProjRecord").CJA_Google_Drive_Link__c);
            var iframeUrl = 'https://drive.google.com/embeddedfolderview?id='+google_url.match(/[-\w]{25,}/)[0]+'#list';
            console.log(iframeUrl);
            component.set("v.iframeUrl", iframeUrl);
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