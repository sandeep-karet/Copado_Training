public class UmrExc {
  public static Acct_Rel__c Create_UMR_AcctRel(
    Account parentAccount,
    Account bspAccount,
    Id acctGrpConParsingId,
    Date startDate
  ) {
    List<Acct_Rel__c> existing_AcctRel = [
      SELECT id
      FROM Acct_Rel__c
      WHERE
        Svc_Acct__c = :parentAccount.Id
        AND Benefit_Sponsor__c = :bspAccount.Id
        AND Relationship_Type__c = 'Contractee'
        AND Contract_Type__c = 'Insurance'
        AND (End_Date__c = NULL
        OR End_Date__c > Today)
      ORDER BY createddate DESC
      LIMIT 1
    ];
    if (existing_AcctRel.size() > 0) {
      return existing_AcctRel[0];
    } else {
      Acct_Rel__c new_AcctRel = new Acct_Rel__c(
        Svc_Acct__c = parentAccount.Id,
        Benefit_Sponsor__c = bspAccount.Id,
        Relationship_Type__c = 'Contractee',
        Contract_Type__c = 'Insurance',
        Line_of_Business__c = 'Commercial_Administrative_Services_Only_ASO',
        Start_Date__c = startDate
      );
      try {
        insert new_AcctRel;
        return new_AcctRel;
      } catch (Exception sinx) {
        if (F1bUtils_v2.exceptionsFound == null) {
          F1bUtils_v2.exceptionsFound = new List<AcctGrpConParse_Exception__c>();
        }
        F1bUtils_v2.exceptionsFound.add(
          new AcctGrpConParse_Exception__c(
            AGCPI__c = acctGrpConParsingId,
            Exception_Type__c = 'DML_ERROR',
            Short_Desc__c = 'CANNOT_CREATE_ACCT_REL',
            SObject__c = 'ACCOUNT_REL__C',
            Full_Desc__c = sinx.getMessage()
          )
        );
        return null;
      }
    }
  }

  public static Void updateAcctRelEndDate(
    String parentGuid,
    String benefitSponsorGuid,
    Datetime endDate,
    Id agcpid
  ) {
    Map<String, Acct_Rel__c> AcctRelMap = new Map<String, Acct_Rel__c>(
      [
        SELECT Id
        FROM Acct_Rel__c
        WHERE
          Svc_Acct__r.Guid__c = :parentGuid
          AND Benefit_Sponsor__r.Guid__c = :benefitSponsorGuid
          AND Relationship_Type__c = 'Contractee'
          AND Contract_Type__c = 'Insurance'
          AND (End_Date__c = NULL
          OR End_Date__c > Today)
        ORDER BY createddate DESC
        LIMIT 1
      ]
    );
    F1bUtils_v2.updateSObjectList(
      Date.valueOf(endDate),
      agcpid,
      AcctRelMap,
      'End_Date__c',
      'ACCT_REL__C'
    );
  }
}