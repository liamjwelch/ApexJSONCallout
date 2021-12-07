public class ResponseFailureToJSON {
    
    @InvocableMethod(label='ResponseFailureToJSON' description='Test pinging external service.')
    public static void calloutMethod(List<ID> ids){
        List<String> rfIDS = new List<String>();
        try {
            List<Response_Failure__c> responseFailures = [SELECT Reponse_Details__c FROM Response_Failure__c WHERE Id in :ids];
            for (Response_Failure__c rf : responseFailures) {
                rfIDS.add(rf.Reponse_Details__c);
                //CHECK THIS CODE
                String detailsToPost = responseFailures.get(0).Reponse_Details__c;
                //Callout
                ResponseFailureToJSON.retryJSON(detailsToPost);
            }
        } catch (QueryException e) {
            // String details = e.getMessage();
            // ResponseFailureToJSON.createResponseFailure(details);
            System.debug(e.getMessage());    
        }
    }
    
    @future(callout=true)
    public static void retryJSON(String postInformation) {
        //Gets ID from Flow
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //To create a 404 Response Failure
            //request.setEndpoint('https://hookb.in/1gaD1dD8l9cd6NOO69jVTEST');
            request.setEndpoint('https://hookb.in/mZmEVoXye6tlzXNNz7xm');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            // Set the body as a JSON object
            request.setBody(postInformation);
            HttpResponse response = http.send(request);
            //UPDATE CONDITION?
            if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                //INSERT RESPONSE_SUCCESS OBJECT
                String details = response.getBody() + ' ' + postInformation;
                //WorkOrderToJSON.createResponseSuccess(details);
                System.debug('Request success... status == ' + response.getStatusCode() + ' ' + response.getStatus());
            } else {
                String details = response.getBody() + ' ' + postInformation;
                // WorkOrderToJSON.createResponseFailure(details);
                System.debug('Request failure... status == ' + response.getBody());
            }
        } catch (CalloutException e) {
            System.debug(e.getMessage());  
        }
    }

    //DELETE?
    public class WrapperResponseFailure {
        public String rfDetails {get; set;}
        public WrapperResponseFailure() {
            this.rfDetails = null; 
        }
    } 
    
}