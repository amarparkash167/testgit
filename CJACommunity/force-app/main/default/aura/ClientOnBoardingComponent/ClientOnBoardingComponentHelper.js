({
    //get Industry Picklist Value
    getRecordTypePicklist: function(component, event) {
        console.log("enter in method");
        var action = component.get("c.getOpportunityRecordTypes");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var recordTypeMap = [];
                for(var key in result){
                    recordTypeMap.push({key: key, value: result[key]});
                }
                component.set("v.RecordTypeMap", recordTypeMap);
            }
        });
        $A.enqueueAction(action);
    },
    
})