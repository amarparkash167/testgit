public class TestMultiTasksCls {
    
    public class onLoad_Data{
      @AuraEnabled List<PickListOption> initialDeliverableOptions{get;  set;}    
      @AuraEnabled Task__c deliverable_Task{get;  set;}  
    }
    
    @AuraEnabled
    public static onLoad_Data onLoad(String taskId){
    try{   
    system.debug('::taskId: ' + taskId);    
    //Wrapper Object
    onLoad_Data obj= new onLoad_Data();    
    List<Task__c> Deliverable_Task;   
    if(String.isBlank(taskId) == false){    
    Deliverable_Task = [Select Id, Name, Project__c From Task__c Where Id=:taskId and RecordType.DeveloperName='Deliverables'];

    if(!Deliverable_Task.isEmpty() && Deliverable_Task != null ){    
    // Set Deliverable Task in Wrapper
    obj.deliverable_Task = Deliverable_Task[0]; 
        
    List<Task__c> SubTasks= new List<Task__c>();    
    SubTasks = [Select Id, Name From Task__c Where Project__c =: Deliverable_Task[0].Project__c and RecordType.DeveloperName='Deliverables'];       
     
    List<PickListOption> deliverableOptions= new List<PickListOption>();    
        
      if(!SubTasks.isEmpty() && SubTasks != null){
          for(Task__c task: SubTasks){
              deliverableOptions.add(new PickListOption(task.Name, task.Id));    
          }      
      }    
        
    obj.initialDeliverableOptions = deliverableOptions;   
    return obj;    
    }
   }    
      }catch(Exception ex){
      System.debug('::Exception LineNumber: '+ ex.getLineNumber());
      System.debug('::Exception Message: '+ ex.getMessage());
      System.debug('::Exception Cause: '+ ex.getCause());    
      } 
    return null;    
    }
    
     @AuraEnabled
    public static void lstTMT  (string test){
        
        system.debug('::here ->   '+test);
        
        List<Task__c> fieldList = (List<Task__c>) JSON.deserialize(test, List<Task__c>.class);
        List<Task__c> lstPAAInsert = new List<Task__c> ();
        system.debug('::also ->   '+fieldList);        
        List<Project__c> lstPro = new List<Project__c>();
        lstPro = [ Select Id from Project__c where name = 'Unassigned Project' limit 1 ];
        List<Task__c> lstDel = new List<Task__c>();
        lstDel = [ Select Id from Task__c where name = 'Unassigned Deliverable' and RecordType.DeveloperName='Deliverables'  limit 1 ];
        
        
        for(Task__c TA : fieldList)
        {
            if(TA.Name != null && TA.Description__c != null)
            {
                if(String.isBlank(TA.Project__c) == true) 
                {
                    TA.Project__c = lstPro[0].id;
                    if(String.isBlank(TA.Deliverables__c) == true)
                   {
                       TA.Deliverables__c = lstDel[0].id;
                   }                    
                }

                
                system.debug('::list to insert ->  '+TA);
                
                lstPAAInsert.add(TA);
                // Set Record Type to "Sub Task"
                TA.RecordTypeId= Schema.sobjectType.Task__c.getRecordTypeInfosByName().get('Sub Task').getRecordTypeId(); 
            }
            //lstPAAInsert.add(TA);
        }
        
        try{
        insert lstPAAInsert;
        }
        catch(DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
    }
    
    public class PickListOption{
    /* Author: Farah Naqvi */    
      @AuraEnabled public String label{get; set;}
      @AuraEnabled public String value{get; set;} 
        
      public PickListOption(String label, String value){
      this.label = label;
      this.value = value;    
      }  
    }
    
    @AuraEnabled 
    public static List<PickListOption> getDeliverables(String projectLookup){
    system.Debug('::Called: '+projectLookup );       
    /* Author: Farah Naqvi */
    List<Task__c> deliverables; 
    List<PicklistOption> options = new List<PicklistOption>();   
 
    if(String.isBlank(projectLookup) == false){
        
    deliverables= new List<Task__c>();
    deliverables = [Select Id, Name From Task__c Where Project__c =:projectLookup and RecordType.DeveloperName = 'Deliverables' ];    
    system.Debug('::Options: '+ deliverables);    
    }
    if(!deliverables.isEmpty() && deliverables.size() > 0){ 
       options.add(new PickListOption('--Select--', ''));
       for(Task__c DeliverableTask: deliverables){
          options.add(new PickListOption(DeliverableTask.Name, DeliverableTask.Id));    
       }
    return options;    
    }
    else{
    return null;    
    }    
    }

}