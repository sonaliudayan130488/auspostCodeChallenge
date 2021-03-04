/*
 * @author : Test Candidate
 * @description: This is the test class to co ver unit testing for case service class
 * @date: 03-mar-2021
 */

@isTest
public class CaseService_Test {

     @testSetup static void createTestRecords() {
         
         // bulk create 
        list<Case> caseRecordsList= TestDataFactory.createTestCaseRecords(100);
        insert caseRecordsList;
     }
    
    // Postive Test for a succesful Callout
    // Check for task Creation
    // Check for Case Update for secret key
    static testMethod void testCaseUpdateCallout_Positive(){
        Test.setMock(HttpCalloutMock.class, new HTTPMockResponseGenerator (
             'Success',204,'{"success":true,"secretKey":"secret_key10"}'
        ));
        
        list<case> testCaseList=[select id,Closed_By_User__c,Secret_Key__c from case where subject like '%Test%' limit 100];
        for(case c:testCaseList){
            c.status='Closed';
        }
        update testCaseList;
        
        // retrieve updated cases
        list<case> testCaseListUpdated=[select id,Closed_By_User__c,Secret_Key__c from case limit 100];

        
        Test.startTest();
          CaseService.updateExternalSystemOnCaseClosure(testCaseListUpdated);       
        Test.stopTest();
          
        list<Task> taskList=[select id from task where subject like '%External System Update: SUCCESS%'];
        list<Case> caseUpdateList=[select id , Secret_Key__c from case where Secret_Key__c != null];
        
        // test if tasks for each case is created
        system.assert(taskList.size()==100);
        system.assert(caseUpdateList.size()==100);
        
       // test if the secret key was updated succesfully on all case records
        for(case c:caseUpdateList){
            system.assertEquals('secret_key10', c.Secret_Key__c);
        }
        
    }
    
    // Negative Test for a succesful Callout
    static testMethod void testCaseUpdateCallout_Negative(){
        List<Case> caseRecList=[select id,Closed_By_User__c,Secret_Key__c from case limit 100];
        Test.setMock(HttpCalloutMock.class, new HTTPMockResponseGenerator (
             'Success',500,'{"success":false,"error":"error message"}'
        ));

        for(Case caseRec:caseRecList){
            caseRec.status='Closed';
        }
        
        update caseRecList;
       
        List<Case> caseRecListUpdated=[select id,Closed_By_User__c,Secret_Key__c from case where id in:caseRecList];
     
         Test.startTest();
           CaseService.updateExternalSystemOnCaseClosure(caseRecListUpdated);
         test.stopTest();
        
        list<Task> taskList=[select id from task where subject like '%External System Update: FAILURE%' and whatId in:caseRecListUpdated];
        list<Case> caseUpdateListAfterUpdate=[select id , Secret_Key__c from case where Secret_Key__c = null];
        
        // test if tasks for each case is created with subject failure
        system.assert(taskList.size()==100);
        // secret key not updated on case
        system.assert(caseUpdateListAfterUpdate.size()==100);       
        
    }
    
    // Test Exception scenario where THE API response is not avaialable
    static testMethod void testCaseUpdateCallout_Exception(){
        List<Case> caseList= [select id,Closed_By_User__c,Secret_Key__c from case limit 2];

        for(Case c:caseList){
            c.status='Closed';
        }
        update caseList;
        boolean exceptionOccured=false;
        
        try{
            Test.startTest();
              CaseService.updateExternalSystemOnCaseClosure(caseList);
            Test.stopTest();
        }
        catch(Exception e){
            exceptionOccured=true;
        }
        
        system.assertEquals(true, exceptionOccured);
    }

}