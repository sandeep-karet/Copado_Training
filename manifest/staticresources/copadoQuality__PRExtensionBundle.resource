{
  "recordTypeMap": {},
  "RecordSetBundles": [
    {
      "Records": [
        {
          "attributes": {
            "type": "copado__JobTemplate__c",
            "url": "/services/data/v64.0/sobjects/copado__JobTemplate__c/a0uKI000000E55cYAC"
          },
          "copado__ApiName__c": "Pull_Request_1",
          "copado__Type__c": "Custom",
          "copado__Version__c": 1,
          "Id": "a0uKI000000E55cYAC",
          "LastReferencedDate": "2025-06-06T10:28:18.000+0000",
          "LastViewedDate": "2025-06-06T10:28:18.000+0000",
          "Name": "Pull Request"
        }
      ],
      "ObjectType": "copado__JobTemplate__c"
    },
    {
      "Records": [
        {
          "attributes": {
            "type": "copado__JobStep__c",
            "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0tKI000001OL4FYAW"
          },
          "copado__ApiName__c": "Pull_Request_1_Pull_Request_creation_1",
          "copado__ConfigJson__c": "{\"flowName\":\"Pull_Request_Automation\",\"parameters\":[{\"name\":\"userStoryId\",\"value\":\"{$Context.JobExecution__r.DataJson.userStoryId}\"},{\"name\":\"promotionId\",\"value\":\"{$Context.JobExecution__r.DataJson.promotionId}\"}]}",
          "copado__CustomType__c": "Salesforce Flow",
          "copado__IsSkipped__c": false,
          "copado__JobTemplate__c": "a0uKI000000E55cYAC",
          "copado__Order__c": 1,
          "copado__Type__c": "Flow",
          "Id": "a0tKI000001OL4FYAW",
          "Name": "Validate Pull Requests"
        }
      ],
      "ObjectType": "copado__JobStep__c"
    }
  ],
  "blobsByUID": {}
}