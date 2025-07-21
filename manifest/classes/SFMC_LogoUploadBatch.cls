global class SFMC_LogoUploadBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
  AcctGrpConParsing_Item__c agcpi = new AcctGrpConParsing_Item__c(
    Batch_Key__c = String.valueOf(DateTime.now().getTime()),
    Item_Key__c = String.valueOf(DateTime.now().getTime() / 1000),
    Processed__c = false,
    Batch_Time__c = DateTime.now(),
    Source__c = 'SFMC_LogoUpload'
  );
  private String agcpiId;
  SFMC__c sfmc = SFMC__c.getOrgDefaults();
  global SFMC_LogoUploadBatch() {
    insert agcpi;
    agcpiId = agcpi.id;
  }
  global Database.QueryLocator start(Database.BatchableContext bc) {
    String libraryId = sfmc.LibraryId__c;
    String soqlQuery = 'SELECT Id, Title, SFMC_Id__c, ContentDocument.Description,contentdocument.parentId, FileExtension, Description FROM ContentVersion WHERE contentdocument.parentId =: libraryId AND LastModifiedDate <= TODAY AND SFMC_Id__c = NULL';
    return Database.getQueryLocator(soqlQuery);
  }

  global void execute(
    Database.BatchableContext bc,
    List<ContentVersion> scope
  ) {
    String grant_type = sfmc.Grant_Type__c;
    String clientId = sfmc.ClientId__c;
    String clientSecret = sfmc.Client_Secret__c;
    String accountid = sfmc.AccountId__c;
    String categoryName = sfmc.CategoryName__c;
    Integer categoryId = Integer.valueOf(sfmc.CategoryId__c);
    String endpointurl = sfmc.Token_EndpointUrl__c;
    String endpoint = sfmc.EndpointUrl__c;
    String accessToken = '';
    String sfmcId = '';
    Integer maxsize = 255;
    List<AcctGrpConParse_Exception__c> agcpeList = new List<AcctGrpConParse_Exception__c>();
    List<ContentVersion> cnToBeUpdated = new List<ContentVersion>();

    Map<String, Blob> conVersionMap = new Map<String, Blob>();
    List<ContentVersion> conVerList = [
      SELECT Id, versionData
      FROM ContentVersion
      WHERE ID IN :Scope
    ];

    for (ContentVersion con : conVerList) {
      conVersionMap.put(con.Id, con.VersionData);
    }

    List<Asset_Type__mdt> fieldMapping = [
      SELECT Id, DeveloperName, Asset_Type__c, Asset_Id__c
      FROM Asset_Type__mdt
    ];
    Map<String, Integer> assetIdMap = new Map<String, Integer>();
    for (Asset_Type__mdt assetType : fieldMapping) {
      assetIdMap.put(
        assetType.Asset_Type__c,
        Integer.valueOf(assetType.Asset_Id__c)
      );
    }

    for (ContentVersion cn : scope) {
      String encodedFileString = EncodingUtil.base64Encode(
        conVersionMap.get(cn.Id)
      );
      String filename =
        cn.Title +
        '-' +
        cn.FileExtension +
        '.' +
        cn.FileExtension;
      HttpRequest request = new HttpRequest();
      request.setHeader('Content-Type', 'application/json');
      request.setMethod('POST');
      String jsonBody = JSON.serialize(
        new Map<String, String>{
          'client_id' => clientId,
          'client_secret' => clientSecret,
          'account_id' => accountid,
          'grant_type' => grant_type
        }
      );

      request.setBody(jsonBody);
      request.setEndpoint(endpointurl);
      try {
        Http http = new Http();
        HttpResponse response = new HttpResponse();
        response = http.send(request);
        for (String tmpKey : response.getHeaderKeys()) {
          System.debug(
            LoggingLevel.FINER,
            'sfmcLogo_access' + response.getHeader(tmpKey)
          );
        }
        system.debug(response.getStatusCode());
        if (response.getStatusCode() == 200) {
          String jsonResponse = response.getBody();
          System.debug('Response-' + jsonResponse);
        }
        System.debug(
          LoggingLevel.FINER,
          'sfmcLogo_accessRes' + response.getBody()
        );
        map<string, Object> resultMap = (map<string, Object>) JSON.deserializeUntyped(
          response.getBody()
        );
        accesstoken = (String) resultMap.get('access_token');
      } catch (Exception ex) {
        system.debug(ex.getCause());
        AcctGrpConParse_Exception__c agcpe = new AcctGrpConParse_Exception__c(
          AGCPI__c = agcpiId,
          Exception_Type__c = String.valueOf(ex.getTypeName()),
          Short_Desc__c = 'SFMC_Logo Auth Exception',
          SObject__c = 'ContentVersion',
          Full_Desc__c = ex.getMessage()
        );
        agcpeList.add(agcpe);
      }

      String fileUploadbody = JSON.serialize(
        new SFMC_logoModel.body(
          cn.Title + '-' + cn.FileExtension,
          String.valueOf(cn.FileExtension),
          Integer.valueOf(assetIdMap.get(String.valueOf(cn.FileExtension))),
          categoryName,
          categoryId,
          filename,
          encodedFileString
        )
      );

      HttpRequest req = new HttpRequest();
      req.setMethod('POST');
      req.setHeader('content-type', 'application/Json');
      req.setHeader('Authorization', 'Bearer ' + accessToken);
      req.setTimeout(120000);
      req.setEndpoint(endpoint);
      req.setBody(fileUploadbody);
      try {
        Http callout = new Http();
        HttpResponse res = new HttpResponse();
        res = callout.send(req);
        for (String tmpKey : res.getHeaderKeys()) {
          System.debug(
            LoggingLevel.FINER,
            'sfmcLogo_callout' + res.getHeader(tmpKey)
          );
        }
        system.debug(res.getStatusCode());
        if (res.getStatusCode() == 201) {
          String jsonRes = res.getBody();
          System.debug('JSONResponse-' + jsonRes);
          map<string, Object> responseMap = (map<string, Object>) JSON.deserializeUntyped(
            res.getBody()
          );
          sfmcId = String.valueOf(responseMap.get('id'));
          cn.SFMC_Id__c = sfmcId;
          cnToBeUpdated.add(cn);
        } else {
          map<string, Object> errorResponseMap = (map<string, Object>) JSON.deserializeUntyped(
            res.getBody()
          );
          String errorDesc = String.valueOf(
            errorResponseMap.get('validationErrors')
          );
          if (errorDesc.length() > maxsize) {
            errorDesc = errorDesc.substring(0, maxsize);
          }
          AcctGrpConParse_Exception__c agcpe = new AcctGrpConParse_Exception__c(
            AGCPI__c = agcpiId,
            Exception_Type__c = String.valueOf(res.getStatusCode()),
            Short_Desc__c = 'SFMC_File' +
              '[Id:' +
              cn.Id +
              ';' +
              'Title:' +
              cn.Title +
              ']',
            SObject__c = 'ContentVersion',
            Full_Desc__c = errorDesc
          );
          agcpeList.add(agcpe);
        }
        System.debug(LoggingLevel.FINER, 'sfmcLogo_upload' + res.getBody());
      } catch (Exception ex) {
        system.debug(ex.getCause());
        AcctGrpConParse_Exception__c agcpe = new AcctGrpConParse_Exception__c(
          AGCPI__c = agcpiId,
          Exception_Type__c = String.valueOf(ex.getTypeName()),
          Short_Desc__c = 'SFMC_File' +
            '[Id:' +
            cn.Id +
            ';' +
            'Title:' +
            cn.Title +
            ']',
          SObject__c = 'ContentVersion',
          Full_Desc__c = ex.getMessage()
        );
        agcpeList.add(agcpe);
      }
    }
    update cnToBeUpdated;
    if (!agcpeList.IsEmpty()) {
      Database.insert(agcpeList, false);
    }
  }

  global void finish(Database.BatchableContext bc) {
    List<AcctGrpConParsing_Item__c> lstAgcpi = [
      SELECT Id
      FROM AcctGrpConParsing_Item__c
      WHERE Source__c = 'SFMC_LogoUpload' AND Id = :agcpiId
      LIMIT 1
    ];
    if (!lstAgcpi.isEmpty()) {
      agcpi = lstAgcpi[0];
      agcpi.processed__c = true;
      update agcpi;
    }
  }
}