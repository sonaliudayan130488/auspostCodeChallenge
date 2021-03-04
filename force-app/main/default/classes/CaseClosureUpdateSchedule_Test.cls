/*
 * @author : Test Candidate
 * @description: This class is to test the schedule of the batch job for case closure updates
 * @date: 03-mar-2021
 */

@isTest
public class CaseClosureUpdateSchedule_Test {

    
    // test method to test if the scheduling is working as expected
    static testMethod void testScheduleCreated_Positive(){
             
       String CRON_EXP = '0 0 0 3 9 ? 2024';
        
       Test.startTest(); 
       String jobId = System.schedule('TestCaseUpdateSchedule', CRON_EXP, new CaseClosureUpdateSchedule());
       CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
       Test.stopTest();
        
       System.assertEquals(0, ct.TimesTriggered); 

       // test next run
       System.assertEquals('2024-09-03 00:00:00', String.valueOf(ct.NextFireTime));   

    }

}