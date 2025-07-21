public without sharing class subOptionsController {
  public class subAssetWrapper {
    @auraEnabled
    public String subId { get; set; }
    @auraEnabled
    public String productCode { get; set; }
    @auraEnabled
    public String feeType { get; set; }
    @auraEnabled
    public String membershipFee { get; set; }
    @auraEnabled
    public String asset { get; set; }

    public subAssetWrapper(
      String subId,
      String productCode,
      String feeType,
      String membershipFee,
      String asset
    ) {
      this.subId = subId;
      this.productCode = productCode;
      this.feeType = feeType;
      this.membershipFee = membershipFee;
      this.asset = asset;
    }
  }

  @auraEnabled
  public static String accountName(String parentGUID) {
    try {
      Account acct = [SELECT Name FROM Account WHERE Guid__c = :parentGUID];
      return acct.Name;
    } catch (exception e) {
      return null;
    }
  }

  @auraEnabled
  public static List<subAssetWrapper> createSubAsset(String parentGUID) {
    List<subAssetWrapper> subAssetList = new List<subAssetWrapper>();
    for (SBQQ__Subscription__c sub : [
      SELECT
        Id,
        Fee_Type__c,
        SBQQ__Product__r.ProductCode,
        Current_Membership_Fee__c,
        (SELECT Consult_Fees__c, Product2.ProductCode FROM SBQQ__ChildAssets__r)
      FROM SBQQ__Subscription__c
      WHERE
        SBQQ__Account__r.Guid__c = :parentGUID
        AND (SBQQ__SubscriptionStartDate__c <= TODAY
        OR Termination_Date__c = NULL)
      ORDER BY SBQQ__SubscriptionStartDate__c DESC
    ]) {
      Boolean hasAsset = false;
      String BHP1T;
      String BHPOT;
      String BHNPT;
      String assetString;
      for (Asset asset : sub.SBQQ__ChildAssets__r) {
        hasAsset = true;
        if (sub.SBQQ__Product__r.ProductCode != 'BH') {
          assetString = ('Total Fee: ' + asset.Consult_Fees__c);
          subAssetList.add(
            new subAssetWrapper(
              sub.Id,
              sub.SBQQ__Product__r.ProductCode,
              sub.Fee_Type__c,
              string.valueOf(sub.Current_Membership_Fee__c),
              assetString
            )
          );
        } else {
          if (asset.Product2.ProductCode == 'BHP1T') {
            BHP1T = string.valueOf(asset.Consult_Fees__c);
          } else if (asset.Product2.ProductCode == 'BHPOT') {
            BHPOT = string.valueOf(asset.Consult_Fees__c);
          } else if (asset.Product2.ProductCode == 'BHNPT') {
            BHNPT = string.valueOf(asset.Consult_Fees__c);
          }
          if (BHP1T != null && BHPOT != null && BHNPT != null) {
            assetString =
              '[BHP1T: ' +
              BHP1T +
              '], [ BHPOT: ' +
              BHPOT +
              '], [BHNPT: ' +
              BHNPT +
              ']';
            subAssetList.add(
              new subAssetWrapper(
                sub.Id,
                sub.SBQQ__Product__r.ProductCode,
                sub.Fee_Type__c,
                string.valueOf(sub.Current_Membership_Fee__c),
                assetString
              )
            );
          }
        }
      }
      if (!hasAsset) {
        assetString = 'No Asset';
        subAssetList.add(
          new subAssetWrapper(
            sub.Id,
            sub.SBQQ__Product__r.ProductCode,
            sub.Fee_Type__c,
            string.valueOf(sub.Current_Membership_Fee__c),
            assetString
          )
        );
      }
    }
    return subAssetList;
  }
}