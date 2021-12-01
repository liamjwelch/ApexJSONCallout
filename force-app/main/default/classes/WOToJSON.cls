public class WOToJSON {
    
    @InvocableMethod(label='WorkOrderToJSON' description='Test pinging external service.')
    public static void calloutMethod(List<ID> ids){
        List<String> woIDS = new List<String>();
        try {
            List<WorkOrder> workOrders = [SELECT RootWorkOrderId FROM WorkOrder WHERE Id in :ids];
            for (WorkOrder wo : workOrders) {
                woIDS.add(wo.RootWorkOrderId);
                Id idToPost = workOrders.get(0).RootWorkOrderID;
                //Callout
                WorkOrderToJSON.getPostJSON(idToPost);
            }
        } catch (QueryException e) {
            System.debug(e.getMessage());    
        }
    }
    
    @future(callout=true)
    public static void getPostJSON(Id lookupID) {
        //Gets ID from Flow
        try {
            WorkOrder objWO = [SELECT CreatedDate, Status FROM WorkOrder WHERE RootWorkOrderId = : lookupID];
            WrapperWorkOrder objWrapperWO = new WrapperWorkOrder();
            objWrapperWO.woCreatedDate = objWO.CreatedDate;
            objWrapperWO.woStatus = objWO.Status;
            try {
                String post = JSON.serialize(objWO);
                system.debug(JSON.serialize(objWO));
                try {
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint('https://hookb.in/1gaD1dD8l9cd6NOO69jV');
                    request.setMethod('POST');
                    request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                    // Set the body as a JSON object
                    request.setBody(post);
                    HttpResponse response = http.send(request);
                    // Parse the JSON response
                    if(response.getStatusCode() != 201) {
                        // Deserialize the JSON string into collections of primitive data types.
                        String details = response.getBody();
                        // Cast the values in the 'rs' key as a list
                        //System.debug('The original list ' + results);
                        //1      List<Boolean> response_successes = (List<Object>) results.get('success');
                        Response_Success__c rs = new Response_Success__c();
                        rs.Response_details__c = details;
                        //might want to grab the previous date
                        rs.CreatedDate = system.now();
                        insert rs;
                        System.debug('rs'+rs);
                        System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' TEST ' + response.getStatus() + ' TEST ' + response.getBody() + ' ' + post);
                        //3      System.debug('The attempt at making a list of objects ' + response_successes);
                        System.debug('Received the following rs:');
                    } else {
                        System.debug('This request failed...' + response.getBody());
                    }
                } catch (CalloutException e) {
                    System.debug(e.getMessage());  
                }
            } catch (JSONException e) {
                System.debug(e.getMessage());    
            }        
        } catch (QueryException e) {
            System.debug(e.getMessage());    
        }
    }
    
    public class WrapperWorkOrder {
        
        public Datetime woCreatedDate {get;set;}
        public String woStatus {get; set;}
        
        public WrapperWorkOrder() {
            this.woCreatedDate = null;
            this.woStatus = null; 
        }
    } 
}