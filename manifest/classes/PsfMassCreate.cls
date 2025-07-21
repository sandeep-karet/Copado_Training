public class PsfMassCreate {
  public static void CreateForSubscription(Id subscriptionId) {
    // fetch current subscription
    SBQQ__Subscription__c currentSubscription = [
      SELECT
        id,
        SBQQ__Account__c,
        SBQQ__StartDate__c,
        SBQQ__QuoteLine__c,
        Termination_Date__c,
        SBQQ__Quantity__c,
        Membership_Fee__c,
        Consult_Type__c,
        Current_Membership_Fee__c,
        Fee_Type__c
      FROM SBQQ__Subscription__c
      WHERE id = :subscriptionId
    ];

    // fetch corresponding asset
    List<Asset> assetsReqBySub = [
      SELECT
        id,
        Product2Id,
        Price,
        AccountId,
        Quantity,
        PurchaseDate,
        Consult_Fees__c,
        Product2.ProductCode
      FROM Asset
      WHERE sbqq__RequiredBySubscription__c = :subscriptionId
    ];

    Boolean hasAssets = (assetsReqBySub.size() == 0) ? false : true;

    // gather all psf currently create for subscription
    List<Plan_Specific_Fees__c> subscriptionPsf = [
      SELECT id, Member_Group__c
      FROM Plan_Specific_Fees__c
      WHERE subscription__c = :subscriptionId
    ];
    Set<Id> subscribedGroups = new Set<Id>();
    for (Plan_Specific_Fees__c tmpPsf : subscriptionPsf) {
      subscribedGroups.add(tmpPsf.Member_Group__c);
    }

    // gather all groups for account related to subscription
    Map<Id, Mbr_Group__c> mappedAccountGroups = new Map<Id, Mbr_Group__c>(
      [
        SELECT id, Actual_Copay_May_Be_Less__c
        FROM Mbr_Group__c
        WHERE
          Client_Account__c = :currentSubscription.SBQQ__Account__c
          AND status__c IN ('Pending', 'Active')
      ]
    );

    // filter out groups with psf already created
    Set<Id> groupsToSubscribe = new Set<Id>();
    for (Id tmpId : mappedAccountGroups.keyset()) {
      if (!subscribedGroups.contains(tmpId)) {
        groupsToSubscribe.add(tmpId);
      }
    }

    List<Plan_Specific_Fees__c> newPsfTemplates = new List<Plan_Specific_Fees__c>();
    if (hasAssets) {
      for (Asset tmpAsset : assetsReqBySub) {
        Plan_Specific_Fees__c tmpNewPsf = new Plan_Specific_Fees__c(
          Asset__c = tmpAsset.Id,
          Consult_Fee_Mbr_Pd__c = tmpAsset.Consult_Fees__c,
          subscription__c = subscriptionId,
          Product_Start_Date__c = currentSubscription.SBQQ__StartDate__c
        );
        newPsfTemplates.add(tmpNewPsf);
      }
    } else {
      newPsfTemplates.add(
        new Plan_Specific_Fees__c(
          subscription__c = subscriptionId,
          Product_Start_Date__c = currentSubscription.SBQQ__StartDate__c
        )
      );
    }

    List<Plan_Specific_Fees__c> psfToCreate = new List<Plan_Specific_Fees__c>();
    for (Id unsubGrp : groupsToSubscribe) {
      for (Plan_Specific_Fees__c tmpPsf : newPsfTemplates) {
        Plan_Specific_Fees__c psfFromTemplate = tmpPsf.clone(
          false,
          true,
          false,
          false
        );
        psfFromTemplate.Actual_Copay_May_Be_Less__c = mappedAccountGroups.get(
            unsubGrp
          )
          .Actual_Copay_May_Be_Less__c;
        psfFromTemplate.Member_Group__c = unsubGrp;
        psfToCreate.add(psfFromTemplate);
      }
    }
    if (psfToCreate.size() > 0) {
      Database.SaveResult[] sr = Database.insert(psfToCreate);
    }
  }
}