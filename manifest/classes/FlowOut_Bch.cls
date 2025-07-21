global without sharing class FlowOut_Bch implements Database.Batchable<sObject>, Database.AllowsCallouts {
  private final String qString;
  private String FLOW_URL { get; set; }
  global FlowOut_Bch(String pQuery) {
    RecordType flow_rt = [
      SELECT id
      FROM recordtype
      WHERE sobjecttype = 'Task' AND developername = 'Flow'
    ];
    if (pQuery == null)
      qString =
        'select id, subject, group_guid__c from Task where recordtypeid = \'' +
        flow_rt.Id +
        '\' and Flow_Response__c in (500,0) order by lastmodifieddate desc';
    else
      qString = pQuery;
  }
  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(qString);
  }
  global void execute(Database.BatchableContext BC, List<Task> scope) {
    // Grab Flow custom settings for given profile
    Flow__c FS = Flow__c.getInstance(UserInfo.getProfileId());
    FLOW_URL = FS.TAS_Endpoint__c;
    String target_guid = '';
    for (Task tmpTask : scope) {
      target_guid = tmpTask.group_guid__c;

      //String AUTH_URL = 'https://uat3-tas.teladoc.com';
      HttpRequest auth_req = new HttpRequest();
      auth_req.setMethod('POST');
      auth_req.setHeader('Content-Type', 'application/json');
      auth_req.setTimeout(120000);
      string auth_uri = FLOW_URL + '/v3/authentication/login';
      auth_req.setBody(
        JSON.serialize(
          new Credentials(
            FS.TAS_Username__c,
            FS.TAS_Password__c,
            FS.TAS_Domain__c
          )
        )
      );
      auth_req.setEndpoint(auth_uri);
      Http auth_callout = new Http();
      HttpResponse auth_response = auth_callout.send(auth_req);
      for (String tmpKey : auth_response.getHeaderKeys()) {
        System.debug(
          LoggingLevel.FINER,
          '[FLOWOUT_BCH_HDR] ' + auth_response.getHeader(tmpKey)
        );
      }

      System.debug(
        LoggingLevel.FINER,
        '[FLOWOUT_BCH] ' + auth_response.getBody()
      );
      TDAuthResponse auth = null;
      String accessToken = '';
      try {
        auth = (TDAuthResponse) JSON.deserialize(
          auth_response.getBody(),
          TDAuthResponse.class
        );
        accessToken = auth.auth_token;
      } catch (Exception ex) {
        string taskUrl =
          URL.getOrgDomainUrl().toExternalForm() +
          '/' +
          tmpTask.Id;
        SumoLogic.PostLog(tmpTask.Id, 'FLOWOUT_BCH', tmpTask.Subject, -1);
      }

      HttpRequest req = new HttpRequest();
      req.setMethod('POST');
      if (!Test.isRunningTest())
        req.setHeader('Teladoc-Api-Request-Token', FS.API_Token__c);

      req.setHeader('Authorization', 'Bearer ' + accessToken);
      req.setTimeout(120000);

      string final_uri = FLOW_URL + '/v5/account_setup/accounts';
      system.debug('json_packet: ' + target_guid);
      req.setBody('guid=' + target_guid);
      system.debug(final_uri);
      req.setEndpoint(final_uri);

      Boolean keep_successes = true;
      Http callout = new Http();
      HttpResponse response = callout.send(req);
      if (response.getStatusCode() == 200) {
        //system.debug('SUCCESS: ' + this.result);
        system.debug('TARGET_GUID: ' + target_guid);
        List<Task> completedTasks = [
          SELECT
            id,
            subject,
            flow_response__c,
            Description,
            WhatId,
            group_guid__c
          FROM Task
          WHERE group_guid__c = :target_guid
        ];

        String tmpJson = response.getBody();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(
          tmpJson
        );
        Map<String, Object> data = (Map<String, Object>) m.get('data');
        List<Object> groups = (List<Object>) data.get('groups');
        List<String> errors = (List<String>) data.get('errors');
        for (Object tmpObj : groups) {
          Map<String, Object> tmpMap = (Map<String, Object>) tmpObj;
          System.debug(tmpMap);
          if (tmpMap.get('guid') == target_guid) {
            List<Mbr_Group__c> tmpMbr = [
              SELECT id, guid__c, Group_Number__c, Migration_Group_Number__c
              FROM Mbr_Group__c
              WHERE guid__c = :target_guid
            ];

            tmpMbr[0].Group_Number__c = (String) tmpMap.get('legacyGroupId');
            tmpMbr[0].Migration_Group_Number__c = (String) tmpMap.get(
              'registrationCode'
            );
            update tmpMbr;

            System.debug(tmpMbr[0]);
          }
        }

        if (completedTasks.size() > 0) {
          if (keep_successes) {
            if (completedTasks.size() > 0) {
              completedTasks[0].flow_response__c = response.getStatusCode();
              completedTasks[0].Description = response.getBody();
              completedTasks[0].Status = 'Completed';
              Database.update(completedTasks);
            }
          } else {
            Id case_id = completedTasks[0].WhatId;
            Database.delete(completedTasks);
            /*List<AggregateResult> task_count = [select count(id) case_count
                        from Task 
                        where WhatId = :case_id
                        and Flow_Response__c != 200];
                        // If 0 tasks remain close the case
                        if((Integer)task_count[0].get('case_count') == 0){
                        Case parent_case = [select id, status from Case where id = :case_id];
                        //parent_case.Status = 'Completed';
                        update parent_case;
                        }*/
          }
        }
      } else {
        List<Task> tasks_in_error = [
          SELECT id, subject, flow_response__c, Description
          FROM Task
          WHERE group_guid__c = :target_guid
        ];
        System.debug('Errors returned in packet: ' + tasks_in_error.size());
        if (tasks_in_error.size() > 0) {
          System.debug(tasks_in_error[0]);
          tasks_in_error[0].flow_response__c = response.getStatusCode();
          if (
            response.getStatusCode() != 500 &&
            response.getStatusCode() != 404
          ) {
            if (response.getStatusCode() == 401) {
              tasks_in_error[0].Description =
                '*** Contact salesforcesupport@teladochealth.com regarding Task Id: ' +
                tasks_in_error[0].Id +
                ' ***';
            } else {
              String tmpJson = response.getBody();
              String tmpErrorMsg = '';
              Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(
                tmpJson
              );
              system.debug(m);
              /*List<Object> error_list = (List<Object>)m.get('errors');
                            for(Object tmpTuple : error_list){
                                Map<String,Object> tmpMap = (Map<String,Object>)tmpTuple;
                            */
              tmpErrorMsg += m.get('errors') + '\n';
              /*    
                        }
                            */
              tasks_in_error[0].Description = tmpErrorMsg;
            }
          } else {
            System.Debug('Error body: ' + response.getBody());
            tasks_in_error[0].Description =
              '*** INTEGRATION SERVER ERROR *** ' +
              final_uri +
              '\n';
            tasks_in_error[0].Description += response.getBody();
          }
          Task errorTask = tasks_in_error[0];
          string taskUrl =
            URL.getOrgDomainUrl().toExternalForm() +
            '/' +
            errorTask.Id;
          SumoLogic.PostLog(
            errorTask.Id,
            'FLOWOUT_BCH',
            errorTask.Subject,
            response.getStatusCode()
          );
          Database.update(tasks_in_error);
        }
      }
    }
  }
  global void finish(Database.BatchableContext BC) {
  }
}