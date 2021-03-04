/*
 * @author : Test Candidate
 * @description: This class is to schedule the batch job that makes the callout upon case closures 
 * @date: 03-mar-2021
 */


global class CaseClosureUpdateSchedule implements Schedulable, Database.AllowsCallouts  {
   global void execute(SchedulableContext sc) {
      CaseClosureUpdateBatch caseUpdateBatch = new CaseClosureUpdateBatch(); 
      database.executebatch(caseUpdateBatch);
   }
}
