/*
 * @author : Test Candidate
 * @description: This class is to handle unit test for case
 * @date: 04-mar-2021
 */

@isTest
public class CaseDTO_Test {
    
     @testSetup static void createTestRecords() {
         
        // bulk create 
        list<Case> caseRecordsList= TestDataFactory.createTestCaseRecords(100);
        insert caseRecordsList;
     }
    
    //DTO request Test
    static testMethod void caseDTORequestTest(){
       List<CaseDTORequest> caseDTOs= new  List<CaseDTORequest>();
       Map<Id,case> mapCases=new  Map<Id,case> ();
       List<case> cases=[select Closed_By_User__c,Secret_Key__c from case limit 100];
       for(case c:cases){
         c.status='Closed'; 
       } 
       update cases;
       List<case> casesUpdated=[select Closed_By_User__c,Secret_Key__c from case limit 100];

       for(case c:casesUpdated){
            CaseDTORequest caseDto = new CaseDTORequest();
            caseDto.agentid=c.Closed_By_User__c;
            caseDto.id=c.id;
            caseDTOs.add(caseDto);
            mapCases.put(c.id,c);

       }
       for(CaseDTORequest dto:caseDTOs){
            case caseRec=mapCases.get(dto.id);
            system.assertEquals(caseRec.Closed_By_User__c, dto.agentid);
       }
       
    } 
    
    // DTO Response TEST
     static testMethod void caseDTOResponseTest(){
       Test.setMock(HttpCalloutMock.class, new HTTPMockResponseGenerator (
             'Success',204,'{"success":true,"secretKey":"secret_key100"}'
        ));
       List<CaseDTOResponse> caseResponseDTOs= new  List<CaseDTOResponse>();
         
       Map<Id,case> mapCases=new  Map<Id,case> ();
       List<case> cases=[select Closed_By_User__c,Secret_Key__c from case limit 100];
       for(case c:cases){
         c.status='Closed'; 
       } 
       update cases;
       List<case> casesUpdated=[select Closed_By_User__c,Secret_Key__c from case limit 100];

       test.startTest();
       for(case c:casesUpdated){
            CaseDTORequest caseDto = new CaseDTORequest();
            caseDto.agentid=c.Closed_By_User__c;
            caseDto.id=c.id;
            CaseDTOResponse resDTO=APIGateway.updateCaseDetails(caseDto);
            caseResponseDTOs.add(resDTO);           
       }
       test.stopTest();
       
       for(CaseDTOResponse res:caseResponseDTOs){
               system.assertEquals('secret_key100',res.secretKey);
       }
         
     }

}