public class F1bPsf_Test {
  /*
     * public static void psfUpdateTest() {
        List<AcctGrpConParsing_Item__c> agcpiList = [ SELECT Id, Item_Data__c FROM AcctGrpConParsing_Item__c ];
        F1BMainParser f1bp = new F1BMainParser();
        f1bp.parse(agcpiList[0].Item_Data__c);
        F1bp_Test.buildData(f1bp); 
        test.startTest();
        F1BProcessor.ProcessEntry(f1bp, agcpiList[0].Id);
        test.stopTest();
    
        Decimal gmMbrFee;
        Decimal gmPlnFee;
        for(Integer i = 0; i < f1bp.f1bmg.f1bpsf.size(); i++) {  
            if (f1bp.f1bmg.f1bpsf[i].subProdCode == 'GM') {
                f1bp.f1bmg.f1bpsf[i].psf.Actual_Copay_May_Be_Less__c = false;
                f1bp.f1bmg.f1bpsf[i].psf.Consult_Fee_Mbr_Pd__c = f1bp.f1bmg.f1bpsf[i].psf.Consult_Fee_Mbr_Pd__c -10;
                f1bp.f1bmg.f1bpsf[i].psf.Consult_Fee_Plan_Pd__c = f1bp.f1bmg.f1bpsf[i].psf.Consult_Fee_Plan_Pd__c + 10;
                gmMbrFee = f1bp.f1bmg.f1bpsf[i].psf.Consult_Fee_Mbr_Pd__c;
                gmPlnFee = f1bp.f1bmg.f1bpsf[i].psf.Consult_Fee_Plan_Pd__c;
            }
        }
        F1BProcessor.ProcessEntry(f1bp, agcpiList[0].Id);
        Plan_Specific_Fees__c updatePsfGM = [ SELECT Actual_Copay_May_Be_Less__c, Consult_Fee_Mbr_Pd__c, Consult_Fee_Plan_Pd__c, psf_ProductCode__c FROM Plan_Specific_Fees__c WHERE Subscription__r.SBQQ__Product__r.ProductCode = 'GM' ];
        System.assertEquals(false, updatePsfGM.Actual_Copay_May_Be_Less__c);
		System.assertEquals(gmMbrFee, updatePsfGM.Consult_Fee_Mbr_Pd__c);
		System.assertEquals(gmPlnFee, updatePsfGM.Consult_Fee_Plan_Pd__c);
	
    }
    */
  public static void noPsfData() {
    List<AcctGrpConParsing_Item__c> agcpiList = [
      SELECT Id, Item_Data__c
      FROM AcctGrpConParsing_Item__c
    ];
    F1BMainParser f1bp = new F1BMainParser();
    f1bp.parse(agcpiList[0].Item_Data__c);
    f1bp.f1bmg.f1bpsf = null;
    Test.startTest();
    F1BProcessor.ProcessEntry(f1bp, agcpiList[0].Id);
    System.assertEquals(
      1,
      [SELECT COUNT() FROM Account WHERE Guid__c = :f1bp.benefitSponsor.Guid__c]
    );
    System.assertEquals(
      1,
      [
        SELECT COUNT()
        FROM Mbr_Group__c
        WHERE Guid__c = :f1bp.f1bmg.ephMbrGroup.Guid__c
      ]
    );
    System.assertEquals(0, [SELECT COUNT() FROM Plan_Specific_Fees__c]);
    Test.stopTest();
  }

  public static void emoProductTest() {
    List<AcctGrpConParsing_Item__c> agcpiList = [
      SELECT Id, Item_Data__c
      FROM AcctGrpConParsing_Item__c
    ];
    String emoProd = '{"SpecialInstructions":"NOTHING","AccountStatus":"Prospect","EmployeeEstLives":"100","TotalEstLives":"100","MessageId":"18a7e8ca-6b16-407f-aaac-131f0faa3297","BenefitSponsorID":"11","GUID":"45691c15-0a24-4798-ad76-e0af7085aa46","BenefitSponsorLegalName":"DOGANDCATCORP","BenefitSponsorFriendlyName":"PARENTCATCOMPANY","Address1":"132PAWSTREET","Address2":null,"City":"KITTEN","State":"AZ","ZipPostal":"85001","Country":"US","StartDate":"2020-09-01T00:00:00.000Z","EndDate":null,"PreferredLanguage":"English","SalesRep":"005f4000003H8aHAAS","AccountManager":"005f4000003H8aHAAS","Group":{"GroupID":"45334","OneAppAccess":"Y","AllowGeoFencing":"Y","SFDCPayerGUID":"EEEE6262-C405-2C05-D7FB-BA54CE51C171","GUID":"989f91c6-2535-4d3c-b44c-c386dab17e65","GroupName":"DOGCATHMO","GroupStartDate":"2020-09-01T00:00:00.000Z","GroupEndDate":"2024-09-01T00:00:00.000Z","ReportCategory":"","CardName":"NYANCARD2","Status":"Active","WelcomeKit":{"DisclaimerClient":null,"DisclaimerTeladoc":"Aetna"},"Eligibility":"Staged Eligibility","Products":[{"ProductCode":"EMO","ProductVisitType":null,"ProductEffectiveDate":"2020-09-01T00:00:00.000Z","ProductTermDate":null,"MemberFee":0,"CouldAmountBeLess":false,"AppOptOut":false,"MembershipFee":0,"FeeType":"PEPM","TotalConsultFees":0}]},"ParentOrganizationID":"1","ParentOrganizationName":"ExampleContracteeReseller","ParentGuid":"D17631CA-FA3A-A2D1-EE8F-6DC3F45BF4B4"}';
    F1BMainParser f1bp = new F1BMainParser();
    f1bp.parse(emoProd);
    F1bp_Test.buildData(f1bp);
    Test.startTest();
    F1BProcessor.ProcessEntry(f1bp, agcpiList[0].Id);
    system.debug(
      'exception' + [SELECT Id, Full_Desc__c FROM AcctGrpConParse_Exception__c]
    );
    System.assertEquals(2, [SELECT COUNT() FROM Plan_Specific_Fees__c]);
    Test.stopTest();
  }
}