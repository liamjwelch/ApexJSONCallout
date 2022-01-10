//Class called by flow when a Work Order is updated or created
public class WorkOrderToJSON {
    
    //Method called by the flow that receives the Id of the created or updated WorkOrder
    //Queries relevant data for transmission to endpoint
    @InvocableMethod(label='WorkOrderToJSON' description='Test pinging external service.')
    public static void calloutMethod(List<ID> ids){
        List<String> woIDS = new List<String>();
        try {
            List<WorkOrder> workOrders = [SELECT RootWorkOrderId FROM WorkOrder WHERE Id in :ids];
            for (WorkOrder wo : workOrders) {
                woIDS.add(wo.RootWorkOrderId);
                Id idToPost = workOrders.get(0).RootWorkOrderID;
                WorkOrderToJSON.getPostJSON(idToPost);
            }
        } catch (QueryException e) {
            String details = e.getMessage();
            WorkOrderToJSON.createResponseFailure(details);
            System.debug(e.getMessage());    
        }
    }
    
    //Gets the JSON information from the invocable method and POSTS it to the HTTP endpoint
    @future(callout=true)
    public static void getPostJSON(Id lookupID) {
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
                    request.setEndpoint('https://enu0r5w2zt5vj6l.m.pipedream.net');
                    request.setMethod('POST');
                    request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                    // Set the body as a JSON object
                    request.setBody(post);
                    HttpResponse response = http.send(request);
                    //SUCCESS CONDITIONS
                    if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                        //INSERT RESPONSE_SUCCESS OBJECT
                        String details = 'Success status details were... ' + post;
                        WorkOrderToJSON.createResponseSuccess(details);
                        System.debug('Request success... status == ' + response.getStatusCode() + ' ' + response.getStatus());
                    } else {
                        //INSERT RESPONSE_FAILURE OBJECT
                        String details = post;
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
    
    //Method creates a "Reponse Success"
    public static void createResponseSuccess(String details) {
        Response_Success__c rs = new Response_Success__c();
        rs.Response_details__c = details;
        try {insert rs;
            } catch(SObjectException se) {
                System.debug('The following exception has occurred: ' + se.getMessage());
            }
    }
    
    //Method creates a "Reponse Failure"
    public static void createResponseFailure(String details) {
        Response_Failure__c rf = new Response_Failure__c();
        rf.Reponse_Details__c = details;
        try {
            insert rf;
        } catch(SObjectException se) {
            System.debug('The following exception has occurred: ' + se.getMessage());
        }
    }
    
    //For serialization of object into JSON
    public class WrapperWorkOrder {
        public Datetime woCreatedDate {get;set;}
        public String woStatus {get; set;}
        public WrapperWorkOrder() {
            this.woCreatedDate = null;
            this.woStatus = null; 
        }
    } 
}