
    public class WOToJSON {

        @InvocableMethod(label='WOToJSON' description='Test pinging external service.')
        public static void calloutMethod(List<ID> ids){
        List<String> woIDS = new List<String>();
        List<WorkOrder> workOrders = [SELECT RootWorkOrderId FROM WorkOrder WHERE Id in :ids];
        for (WorkOrder wo : workOrders) {
        woIDS.add(wo.RootWorkOrderId);
        }
        //System.debug(JSON.serializePretty(workOrders));
        //
		Id idToPost = workOrders.get(0).RootWorkOrderID;
        System.debug('SendingJSON');
        WorkOrderToJSON.get_post_JSON(idToPost);
        }
    
    public static void test(List<ID> ids) {
        List<String> woIDS = new List<String>();
        List<WorkOrder> workOrders = [SELECT RootWorkOrderId FROM WorkOrder WHERE Id in :ids];
        for (WorkOrder wo : workOrders) {
        woIDS.add(wo.RootWorkOrderId);
        }
        System.debug(JSON.serializePretty(workOrders));
    	}

    	@future(callout=true)
   		public static void getPostJSON(Id lookupID) {
        
        WorkOrder objWO = [SELECT CreatedDate, Status FROM WorkOrder WHERE RootWorkOrderId = : lookupID];
        WrapperWorkOrder objWrapperWO = new WrapperWorkOrder();
        objWrapperWO.woCreatedDate = objWO.CreatedDate;
        objWrapperWO.woStatus = objWO.Status;
        
        String post = JSON.serialize(objWO);
        system.debug(JSON.serialize(objWO));
            
     	Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://hookb.in/pz7qbbYpWLsRPnrrPLl3');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Set the body as a JSON object
        request.setBody(post);
        HttpResponse response = http.send(request);
        // Parse the JSON response
        if(response.getStatusCode() != 201) {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
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