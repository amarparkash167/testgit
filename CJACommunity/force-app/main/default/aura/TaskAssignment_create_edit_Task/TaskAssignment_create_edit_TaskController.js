({
	doInit : function(component, event, helper) {
    // 
    // var errorFlag= component.find("errorFlag").set("v.isTrue", "false");   
        
        
    // Call get Deliverable Function]
    var action1= component.get("c.getDeliverable");   
        action1.setParams({
            deliverId : component.get("v.recordId")
        });
        action1.setCallback(this, function(response){
            var deliverable= response.getReturnValue();
            component.set("v.deliverableRecord", deliverable);
        });
     
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
     // For Task Assignment List
     helper.create_TaskAssignment_ObjectData(component, event);
             
     // Call Task Assignments 
     var action3= component.get("c.getTaskAssignmentsMap"); 
        action3.setParams({
            DeliverableId : component.get("v.recordId")
        }); 
        action3.setCallback(this, function(response){
            var map = response.getReturnValue();
            console.log('::Map: ',map);
            component.set("v.taskAssignmentMap",map);
        });
        
     // Update Task Assignment Section to reflect th Changes 
           
        $A.enqueueAction(action1);
        $A.enqueueAction(action2);
        $A.enqueueAction(action3);
	}
	,
    itemsChange: function(component, event, helper){
    var taskPickList= component.get("v.taskSelectList");    
    console.log('::taskPickList '+taskPickList);
        
    if(taskPickList !== '--New Task--' && taskPickList){
    //component.set("v.taskAssignmentList", "");      
    //Empty the recordEditForm for Task
    component.find("taskForm").set("v.recordId", "");  
    //Empty the recordEditForm for Task-Assignment        
    component.find("taskForm").set("v.recordId", taskPickList);     
    component.find("taskForm_Card").set("v.title","Edit Task");
    component.find("taskAssignment_Section").set("v.isTrue", "true");  
    component.find("task_Id").set("v.value", taskPickList);    

    // Set child Component 'taskAssignmentList' 
    var taskAssignmentMap = component.get("v.taskAssignmentMap");
    var fetchedList = taskAssignmentMap[taskPickList];
    var childComponent= component.find("cComp"); 
    //console.log('::childComponent: ',childComponent);
   // childComponent.passValues(taskPickList, fetchedList);    
   
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
        deleteList.push(allRowsList[index]);        
        console.log('::deleteRow TaskAssignmentList: ', allRowsList[index]);   
        console.log('::deleteRow TaskAssignmentList: ', deleteList);       
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
      
    }

})