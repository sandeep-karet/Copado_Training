@IsTest
private class PSF_Trg_Test {
  @IsTest
  static void Test_Psf_Duplicate_Prevention() {
    Account umrAcct = TestDataFactory.createUMR();
    Account tmpAcct = TestDataFactory.createTempAcct();
    Mbr_Group__c tmpGrp = TestDataFactory.createSingleMbrGroup(tmpAcct.Id);
    Contract tmpContract = TestDataFactory.createContract(tmpAcct.Id);
    SBQQ__Subscription__c tmpSubscription = TestDataFactory.createSBQQSubscription(
      tmpAcct.Id,
      tmpContract.Id
    );
    Plan_Specific_Fees__c tmpPsf = TestDataFactory.createSinglePlanSpecificFees(
      tmpGrp.Id,
      tmpSubscription.Id
    );
  }

  @IsTest
  static void Test_Psf_flowTest() {
    PSF_Permission_Setting__c objDS = new PSF_Permission_Setting__c(
      SetupOwnerId = UserInfo.getUserId(),
      User_Permission__c = true
    );
    insert objDS;
    Account umrAcct = TestDataFactory.createUMR();
    Account tmpAcct = TestDataFactory.createTempAcct();
    Mbr_Group__c tmpGrp = TestDataFactory.createSingleMbrGroup(tmpAcct.Id);
    Product2 prod = TestDataFactory.createSingleProduct();
    SBQQ__Subscription__c sub = TestDataFactory.createSBQQSubscripWithProd(
      tmpAcct.Id,
      prod.Id
    );
    Plan_Specific_Fees__c tmpPsf = TestDataFactory.createSinglePlanSpecificFees(
      tmpGrp.Id,
      sub.Id
    );
    Mbr_Group__c tmpGrp2 = [SELECT Disable_Flow__c FROM Mbr_Group__c];
    system.assertEquals(true, tmpGrp2.Disable_Flow__c);
    delete tmpPsf;
    Mbr_Group__c tmpGrp3 = [SELECT Disable_Flow__c FROM Mbr_Group__c];
    system.assertEquals(false, tmpGrp3.Disable_Flow__c);
  }

  @IsTest
  static void Test_Psf_Errors() {
    Account umrAcct = TestDataFactory.createUMR();
    Account tmpAcct = TestDataFactory.createTempAcct();
    Mbr_Group__c tmpGrp = TestDataFactory.createSingleMbrGroup(tmpAcct.Id);
    Product2 prod = TestDataFactory.createSingleProduct();
    Asset tempAss = TestDataFactory.createSingleAsset(tmpAcct.Id, prod.Id);
    SBQQ__Subscription__c sub = TestDataFactory.createSBQQSubscripWithProd(
      tmpAcct.Id,
      prod.Id
    );
    try {
      Plan_Specific_Fees__c tmpPsf = TestDataFactory.createSinglePlanSpecificFees(
        tmpGrp.Id,
        sub.Id
      );
      tmpPsf.Asset__c = tempAss.Id;
      upsert tmpPsf;
    } catch (Exception ex) {
    }
  }
}