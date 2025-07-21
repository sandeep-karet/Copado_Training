public class Opp_RevFlagHelper {
  public static void setFlag(Map<Id, Opportunity> oppMap) {
    List<String> oppId = new List<String>();
    for (Opportunity opp : oppMap.values()) {
      if (!opp.Rev_Synergy_Flag_Overwrite__c) {
        oppId.add(opp.Id);
      }
    }

    List<Opportunity> flagOppList = [
      SELECT
        Id,
        Account.Rev_Synergy__c,
        (SELECT Product_Family__c, ProductCode FROM OpportunityLineItems)
      FROM Opportunity
      WHERE Id IN :oppId
    ];

    for (Opportunity opp : flagOppList) {
      Boolean isLvn = false;
      Boolean isTd = false;
      Boolean newMH = false;
      for (OpportunityLineItem oppli : opp.OpportunityLineItems) {
        if (oppli.ProductCode == 'MYSTR3') {
          newMH = true;
        } else if (
          oppli.Product_Family__c != null &&
          oppli.Product_Family__c.contains('Livongo')
        ) {
          isLvn = true;
        } else {
          isTd = true;
        }
      }
      if (opp.OpportunityLineItems.size() > 0) {
        switch on opp.Account.Rev_Synergy__c {
          when 'Legacy Combined TD/LV Client' {
            if (newMH) {
              oppMap.get(opp.Id)
                .Opp_Rev_Synergy_Flag__c = 'Combined TD/LV Solution (MH)';
            } else {
              oppMap.get(opp.Id).Opp_Rev_Synergy_Flag__c = 'No Synergy';
            }
          }
          when 'Legacy LV Client' {
            if ((newMH && !isLvn && !isTd) || (newMH && isLvn && !isTd)) {
              oppMap.get(opp.Id)
                .Opp_Rev_Synergy_Flag__c = 'Combined TD/LV Solution (MH)';
            } else if (isLvn && !isTd && !newMH) {
              oppMap.get(opp.Id).Opp_Rev_Synergy_Flag__c = 'No Synergy';
            } else if (
              (isTd && !isLvn && !newMH) || (isLvn && isTd && !newMH)
            ) {
              oppMap.get(opp.Id)
                .Opp_Rev_Synergy_Flag__c = 'Cross-sell TD Products into LV';
            } else if ((!isLvn && isTd && newMH) || (isLvn && isTd && newMH)) {
              oppMap.get(opp.Id)
                .Opp_Rev_Synergy_Flag__c = 'Cross-sell TD Products into LV + Combined TD/LV Solution (MH)';
            }
          }
          when 'Legacy TD Client' {
            if ((isLvn && !isTd && !newMH) || (isLvn && isTd && !newMH)) {
              oppMap.get(opp.Id)
                .Opp_Rev_Synergy_Flag__c = 'Cross-sell LV Products into TD';
            } else if ((isTd && !isLvn && !newMH)) {
              oppMap.get(opp.Id).Opp_Rev_Synergy_Flag__c = 'No Synergy';
            } else if (
              (!isLvn && !isTd && newMH) || (isTd && !isLvn && newMH)
            ) {
              oppMap.get(opp.Id)
                .Opp_Rev_Synergy_Flag__c = 'Combined TD/LV Solution (MH)';
            } else if ((isLvn && !isTd && newMH) || (isLvn && isTd && newMH)) {
              oppMap.get(opp.Id)
                .Opp_Rev_Synergy_Flag__c = 'Cross-sell LV Products into TD + Combined TD/LV Solution (MH)';
            }
          }
          when 'Net New Client (All Solutions)' {
            if ((isLvn && !isTd && !newMH) || (isTd && !isLvn && !newMH)) {
              oppMap.get(opp.Id).Opp_Rev_Synergy_Flag__c = 'No Synergy';
            } else if ((!isTd && !isLvn && newMH)) {
              oppMap.get(opp.Id)
                .Opp_Rev_Synergy_Flag__c = 'Combined TD/LV Solution (MH)';
            } else if (isTd && isLvn) {
              oppMap.get(opp.Id)
                .Opp_Rev_Synergy_Flag__c = 'Net New Client All Solutions';
            } else if (!isLvn && isTd && newMH) {
              oppMap.get(opp.Id)
                .Opp_Rev_Synergy_Flag__c = 'Cross-sell TD Products into LV + Combined TD/LV Solution (MH)';
            } else if (!isTd && isLvn && newMH) {
              oppMap.get(opp.Id)
                .Opp_Rev_Synergy_Flag__c = 'Cross-sell LV Products into TD + Combined TD/LV Solution (MH)';
            }
          }
        }
      }
    }
  }
}