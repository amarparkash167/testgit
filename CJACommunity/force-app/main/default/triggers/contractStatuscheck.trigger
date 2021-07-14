/*Trigger created by : Ariba Khan
 * Purpose : A contract can only have one activated contract, if user tries to mark more than one contract as activated then show error*/


trigger contractStatuscheck on Contract (after update) {
    
    
    System.debug('testing debug trigger'+Trigger.new);
    if(Trigger.isAfter && Trigger.isUpdate){
        ContractStatusCheckHandler.afterUpdate(Trigger.new, Trigger.oldMap);
   
    } 
}