/*
 * @author : Test Candidate
 * @description: This class is API gateway class  for all outbound callouts to external systems
 * @date: 03-mar-2021
 */

public class APIGateway {

    /*
     * @description: Thie method makes the callout to extrnal system to update the case details and receieve response
     * @Input: caseDto object
     * @Output: HTTPResponse
     */
    public static CaseDTOResponse updateCaseDetails(CaseDTORequest caseDto){

        String jsonBody;
        // Build the json request body from case dto record
        if(caseDto!=null){
             jsonBody=Json.serialize(caseDto);

        }
            
        //make the callout
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://nfapihub.herokuapp.com/');
        req.setBody(jsonBody);
        req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');
        HttpResponse res = h.send(req);
        return (CaseDTOResponse) System.JSON.deserialize(res.getBody(), CaseDTOResponse.class);
        
    }
}
