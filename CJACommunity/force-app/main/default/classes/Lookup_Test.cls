@isTest
public class Lookup_Test {
    static testMethod void search_should_return_Account() {
        Id [] fixedResults = new Id[1];
        Task__c account = createTestTask('Account');
        fixedResults.add(account.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();

        List<LookupSearchResult> results = LookupController.search('Acc', selectedIds);
        
		//getting sObject Type
		String sobjecttype = results.get(0).getSObjectType();
        String icon = results.get(0).getIcon();
        String title = results.get(0).getTitle();
        String subtitle = results.get(0).getSubtitle();
        
        System.assertEquals(1, results.size());
        System.assertEquals(account.Id, results.get(0).getId());
    }

    static testMethod void search_should_not_return_selected_item() {
        Id [] fixedResults = new Id[1];
        Task__c account1 = createTestTask('Account1');
        fixedResults.add(account1.Id);
        Task__c account2 = createTestTask('Account2');
        fixedResults.add(account2.Id);
        Task__c account3 = createTestDeliverable('Account2');
        fixedResults.add(account3.Id);
        Test.setFixedSearchResults(fixedResults);
        List<String> selectedIds = new List<String>();
        selectedIds.add(account2.Id);

        List<LookupSearchResult> results = LookupController.search('Acc', selectedIds);
        
		system.debug('Result size'+results.size());
        System.assertEquals(1, results.size());
        System.assertEquals(account1.Id, results.get(0).getId());
        
        List<LookupSearchResult> results2 = LookupController.deliverable_search('Acc', selectedIds);
        system.debug('Result size'+results2.size());
        System.assertEquals(1, results2.size());
        System.assertEquals(account3.Id, results2.get(0).getId());
    }

    private static Task__c createTestTask(String name) {
        ID Task_RecordType = Schema.SObjectType.Task__c.getRecordTypeInfosByName().get('Sub Task').getRecordTypeId();
        Task__c task = new Task__c(Name = name, Resource__c =UserInfo.getUserId(), Status__c='In Progress', recordtypeId=Task_RecordType);
        insert task;
        return task;
    }
    
    private static Task__c createTestDeliverable(String name) {
        ID Deliverable_RecordType = Schema.SObjectType.Task__c.getRecordTypeInfosByName().get('Deliverable').getRecordTypeId();
        Task__c task = new Task__c(Name = name, recordtypeId=Deliverable_RecordType);
        insert task;
        return task;
    }
}