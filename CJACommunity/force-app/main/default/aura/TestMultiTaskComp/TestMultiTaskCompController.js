({
    myAction : function(component, event, helper) {
        
    },
    doInit : function(component, event, helper) {    
    debugger;
    if( component.get("v.recordId") ){    
    var action= component.get("c.onLoad");  
        
    action.setParams({
        taskId:   component.get("v.recordId")
    });
    action.setCallback(this, function(response){
    console.log('::Response : ', response.getReturnValue());  
    
    if(response.getState() === 'SUCCESS'){    
        
    if(response.getReturnValue()){
    
    console.log('::Record : ', response.getReturnValue().deliverable_Task.Project__c);   
    if(response.getReturnValue().deliverable_Task){ 
    //<!-- Set Task in attribute "taskRecord" -->    
    component.set("v.taskRecord", response.getReturnValue().deliverable_Task);
        
    // <!-- Set Project -  Farah  -->  
    component.find('Project__c1').set("v.value",response.getReturnValue().deliverable_Task.Project__c);
    component.find('Project__c2').set("v.value",response.getReturnValue().deliverable_Task.Project__c);
    component.find('Project__c3').set("v.value",response.getReturnValue().deliverable_Task.Project__c);
    component.find('Project__c4').set("v.value",response.getReturnValue().deliverable_Task.Project__c);
    component.find('Project__c5').set("v.value",response.getReturnValue().deliverable_Task.Project__c);     
    }// End of Task
    if(response.getReturnValue().initialDeliverableOptions){    
 
    // Set Deliverable "Label" By Default at Oth Index 
    var matchedIndex = 0; 
    for(var i=0 ; i< response.getReturnValue().initialDeliverableOptions.length; i++){
        //console.log(':: '+ i+ ' - Record : ', response.getReturnValue().initialDeliverableOptions[i].label);   
        if(response.getReturnValue().initialDeliverableOptions[i].label === response.getReturnValue().deliverable_Task.Name) {
           matchedIndex = i; 
        }   
    }
    [response.getReturnValue().initialDeliverableOptions[0], response.getReturnValue().initialDeliverableOptions[matchedIndex]] =[response.getReturnValue().initialDeliverableOptions[matchedIndex], response.getReturnValue().initialDeliverableOptions[0]];    
     
    // Set Default Deliverable "Value"    
    component.set("v.selected_Deliverable_1", component.get("v.recordId"));  
    component.set("v.selected_Deliverable_2", component.get("v.recordId"));
    component.set("v.selected_Deliverable_3", component.get("v.recordId"));
    component.set("v.selected_Deliverable_4", component.get("v.recordId"));
    component.set("v.selected_Deliverable_5", component.get("v.recordId"));
     
    // <!-- Set Deliverable - Default Options  -->
    component.set("v.deliverableOptions_Project_1", response.getReturnValue().initialDeliverableOptions);
    component.set("v.deliverableOptions_Project_2", response.getReturnValue().initialDeliverableOptions);
    component.set("v.deliverableOptions_Project_3", response.getReturnValue().initialDeliverableOptions);
    component.set("v.deliverableOptions_Project_4", response.getReturnValue().initialDeliverableOptions);
    component.set("v.deliverableOptions_Project_5", response.getReturnValue().initialDeliverableOptions);     
        
    }//End of Deliverables   
       
    }  
    
    }       
    });
    $A.enqueueAction(action);
    }//if( component.get("v.recordId") )
    },    
    
    
    handleSubmit1: function (component, event, helper) {
        event.preventDefault();
        
        //debugger;

        var validSoFar= true;
        
        //Loop Variables
        var project;
        var deliverable;
        var deliverable_Options;
        
        // Code By Farah
        for(var i=0; i< 5; i++){
        project = "Project__c"+ (i+1);       
        deliverable= "Deliverables__c"+(i+1);     
        deliverable_Options= "v.deliverableOptions_Project_"+(i+1);   
        
            if(component.find(project).get("v.value") && component.find(deliverable).get("v.value") === '' && 
               component.get(deliverable_Options).length > 0 && component.get(deliverable_Options)[0].label){
            //showHelpMessageIfInvalid();
            component.find(deliverable).showHelpMessageIfInvalid();    
            }
        
        }
        // 
        for(var i=0; i< 5; i++){
        project = "Project__c"+ (i+1);            
        deliverable= "Deliverables__c"+(i+1);   
        deliverable_Options= "v.deliverableOptions_Project_"+(i+1);    
        
            if(component.find(project).get("v.value") && component.find(deliverable).get("v.value") === '' && 
               component.get(deliverable_Options).length > 0 && component.get(deliverable_Options)[0].label){
            validSoFar = false;    
            console.log(':: valid Loop Deliverable: '+ deliverable);  
            console.log(':: valid Loop Project: '+ component.find(project).get("v.value"));
            console.log(':: valid Loop Deliverable Options: ', component.get(deliverable_Options)[0]);    
            console.log(':: valid Loop Deliverable Options Length: ' + component.get(deliverable_Options).length);
            break;
            }
        
        }
        // Code by Farah
        
        if(validSoFar === true){
        
        //var Adv1 = component.find("Advertiser__c1").get("v.value");
        //console.log(Adv1);
        component.set("v.TMT[0].Name", component.find("Name1").get("v.value"));
        component.set("v.TMT[0].Project__c", component.find("Project__c1").get("v.value"));
        component.set("v.TMT[0].Deliverables__c", component.find("Deliverables__c1").get("v.value"));
        component.set("v.TMT[0].Due_Date__c", component.find("DueDate__c1").get("v.value"));
        component.set("v.TMT[0].Description__c", component.find("Description__c1").get("v.value"));
        
        //console.log(Adv1);
        component.set("v.TMT[1].Name", component.find("Name2").get("v.value"));
        component.set("v.TMT[1].Project__c", component.find("Project__c2").get("v.value"));
        component.set("v.TMT[1].Deliverables__c", component.find("Deliverables__c2").get("v.value"));
        component.set("v.TMT[1].Due_Date__c", component.find("DueDate__c2").get("v.value"));
        component.set("v.TMT[1].Description__c", component.find("Description__c2").get("v.value"));
        
        //console.log(Adv1);
        component.set("v.TMT[2].Name", component.find("Name3").get("v.value"));
        component.set("v.TMT[2].Project__c", component.find("Project__c3").get("v.value"));
        component.set("v.TMT[2].Deliverables__c", component.find("Deliverables__c3").get("v.value"));
        component.set("v.TMT[2].Due_Date__c", component.find("DueDate__c3").get("v.value"));
        component.set("v.TMT[2].Description__c", component.find("Description__c3").get("v.value"));
        
        //console.log(Adv1);
        component.set("v.TMT[3].Name", component.find("Name4").get("v.value"));
        component.set("v.TMT[3].Project__c", component.find("Project__c4").get("v.value"));
        component.set("v.TMT[3].Deliverables__c", component.find("Deliverables__c4").get("v.value"));
        component.set("v.TMT[3].Due_Date__c", component.find("DueDate__c4").get("v.value"));
        component.set("v.TMT[3].Description__c", component.find("Description__c4").get("v.value"));
        
        //console.log(Adv1);
        component.set("v.TMT[4].Name", component.find("Name5").get("v.value"));
        component.set("v.TMT[4].Project__c", component.find("Project__c5").get("v.value"));
        component.set("v.TMT[4].Deliverables__c", component.find("Deliverables__c5").get("v.value"));
        component.set("v.TMT[4].Due_Date__c", component.find("DueDate__c5").get("v.value"));
        component.set("v.TMT[4].Description__c", component.find("Description__c5").get("v.value"));
        
        
        var saveContactAction = component.get("c.lstTMT");
        saveContactAction.setParams({
            test: JSON.stringify(component.get("v.TMT"))
        });
        
        
        
        // Configure the response handler for the action
        saveContactAction.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                
                // Prepare a toast UI message
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Multiple Tasks Saved",
                    "message": "Multiple tasks were created."
                });
                
                // Update the UI: close panel, show toast, refresh account page
                $A.get("e.force:closeQuickAction").fire();
                resultsToast.fire();
                $A.get("e.force:refreshView").fire();
            }
            else if (state === "ERROR") {
                console.log('Problem saving multiple tasks, response state: ' + state);
            }
                else {
                    console.log('Unknown problem, response state: ' + state);
                }
        });
        
        // Send the request to create the new contact
        $A.enqueueAction(saveContactAction); 
        }// validSoFar
        
    },
    
    //cancel function here
    
        HideMe: function(component, event, helper) {
          component.set("v.ShowModule", false);
       },
       ShowModuleBox: function(component, event, helper) {
          component.set("v.ShowModule", true);
       },
    
    //cancel function ends here
    
    
    myfunc: function (component, event, helper) {
        
        event.preventDefault();
        
        debugger;
        
        var validSoFar= true;
        
        //Loop Variables
        var project;
        var deliverable;
        var deliverable_Options;
        
        // Code By Farah
        for(var i=0; i< 5; i++){
        project = "Project__c"+ (i+1);       
        deliverable= "Deliverables__c"+(i+1);     
        deliverable_Options= "v.deliverableOptions_Project_"+(i+1);   
        
            if(component.find(project).get("v.value") && component.find(deliverable).get("v.value") === '' && 
               component.get(deliverable_Options).length > 0 && component.get(deliverable_Options)[0].label){
            //showHelpMessageIfInvalid();
            component.find(deliverable).showHelpMessageIfInvalid();    
            }
        
        }
        // 
        for(var i=0; i< 5; i++){
        project = "Project__c"+ (i+1);            
        deliverable= "Deliverables__c"+(i+1);   
        deliverable_Options= "v.deliverableOptions_Project_"+(i+1);    
        
            if(component.find(project).get("v.value") && component.find(deliverable).get("v.value") === '' && 
               component.get(deliverable_Options).length > 0 && component.get(deliverable_Options)[0].label){
            validSoFar = false;    
            console.log(':: valid Loop Deliverable: '+ deliverable);  
            console.log(':: valid Loop Project: '+ component.find(project).get("v.value"));      
            break;
            }
        
        }
        // Code by Farah
        
        if(validSoFar === true){
        
        
        //console.log(Adv1);
        component.set("v.TMT[0].Name", component.find("Name1").get("v.value"));
        component.set("v.TMT[0].Project__c", component.find("Project__c1").get("v.value"));
        component.set("v.TMT[0].Deliverables__c", component.find("Deliverables__c1").get("v.value"));
        component.set("v.TMT[0].Due_Date__c", component.find("DueDate__c1").get("v.value"));
        component.set("v.TMT[0].Description__c", component.find("Description__c1").get("v.value"));
        
        //console.log(Adv1);
        component.set("v.TMT[1].Name", component.find("Name2").get("v.value"));
        component.set("v.TMT[1].Project__c", component.find("Project__c2").get("v.value"));
        component.set("v.TMT[1].Deliverables__c", component.find("Deliverables__c2").get("v.value"));
        component.set("v.TMT[1].Due_Date__c", component.find("DueDate__c2").get("v.value"));
        component.set("v.TMT[1].Description__c", component.find("Description__c2").get("v.value"));
        
        //console.log(Adv1);
        component.set("v.TMT[2].Name", component.find("Name3").get("v.value"));
        component.set("v.TMT[2].Project__c", component.find("Project__c3").get("v.value"));
        component.set("v.TMT[2].Deliverables__c", component.find("Deliverables__c3").get("v.value"));
        component.set("v.TMT[2].Due_Date__c", component.find("DueDate__c3").get("v.value"));
        component.set("v.TMT[2].Description__c", component.find("Description__c3").get("v.value"));
        
        //console.log(Adv1);
        component.set("v.TMT[3].Name", component.find("Name4").get("v.value"));
        component.set("v.TMT[3].Project__c", component.find("Project__c4").get("v.value"));
        component.set("v.TMT[3].Deliverables__c", component.find("Deliverables__c4").get("v.value"));
        component.set("v.TMT[3].Due_Date__c", component.find("DueDate__c4").get("v.value"));
        component.set("v.TMT[3].Description__c", component.find("Description__c4").get("v.value"));
        
        //console.log(Adv1);
        component.set("v.TMT[4].Name", component.find("Name5").get("v.value"));
        component.set("v.TMT[4].Project__c", component.find("Project__c5").get("v.value"));
        component.set("v.TMT[4].Deliverables__c", component.find("Deliverables__c5").get("v.value"));
        component.set("v.TMT[4].Due_Date__c", component.find("DueDate__c5").get("v.value"));
        component.set("v.TMT[4].Description__c", component.find("Description__c5").get("v.value"));
        
        var saveContactAction = component.get("c.lstTMT");
        saveContactAction.setParams({
            test: JSON.stringify(component.get("v.TMT"))
        });
        //alert('a');debugger;
        //alert(component.find("Advertiser__c5").get("v.value"));
        //component.set("v.Advertiser__c5","");
        //document.getElementById("Advertiser__c5").value = '';
        
        
        // Configure the response handler for the action
        saveContactAction.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.flag",false);                
                
                // Prepare a toast UI message
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Multiple Tasks Saved",
                    "message": "New Multiple Tasks were created."
                });

                // Update the UI: close panel, show toast, refresh account page
                //$A.get("e.force:closeQuickAction").fire();
                
                //Set Deliverable Options empty 
                component.set("v.deliverableOptions_Project_1" , "");
                component.set("v.deliverableOptions_Project_2" , "");
                component.set("v.deliverableOptions_Project_3" , "");
                component.set("v.deliverableOptions_Project_4" , "");
                component.set("v.deliverableOptions_Project_5" , ""); 
                
                component.set("v.selected_Deliverable_1" , "");
                component.set("v.selected_Deliverable_2" , "");
                component.set("v.selected_Deliverable_3" , "");
                component.set("v.selected_Deliverable_4" , "");
                component.set("v.selected_Deliverable_5" , "");   
                
                component.set("v.flag",true);
                
                resultsToast.fire();
                //$A.get("e.force:refreshView").fire();
                
            }
            else if (state === "ERROR") {
                console.log('Problem saving Multiple Tasks, response state: ' + state);
            }
                else {
                    console.log('Unknown problem, response state: ' + state);
                }
        });
        
        // Send the request to create the new contact
        $A.enqueueAction(saveContactAction);
        }// validSoFar        
        
        //$A.get('e.force:refreshView').fire();
        //component.set("v.Advertiser__c5","012");
        
    },
    
    getDeliverable_RecordEditForm_1: function(component, event, helper){
    //Reset deliverable to Empty
    component.set("v.selected_Deliverable_1", "");
    component.find("Deliverables__c1").set("v.required", false);    
    var projectId=  event.getParam("value");   
    console.log('::On change Project 1:  '+ projectId[0]);    
    if(projectId[0]){ 
       var action = component.get("c.getDeliverables");
        action.setParams({
            projectLookup: event.getParam("value")[0]
        });
        action.setCallback(this, function(response){    
            if(response.getState() === 'SUCCESS'){
                if(response.getReturnValue()){
                   component.set("v.deliverableOptions_Project_1" , response.getReturnValue()); 
                    if(response.getReturnValue().length > 0){  
                       //Set Default Value in Deliverable 
                       //component.set("v.selected_Deliverable_1", response.getReturnValue()[0].value);     //commented
                       //Make Deliverable Required
                       component.find("Deliverables__c1").set("v.required", true);  
                       //component.find("Deliverables__c1").showHelpMessageIfInvalid();  
                        
                       console.log('::option 1:  ', response.getReturnValue()); 
                    }
                }    
            } 
            else if(response.getState() === 'ERROR'){
                console.log('::Error: ', response.getError()); 
            }
        });
        $A.enqueueAction(action);
    }// If ProjectId is Not Empty  
    else{
        component.set("v.deliverableOptions_Project_1" , "");
        component.find("Deliverables__c1").set("v.required", false); 
    }    
    }
,
    
    getDeliverable_RecordEditForm_2: function(component, event, helper){
    //Reset deliverable to Empty
    component.set("v.selected_Deliverable_2", "");    
    component.find("Deliverables__c2").set("v.required", false);        
    var projectId=  event.getParam("value");        
    console.log('::On change Project 2:  '+ projectId[0]);    
    if(projectId[0]){
       var action = component.get("c.getDeliverables");
        action.setParams({
            projectLookup: event.getParam("value")[0]
        });
        action.setCallback(this, function(response){ 
            if(response.getState() === 'SUCCESS'){
                if(response.getReturnValue()){
                   component.set("v.deliverableOptions_Project_2" , response.getReturnValue());  
                    if(response.getReturnValue().length > 0){  
                       //Set Default Value in Deliverable 
                       //component.set("v.selected_Deliverable_2", response.getReturnValue()[0].value);    
                       //Make Deliverable Required
                       component.find("Deliverables__c2").set("v.required", true);    
                       console.log('::option 2:  ', response.getReturnValue()); 
                    }   
                }
            } 
            else if(response.getState() === 'ERROR'){
                console.log('::Error: ', response.getError()); 
            }
        });
        $A.enqueueAction(action);
    }// If ProjectId is Not Empty   
    else{
        component.set("v.deliverableOptions_Project_2" , "");
        component.find("Deliverables__c2").set("v.required", false); 
    }         
    }
,
    
    getDeliverable_RecordEditForm_3: function(component, event, helper){
    //Reset deliverable to Empty
    component.set("v.selected_Deliverable_3", "");  
    component.find("Deliverables__c3").set("v.required", false);          
    var projectId=  event.getParam("value");   
    console.log('::On change Project 3:  '+ projectId[0]);    
    if(projectId[0]){
       var action = component.get("c.getDeliverables");
        action.setParams({
            projectLookup: event.getParam("value")[0]
        });
        action.setCallback(this, function(response){    
            if(response.getState() === 'SUCCESS'){
                if(response.getReturnValue()){
                   component.set("v.deliverableOptions_Project_3" , response.getReturnValue());  
                    if(response.getReturnValue().length > 0){  
                       //Set Default Value in Deliverable 
                       //component.set("v.selected_Deliverable_3", response.getReturnValue()[0].value);    
                       //Make Deliverable Required
                       component.find("Deliverables__c3").set("v.required", true);   
                       console.log('::option 3:  ', response.getReturnValue()); 
                    } 
                }    
            } 
            else if(response.getState() === 'ERROR'){
                console.log('::Error: ', response.getError()); 
            }
        });
        $A.enqueueAction(action);
    }// If ProjectId is Not Empty  
    else{
        component.set("v.deliverableOptions_Project_3" , "");
        component.find("Deliverables__c3").set("v.required", false); 
    }         
    }
,
    
    getDeliverable_RecordEditForm_4: function(component, event, helper){
    //Reset deliverable to Empty
    component.set("v.selected_Deliverable_4", "");
    component.find("Deliverables__c4").set("v.required", false);          
    var projectId=  event.getParam("value");   
    console.log('::On change Project 4:  '+ projectId[0]);    
    if(projectId[0]){
       var action = component.get("c.getDeliverables");
        action.setParams({
            projectLookup: event.getParam("value")[0]
        });
        action.setCallback(this, function(response){    
            if(response.getState() === 'SUCCESS'){
                if(response.getReturnValue()){   
                   component.set("v.deliverableOptions_Project_4" , response.getReturnValue());                     
                    if(response.getReturnValue().length > 0){  
                       //Set Default Value in Deliverable 
                       //component.set("v.selected_Deliverable_4", response.getReturnValue()[0].value);    
                       //Make Deliverable Required
                       component.find("Deliverables__c4").set("v.required", true);   
                       console.log('::option 4:  ', response.getReturnValue()[0].value); 
                    }
                }
            } 
            else if(response.getState() === 'ERROR'){
                console.log('::Error: ', response.getError()); 
            }
        });
        $A.enqueueAction(action);
    }// If ProjectId is Not Empty    
    else{
        component.set("v.deliverableOptions_Project_4" , "");
        component.find("Deliverables__c4").set("v.required", false); 
    }         
    }
, 
    
    getDeliverable_RecordEditForm_5: function(component, event, helper){
    //Reset deliverable to Empty
    component.set("v.selected_Deliverable_5", "");    
    component.find("Deliverables__c5").set("v.required", false);          
    var projectId=  event.getParam("value");   
    console.log('::On change Project 5:  '+ projectId[0]);    
    if(projectId[0]){
       var action = component.get("c.getDeliverables");
        action.setParams({
            projectLookup: event.getParam("value")[0]
        });
        action.setCallback(this, function(response){    
            if(response.getState() === 'SUCCESS'){
                if(response.getReturnValue()){     
                   component.set("v.deliverableOptions_Project_5" , response.getReturnValue());                      
                    if(response.getReturnValue().length > 0){  
                       //Set Default Value in Deliverable 
                       //component.set("v.selected_Deliverable_5", response.getReturnValue()[0].value);    
                       //Make Deliverable Required
                       component.find("Deliverables__c5").set("v.required", true);     
                       console.log('::option 5:  ', response.getReturnValue()[0].value); 
                    } 
                }    
            } 
            else if(response.getState() === 'ERROR'){
                console.log('::Error: ', response.getError()); 
            }
        });
        $A.enqueueAction(action);
    }// If ProjectId is Not Empty    
    else{
        component.set("v.deliverableOptions_Project_5" , "");
        component.find("Deliverables__c5").set("v.required", false); 
    }         
    }
    
})