public with sharing class LookupController {
    public LookupController() {

    }

    private final static Integer MAX_RESULTS = 10;
    private final static ID Task_RecordType = Schema.SObjectType.Task__c.getRecordTypeInfosByName().get('Sub Task').getRecordTypeId();
    private final static ID Deliverable_RecordType = Schema.SObjectType.Task__c.getRecordTypeInfosByName().get('Deliverable').getRecordTypeId();

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> search(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        searchTerm += '*';
        
	
        // Execute search query
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
            Task__c (Id, Name, DeliverableName__c, ProjectName__c,Resource_Name__c WHERE recordtypeId=:Task_RecordType and Status__c!='Completed' and Project__r.Stage__c != '15- Closed' and id NOT IN :selectedIds)
            LIMIT :MAX_RESULTS];

        // Prepare result
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Tasks & convert them into LookupSearchResult
        String taskIcon = 'standard:task';
        Task__c [] tasks = ((List<Task__c>) searchResults[0]);
        for (Task__c task : tasks) {
            results.add(new LookupSearchResult(task.Id, 'Tasks', taskIcon, task.Name + ' • '+ task.DeliverableName__c, task.ProjectName__c+' -'+task.Resource_Name__c));
            //results.add(new LookupSearchResult(task.Id, 'Tasks', taskIcon, task.Name, task.Project_Milestone__r.Name+' • '+ task.Project_Name__c));
        }

        // // Extract Opportunities & convert them into LookupSearchResult
        // String opptyIcon = 'standard:opportunity';
        // Opportunity [] opptys = ((List<Opportunity>) searchResults[1]);
        // for (Opportunity oppty : opptys) {
        //     results.add(new LookupSearchResult(oppty.Id, 'Opportunity', opptyIcon, oppty.Name, 'Opportunity • '+ oppty.StageName));
        // }

        return results;
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> deliverable_search(String searchTerm, List<String> selectedIds) {
        // Prepare query paramters
        searchTerm += '*';
        
	
        // Execute search query
        List<List<SObject>> searchResults = [FIND :searchTerm IN ALL FIELDS RETURNING
            Task__c (Id, Name, ProjectName__c,Due_Date__c,Status__c WHERE recordtypeId=:Deliverable_RecordType and id NOT IN :selectedIds)
            LIMIT :MAX_RESULTS];

        // Prepare result
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Tasks & convert them into LookupSearchResult
        String taskIcon = 'standard:task';
        Task__c [] tasks = ((List<Task__c>) searchResults[0]);
        for (Task__c task : tasks) {
            results.add(new LookupSearchResult(task.Id, 'Tasks', taskIcon, task.Name + ' • '+ task.Due_Date__c + ' • ' + task.Status__c, task.ProjectName__c));
            //results.add(new LookupSearchResult(task.Id, 'Tasks', taskIcon, task.Name, task.Project_Milestone__r.Name+' • '+ task.Project_Name__c));
        }

        // // Extract Opportunities & convert them into LookupSearchResult
        // String opptyIcon = 'standard:opportunity';
        // Opportunity [] opptys = ((List<Opportunity>) searchResults[1]);
        // for (Opportunity oppty : opptys) {
        //     results.add(new LookupSearchResult(oppty.Id, 'Opportunity', opptyIcon, oppty.Name, 'Opportunity • '+ oppty.StageName));
        // }

        return results;
    }
}