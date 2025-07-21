public class OppLineItem_Parser extends QItem_BaseParser {
  public List<LVGO__OpportunityLineItem__c> oppliList { get; set; }
  public static final String WPSOL_TO_IGNORE = System.Label.WPSOL;
  public static final String TD_Bundle = System.Label.TD_Bundle;
  public static final String NonAnchor_Products = System.Label.NonAnchorProducts;
  public OppLineItem_Parser() {
    super();
    oppliList = new List<LVGO__OpportunityLineItem__c>();
  }

  public override void Parse(JSONParser parser) {
    Map<String, String> prodMap = new Map<String, String>();
    List<Product2> prodList = [SELECT Id, ProductCode FROM Product2];
    for (Product2 prod : prodList) {
      prodMap.put(prod.ProductCode, prod.Id);
    }

    // list of warrper object based on JSON payload, use this list to build the opportuntiy line item
    List<oppliWrapper> oliWrapper = (List<oppliWrapper>) parser.readValueAs(
      List<oppliWrapper>.class
    );
    Map<String, myStrengthFeatures> dtMap = new Map<String, myStrengthFeatures>();
    for (oppliWrapper opli : oliWrapper) {
      if (
        opli.ParentsProductCode != null &&
        (opli.ProductCode == 'MYSTR3' ||
        opli.ProductCode == 'MYSTRPLUS' ||
        opli.ProductCode == 'MSDIGIT')
      ) {
        myStrengthFeatures mSF = new myStrengthFeatures();
        mSF.DisableTeletherapy = opli.DisableTeletherapy;
        mSF.DisableBHCoaching = opli.DisableBHCoaching;
        dtMap.put(opli.ParentsProductCode, mSF);
      }
    }
    List<LVGO__OpportunityLineItem__c> oppLineItemstoInsert = new List<LVGO__OpportunityLineItem__c>();
    List<String> parentProd = WPSOL_TO_IGNORE.replaceAll('\\s+', '').split(',');
    List<String> tdParentBundle = TD_Bundle.replaceAll('\\s+', '').split(',');
    List<String> NonAnchorProductsList = NonAnchor_Products.replaceAll(
        '\\s+',
        ''
      )
      .split(',');
    for (oppliWrapper opli : oliWrapper) {
      if (
        ((parentProd.contains(opli.ProductCode) ||
        (opli.ParentsProductCode != null &&
        opli.Anchor == 'false') &&
        (opli.ParentsProductCode != 'TKB') &&
        (opli.GrandParentsProductCode != 'TKB')) ||
        (NonAnchorProductsList.contains(opli.ProductCode) &&
        opli.ParentsProductCode != null &&
        opli.Anchor == 'false' &&
        (opli.ParentsProductCode == 'TKB' ||
        opli.GrandParentsProductCode == 'TKB'))) &&
        !tdParentBundle.contains(opli.ParentsProductCode)
      ) {
        continue;
      }

      LVGO__OpportunityLineItem__c oppLineItem = new LVGO__OpportunityLineItem__c();
      oppLineItem.LVGO__Quantity__c = opli.SubscriptionTerm != null
        ? Integer.valueOf(opli.SubscriptionTerm)
        : 0;
      oppLineItem.LVGO__UnitPrice__c = Decimal.valueOf(opli.SalesPrice);
      oppLineItem.LVGO__Gross_Program_ARR_Copy__c = opli.TotalPrice != null
        ? Decimal.valueOf(opli.TotalPrice)
        : 0;
      oppLineItem.LVGO__Estimated_Partner_Admin_Fees__c = opli.AdminFee != null
        ? Decimal.valueOf(opli.AdminFee)
        : 0;
      oppLineItem.LVGO__Up_Front_Per_Member__c = opli.UpFrontFee != null
        ? Decimal.valueOf(opli.UpFrontFee)
        : 0;
      oppLineItem.LVGO__Estimated_At_Risk_PPPM__c = opli.AtRiskFee != null
        ? Decimal.valueOf(opli.AtRiskFee)
        : 0;
      oppLineItem.LVGO__Program_ARR_Copy__c = opli.NetArr != null
        ? Decimal.valueOf(opli.NetArr)
        : 0;
      oppLineItem.LVGO__Product_Participants__c = opli.ParticipantQuantity !=
        null
        ? Integer.valueOf(opli.ParticipantQuantity)
        : 0;
	  oppLineItem.LVGO__Product_Rollup__c = opli.ProductRollup !=    //Added By rushikesh 5537
        null
        ? string.valueOf(opli.ProductRollup)
        : null;
      if (
        opli.ParentsProductCode != null &&
        dtMap != null &&
        !dtMap.IsEmpty() &&
        dtMap.containsKey(opli.ParentsProductCode)
      ) {
        oppLineItem.LVGO__Disable_Teletherapy__c = dtMap.get(
              opli.ParentsProductCode
            )
            .DisableTeletherapy != null &&
          dtMap.get(opli.ParentsProductCode).DisableTeletherapy == 'YES'
          ? true
          : false;
        oppLineItem.LVGO__Disable_BH_Coaching__c = dtMap.get(
              opli.ParentsProductCode
            )
            .DisableBHCoaching != null &&
          dtMap.get(opli.ParentsProductCode).DisableBHCoaching == 'YES'
          ? true
          : false;
      } else {
        oppLineItem.LVGO__Disable_Teletherapy__c = opli.DisableTeletherapy !=
          null &&
          opli.DisableTeletherapy == 'YES'
          ? true
          : false;
        oppLineItem.LVGO__Disable_BH_Coaching__c = opli.DisableBHCoaching !=
          null &&
          opli.DisableBHCoaching == 'YES'
          ? true
          : false;
      }
      if (
        opli.ParentsProductCode != null &&
        opli.Anchor == 'true' &&
        opli.ParentsProductCode != 'MYSTRSOL'
      ) {
        oppLineItem.LVGO__Product2__c = prodMap.get(opli.ParentsProductCode);
        oppLineItem.LVGO__Source_id__c = opli.Id != null
          ? String.valueOf(opli.Id)
          : '';
      } else if (
        opli.ParentsProductCode != null &&
        opli.Anchor == 'true' &&
        opli.ParentsProductCode == 'MYSTRSOL'
      ) {
        oppLineItem.LVGO__Product2__c = prodMap.get(opli.ProductCode);
        oppLineItem.LVGO__Source_id__c = opli.Id != null
          ? String.valueOf(opli.Id)
          : '';
      } else {
        oppLineItem.LVGO__Product2__c = prodMap.get(opli.ProductCode);
        oppLineItem.LVGO__Source_id__c = opli.Id != null
          ? String.valueOf(opli.Id)
          : '';
      }
      system.debug('OppLineItem::: ' + oppLineItem);
      oppliList.add(oppLineItem);
    }
    // need to add the opp line item you want to insert or update in oppList below ****
    // oppliList.add();
  }

  public class oppliWrapper {
    public String Id { get; set; }
    public String SalesPrice { get; set; }
    public String ParentsProductCode { get; set; }
    public string GrandParentsProductCode { get; set; }
    public String Productcode { get; set; }
    public String Name { get; set; }
    public String Anchor { get; set; }
    public String ParticipantQuantity { get; set; }
    public String SubscriptionTerm { get; set; }
    public String TotalPrice { get; set; }
    public String NetArr { get; set; }
    public String AdminFee { get; set; }
    public String AtRiskFee { get; set; }
    public String UpFrontFee { get; set; }
    public String DisableTeletherapy { get; set; }
    public String DisableBHCoaching { get; set; }
	public String ProductRollup { get; set; }               //Added By rushikesh 5537
  }

  public class myStrengthFeatures {
    public String DisableTeletherapy { get; set; }
    public String DisableBHCoaching { get; set; }
  }
}