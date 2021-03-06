//Class for handling single retries from record view in SF
public class ResponseFailureToJSON {
    
    //Method called by the flow that receives the Id of the Response Failure
    //Queries relevant data for transmission to endpoint
    @InvocableMethod(label='ResponseFailureToJSON' description='Test pinging external service.')
    public static void calloutMethod(List<ID> ids){
        List<String> rfIDS = new List<String>();
        try {
            List<Response_Failure__c> responseFailures = [SELECT Reponse_Details__c FROM Response_Failure__c WHERE Id in :ids];
            for (Response_Failure__c rf : responseFailures) {
                rfIDS.add(rf.Reponse_Details__c);
                String detailsToPost = responseFailures.get(0).Reponse_Details__c;
                ResponseFailureToJSON.retryJSON(detailsToPost);
            }
        } catch (QueryException e) {
            System.debug(e.getMessage());    
        }
    }
    
    //Gets the JSON information from the invocable method and POSTS it to the HTTP endpoint
    @future(callout=true)
    public static void retryJSON(String postInformation) {
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://enu0r5w2zt5vj6l.m.pipedream.net');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setBody(postInformation);
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                System.debug('Request success... status == ' + response.getStatusCode() + ' ' + response.getStatus());
            } else {
                String details = response.getBody() + ' ' + postInformation;
                System.debug('Request failure... status == ' + response.getBody());
            }
        } catch (CalloutException e) {
            System.debug(e.getMessage());  
        }
    }    
}