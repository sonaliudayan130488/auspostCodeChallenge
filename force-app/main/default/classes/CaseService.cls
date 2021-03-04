/*
 * @author : Test Candidate
 * @description: This class is to handle business logic on case objects
 * @date: 03-mar-2021
 */

public with sharing class CaseService {
    
    /*@description: make a callout to external system to update case details
     *@input param:  List of  case records
      @output param: void
    */
    public static void updateExternalSystemOnCaseClosure(List<Case> newCaseRecords){
        // List of Case DTO Response Records
        try {
            Map<Case,CaseDTOResponse> caseResponseMap=new Map<Case,CaseDTOResponse>();
            List<CaseDTOResponse> responseRecords =new  List<CaseDTOResponse>();
            for(Case caseRec:newCaseRecords){
                CaseDTORequest caseDto=new CaseDTORequest();
                caseDto.id=caseRec.id;
                caseDto.agentid=caseRec.Closed_By_User__c;
                CaseDTOResponse responseRecord= APIGateway.updateCaseDetails(caseDto);
                caseResponseMap.put(caseRec,responseRecord);
            }
            system.debug('caseResponseMap'+caseResponseMap.size());
            // execute method that handles the response
            handleCaseUpdateResponseAndCreateTasks(caseResponseMap);
        }
        // Logging framework Should handle the exception
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }

    }
    
     /*@description: handle response received for each case record; create tasks based on sucesful creation of failures
     * @input param:  Map of  case records with corresponding response received
       @output param: void
     */
    public static void handleCaseUpdateResponseAndCreateTasks(Map<Case,CaseDTOResponse> caseResponseMap){
        List<task> taskCreateToInsert = new List<task>();
        List<Case> casestoUpdate=new List<Case> ();

        try{
            for(Case caseRec: caseResponseMap.keyset()){
                CaseDTOResponse response=caseResponseMap.get(caseRec);
                if(response!=null){
                
                    // if response was a success and a secret key was received
                    if(response.secretKey!=null && response.success==true){
                        caseRec.Secret_Key__c=response.secretKey;
                        casestoUpdate.add(caseRec);
                        // insert a success task
                        task newTask=new task(whatid=caseRec.id,Subject='External System Update: SUCCESS',Status='Closed');
                        taskCreateToInsert.add(newTask);
                    }
                    else {
                        // insert a failure task
                        task newTask=new task(whatid=caseRec.id,Subject='External System Update: FAILURE',Status='Closed');
                        taskCreateToInsert.add(newTask);
                    }
                }
            }
        
            system.debug('taskCreateToInsert'+taskCreateToInsert);
            system.debug('casestoUpdate'+casestoUpdate);

            // insert the Tasks
            if(!taskCreateToInsert.isEmpty()){
               insert taskCreateToInsert;
            }
            // Update the cases that have received a secret key from the succesful callout to the external system
            if(!casestoUpdate.isEmpty()){
                update casestoUpdate;
            }
        }
        // Logging framework should handle exception scenarios
        catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());

        }

    }
   
}