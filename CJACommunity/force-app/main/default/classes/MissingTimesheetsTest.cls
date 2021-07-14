@isTest
private class MissingTimesheetsTest {

    public static String CRON_EXP = '0 0 23 * * ? *';
    static testmethod void testScheduledJob() {
        // Create some test data
        
		Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('ScheduledApexTest',
                                        CRON_EXP, 
                                        new MissingTimesheetsSchedulable());
        
        // Stopping the test will run the job synchronously
        Test.stopTest();
        
    }    
}