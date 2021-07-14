({
    changeOfSelectedTask: function(component, event, helper){
    // Rest Values
    component.set("v.taskId", "");
    component.set("v.taskAssignmentList", ""); 
    component.set("v.param1", "");
    component.set("v.param2", "");         
        
    var param1= event.getParam('param1');
    var param2= event.getParam('param2');    
        
        component.set("v.taskId", param1);
        component.set("v.taskAssignmentList",param2);
        
        //console.log('::param 1 Id: '+ param1);
        //console.log('::param 2 List: ',  param2);  
        
        helper.doInit(component, event);
    },
    addRow : function(component, event, helper) {
        //Execute the AddRowEvent Lightning Event 
		component.getEvent("AddRowEvent").fire();
	},
    
    deleteRow: function(component, event, helper){
        //Execute the DeleteRowEvent Lightning Event and pass the deleted Row Index to Event attribute
        component.getEvent("DeleteRowEvent").setParams({"indexVar": component.get("v.rowIndex")}).fire();
        var rowIndexVar=  component.get("v.rowIndex");
        
        if((typeof rowIndexVar) == 'number' && rowIndexVar === 0){
           console.log('::Row Index: ',  component.get("v.rowIndex")); 
           component.getEvent("AddRowEvent").fire(); 
        }
        
        
        
    }
})