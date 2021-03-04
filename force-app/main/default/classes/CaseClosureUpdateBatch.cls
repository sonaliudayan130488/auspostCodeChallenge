/*
 * @author : Test Candidate
 * @description: This class is to make callouts to external system when case is update to closed 
 * @date: 03-mar-2021
 */

global class CaseClosureUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    // Get value from Custom Metadata Type for Date Range between today - X number of days that needs to be considered for case closure
    // BY default this is set to 0. In case of system outages, the value csn be set accordingly such that batch job will capture cases closed X days before Today
    Integer days=  (Integer)SystemSettings__mdt.getInstance('Case_Update_Batch_Days').Case_Update_Batch_Number_of_Days__c;
    date closureDate=System.today()-days;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        // Fetch the records that have been closed today ,IsClosedOnCreate is false and Secret key is blank
        String query = 'SELECT  id, Secret_Key__c,Closed_By_User__c From Case where ClosedDate>=:closureDate and  Secret_Key__c=null';

       // String query = 'SELECT  id, Secret_Key__c From Case where ClosedDate=:closureDate and IsClosedOnCreate=false and Secret_Key__c=null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Case> scope){
        System.Debug('Generated Scope'+scope);
        // call Case service to process the records
        CaseService.updateExternalSystemOnCaseClosure(scope);
    }
    
    global void finish(Database.BatchableContext bc){
         
    }

}