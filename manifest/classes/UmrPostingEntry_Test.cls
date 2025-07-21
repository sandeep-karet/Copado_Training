@IsTest
private class UmrPostingEntry_Test {
  @TestSetup
  static void setup() {
    Document newDoc = new Document();
    newDoc.Body = Blob.valueOf('Text Image');
    newDoc.ContentType = 'application/pdf';
    newDoc.DeveloperName = 'my_document';
    newDoc.IsPublic = true;
    newDoc.Name = 'Test Document';
    newDoc.FolderId = [SELECT id FROM folder WHERE name = 'Quotes'].id;
    insert newDoc;

    Document newDoc2 = new Document();
    newDoc2.Body = Blob.valueOf('Text Image');
    newDoc2.ContentType = 'application/pdf';
    newDoc2.DeveloperName = 'MK_TDH_HZ_2';
    newDoc2.IsPublic = true;
    newDoc2.Name = 'MK_TDH_HZ_2';
    newDoc2.FolderId = [SELECT id FROM folder WHERE name = 'Quotes'].id;
    insert newDoc2;

    ContentVersion cv = new ContentVersion();
    cv.Title = 'My Document';
    cv.PathOnClient = 'TestDocument.pdf';
    cv.VersionData = Blob.valueOf('Test Content');
    cv.IsMajorVersion = true;
    insert cv;

    ContentVersion cv2 = new ContentVersion();
    cv2.Title = 'MK_TDH_HZ_2';
    cv2.PathOnClient = 'MK_TDH_HZ_2.pdf';
    cv2.VersionData = Blob.valueOf('Test Content');
    cv2.IsMajorVersion = true;
    insert cv2;

    List<ContentVersion> testContent = [
      SELECT ContentDocumentId
      FROM ContentVersion
    ];
    ID workspaceId = [SELECT Id FROM ContentWorkspace WHERE Name = 'Logos'][0]
    .Id;

    for (ContentVersion cvs : testContent) {
      ContentWorkspaceDoc newWorkspaceDoc = new ContentWorkspaceDoc();
      newWorkspaceDoc.ContentWorkspaceId = workspaceId;
      newWorkspaceDoc.ContentDocumentId = cvs.ContentDocumentId;
      insert newWorkspaceDoc;
    }

    List<ContentDocument> documents = [
      SELECT Id, Title, LatestPublishedVersionId
      FROM ContentDocument
    ];
    for (ContentDocument cd : documents) {
      cd.parentId = workspaceId;
      update cd;
    }

    List<Product2> cpq_prods = new List<Product2>();
    Product2 prod_gm = new Product2(
      name = 'General Medical',
      productCode = 'GM'
    );
    Product2 prod_bh = new Product2(
      name = 'Behavioral Health Care',
      productCode = 'BH'
    );
    Product2 prod_derm = new Product2(
      name = 'Dermatology',
      productCode = 'DERM'
    );
    Database.insert(new List<SObject>{ prod_gm, prod_bh, prod_derm });
    Map<String, String> umrProdMap = new Map<String, String>();
    List<Product2> umrProdList = [SELECT Id, Name FROM Product2];
    for (Product2 prod : umrProdList) {
      umrProdMap.put(prod.name, prod.Id);
    }
    TestDataFactory.CreateProduct();
    Map<String, String> prodMap = new Map<String, String>();
    List<Product2> prodList = [SELECT Id, Name, ProductCode FROM Product2];
    for (Product2 prod : prodList) {
      prodMap.put(prod.ProductCode, prod.Id);
    }

    Account tmpAcct = new Account(
      Name = 'UMR',
      Account_Legal_Name__c = 'UMR',
      Source__c = 'HUB',
      CurrencyIsoCode = 'USD',
      Business_Region__c = 'USA',
      Guid__c = '1BB95CCB-765E-17A8-6778-6846FB556025'
    );
    insert tmpAcct;
    Contact conObj = TestDataFactory.createContact(tmpAcct.Id);

    List<SBQQ__Subscription__c> umr_subs = new List<SBQQ__Subscription__c>();
    umr_subs.add(
      new SBQQ__Subscription__c(
        Source_Id__c = 'a2h60000001Rxg6AAC',
        SBQQ__Account__c = tmpAcct.Id,
        SBQQ__Product__c = umrProdMap.get('General Medical'),
        SBQQ__Quantity__c = 100
      )
    );
    umr_subs.add(
      new SBQQ__Subscription__c(
        Source_Id__c = 'a2hf2000002IW0CAAW',
        SBQQ__Account__c = tmpAcct.Id,
        SBQQ__Product__c = umrProdMap.get('Behavioral Health Care'),
        SBQQ__Quantity__c = 100
      )
    );
    umr_subs.add(
      new SBQQ__Subscription__c(
        Source_Id__c = 'a2hf2000002IW0DAAW',
        SBQQ__Account__c = tmpAcct.Id,
        SBQQ__Product__c = umrProdMap.get('Dermatology'),
        SBQQ__Quantity__c = 100
      )
    );
    insert umr_subs;
    Map<String, String> subIdMap = new Map<String, String>();
    List<SBQQ__Subscription__c> subList = [
      SELECT Id, Source_Id__c
      FROM SBQQ__Subscription__c
    ];
    for (SBQQ__Subscription__c sub : subList) {
      subIdMap.put(sub.Source_Id__c, sub.Id);
    }

    TestDataFactory.createAsset(
      'DERM',
      75,
      tmpAcct.Id,
      conObj.Id,
      prodMap.get('DERMFEE'),
      subIdMap.get('a2hf2000002IW0DAAW')
    );
    TestDataFactory.createAsset(
      'Consult Fee- Psych/MD-1stvisitonly-Total',
      200,
      tmpAcct.Id,
      conObj.Id,
      prodMap.get('BHP1T'),
      subIdMap.get('a2hf2000002IW0CAAW')
    );
    TestDataFactory.createAsset(
      'Consult Fee- Non-Psychiatrist- Total',
      85,
      tmpAcct.Id,
      conObj.Id,
      prodMap.get('BHNPT'),
      subIdMap.get('a2hf2000002IW0CAAW')
    );
    TestDataFactory.createAsset(
      'Consult Fee- Psych/MD-ONGOING-Total',
      95,
      tmpAcct.Id,
      conObj.Id,
      prodMap.get('BHPOT'),
      subIdMap.get('a2hf2000002IW0CAAW')
    );
    TestDataFactory.createAsset(
      'GM',
      45,
      tmpAcct.Id,
      conObj.Id,
      prodMap.get('GMCF'),
      subIdMap.get('a2h60000001Rxg6AAC')
    );

    List<AcctGrpConParsing_Item__c> tmpAgcpis = Test.loadData(
      AcctGrpConParsing_Item__c.sObjectType,
      'umr_agcpi_tests'
    );
    for (AcctGrpConParsing_Item__c tmpAgcpi : tmpAgcpis)
      tmpAgcpi.Id = null;
    insert tmpAgcpis;

    String recordtypeId = [
      SELECT id, name
      FROM RecordType
      WHERE SobjectType = 'Disclaimers__c' AND name = 'Disclaimer'
    ]
    .Id;
    Disclaimers__c tmpDisclaimer = new Disclaimers__c(
      RecordTypeId = recordtypeId,
      Name = 'STND',
      Disclaimer_Language__c = '© 2019 Teladoc Health, Inc. All rights reserved. Teladoc and the Teladoc logo are registered trademarks of Teladoc Health, Inc. and may not be used without written permission. Teladoc does not replace the primary care physician. Teladoc does not guarantee that a prescription will be written. Teladoc operates subject to state regulation and may not be available in certain states. Teladoc does not prescribe DEA controlled substances, non therapeutic drugs and certain other drugs which may be harmful because of their potential for abuse. Teladoc physicians reserve the right to deny care for potential misuse of services.'
    );
    insert tmpDisclaimer;

    Web_URLs__c tmpUrL = new Web_URLs__c(Name = 'Teladoc.com');
    insert tmpUrL;
  }

  @IsTest
  static void testUmrEntriesNoBhDerm() {
    UmrAcctGrpConParser uagcp = new UmrAcctGrpConParser();
    System.assertNotEquals(0, [SELECT COUNT() FROM AcctGrpConParsing_Item__c]);
    List<AcctGrpConParsing_Item__c> tmpAgcpi = [
      SELECT
        id,
        batch_key__c,
        batch_time__c,
        item_data__c,
        item_defaults__c,
        item_key__c
      FROM acctgrpconparsing_item__c
      WHERE processed__c = FALSE
      LIMIT 1
    ];
    system.debug(tmpAgcpi[0].item_data__c);
    System.assertEquals(1, tmpAgcpi.size());
    uagcp.ProcessPostingEntries(tmpAgcpi);

    System.assertEquals(2, [SELECT COUNT() FROM Account]);

    System.assertEquals(1, [SELECT COUNT() FROM Plan_Specific_Fees__c]);
  }
  @IsTest
  static void testUmrEntries() {
    UmrAcctGrpConParser uagcp = new UmrAcctGrpConParser();
    System.assertNotEquals(0, [SELECT COUNT() FROM AcctGrpConParsing_Item__c]);
    List<AcctGrpConParsing_Item__c> tmpAgcpi = [
      SELECT
        id,
        batch_key__c,
        batch_time__c,
        item_data__c,
        item_defaults__c,
        item_key__c
      FROM acctgrpconparsing_item__c
      WHERE processed__c = FALSE
      LIMIT 1
      OFFSET 1
    ];

    System.assertEquals(1, tmpAgcpi.size());
    uagcp.ProcessPostingEntries(tmpAgcpi);

    System.assertEquals(2, [SELECT COUNT() FROM Account]);

    System.assertEquals(5, [SELECT COUNT() FROM Plan_Specific_Fees__c]);
  }
}