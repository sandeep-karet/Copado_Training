@isTest
private class UmrAcctGrpConParse_Bch_Test {
  @TestSetup
  static void setup() {
    Account umrAcct = TestDataFactory.createUMR();
    List<Product2> cpq_prods = new List<Product2>();
    Product2 prod_gm = new Product2(name = 'General Medical');
    Product2 prod_bh = new Product2(name = 'Behavioral Health Care');
    Product2 prod_derm = new Product2(name = 'Dermatology');

    Database.insert(new List<SObject>{ prod_gm, prod_bh, prod_derm });

    Account tmpAcct = new Account(
      Name = 'UMR',
      Account_Legal_Name__c = 'UMR',
      Source__c = 'HUB',
      CurrencyIsoCode = 'USD',
      Business_Region__c = 'USA'
    );

    insert tmpAcct;
    List<SBQQ__Subscription__c> umr_subs = new List<SBQQ__Subscription__c>();
    umr_subs.add(
      new SBQQ__Subscription__c(
        Source_Id__c = 'a2h60000001Rxg6AAC',
        SBQQ__Account__c = tmpAcct.Id,
        SBQQ__Product__c = prod_gm.Id,
        SBQQ__Quantity__c = 100
      )
    );
    umr_subs.add(
      new SBQQ__Subscription__c(
        Source_Id__c = 'a2hf2000002IW0CAAW',
        SBQQ__Account__c = tmpAcct.Id,
        SBQQ__Product__c = prod_bh.Id,
        SBQQ__Quantity__c = 100
      )
    );
    umr_subs.add(
      new SBQQ__Subscription__c(
        Source_Id__c = 'a2hf2000002IW0DAAW',
        SBQQ__Account__c = tmpAcct.Id,
        SBQQ__Product__c = prod_derm.Id,
        SBQQ__Quantity__c = 100
      )
    );
    insert umr_subs;
    List<AcctGrpConParsing_Item__c> tmpAgcpis = Test.loadData(
      AcctGrpConParsing_Item__c.sObjectType,
      'umr_agcpi_tests'
    );
    for (AcctGrpConParsing_Item__c tmpAgcpi : tmpAgcpis) {
      tmpAgcpi.processed__c = false;
    }
    update tmpAgcpis;
    Disclaimers__c tmpDisclaimer = new Disclaimers__c(
      Name = 'STND',
      Disclaimer_Language__c = '© 2019 Teladoc Health, Inc. All rights reserved. Teladoc and the Teladoc logo are registered trademarks of Teladoc Health, Inc. and may not be used without written permission. Teladoc does not replace the primary care physician. Teladoc does not guarantee that a prescription will be written. Teladoc operates subject to state regulation and may not be available in certain states. Teladoc does not prescribe DEA controlled substances, non therapeutic drugs and certain other drugs which may be harmful because of their potential for abuse. Teladoc physicians reserve the right to deny care for potential misuse of services.'
    );
    insert tmpDisclaimer;

    Web_URLs__c tmpUrL = new Web_URLs__c(Name = 'Teladoc.com');
    insert tmpUrL;
  }

  @IsTest
  static void UmrAcctGrpConParse_Bch_Null_Test() {
    string query = null;
    Test.startTest();
    UmrAcctGrpConParse_Bch testing = new UmrAcctGrpConParse_Bch(query);
    DataBase.executeBatch(testing);
    Test.stopTest();
  }

  @IsTest
  static void UmrAcctGrpConParse_Bch_Test() {
    string query = 'select id, batch_key__c, batch_time__c, item_data__c, item_defaults__c, item_key__c from acctgrpconparsing_item__c where source__c = \'UMR\' and processed__c = false';

    Test.startTest();
    UmrAcctGrpConParse_Bch testing = new UmrAcctGrpConParse_Bch(query);
    DataBase.executeBatch(testing);
    Test.stopTest();
  }
}