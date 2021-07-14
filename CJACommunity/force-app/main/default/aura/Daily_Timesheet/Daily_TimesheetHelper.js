({
    
    initializeData: function(component, event) {
        // create a Default RowItem [Account Instance] on first time Component Load
        // by call this helper function  
        
        //alert(component.get("v.recordId") );
        // Get Timesheet Status
         var active = component.get("c.isActiveUser");
         active.setParams({ "RecordId" : component.get("v.recordId") });
         active.setCallback(this, function(response){
            var active_status = response.getState();
            if (active_status === "SUCCESS") {
                component.set("v.timesheet_user", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(active);
        console.log("User Has Timesheet");
        console.log(active);
        
        // has Manager
         // Get Timesheet Status
         var manager = component.get("c.hasManager");
         manager.setCallback(this, function(response){
            var manager_status = response.getState();
            if (manager_status === "SUCCESS") {
                component.set("v.manager_Id", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(manager);
        console.log("User Has Timesheet");
        console.log(manager);
        
        // Set Status of Task Values
        var st = component.get("c.getStatus");
        st.setCallback(this, function(response){
            var st_status = response.getState();
            if (st_status === "SUCCESS") {
                component.set("v.status", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(st);
        console.log(st);
        
        //component.set("v.status",st);
        
        //var user_id = component.get("c.isActiveUser");
        
        
        /* Get Timesheet Id 
         Timesheet Id will be Used to Create Timesheet Details*/
        
        var timesheet_id = component.get("c.getTimesheetId");
        timesheet_id.setParams({ "recordId" : component.get("v.recordId") });
        timesheet_id.setCallback(this, function(response){
            var timesheet_status = response.getState();
            if (timesheet_status === "SUCCESS") {
                component.set("v.recordId", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(timesheet_id);
        console.log(timesheet_id);
        
        // List of Timesheet Details Already Exist
        var timesheet_Detail = component.get("c.getTimesheetDetail");
        timesheet_Detail.setParams({ "recordId" : component.get("v.recordId") });
        timesheet_Detail.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.TimesheetDetailList", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(timesheet_Detail);
        
        
        
        
        
        // Get Todays Date
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today);
        var rowId = 1;
        component.set('v.rowId', rowId);
        var taskAssList = component.get("v.TimesheetDetailList");
        console.log('Timesheet Detail List in Init');
        console.log('Time sheet details list = ' + taskAssList); 
        
        // set Date
        var timesheet_date = component.get("c.getTimesheetDate");
        timesheet_date.setCallback(this, function(response){
            var date_status = response.getState();
            if (date_status === "SUCCESS") {
                component.set("v.today", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(timesheet_date);
        console.log(timesheet_date);   
        
        // set total hours
        var hours = component.get("c.getTimesheetHours");
        hours.setCallback(this, function(response){
            var hours_status = response.getState();
            if (hours_status === "SUCCESS") {
                component.set("v.total", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(hours);
        console.log(hours);        
        
        // Set Approval Status
        
        
        var aStatus = component.get("c.getApprovalStatus");
        console.log(aStatus);
        aStatus.setCallback(this, function(response){
            var approval_status = response.getState();
            if (approval_status === "SUCCESS") {
                component.set("v.approval_status", response.getReturnValue());
                console.log( ' '+ response.getReturnValue());
            }
        });
        
        $A.enqueueAction(aStatus);
        
    },
    
    taskList : function(component,event){
        
        // List of Resource Task Assignment  
        var taskListAssignment = component.get("c.getTaskAssignment");
        taskListAssignment.setParams({ "recordId" : component.get("v.recordId") });
        console.log(taskListAssignment);
        taskListAssignment.setCallback(this, function(response){
            var taskAss = response.getState();
            if (taskAss === "SUCCESS") {
                component.set("v.taskListAssignment", response.getReturnValue());
            }
        });
        
        $A.enqueueAction(taskListAssignment);
        
        // Get Timesheet Detail List which has 0 Actual Hours   
        var taskList = component.get("c.getTask");
        taskList.setParams({ "recordId" : component.get("v.recordId") });
        taskList.setCallback(this, function(response){
            var task = response.getState();
            if (task === "SUCCESS") {
                component.set("v.taskList", response.getReturnValue());
            }
            else{
                console.error('ERROR:' + response.getError());
            }
        });
        
        $A.enqueueAction(taskList);
    },
    calulateHours : function(component, event){
        
        try {     
            
            
            
            var taskAssList = component.get("v.taskList");
            console.log(taskAssList); 
            var totalval=0;            
            for(var i=0; i<taskAssList.length; i++) { 
                
                totalval += parseInt(taskAssList[i].Actual_Hours__c) ;
                console.log(totalval);                
            }    
            
            var taskAssList = component.get("v.TimesheetDetailList");
            console.log(taskAssList); 
            for(var i=0; i<taskAssList.length; i++) { 
                
                totalval += parseInt(taskAssList[i].Actual_Hours__c) ;
                console.log(totalval);                
            }    
            component.set('v.total',totalval);            
        }                           
        catch (e) {
            alert('Exception : '  + e);
        }     
        
    },
    
    saveTimesheet: function(component, event){
        console.log('Save has been called');
        
        var listtaskAss = component.get("v.taskListAssignment");
        
        //console.log('Task Assignment');
        console.log(listtaskAss);	
        
        // call the apex class method for save the Timesheet List
        // with pass the  List attribute to method param.
        
        // Insert Timesheet Detail Entries
        
        var taskAss = component.get("v.taskList");
        console.log("Task list component length = " + taskAss.length);	
        
        var ids =new Array();
        for (var i= 0 ; i < taskAss.length ; i++){
            ids.push(taskAss[i]);
        }
        
        var idListJSON =JSON.stringify(ids);
        
        var action = component.get("c.passString");
        action.setParams({ "listofTimesheetDetail" : taskAss });
        //console.log('listoftImesheetDetail' + taskAss);
        console.log(action);
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State::' + state);
            if (state === "SUCCESS") {
                console.log('response'+ response);
                console.log('Account records saved successfully');
                console.log("From server: " + response.getReturnValue());
                
            }
            
            else{
                
                console.log('Error::' + response.getError());
                console.log("From server Response: " + response.getReturnValue());
            }
        });
        // enqueue the server side action  
        $A.enqueueAction(action);
        
        
        // Update Timesheet Details
        var timesheetDetail = component.get("v.TimesheetDetailList");
        console.log("Timesheet Detail" + timesheetDetail);	
        
        var ids =new Array();
        for (var i= 0 ; i < timesheetDetail.length ; i++){
            ids.push(timesheetDetail[i]);
        }
        
        var idListJSON =JSON.stringify(ids);
        console.log('Timesheet Detail::' + idListJSON);
        var action = component.get("c.UpdateTimesheetDetail");
        action.setParams({ "listofTimesheetDetail" : timesheetDetail });
        
        console.log(' Time sheet details  = ' + timesheetDetail );
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State::' + state);
            if (state === "SUCCESS") {
                console.log('Timesheet Detail records updated successfully');
                console.log("From server: " + response.getReturnValue());
                
            }
            
            else{
                
                console.log('Error::' + response.getError());
                console.log("From server Response: " + response.getReturnValue());
            }
        });
        // enqueue the server side action  
        $A.enqueueAction(action);
        
        // Update Task Assignment
        // 
        var listtaskAss = component.get("v.taskListAssignment");
        
        console.log('Task Assignment');
        console.log(listtaskAss);	
        
        var ids =new Array();
        for (var i= 0 ; i < listtaskAss.length ; i++){
            ids.push(listtaskAss[i]);
            console.log(listtaskAss[i].status__c);
        }
        
        var idListJSON =JSON.stringify(ids);
        console.log('List of Task Assignment to be updated::' + idListJSON);
        
        var action = component.get("c.UpdateTaskAss");
        action.setParams({ "listofTaskAss" : listtaskAss });
        
        console.log(action);
        // set call back 
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State::' + state);
            if (state === "SUCCESS") {
                //alert('Timesheet Detail records updated successfully');
                //alert("From server: " + response.getReturnValue());
                
                //alert('Timesheet has been updated');    
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                     type: 'success',
                    "title": "Success!",
                    "message": "The record has been updated successfully."
                });

                
               
            }
            
            else{
                 	var toastEvent = $A.get("e.force:showToast");
                	toastEvent.setParams({
                     type: 'error',
                    "title": "Error!",
                    "message": "Error has been occured. Try Again!!"
               	 });
                	toastEvent.fire();  
                	console.log('Error::' + response.getError());
                	//alert("ERROR OCCURED TRY AGAIN: ");
            	}
        	});
        // enqueue the server side action  
        $A.enqueueAction(action);
    },
})