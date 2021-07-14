({
    doInit : function(component, event, helper) {
    //Set Task Id in RecordEditForm
    var taskId = component.get("v.recordId");
    component.find("taskForm").set("v.recordId", taskId);     
        
        // Call get Deliverable Function
        var action1= component.get("c.getTaskRecordFromTaskPage");     
        action1.setParams({
            taskId : component.get("v.recordId")
        });
        action1.setCallback(this, function(response1){
            var state1= response1.getState();
            if(state1 == 'SUCCESS'){
                
            //Set SF Base Url
            component.set("v.sfBaseUrl",response1.getReturnValue().SF_Base_Url);               
                
            var task= response1.getReturnValue().task;
            component.set("v.task_Instance", task);
            
            console.log('::Task: ', task);    
            
            var statusPickList= response1.getReturnValue().all_taskStatus;
            component.set("v.task_StatusPicklist",statusPickList);
            console.log('::statusPickList: ', statusPickList);      
            console.log('::statusPickList Type: ', typeof(statusPickList));          
            
            var priorityPickList= response1.getReturnValue().all_taskPriorities;
            component.set("v.task_PriorityPicklist", priorityPickList);
                
            //Set Task Instance 
            //helper.setTaskInstance(component, event);              
            
            var deliverable= response1.getReturnValue().DeliverableRec;
            component.set("v.deliverableRecord", deliverable);
             

            // For Task Assignment List
        	helper.create_TaskAssignment_ObjectData(component, event);

        	// Call Task Assignments 
            var map = response1.getReturnValue().taskAssignmentMap;
              
            component.set("v.taskAssignmentMap",map);

     		// Pass Task Id and Task Assignment to Child Component         
            var taskAssignmentMap = component.get("v.taskAssignmentMap");
     		var fetchedList = taskAssignmentMap[taskId];
                
            //console.log(':: fetchedList: ', fetchedList); 
            if(fetchedList && fetchedList.length > 0){    
            //console.log('::: empty false');    
            component.set("v.TaskAssignmentList" , fetchedList);  
                
            //Create Event
            var createEvent = $A.get("e.c:passParameters"); 
     		createEvent.setParams({
       		"param1": taskId,
       		"param2": fetchedList
            });                    
            createEvent.fire();    
                
            }
            else{
            component.find("taskAssignment_Section").set("v.isTrue", "true"); 

            }    
   
            
            component.find("taskAssignment_Section").set("v.isTrue", "true");      
                
            window.setTimeout(
                $A.getCallback( function() {
                    // Now set our preferred value
                     component.find("task_status").set("v.value", task.Status__c);
  				     component.find("task_priority").set("v.value", task.Priority__c);
                    
                     var taskInstance  = component.get("v.task_Instance");
                    if(!taskInstance.Status__c){
                        taskInstance.Status__c = 'Not Started';
                    }
                    else{
                    taskInstance.Status__c = task.Status__c;    
                    }
                    if(!taskInstance.Priority__c){
                        taskInstance.Priority__c = 'Normal';
                    } 
                    else{
                    taskInstance.Priority__c = task.Priority__c;    
                    }

                     component.set("v.task_Instance" , taskInstance);
                }));
                
                
                
        	}// If SUCCESS    
        	});
        	$A.enqueueAction(action1); 

            
    }
    
    ,
    itemsChange: function(component, event, helper){
        var taskPickList= component.get("v.taskSelectList");    
        console.log('::taskPickList '+taskPickList);
        
        if(taskPickList !== '--New Task--' && taskPickList){
            helper.setTaskInstance(component, event); // Please open this Zaid closed it
            //Reset Message
            var errorFlag= component.find("errorFlag");  
            errorFlag.set("v.isTrue",false);
            
            component.find("taskForm").set("v.recordId", taskPickList);     
            component.find("taskForm_Card").set("v.title","Edit Task");
            component.find("taskAssignment_Section").set("v.isTrue", "true");  
            component.find("task_Id").set("v.value", taskPickList);     
            
            // Set child Component 'taskAssignmentList' 
            var taskAssignmentMap = component.get("v.taskAssignmentMap");
            var fetchedList = taskAssignmentMap[taskPickList];
            var childComponent= component.find("cComp");    
            
            //Create Event
            
            var createEvent = $A.get("e.c:passParameters"); 
            createEvent.setParams({
                "param1": taskPickList,
                "param2": fetchedList
            });     
            
            createEvent.fire(); 
        }
        else{
            //component.set("v.taskAssignmentList", "");
              
            helper.setTaskInstance(component, event);
            component.find("taskForm").set("v.recordId", "");        
            component.find("taskForm_Card").set("v.title","Create Task");
            component.find("taskAssignment_Section").set("v.isTrue", "true");   
            
            var createEvent = $A.get("e.c:passParameters"); 
            createEvent.setParams({
                "param1": "",
                "param2": ""
            });
            createEvent.fire();    
        }
    },
    
    addRow: function(component, event, helper){
        // call the comman "createObjectData" helper method to add new Object Row to List  
        helper.create_TaskAssignment_ObjectData(component, event);
    }, 
    
    removeDeletedRow: function(component, event, helper){
        var index= event.getParam("indexVar");
        var deleteList = component.get("v.TaskAssignDelete_List");    
        //get the all List (TaskAssignmentList attribute) and remove the Object Element Using "splice" method      
        var allRowsList= component.get("v.TaskAssignmentList");   
        if(allRowsList && allRowsList.length > 0){
            if(allRowsList[index] && allRowsList[index].Task__c && allRowsList[index].Project_Resource__c){
            deleteList.push(allRowsList[index]);  
            console.log('::Deleted Row: ', allRowsList[index]);
            }  
        }

        allRowsList.splice(index,1);    
        //set the AccountList after remove selected row element  
        component.set("v.TaskAssignmentList", allRowsList);   
    },
    
    Save: function(component, event, helper){
        var errorFlag= component.find("errorFlag");    
        var taskPickList= component.get("v.taskSelectList");    
        
        // first call the helper function in if block which will return true or false.
        // this helper function check the "Project Resource" will not be blank on each row.
        if(helper.validate(component, event)){
            // call the apex class method for save the TaskAssignment List
            // with pass the contact List attribute to method param.   
            var action = component.get("c.insert_TaskAssignment");
            
            var taskAssignmentListVar= component.get("v.TaskAssignmentList");
            var ids= new Array();
            for(var i=0; i < taskAssignmentListVar.length; i++){
                ids.push(taskAssignmentListVar[i]);
            }    
            console.log('::Update List : ',taskAssignmentListVar);
            var taskAssignmentJson= JSON.stringify(ids);    
            action.setParams({
                "taskAssignmentList" : taskAssignmentJson,
                "taskId" : component.get("v.taskSelectList")
            });    
            
            action.setCallback(this, function(response){
                var state= response.getState();
                if(state === 'SUCCESS'){
                    // if response if success then reset the 'TaskAssignment List' Attribute 
                    // and call the common helper method for create a default Object Data to TaskAssignment List   
                    component.set("v.TaskAssignmentList", []);  
                    helper.create_TaskAssignment_ObjectData(component, event);
                    errorFlag.set("v.isTrue",true);   
                    var msg= component.find("errorComp");        
                    msg.set("v.type", "success");
                    msg.set("v.message", "Task Assignment saved successfully");       
                    
                }    
            });
            // enqueue the server side action  
            $A.enqueueAction(action);
            
        }
        //Call Delete Row Functionality and empty Delete List
        var deleteList = component.get("v.TaskAssignDelete_List"); 
        console.log('::Delete List on Save: ',deleteList); 
        if(deleteList && deleteList.length > 0){
            var action2= component.get("c.deleteTaskAssignments");    
            action2.setParams({
                taskAssign_Del_List : deleteList  
            });    
            action2.setCallback(this, function(response){
                var listResponse = response.getReturnValue(); 
                console.log('::listResponse: ',listResponse); 
            });//end of action2
            $A.enqueueAction(action2);    
        }
        
        
        var action3= component.get("c.getTaskAssignmentsMap");      
        // Call Task Assignments 
        action3.setParams({
            DeliverableId : component.get("v.recordId")
        }); 
        action3.setCallback(this, function(response){
            var map = response.getReturnValue();
            component.set("v.taskAssignmentMap",map);
            
            var taskAssignmentMap = component.get("v.taskAssignmentMap");
            var fetchedList = taskAssignmentMap[taskPickList];
            
            var createEvent = $A.get("e.c:passParameters"); 
            createEvent.setParams({
                "param1": taskPickList,
                "param2": fetchedList
            });     
            
            createEvent.fire(); 
            
        });//end of action3  
        $A.enqueueAction(action3); 
        
    },
    createOnLoad: function(component, event, helper){
        // var fields=component.find("taskForm").get("v.fields");
        //component.get("v.recordId")
        // fields[5] = component.get("v.recordId");
        // console.log('::Task On Load: '+ fields);
        
    },
    /*    
    SaveTask:function(component, event, helper){
        // Get Message Component
        
        var errorFlag= component.find("errorFlag");    
        console.log('::errorFlag : '+errorFlag );   
        var task= component.get("v.task_Instance");
        task.Deliverable__c = component.get("v.recordId");  
        console.log('::Task : '+task );
        var action= component.get("c.insertTask");
        console.log('::Task Action : ',action);
        action.setParams({
            "Task": task
        });
        
        action.setCallback(this, function(response){
            console.log('::Call Back: '+ component.get("v.taskMessage"));
            var state= response.getState();
            var message = response.getReturnValue();    
            if(state !== 'SUCCESS'){
                component.set("v.task_Instance", []); 
                helper.create_Task_ObjectData(component, event);
                //alert('Task saved successfully'); 
                if(message && message ==='Error'){
                    
                    errorFlag.set("v.isTrue",true);
                    
                    var msg= component.find("errorComp");        
                    console.log('::Save Task msg : '+msg );
                    msg.set("v.type", "error");
                    msg.set("v.message", "Error occured while saving task");       
                }
                else if(message && message === 'Success'){
                    errorFlag.set("v.isTrue",true);
                    var msg= component.find("errorComp");        
                    console.log('::Save Task msg : '+msg );  
                    msg.set("v.type", "success");
                    msg.set("v.message", "Task saved successfully");  
                }
                
                //Call Task Picklist Apex Function  
                var action2= component.get("c.getPickListValuesIntoList");
                action2.setParams({
                    parentId: component.get("v.recordId")
                });	
                //console.log('::Record Id: '+ component.get("v.recordId"));
                action2.setCallback(this, function(response){
                    //console.log('::response: '+ response.getReturnValue());    
                    var list= response.getReturnValue();
                    component.set("v.pickListValues",list);            
                });         
                $A.enqueueAction(action2);            
            }
        });
        // enqueue the server side action  
        $A.enqueueAction(action);
        
    },
  */  
    redirectToSource: function(component, event, helper){
        console.log('');
        var taskId =  component.get("v.recordId");    
        window.open("https://cloudjunction--crm.lightning.force.com/lightning/r/Deliverable__c/"+taskId+"/view?0.source=alohaHeader", "_self");    
        //window.history.back();
    },
     handleChange: function (component, event) {
      //alert(event.getParam('value'));
         console.log('::Checkbox: '+event.getParam('value'));
      var taskInstance = component.get("v.task_Instance");   
      taskInstance.Billable__c = event.getParam('value');
      component.set("v.task_Instance" , taskInstance);   
    },    
    
    SaveAll: function(component, event, helper){
    
        // Disable Save and Cancel Button
        component.set("v.saveBtnBool", true);
        component.set("v.cancelBtnBool", true);
        
        component.set("v.deleteMessage" , "");
        component.set("v.rtaMessage" , "");
        
        // Set Deliverable_Id in Task_Instance 
        var taskInstance = component.get("v.task_Instance");
        
        var deleteFlag= component.find("deleteFlag");  
        deleteFlag.set("v.isTrue",false);

        var errorFlag= component.find("errorFlag");  
        errorFlag.set("v.isTrue",false);
        var taskPickList= component.get("v.recordId");    
        
        if(taskInstance.Name){
            errorFlag.set("v.isTrue", false);    
            
            // first call the helper function in if block which will return true or false.
            // this helper function check the "Project Resource" will not be blank on each row.
            if(helper.validate(component, event)){
                // call the apex class method to save the Task and RTA List
                // with pass the Task and taskAssignmentList attribute to method param.   
                
                var deleteList = component.get("v.TaskAssignDelete_List");  
                
                if(deleteList && deleteList.length >= 0){
                    // Validate Delete
                   helper.validate_DeleteList(component, event);
                   helper.saveAll_With_DeleteList(component, event);  
                }
                else{
                   helper.saveAll_Without_DeleteList(component, event); 
                } 
            }
        }
        else{
            errorFlag.set("v.isTrue",true);
            
            var msg= component.find("errorComp");        
            msg.set("v.type", "warning");
            msg.set("v.message", "Select Task or Add Task Name for New Task Creation");               
        }
        component.set("v.wrapper_insertRTA" , "")
        
        //Set Toast Message
        var deleteMsg=  component.get("v.deleteMessage");
        var rtaMsg=  component.get("v.rtaMessage");
        
        if(rtaMsg && rtaMsg.toLowerCase().indexOf('success') !== -1){
        helper.showSuccessToast(component,event);    
            console.log('::success RTA: ');    
        }
        else if(rtaMsg && rtaMsg.toLowerCase().indexOf('error') !== -1){
        helper.showErrorToast(component,event);   
        }
        
        if(deleteMsg && deleteMsg.toLowerCase().indexOf('success') !== -1){
        helper.showSuccessToast_Delete(component,event);    
        }
        else if(deleteMsg && deleteMsg.toLowerCase().indexOf('error') !== -1){
        helper.showErrorToast_Delete(component,event);    
        }        

        // Enable Save and Cancel Button
        component.set("v.saveBtnBool", false);
        component.set("v.cancelBtnBool", false);        
        
    },

    changeStartDate: function(component, event, helper){
    var taskAssignList= component.get("v.TaskAssignmentList");
        
        if(taskAssignList && taskAssignList.length === 1 && !taskAssignList[0].Project_Resource__c){

        var task = component.get('v.task_Instance');

        taskAssignList.length = 0;    
            
        var RowItemList= component.get("v.TaskAssignmentList");	
        RowItemList.push({
            //   'sobjectType':'Task_Assignment__c',
            'Task__c':'',            
            'Project_Resource__c': '',
            'Start_Date__c': task.Start_Date__c,
            'End_Date__c':task.Due_Date__c,
            'Id': '',
            'Name': '',
            'Status__c':'Not Started'
            
        });
      
        component.set("v.TaskAssignmentList", RowItemList);
        }
    },
    changeEndDate: function(component, event, helper){
    var taskAssignList= component.get("v.TaskAssignmentList");
        
        if(taskAssignList && taskAssignList.length === 1 && !taskAssignList[0].Project_Resource__c){
        
        var task = component.get('v.task_Instance');

        taskAssignList.length = 0;    
            
        var RowItemList= component.get("v.TaskAssignmentList");	
        RowItemList.push({
            //   'sobjectType':'Task_Assignment__c',
            'Task__c':'',            
            'Project_Resource__c': '',
            'Start_Date__c': task.Start_Date__c,
            'End_Date__c':task.Due_Date__c,
            'Id': '',
            'Name': '',
            'Status__c':'Not Started'
            
        });
      
        component.set("v.TaskAssignmentList", RowItemList);
        }        
    },    
    
})