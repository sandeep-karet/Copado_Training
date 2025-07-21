/**
 * Created by clin on 10/23/2019.
 */

@IsTest
private class Flow1b_Bch_Test {
  @TestSetup
  static void setup() {
    List<AcctGrpConParsing_Item__c> newAgcpi = new List<AcctGrpConParsing_Item__c>();
    String batchid = String.valueOf(Datetime.now().getTime());
    AcctGrpConParsing_Item__c tmpAgcpi1 = new AcctGrpConParsing_Item__c(
      Source__c = 'FLOW1b',
      Processed__c = false,
      Batch_Key__c = batchid,
      Item_Key__c = '12345',
      Item_Data__c = '{"MessageId":"40579702-ec2e-40e4-ac14-008652c64f87","BenefitSponsorID":"1","GUID":"bf181fc9-47d9-4c86-9a4f-72487967cd50","BenefitSponsorLegalName":"Armstrong Flooring, Inc.","BenefitSponsorFriendlyName":"Armstrong Flooring, Inc.  EDITED","Address1":"2500 Columbia Ave","Address2":null,"City":"Lancaster","State":"PA","ZipPostal":"17604","Country":"USA","StartDate":"2019-07-01T07:00:00.000Z","PreferredLanguage":"EN","ParentOrganizationID":"357","ParentOrganizationName":"StrongCo","ParentGuid":"2840CD29-73FB-7F9B-F95D-FE73D8E59460","Group":{"GroupID":"354","GUID":"95afb24c-4d56-4d72-bf8b-590da13496e6","GroupName":"AHF, LLC PPO","GroupStartDate":"2019-07-01T07:00:00.000Z","GroupEndDate":null,"ReportCategory":"","Products":[{"ProductCode":"GM","ProductVisitType":"","ProductEffectiveDate":"2019-07-01T07:00:00.000Z","ProductTermDate":null,"MemberFee":"10","CouldAmountBeLess":"N","MembershipFee":"0.63","FeeType":"0.63","TotalConsultFees":"PEPM"},{"ProductCode":"BH","ProductVisitType":"","ProductEffectiveDate":"2019-07-01T07:00:00.000Z","ProductTermDate":null,"MemberFee":"5","CouldAmountBeLess":"N","MembershipFee":"0.63","FeeType":"0.63","TotalConsultFees":"PEPM"}]}}',
      Item_Defaults__c = '{}'
    );

    newAgcpi.add(tmpAgcpi1);
    insert newAgcpi;
  }
}