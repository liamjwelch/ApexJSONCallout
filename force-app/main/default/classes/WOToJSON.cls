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
            String details = e.getMessage();
            WorkOrderToJSON.createResponseFailure(details);
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
                    //To create a 404 Response Failure
                    //request.setEndpoint('https://hookb.in/1gaD1dD8l9cd6NOO69jVTEST');
                    request.setEndpoint('https://hookb.in/1gaD1dD8l9cd6NOO69jV');
                    request.setMethod('POST');
                    request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                    // Set the body as a JSON object
                    request.setBody(post);
                    HttpResponse response = http.send(request);
                    //UPDATE CONDITION?
                    if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                        //INSERT RESPONSE_SUCCESS OBJECT
                        String details = response.getBody();
                        WorkOrderToJSON.createResponseSuccess(details);
                        System.debug('Request success... status == ' + response.getStatusCode() + ' ' + response.getStatus());
                    } else {
                        String details = response.getBody();
                        WorkOrderToJSON.createResponseFailure(details);
                        System.debug('Request failure... status == ' + response.getBody());
                    }
                } catch (CalloutException e) {
                    String details = e.getMessage();
                    WorkOrderToJSON.createResponseFailure(details);
                    System.debug(e.getMessage());  
                }
            } catch (JSONException e) {
                String details = e.getMessage();
                WorkOrderToJSON.createResponseFailure(details);
                System.debug(e.getMessage());    
            }        
        } catch (QueryException e) {
            String details = e.getMessage();
            WorkOrderToJSON.createResponseFailure(details);
            System.debug(e.getMessage());    
        }
    }
    
    public static void createResponseSuccess(String details) {
        Response_Success__c rs = new Response_Success__c();
        //UPDATE UPPERCASE
        rs.Response_details__c = details;
        //CURRENT SYSTEM DATE?
        rs.CreatedDate = system.now();
        try {insert rs;
            } catch(SObjectException se) {
                System.debug('The following exception has occurred: ' + se.getMessage());
            }
    }
    
    public static void createResponseFailure(String details) {
        Response_Failure__c rf = new Response_Failure__c();
        rf.Reponse_Details__c = details;
        try {
            insert rf;
        } catch(SObjectException se) {
            System.debug('The following exception has occurred: ' + se.getMessage());
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