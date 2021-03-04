/*
 * @author : Test Candidate
 * @description: This is the tes data factory class that is a generic reusable class to generate test record for unit test classes
 * @date: 04-mar-2021
 */

public class TestDataFactory {
    
    public static List<Case> createTestCaseRecords(integer size){
         list<Case> caseRecordsList = new List<Case>();
         for(integer i=0;i<size;i++){
             case caseNew=new case(subject=' Test case'+i, description='Test Desc XXX');
             caseRecordsList.add(caseNew);             
         }
        return caseRecordsList;
    }

}