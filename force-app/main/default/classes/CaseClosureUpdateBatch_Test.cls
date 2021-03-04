/*
 * @author : Test Candidate
 * @description: This is the test class to cover unit testing for case update close batch
 * @date: 03-mar-2021
 */

@isTest
public class CaseClosureUpdateBatch_Test {

     @testSetup static void createTestRecords() {
         
        // bulk create 
        list<Case> caseRecordsList= TestDataFactory.createTestCaseRecords(100);
        insert caseRecordsList;
     }
    
    
     // TEST batch execution for succesful callout
     static testMethod void testCaseUpdateCalloutFromBatch_Positive(){
        Test.setMock(HttpCalloutMock.class, new HTTPMockResponseGenerator (
             'Success',204,'{"success":true,"secretKey":"secret_key30"}'
        ));
        
        list<case> testCaseList=[select id,Closed_By_User__c,Secret_Key__c from case where subject like '%Test%' limit 100];
        for(case c:testCaseList){
            c.status='Closed';
        }
        update testCaseList;
        
        test.startTest();
			Id batchJobId = Database.executeBatch(new CaseClosureUpdateBatch(), 100);        
        test.stopTest();
        
        //Check job status
        AsyncApexJob job=[select status from AsyncApexJob where id=:batchJobId ];
        system.assertEquals('Completed', job.status);
        
        list<case> testCaseListUpdated=[select id,Closed_By_User__c,Secret_Key__c from case where subject like '%Test%' and id in:testCaseList];
        for(case c:testCaseListUpdated){
           system.assertEquals('secret_key30', c.Secret_Key__c);
        }
        
     }
    
   // TEST batch execution for unsuccesful callout
    static testMethod void testCaseUpdateCalloutFromBatch_Negative(){
        Test.setMock(HttpCalloutMock.class, new HTTPMockResponseGenerator (
             'Success',500,'{"success":false,"error":"error message"}'
        ));
        
        list<case> testCaseList=[select id,Closed_By_User__c,Secret_Key__c from case where subject like '%Test%' limit 100];
        for(case c:testCaseList){
            c.status='Closed';
        }
        update testCaseList;
        
        test.startTest();
			Id batchJobId = Database.executeBatch(new CaseClosureUpdateBatch(), 100);        
        test.stopTest();
        
        //Check job status
        AsyncApexJob job=[select status from AsyncApexJob where id=:batchJobId ];
        system.assertEquals('Completed', job.status);
        
        list<case> testCaseListUpdated=[select id,Closed_By_User__c,Secret_Key__c from case where subject like '%Test%' and id in:testCaseList];
        for(case c:testCaseListUpdated){
           system.assertEquals(null, c.Secret_Key__c);
        }
        
     }
}