({
	create_TaskAssignment_ObjectData : function(component, event) {
	var RowItemList= component.get("v.TaskAssignmentList");	
        RowItemList.push({
       //   'sobjectType':'Task_Assignment__c',
            'Task__c':'',            
            'Project_Resource__c': '',
            'Start_Date__c': '',
            'End_Date__c':'',
            'Id': '',
            'Name': '',
            'Status__c':''

        });
    component.set("v.TaskAssignmentList", RowItemList);
	},
    
	create_Task_ObjectData : function(component, event) {
	var taskObject= component.get("v.task_Instance");	
        taskObject.push({
          'sobjectType':'Task__c',
            'Name': '',
            'Start_Date__c': '',
            'Due_Date__c':'',
            'Status__c':'',
            'Deliverable__c': '',
            'Priority__c' : '',
            'Id': ''            
        });
    component.set("v.task_Instance", taskObject);
	},
    
    validate:function(component, event){	
    var isValid= true;
    var allTaskAssignmentRows= component.get("v.TaskAssignmentList");    
        
    for(var indexVar=0; indexVar < allTaskAssignmentRows.length; indexVar++){
       // console.log('::Typeof Project Resource: '+allTaskAssignmentRows[indexVar].Project_Resource__c);
        allTaskAssignmentRows[indexVar].Task__c = component.get("v.taskSelectList");
        allTaskAssignmentRows[indexVar].Id = allTaskAssignmentRows[indexVar].Id; 
 
        allTaskAssignmentRows[indexVar].Project_Resource__c = allTaskAssignmentRows[indexVar].Project_Resource__c;
        
        if(typeof allTaskAssignmentRows[indexVar].Project_Resource__c == 'object'){
        allTaskAssignmentRows[indexVar].Project_Resource__c = allTaskAssignmentRows[indexVar].Project_Resource__c[0]; 
        }
        
        if(allTaskAssignmentRows[indexVar].Id == ''){
        console.log('::Id Value : ', allTaskAssignmentRows[indexVar].Id);    
           allTaskAssignmentRows[indexVar].Id = allTaskAssignmentRows[indexVar].Id[0];  
        }
        console.log('::ProjectResource Type : ', typeof allTaskAssignmentRows[indexVar].Project_Resource__c);
        console.log('::Id Type : ', typeof allTaskAssignmentRows[indexVar].Id);

        if(allTaskAssignmentRows[indexVar].Project_Resource__c === ''){
           isValid= false;
           alert('Project Resource cannot be blank on row number ' + (indexVar + 1)); 
        }
    }
    return isValid;
    }
     
    
})