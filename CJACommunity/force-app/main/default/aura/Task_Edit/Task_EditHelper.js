({
    create_TaskAssignment_ObjectData : function(component, event) {
        var task = component.get('v.task_Instance');
        
        var RowItemList= component.get("v.TaskAssignmentList");	
        RowItemList.push({
            //   'sobjectType':'Task_Assignment__c',
            'Task__c':'',            
            'Project_Resource__c': '',
            'Start_Date__c': task.Start_Date__c,
            'End_Date__c':task.Due_Date__c,
            'Id': '',
            'Name': '',
            'Status__c':'Not Started',
            'Estimated_Hour__c': ''
            
        });
      
        component.set("v.TaskAssignmentList", RowItemList);
    },    
    
    create_TaskAssignment_DeleteData : function(component, event) {
       //component.set("v.TaskAssignDelete_List", ""); 
       var taskAssignList =  component.get("v.TaskAssignDelete_List"); 
       taskAssignList.length = 0; 
        /*
        var RowItemList= component.get("v.TaskAssignDelete_List");	
        RowItemList.push({
            //   'sobjectType':'Task_Assignment__c',
            'Task__c':'',            
            'Project_Resource__c': '',
            'Start_Date__c': '',
            'End_Date__c':'',
            'Id': '',
            'Name': '',
            'Status__c':'Not Started'
            
        });
        component.set("v.TaskAssignDelete_List", RowItemList);
        */
    },    
    
    create_NewTask_ObjectData : function(component, event) { 
    var deliverable= component.get("v.deliverableRecord");    
        
        var newTaskObject = {
            'sobjectType':'Task__c',
            'Name': '',
            'Start_Date__c': '',
            'Completion_Date__c':'',
            'Status__c':'',
            'Deliverable__c': deliverable.Id,
            'Priority__c' : ''        
        };
        component.set("v.task_Instance", newTaskObject);
        
        //var taskInstance= component.get("v.task_Instance"); 
        //taskInstance.Deliverable__c =  component.get("v.recordId");    
    },    
    
    create_Task_ObjectData : function(component, event) { 
        var newTaskObject = {
            'sobjectType':'Task__c',
            'Name': '',
            'Start_Date__c': '',
            'Completion_Date__c':'',
            'Status__c':'',
            'Deliverable__c': component.get("v.recordId"),
            'Priority__c' : '',
            'Id': ''            
        };
        component.set("v.task_Instance", newTaskObject);
        
        //var taskInstance= component.get("v.task_Instance"); 
        //taskInstance.Deliverable__c =  component.get("v.recordId");    
    },
    
    validate:function(component, event){	
        var isValid= true;
        var allTaskAssignmentRows= component.get("v.TaskAssignmentList");   
        var taskId = component.get("v.recordId");     
        var arrayToDelete = []; 
        
        //console.log('::New Task: ', component.get("v.task_Instance")); 
        //console.log('::allTaskAssignmentRows: ', allTaskAssignmentRows); 
        
        
        for(var indexVar=0; indexVar < allTaskAssignmentRows.length; indexVar++){
           // if(taskId  && taskId !== '--New Task--'){
                allTaskAssignmentRows[indexVar].Task__c = taskId;
           // }
           // else{
             //   allTaskAssignmentRows[indexVar].Task__c = "";    
            //}
            allTaskAssignmentRows[indexVar].Id = allTaskAssignmentRows[indexVar].Id; 
            
            allTaskAssignmentRows[indexVar].Project_Resource__c = allTaskAssignmentRows[indexVar].Project_Resource__c;
            
            if(typeof allTaskAssignmentRows[indexVar].Project_Resource__c == 'object'){
                allTaskAssignmentRows[indexVar].Project_Resource__c = allTaskAssignmentRows[indexVar].Project_Resource__c[0]; 
            }
            
            if(allTaskAssignmentRows[indexVar].Id == ''){
                //console.log('::Id Value : ', allTaskAssignmentRows[indexVar].Id);    
                allTaskAssignmentRows[indexVar].Id = allTaskAssignmentRows[indexVar].Id[0];  
            }

           if((allTaskAssignmentRows[indexVar].Task__c === '' && allTaskAssignmentRows[indexVar].Project_Resource__c === '') ||
              (allTaskAssignmentRows[indexVar].Task__c && allTaskAssignmentRows[indexVar].Project_Resource__c === '')) {
               arrayToDelete.push(indexVar);    
               } 
        }
        var pulled = _.pullAt(allTaskAssignmentRows, arrayToDelete);    
        //console.log(':Pulled TaskAsignment: ', pulled); 
        
        return isValid;
    },
    
    validate_DeleteList:function(component, event){
    var deleteTaskAssignmentRows= component.get("v.TaskAssignDelete_List"); 
        
    var arrayToDelete = [];    
        
    for(var indexVar=0; indexVar < deleteTaskAssignmentRows.length; indexVar++){
        console.log(indexVar+'::Delete Row:  ', deleteTaskAssignmentRows[indexVar]); 
       if((deleteTaskAssignmentRows[indexVar].Task__c === '' && deleteTaskAssignmentRows[indexVar].Project_Resource__c === '') ||
         (deleteTaskAssignmentRows[indexVar].Task__c && deleteTaskAssignmentRows[indexVar].Project_Resource__c === '')) {
         arrayToDelete.push(indexVar);    
        }   
    }
    
    var pulled = _.pullAt(deleteTaskAssignmentRows, arrayToDelete);    
        console.log('::Pulled Deleted: ', pulled);    
        
    }
    ,
    saveAll_With_DeleteList:function(component, event){
        console.log('::saveAll_With_DeleteList ');
        // Set Deliverable_Id in Task_Instance 
        var taskInstance = component.get("v.task_Instance");
        
        var deleteFlag= component.find("deleteFlag");  
        var errorFlag= component.find("errorFlag");  
        
        var taskId= component.get("v.recordId");   
        var deleteList = component.get("v.TaskAssignDelete_List");
        console.log('::saveAll_With_DeleteList deleteList :  ', deleteList);
        console.log('::Task Deliverable :  ', taskInstance.Deliverable__c);
        console.log('::Task Id :  ', taskInstance.Id);
        
        var action = component.get("c.insertRTA");
        
        //Insert Task Assignments - Action 
        var taskAssignmentListVar= component.get("v.TaskAssignmentList");
        var ids= new Array();
        for(var i=0; i < taskAssignmentListVar.length; i++){
            ids.push(taskAssignmentListVar[i]);
        }    
        
        var taskAssignmentJson= JSON.stringify(ids);    
        action.setParams({
            "Task" : taskInstance,                
            "taskAssignmentList" : taskAssignmentJson
        });    
        
        action.setCallback(this, function(response){
            var state= response.getState();
            if(state === 'SUCCESS'){
                // if response if success then reset the 'TaskAssignment List' Attribute 
                // and call the common helper method for create a default Object Data to TaskAssignment List   
                component.set("v.wrapper_insertRTA", response.getReturnValue());    
                
                var wrapper_insertRTA = component.get("v.wrapper_insertRTA");    
                console.log('::insertRTA upsertMessage ', wrapper_insertRTA.upsertMessage);
                component.set("v.TaskAssignmentList", []);  
                this.create_TaskAssignment_ObjectData(component, event);
                if(wrapper_insertRTA && wrapper_insertRTA.upsertMessage){
                    // Show Error Message
                    //errorFlag.set("v.isTrue",true);   
                    var msg= component.find("errorComp");        
                    //msg.set("v.type", "warning");
                    //msg.set("v.message", wrapper_insertRTA.upsertMessage); 
                    
                   component.set("v.rtaMessage" , wrapper_insertRTA.upsertMessage); 
                   this.showSuccessToast(component, event); 
                }
                
                //Call Delete Row Functionality and empty Delete List - Action 2
                var action2= component.get("c.deleteTaskAssignments");    
                action2.setParams({
                    taskAssign_Del_List : deleteList  
                });    
                action2.setCallback(this, function(response){
                    var state2 =  response.getState();
                    var deleteResponse = response.getReturnValue();
                    if(state2 === 'SUCCESS'){
    
                    //deleteFlag.set("v.isTrue",true);
                    
                    var msg= component.find("deleteComp");        
                    //msg.set("v.type", "warning");
                    //msg.set("v.message", deleteResponse);         
                    
                   if(deleteResponse){     
                   component.set("v.deleteMessage" , deleteResponse);    
                   this.showSuccessToast_Delete(component,event);    
                   }

                   this.create_TaskAssignment_DeleteData(component, event);
                            
                            // Refresh Task Assignments - Action 5 
                            var action5= component.get("c.getTaskAssignmentsMap_One_Task");      
                            action5.setParams({
                                taskId : component.get("v.recordId")
                            }); 
                            action5.setCallback(this, function(response){
                                var map = response.getReturnValue();
                                component.set("v.taskAssignmentMap",map);
                                var wrapper_insertRTA = component.get("v.wrapper_insertRTA");
                                console.log(':: wrapper_insertRTA: ', wrapper_insertRTA);
                                
                                console.log(':: rta Refresh', component.get("v.taskAssignmentMap"));
                                var taskAssignmentMap = component.get("v.taskAssignmentMap");
                                if(wrapper_insertRTA && wrapper_insertRTA.taskId){
                                    var fetchedList = taskAssignmentMap[wrapper_insertRTA.taskId]; 
                                    console.log(":: fetchedList: ", fetchedList);
                                    
            if(fetchedList && fetchedList.length > 0){    
            //console.log('::: empty false');    
            component.set("v.TaskAssignmentList" , fetchedList);  
                
            //Create Event
            var createEvent = $A.get("e.c:passParameters"); 
     		createEvent.setParams({
       		"param1": wrapper_insertRTA.taskId,
       		"param2": fetchedList
            });                    
            createEvent.fire();    
                
            }
            else{
                if(component.get("v.TaskAssignmentList")){   
             var createEvent = $A.get("e.c:passParameters"); 
                 createEvent.setParams({
                   "param1": wrapper_insertRTA.taskId,
                   "param2": component.get("v.TaskAssignmentList")
                 });     
                 createEvent.fire();
                }
                else{
                this.create_TaskAssignment_ObjectData(component,event);    
                var createEvent = $A.get("e.c:passParameters"); 
                 createEvent.setParams({
                   "param1": wrapper_insertRTA.taskId,
                   "param2": component.get("v.TaskAssignmentList")
                 });     
                 createEvent.fire();                    
                }
            //component.find("taskAssignment_Section").set("v.isTrue", "true"); 
            }                                      
                                }  
                            });//end of action5  
                        
                $A.get("e.force:closeQuickAction").fire();
                $A.get("e.force:refreshView").fire();        
                            $A.enqueueAction(action5);                               
                }//If Success action 2
                else if(state2 === 'ERROR'){
                component.set("v.deleteMessage" , "Error occured, cannot delete Task Assigments");    
                this.showErrorToast_Delete(component,event);    
                component.set("v.deleteMessage" , "Error occured, cannot delete Task Assigments"); 
                    
                            // Refresh Task Assignments - Action 5 
                            var action5= component.get("c.getTaskAssignmentsMap_One_Task");      
                            action5.setParams({
                                taskId : component.get("v.recordId")
                            }); 
                            action5.setCallback(this, function(response){
                                var map = response.getReturnValue();
                                component.set("v.taskAssignmentMap",map);
                                var wrapper_insertRTA = component.get("v.wrapper_insertRTA");
                                console.log(':: wrapper_insertRTA: ', wrapper_insertRTA);
                                
                                console.log(':: rta Refresh', component.get("v.taskAssignmentMap"));
                                var taskAssignmentMap = component.get("v.taskAssignmentMap");
                                if(wrapper_insertRTA && wrapper_insertRTA.taskId){
                                    var fetchedList = taskAssignmentMap[wrapper_insertRTA.taskId]; 
                                    console.log(":: fetchedList: ", fetchedList);
                                    
            if(fetchedList && fetchedList.length > 0){    
            //console.log('::: empty false');    
            component.set("v.TaskAssignmentList" , fetchedList);  
                
            //Create Event
            var createEvent = $A.get("e.c:passParameters"); 
     		createEvent.setParams({
       		"param1": wrapper_insertRTA.taskId,
       		"param2": fetchedList
            });                    
            createEvent.fire();    
                
            }
            else{
             var createEvent = $A.get("e.c:passParameters"); 
                 createEvent.setParams({
                   "param1": wrapper_insertRTA.taskId,
                   "param2": component.get("v.TaskAssignmentList")
                 });     
                 createEvent.fire();        
            //component.find("taskAssignment_Section").set("v.isTrue", "true"); 
            }                                      
                                }  
                                
            $A.get("e.force:closeQuickAction").fire();   
            $A.get("e.force:refreshView").fire();                                
                            });//end of action5  
                            $A.enqueueAction(action5);         
                    
                }                 
                });//end of action2
                $A.enqueueAction(action2);      
            }//If Success Action  
            else if(state === 'ERROR'){
            component.set("v.rtaMessage" , "Error occured, cannot insert/update Task Assigments");     
            this.showErrorToast(component, event);
            }
        });//end of action
        // enqueue the server side action  
        $A.enqueueAction(action); //end of action
        
    },
    
    saveAll_Without_DeleteList:function(component, event){
        console.log('::saveAll_Without_DeleteList ');
        
        // Set Deliverable_Id in Task_Instance 
        var taskInstance = component.get("v.task_Instance");
        
        var deleteFlag= component.find("deleteFlag");  
        var errorFlag= component.find("errorFlag");  
        
        var taskId= component.get("v.recordId");          
        
        var action = component.get("c.insertRTA");
        
        //Insert Task Assignments - Action 
        var taskAssignmentListVar= component.get("v.TaskAssignmentList");
        var ids= new Array();
        for(var i=0; i < taskAssignmentListVar.length; i++){
            ids.push(taskAssignmentListVar[i]);
        }    
        
        var taskAssignmentJson= JSON.stringify(ids);    
        action.setParams({
            "Task" : taskInstance,                
            "taskAssignmentList" : taskAssignmentJson
        });    
        
        action.setCallback(this, function(response){
            var state= response.getState();
            var response1 = response.getReturnValue();
            if(state === 'SUCCESS'){
                // if response if success then reset the 'TaskAssignment List' Attribute 
                // and call the common helper method for create a default Object Data to TaskAssignment List   
                component.set("v.wrapper_insertRTA", response.getReturnValue());    
                
                var wrapper_insertRTA = component.get("v.wrapper_insertRTA");    
                console.log('::insertRTA upsertMessage ', wrapper_insertRTA.upsertMessage);
                component.set("v.TaskAssignmentList", []);  
                this.create_TaskAssignment_ObjectData(component, event);
                if(wrapper_insertRTA && wrapper_insertRTA.upsertMessage){
                    // Show Error Message
                    errorFlag.set("v.isTrue",true);   
                    var msg= component.find("errorComp");        
                    msg.set("v.type", "warning");
                    msg.set("v.message", wrapper_insertRTA.upsertMessage);   
                    
                    component.set("v.rtaMessage" , wrapper_insertRTA.upsertMessage);
                    this.showSuccessToast(component, event); 
                }
                
                // Refresh Task Assignments - Action 5 
                var action5= component.get("c.getTaskAssignmentsMap_One_Task");      
                action5.setParams({
                    taskId : component.get("v.recordId")
                }); 
                action5.setCallback(this, function(response){
                    var map = response.getReturnValue();
                    component.set("v.taskAssignmentMap",map);
                    var wrapper_insertRTA = component.get("v.wrapper_insertRTA");
                    console.log(':: wrapper_insertRTA: ', wrapper_insertRTA);
                    
                    console.log(':: rta Refresh', component.get("v.taskAssignmentMap"));
                    var taskAssignmentMap = component.get("v.taskAssignmentMap");
                    if(wrapper_insertRTA && wrapper_insertRTA.taskId){
                        var fetchedList = taskAssignmentMap[wrapper_insertRTA.taskId]; 
                        console.log(":: fetchedList: ", fetchedList);
                        
                        component.set("v.TaskAssignmentList", fetchedList);
                        
                        var createEvent = $A.get("e.c:passParameters"); 
                        createEvent.setParams({
                            "param1": wrapper_insertRTA.taskId,
                            "param2": fetchedList
                        });     
                        createEvent.fire();     
                    }  
                });//end of action5  
                $A.enqueueAction(action5);             
                
               $A.get("e.force:closeQuickAction").fire(); 
               $A.get("e.force:refreshView").fire();
                
            }// If insertRTA is SUCCESS
            else{
                component.set("v.rtaMessage" , "Error occured, cannot update/insert Task and Task Assignments");
                this.showErrorToast(component, event); 
                
                var taskAssignmentMap = component.get("v.taskAssignmentMap");
                var fetchedList = taskAssignmentMap[taskId]; 
                console.log(":: fetchedList: ", fetchedList);
                
                component.set("v.TaskAssignmentList", fetchedList);
                
                var createEvent = $A.get("e.c:passParameters"); 
                createEvent.setParams({
                    "param1": wrapper_insertRTA.taskId,
                    "param2": fetchedList
                });     
                createEvent.fire();     
                
            }
        });// end of action
        // enqueue the server side action  
        $A.enqueueAction(action); //end of action
        
    },    
    
    setTaskInstance:function(component, event){
        var taskId= component.get("v.recordId");    
        var taskInstance= component.get("v.task_Instance");   
        
        /*
        if(taskInstance.Billable__c && taskInstance.Billable__c === true){
            console.log('::taskInstance.Billable__c ', taskInstance.Billable__c);
        var arr=[{'label': 'Billable', 'value': 'true'}];    
        component.find("task_billable").set("v.value", arr);    
        }
        else{
            console.log('::taskInstance.Billable__c ', taskInstance.Billable__c);
        var arr=[{'label': 'Billable', 'value': 'true'}];     
        component.find("task_billable").set("v.value", arr);    
        }    
        
        */
        
        
        //  $A.get('e.force:refreshView').fire();    
        
        // Set lightning:recordEditForm recordId Attribute          
        component.find("taskForm").set("v.recordId", taskId);    
        
        //Explicitly set values for Task Fields
        /*    
            component.find("task_name").set("v.value", selectedTask.Name);
            component.find("task_startDate").set("v.value", selectedTask.Start_Date__c);
            component.find("task_endDate").set("v.value", selectedTask.Completion_Date__c);
            component.find("task_status").set("v.value", selectedTask.Status__c);
            component.find("task_priority").set("v.value", selectedTask.Priority__c);
            component.find("task_Id").set("v.value", selectedTask.Id);
            component.find("task_Deliverable").set("v.value", selectedTask.Deliverable__c);    
            */
        
        if(taskInstance && !taskInstance.Status__c){
        component.find("task_status").set("v.value", 'Not Started');    
        taskInstance.Status__c= 'Not Started';    
        }
        else if(taskInstance && taskInstance.Status__c){
        component.find("task_status").set("v.value",  taskInstance.Status__c);    
        }
        
        if(taskInstance && !taskInstance.Priority__c){
        //component.find("task_priority").set("v.value", 'Normal');    
        taskInstance.Priority__c = 'Normal';    
        }
        else if(taskInstance && taskInstance.Priority__c){
        component.find("task_priority").set("v.value",  taskInstance.Priority__c);    
        }
        
        component.set("v.task_Instance", taskInstance); 
        console.log('::Task After: ', component.get("v.task_Instance"));
        
        // console.log(':: Task Input Field: ', component.find("task_status").get("v.value"));
        // console.log(':: Task taskInstance Priority: ', taskInstance.Priority__c);     
        // console.log(':: Task taskInstance Status: : ', taskInstance.Status__c);
        
    },
    
    showInfoToast : function(component, event) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Info Message',
            message: 'Mode is dismissible ,duration is 5sec and this is normal Message',
            messageTemplate: 'Record {0} created! See it {1}!',
            duration:' 5000',
            key: 'info_alt',
            type: 'info',
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    showSuccessToast : function(component, event) {
    var rtaMsg=  component.get("v.rtaMessage");    
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success:',
            message: rtaMsg ,
            //messageTemplate: 'Record {0} created! See it {1}!',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    showErrorToast : function(component, event) {
    var rtaMsg=  component.get("v.rtaMessage");    
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error: ',
            message: rtaMsg,
            //messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
            duration:'5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    showWarningToast : function(component, event) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Warning',
            message: 'Mode is pester ,duration is 5sec and normal message',
            messageTemplate: 'Mode is sticky ,duration is 5sec and Message is overrriden because messageTemplateData is {1}',
            messageTemplateData: ['Salesforce', {
                url: 'http://www.webkul.com/',
                label: 'Click Here',
            }],
            duration:'5000',
            key: 'info_alt',
            type: 'warning',
            mode: 'sticky'
        });
        toastEvent.fire();
    },    
    showSuccessToast_Delete : function(component, event) {
    var deleteMsg=  component.get("v.deleteMessage");    
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success: ',
            message: deleteMsg,
            //messageTemplate: 'Record {0} created! See it {1}!',
            duration:'5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    showErrorToast_Delete : function(component, event) {
    var deleteMsg=  component.get("v.deleteMessage");     
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error: ',
            message: deleteMsg,
            //messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
            duration:'5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    }    
    
    
})