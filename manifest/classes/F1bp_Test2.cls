@IsTest
public class F1bp_Test2 {
  @TestSetup
  public static void setup() {
    Test.startTest();
    SBQQ.TriggerControl.disable();
    F1b_Remove_Setting__c f1bSetting = F1b_Remove_Setting__c.getOrgDefaults();
    f1bSetting.Key_Word__c = 'NONE;!!!';
    insert f1bSetting;
    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
    List<User> userstoInsert = new List<User>();
    User u1 = new User(
      Alias = 'standt1',
      Country = 'United Kingdom',
      Email = 'test12345@testTest.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'test1234@testzxcas.org'
    );
    userstoInsert.add(u1);
    User u2 = new User(
      Alias = 'standt2',
      Country = 'United Kingdom',
      Email = 'test1234x@testTest.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'test123x@testzxcas.org'
    );
    userstoInsert.add(u2);
    insert userstoInsert;
    String recordtypeId = [
      SELECT id, name
      FROM RecordType
      WHERE SobjectType = 'Disclaimers__c' AND name = 'Disclaimer'
    ]
    .Id;

    List<Disclaimers__c> DisctoInsert = new List<Disclaimers__c>();
    Disclaimers__c tmpDisclaimer1 = new Disclaimers__c(
      RecordTypeId = recordtypeId,
      Name = 'Aetna',
      Disclaimer_Language__c = '© 2019 Teladoc Health, Inc. All rights reserved. Teladoc and the Teladoc logo are registered trademarks of Teladoc Health, Inc. and may not be used without written permission. Teladoc does not replace the primary care physician. Teladoc does not guarantee that a prescription will be written. Teladoc operates subject to state regulation and may not be available in certain states. Teladoc does not prescribe DEA controlled substances, non therapeutic drugs and certain other drugs which may be harmful because of their potential for abuse. Teladoc physicians reserve the right to deny care for potential misuse of services.'
    );
    DisctoInsert.add(tmpDisclaimer1);
    Disclaimers__c tmpDisclaimer2 = new Disclaimers__c(
      RecordTypeId = recordtypeId,
      Name = 'BCBSServiceBenefitPlan',
      Disclaimer_Language__c = 'in certain states. Teladoc does not prescribe DEA controlled substances, non therapeutic drugs and certain other drugs which may be harmful because of their ps.'
    );
    DisctoInsert.add(tmpDisclaimer2);

    insert DisctoInsert;

    Test.StopTest();
    Account umrAcct = TestDataFactory.createUMR();

    document testDoc = new Document();
    testDoc.Body = Blob.valueOf('Some Text');
    testDoc.ContentType = 'application/pdf';
    testDoc.DeveloperName = 'my_document';
    testDoc.IsPublic = true;
    testDoc.Name = 'MK_TDH_HZ_2';
    testDoc.FolderId = [SELECT id FROM folder WHERE name = 'Logos'].id;
    insert testDoc;

    ContentVersion cv = new ContentVersion();
    cv.Title = 'MK_TDH_HZ_2';
    cv.PathOnClient = 'TestDocument.pdf';
    cv.VersionData = Blob.valueOf('Test Content');
    cv.IsMajorVersion = true;
    insert cv;

    ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion];
    ID workspaceId = [SELECT Id FROM ContentWorkspace WHERE Name = 'Logos'][0]
    .Id;

    ContentWorkspaceDoc newWorkspaceDoc = new ContentWorkspaceDoc();
    newWorkspaceDoc.ContentWorkspaceId = workspaceId;
    newWorkspaceDoc.ContentDocumentId = testContent.ContentDocumentId;
    insert newWorkspaceDoc;

    ContentDocument documents = [
      SELECT Id, Title, LatestPublishedVersionId
      FROM ContentDocument
    ];
    documents.parentId = workspaceId;
    update documents;

    List<AcctGrpConParsing_Item__c> tmpAgcpis = Test.loadData(
      AcctGrpConParsing_Item__c.sObjectType,
      'f1bpv3'
    );

    Account ngAcct = new Account(
      Account_Legal_Name__c = 'National General',
      Name = 'National General',
      Account_Type__c = 'Reseller',
      Business_Region__c = 'USA',
      Source__c = 'TD',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Standard')
        .getRecordTypeId(),
      Guid__c = 'D17631CA-FA3A-A2D1-EE8F-6DC3F45BF4B4'
    );

    insert ngAcct;

    Mbr_Group__c mbrgroup = new Mbr_Group__c();
    mbrgroup.Client_Account__c = ngAcct.Id;
    mbrgroup.Name__c = 'Test';
    mbrgroup.OneAppAccess__c = 'Yes';
    mbrgroup.GUID__c = '989f91c6-2535-4d3c-b44c-c386dab17e65';
    insert mbrgroup;

    TestDataFactory.CreateProduct();
    SBQQ.TriggerControl.enable();
  }

  public static void buildData(F1BMainParser f1bp) {
    SBQQ.TriggerControl.disable();
    Account payerAcct = new Account(
      Name = 'Payer',
      Friendly_Account_Name__c = 'payerAccount',
      Source__c = 'HUB',
      CurrencyIsoCode = 'USD',
      Business_Region__c = 'USA',
      Account_Type__c = 'Health Plan',
      Guid__c = 'EEEE6262-C405-2C05-D7FB-BA54CE51C171'
    );
    insert payerAcct;
    Account parentAcct = [
      SELECT Id
      FROM Account
      WHERE Name = 'National General'
    ];
    Contact conObj = TestDataFactory.createContact(parentAcct.Id);
    SBQQ__Quote__c quoteObj = TestDataFactory.createQuote();
    Opportunity oppObj = TestDataFactory.createCWOpportunity(
      quoteObj,
      parentAcct.Id
    );
    TestDataFactory.createQuoteLine(quoteObj.Id);
    Contract contObj = TestDataFactory.createContract(
      parentAcct.Id,
      oppObj.Id,
      quoteObj.Id
    );
    Map<String, SBQQ__QuoteLine__c> qlMap = new Map<String, SBQQ__QuoteLine__c>();
    Map<String, Product2> prodMap = new Map<String, Product2>();
    List<SBQQ__QuoteLine__c> qlList = [
      SELECT
        Id,
        Name,
        SBQQ__Product__r.ProductCode,
        SBQQ__Quote__c,
        SBQQ__Product__c,
        SBQQ__ListPrice__c
      FROM SBQQ__QuoteLine__c
    ];
    for (SBQQ__QuoteLine__c ql : qlList) {
      qlMap.put(ql.SBQQ__Product__r.ProductCode, ql);
    }
    List<Product2> prodList = [SELECT Id, Name, ProductCode FROM Product2];
    for (Product2 prod : prodList) {
      prodMap.put(prod.ProductCode, prod);
    }

    Boolean isBHCreated = false;
    List<Mbr_Group__c> mbrgrp = [
      SELECT Id
      FROM Mbr_Group__c
      WHERE Name__c = 'test'
    ];
    Map<String, List<String>> ProductFeeMap = new Map<String, List<String>>();
    ProductFeeMap.put('GM', new List<String>{ 'GMCF' });
    ProductFeeMap.put('DERM', new List<String>{ 'DERMFEE' });
    ProductFeeMap.put('NUT', new List<String>{ 'NUT' });
    ProductFeeMap.put('OI', new List<String>{ 'OI' });
    ProductFeeMap.put('TDBC', new List<String>{ 'TDBC' });
    ProductFeeMap.put('TC', new List<String>{ 'TCPROGFEE' });
    ProductFeeMap.put('SH', new List<String>{ 'SH' });
    Map<String, Map<String, Decimal>> CFmap = new Map<String, Map<String, Decimal>>();

    List<SBQQ__Subscription__c> subsToInsert = new List<SBQQ__Subscription__c>();
    Boolean isAsset = false;
    for (Integer i = 0; i < f1bp.f1bmg.f1bpsf.size(); i++) {
      String prodCode = f1bp.f1bmg.f1bpsf[i].subProdCode;
      System.debug('ProductCode in test' + prodCode + '/' + f1bp.f1bmg.f1bpsf);
      subsToInsert.add(
        new SBQQ__Subscription__c(
          SBQQ__Quantity__c = 1000,
          SBQQ__QuoteLine__c = qlMap.get(prodCode).Id,
          SBQQ__Account__c = parentAcct.Id,
          SBQQ__Contract__c = contObj.Id,
          fee_type__c = f1bp.f1bmg.f1bpsf[i].sub.Fee_Type__c,
          SBQQ__SubscriptionStartDate__c = System.today() - 1,
          SBQQ__Product__c = qlMap.get(prodCode).SBQQ__Product__c,
          Current_Membership_Fee__c = f1bp.f1bmg.f1bpsf[i]
            .sub.Current_Membership_Fee__c
        )
      );

      system.debug('asset prod' + f1bp.f1bmg.f1bpsf[i]);
      String key;
      if (f1bp.f1bmg.f1bpsf[i].AssetProdCode == null) {
        key = ProductFeemap.get(prodCode) != null
          ? ProductFeemap.get(prodCode)[0]
          : null;
      } else
        key = f1bp.f1bmg.f1bpsf[i].AssetProdCode;
      if (key != null) {
        if (CFmap.get(prodCode) != null) {
          CFmap.get(prodCode)
            .put(
              key,
              (f1bp.f1bmg.f1bpsf[i].psf.Consult_Fee_Mbr_Pd__c +
              f1bp.f1bmg.f1bpsf[i].psf.Consult_Fee_Plan_Pd__c)
            );
        } else {
          Map<string, Decimal> assetmap = new Map<String, Decimal>();
          assetmap.put(
            key,
            (f1bp.f1bmg.f1bpsf[i].psf.Consult_Fee_Mbr_Pd__c +
            f1bp.f1bmg.f1bpsf[i].psf.Consult_Fee_Plan_Pd__c)
          );
          CFmap.put(prodCode, assetmap);
        }
        System.debug('CF Map' + CFmap);
      }
      if (productFeeMap.containsKey(prodCode))
        isAsset = true;
    }
    Database.saveResult[] svRes = Database.insert(subsToInsert, false);
    Set<Id> subIds = new Set<Id>();
    for (Database.saveResult sr : svRes) {
      if (sr.isSuccess()) {
        subIds.add(sr.getId());
      }
    }
    Map<String, SBQQ__Subscription__c> subscriptionMap = new Map<String, SBQQ__Subscription__c>();
    for (SBQQ__Subscription__c subs : [
      SELECT Id, SBQQ__Product__r.ProductCode, SBQQ__Account__c
      FROM SBQQ__Subscription__c
      WHERE Id IN :subIds
    ]) {
      subscriptionMap.put(subs.SBQQ__Product__r.ProductCode, subs);
    }
    if (isAsset) {
      List<Asset> assetstoInsert = new List<Asset>();
      for (String prodCode : ProductFeeMap.keySet()) {
        List<String> feeProds = ProductFeeMap.get(prodCode);
        for (String fee : feeProds) {
          assetstoInsert.add(
            new Asset(
              Name = fee,
              Product2Id = prodMap.get(fee).Id,
              AccountId = parentAcct.Id,
              ContactId = conObj.Id,
              Consult_Fees__c = CFMap.get(prodCode).get(fee),
              SBQQ__RequiredBySubscription__c = subscriptionMap.get(prodCode).Id
            )
          );
        }
      }
      List<Plan_Specific_Fees__c> psfToInsert = new List<Plan_Specific_Fees__c>();
      Set<Id> assIds = new Set<Id>();
      Database.saveResult[] srRes = Database.insert(assetstoInsert, false);
      for (Database.saveResult sr : srRes) {
        if (sr.isSuccess()) {
          assIds.add(sr.getId());
        }
      }
      for (Asset ast : [
        SELECT Id, SBQQ__RequiredBySubscription__c
        FROM Asset
        WHERE Id IN :assIds
      ]) {
        psfToInsert.add(
          TestDataFactory.createPlanSpecificFees(
            ast.Id,
            mbrgrp[0].Id,
            ast.SBQQ__RequiredBySubscription__c
          )
        );
      }
      insert psfToInsert;
    }

    SBQQ.TriggerControl.enable();
  }

  @IsTest
  static void PositiveTest() {
    SBQQ.TriggerControl.disable();
    Account acct = [SELECT Id FROM Account WHERE Name = 'National General'];
    Account TestAcct = new Account(
      Account_Legal_Name__c = 'Test Account',
      Name = 'Test Account',
      Account_Type__c = 'Reseller',
      Business_Region__c = 'USA',
      Source__c = 'TD',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Standard')
        .getRecordTypeId(),
      Guid__c = '45691c15-0a24-4798-ad76-e0af7085aa46'
    );

    insert TestAcct;

    List<AcctGrpConParsing_Item__c> agcpiList = [
      SELECT Id, Item_Data__c
      FROM AcctGrpConParsing_Item__c
    ];
    F1BMainParser f1bp = new F1BMainParser();
    f1bp.parse(agcpiList[0].Item_Data__c);
    List<String> productSet = new List<String>();
    for (Integer i = 0; i < f1bp.f1bmg.f1bpsf.size(); i++) {
      if (
        f1bp.f1bmg.f1bpsf[i].subProdCode == 'BH' ||
        f1bp.f1bmg.f1bpsf[i].subProdCode == 'MH' ||
        f1bp.f1bmg.f1bpsf[i].subProdCode == 'PRIM360CARE'
      ) {
        productSet.add(f1bp.f1bmg.f1bpsf[i].AssetProdCode);
      } else {
        productSet.add(f1bp.f1bmg.f1bpsf[i].subProdCode);
      }
    }
    Test.startTest();

    F1BProcessor.ProcessEntry(f1bp, agcpiList[0].Id);
    /*System.assertEquals(1, [ SELECT Count() FROM Account WHERE Guid__c = :f1bp.benefitSponsor.Guid__c ]);
        //System.assertEquals(1, [ SELECT Count() FROM Mbr_Group__c WHERE Guid__c = :f1bp.f1bmg.ephMbrGroup.Guid__c ]);
        
        for (Plan_Specific_Fees__c p: testList) {
            system.debug(p.psf_productCode__c);
        }
        system.debug('exception' + [Select Id,Full_Desc__c From AcctGrpConParse_Exception__c]);
        System.assertEquals(productSet.size(), [ SELECT Count() FROM Plan_Specific_Fees__c ]);
		*/
    Test.stopTest();
    Map<String, List<Plan_Specific_Fees__c>> psfMap = new Map<String, List<Plan_Specific_Fees__c>>();
    STring s = agcpiList[0].Id;
    List<Plan_Specific_Fees__c> testList = [
      SELECT
        Id,
        psf_productCode__c,
        Subscription__c,
        Consult_Fee_Mbr_Pd__c,
        Product_Start_Date__c,
        Product_End_Date__c,
        Actual_Copay_May_Be_Less__c
      FROM Plan_Specific_Fees__c
    ];
    psfMap.put(s, testList);
    BundleClass.deletePsf(psfMap, s);
    BundleClass bClass = new BundleClass();
    bClass.createExistingKey('BH', testList);
    SBQQ.TriggerControl.enable();
  }
}