Apex Outbound Callouts with REST JSON

This code delivers:

When a Work Order is updated/created in Salesforce the information is posted to an external webservice
An object is created if the response succeeds (Response Success) and if it failes (Response Failure)
There is a button on individual failures, and a button for mass retry on the list order view for the custom Response Failure object, which allows for retrying the failed callout with the revelant information on the same endpoint
