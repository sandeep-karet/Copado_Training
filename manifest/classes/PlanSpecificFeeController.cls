// *******************************************************
// Apex class to override New/Edit buttons in Plan-Specific Fees by Product (Plan_Specific_Fees__c) object
/*Description: add to the Plan-Specific Fees by Products object, the following 6 currency fields.
             They will need to be in a new section right above “System Information’.
              Please make the section header “Behavorial Health Consult Fee Structures"""*/
// *******************************************************
public class PlanSpecificFeeController {
  public Plan_Specific_Fees__c groupProdRec { get; set; }
  public String Subtitle { get; private set; }

  // Product rendering helpers
  public Boolean showProduct { get; private set; }
  public Boolean isEMO2 { get; private set; }
  public Boolean isGenMed { get; private set; }
  public Boolean isTobacco { get; private set; }
  public Boolean isBehavior { get; private set; }
  public Boolean isDerm { get; private set; }
  public Boolean isGlobalCare { get; private set; }
  public Boolean isBackCare { get; private set; }
  public Boolean isNutrition { get; private set; }
  public Boolean isOther { get; private set; }
  public Boolean allowSubSelection { get; private set; }
  public Boolean allowSave { get; private set; }
  public Boolean isNewSub { get; private set; }

  public String selProductName { get; private set; }
  public String selProductCode { get; private set; }
  public String subscriptionTitle { get; private set; }

  public Id selSubId { get; set; }
  public SBQQ__Subscription__c selSub { get; set; }
  public Mbr_Group__c grp { get; set; }

  public List<SBQQ__Subscription__c> prodUnderContractList { get; set; }
  public List<subWrapper> subWrapperList { get; set; }
  public Map<Id, SBQQ__Subscription__c> subMap { get; set; }

  private Map<String, Asset> assetMap { get; set; }
  private Id psfId;

  // Constructor - initialize based on what type of page to show.
  public PlanSpecificFeeController(ApexPages.StandardController stdCntrl) {
    allowSave = true;
    psfId = stdCntrl.getId();

    Plan_Specific_Fees__c tmpGroup = (Plan_Specific_Fees__c) stdCntrl.getRecord();
    if (psfId != null) {
      // A Specific PSF ID is selected
      isNewSub = false;
      groupProdRec = [
        SELECT
          Id,
          Name,
          Member_Group__c,
          Member_Group__r.Client_Account__c,
          Product_Under_Contract__c,
          Consults_per_Family__c,
          Consult_Frequency__c,
          Actual_Copay_May_Be_Less__c,
          DERMConsult_Fee_Mbr_Pd__c,
          DERMConsult_Fee_Plan_Pd__c,
          Consult_Fee_Mbr_Pd__c,
          Consult_Fee_Plan_Pd__c,
          Consult_Fee_Initial_Diagnostic_Mbr_Pd__c,
          Consult_Fee_Initial_Diagnostic_Plan_Pd__c,
          Consult_Fee_Ongoing_MD_Mbr_Pd__c,
          Consult_Fee_Ongoing_MD_Plan_Pd__c,
          Consult_Fee_Ongoing_Non_MD_Mbr_Pd__c,
          Consult_Fee_Ongoing_Non_MD_Plan_Pd__c,
          Subscription__r.SBQQ__Product__r.Name,
          Subscribed_Asset__c,
          Subscription__c,
          Product__c,
          Subscription__r.SBQQ__Product__r.ProductCode,
          Subscription__r.SBQQ__Account__r.name,
          TC_Client_Case_Rate_Fee__c,
          TC_Mbr_Case_Rate_Fee__c,
          Subscription__r.SBQQ__StartDate__c,
          LastModifiedBy.Name,
          LastModifiedDate,
          CreatedBy.Name,
          CreatedDate,
          Subscription__r.Sort_Order__c,
          Member_Group__r.Name__c,
          Product_Start_Date__c,
          Product_End_Date__c
        FROM Plan_Specific_Fees__c
        WHERE Id = :psfId
        ORDER BY Subscription__r.Sort_Order__c
      ];

      Subtitle = 'Edit ' + groupProdRec.Name;
      //Subtitle = 'Clone ' + ApexPages.currentPage().getParameters().get('clone');
      // Missing fields:
      // Contact_to_pay_Cede_Back_to__c
      // HPReferral_PCP_Fee_Mbr_Paid__c,HPReferral_PCP_Fee_Plan_Paid__c,HPReferral_Specialist_Fee_Mbr_Paid__c,
      // HPReferral_Specialist_Fee_Plan_Paid__c,
      subscriptionTitle = 'Related Subscriptions';

      grp = [
        SELECT Id, Client_Account__c, Actual_Copay_May_Be_Less__c, Name__c
        FROM Mbr_Group__c
        WHERE Id = :groupProdRec.Member_Group__c
      ];
      if (groupProdRec.Subscription__c != null) {
        // load only the assigned subscription and highlight it
        loadSelectedSubscription(groupProdRec.Subscription__c);
        selSubId = groupProdRec.Subscription__c;
        // pass start date if applicable

        allowSave = true;
      } else {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'PSF does not have an assigned Subscription.  This record is invalid.'
          )
        );
        allowSave = false;
      }
      loadAssets();
      selProduct();
    } else {
      // This is NEW, and we know the group (this should be coming from the group screen)
      // If a valid group ID isn't found, an error page will be displayed.
      isNewSub = true;
      Subtitle = 'New Plan-Specific Fees by Product';
      prodUnderContractList = new List<SBQQ__Subscription__c>();
      groupProdRec = new Plan_Specific_Fees__c();
      Id gid = tmpGroup.Member_Group__c;
      if (gid == null) {
        //try to get from parameter, since this isn't coming from a page compatible with the PSF Standard controller
        gid = ApexPages.currentPage().getParameters().get('gid');
      }
      if (gid != null) {
        groupProdRec.Member_Group__c = gid;
        grp = [
          SELECT Id, Client_Account__c, Actual_Copay_May_Be_Less__c, Name__c
          FROM Mbr_Group__c
          WHERE Id = :gid
        ];
        loadSubscriptionsByGroup(grp);
        groupProdRec.Actual_Copay_May_Be_Less__c = grp.Actual_Copay_May_Be_Less__c;
      } else {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'This page may only be accessed from a valid group or PSF.'
          )
        );
      }
      // Show the product info section, so user can select Group/Sub/Product combo to get products
      if (gid != null) {
        showProduct = true;
        loadAssets();
      }
    }

    // Display an error if there are no associated subscriptions
    if (subMap == null || subMap.size() == 0) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'No valid subscriptions found.  A subscription must be created first.'
        )
      );
      allowSave = false;
    }
  }

  public PageReference selGroup() {
    // TODO: This can be removed if group remains readonly
    // User has changed groups- rerender page
    // (this is disabled, changing groups is not allowed any more)
    prodUnderContractList = new List<SBQQ__Subscription__c>();
    if (groupProdRec.Member_Group__c != null) {
      Mbr_Group__c groupRec = [
        SELECT Id, Client_Account__c, Actual_Copay_May_Be_Less__c
        FROM Mbr_Group__c
        WHERE Id = :groupProdRec.Member_Group__c
        LIMIT 1
      ];
      prodUnderContractList = [
        SELECT
          Id,
          Name,
          SBQQ__StartDate__c,
          Status__c,
          Consult_Type__c,
          Consult_Fees__c,
          Sort_Order__c,
          Current_Membership_Fee__c,
          SBQQ__Product__r.Name,
          SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,
          SBQQ__Account__r.name
        FROM SBQQ__Subscription__c
        WHERE SBQQ__Account__c = :groupRec.Client_Account__c
        ORDER BY Sort_Order__c
      ];
      groupProdRec.Actual_Copay_May_Be_Less__c = groupRec.Actual_Copay_May_Be_Less__c;
    }
    return null;
  }

  public PageReference selProduct() {
    // "Select" has been clicked in the product list.
    // Set default rendering flags
    isGenMed = false;
    isTobacco = false;
    isBehavior = false;
    isDerm = false;
    isGlobalCare = false;
    isBackCare = false;
    isNutrition = false;
    isEMO2 = false;

    selSub = subMap.get(selSubId);
    // Set the selected product
    showProduct = true;
    List<Plan_Specific_Fees__c> results = [
      SELECT
        Id,
        Name,
        Member_Group__c,
        Member_Group__r.Client_Account__c,
        Product_Under_Contract__c,
        Consults_per_Family__c,
        Consult_Frequency__c,
        Actual_Copay_May_Be_Less__c,
        DERMConsult_Fee_Mbr_Pd__c,
        DERMConsult_Fee_Plan_Pd__c,
        Consult_Fee_Mbr_Pd__c,
        Consult_Fee_Plan_Pd__c,
        Consult_Fee_Initial_Diagnostic_Mbr_Pd__c,
        Consult_Fee_Initial_Diagnostic_Plan_Pd__c,
        Consult_Fee_Ongoing_MD_Mbr_Pd__c,
        Consult_Fee_Ongoing_MD_Plan_Pd__c,
        Consult_Fee_Ongoing_Non_MD_Mbr_Pd__c,
        Consult_Fee_Ongoing_Non_MD_Plan_Pd__c,
        Subscribed_Asset__c,
        Subscription__c,
        Product__c,
        Subscription__r.SBQQ__Product__r.ProductCode,
        TC_Client_Case_Rate_Fee__c,
        TC_Mbr_Case_Rate_Fee__c,
        Subscription__r.SBQQ__StartDate__c,
        LastModifiedBy.Name,
        LastModifiedDate,
        CreatedBy.Name,
        CreatedDate,
        Product_Start_Date__c,
        Product_End_Date__c
      FROM Plan_Specific_Fees__c
      WHERE Member_Group__c = :grp.Id AND Subscription__c = :selSubId
      LIMIT 1
    ];

    if (results.size() == 0) {
      // Find selected product name
      if (subMap != null && subMap.keySet().contains(selSubId)) {
        selProductName = subMap.get(selSubId).SBQQ__Product__r.Name;
        selProductCode = subMap.get(selSubId).SBQQ__Product__r.ProductCode;
        groupProdRec.Subscription__c = selSubId;
      }
      allowSave = true;
    } else {
      // We found a PSF in use, so this can only be added to a new subscription
      if (!isNewSub) {
        // Edit: Update the existing record
        groupProdRec = results[0];
        selProductName = groupProdRec.Product__c;
        selProductCode = groupProdRec.Subscription__r.SBQQ__Product__r.ProductCode;
        allowSave = true;
      } else {
        // New: If there's already a matching record, don't allow modifications or ability to save
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'A PSF already exists for the selected product.'
          )
        );
        allowSave = false;
        selProductName = ''; // force invalid product
        selProductCode = '';
      }
    }

    // set visibility flags based on selected group code
    // The first set uses custom logic.  If custom logic is not needed, isOther will be used.
    isBehavior = (selProductCode == 'BH');
    isDerm = (selProductCode == 'DERM');
    isGenMed = (selProductCode == 'GM');
    isTobacco = (selProductCode == 'TC');
    isBackCare = (selProductCode == 'TDBC');
    isGlobalCare = (selProductCode == 'GLOBALCARE');
    isNutrition = (selProductCode == 'NUT');
    isEMO2 = (selProductCode == 'EMO2');

    if (
      isBehavior ||
      isDerm ||
      isGenMed ||
      isTobacco ||
      isGlobalCare ||
      isBackCare ||
      isNutrition ||
      isEMO2
    ) {
      isOther = false;
    } else {
      isOther = true;
    }

    // Set Default Values for appropriate fields based on assets
    setGroupProductDefaults(selSubId);

    return null;
  }

  // returns the default fee from assets or NULL
  private Decimal getDefaultAssetFee(String code, String subId) {
    if (assetMap != null && assetMap.keySet().contains(code + '|' + subId)) {
      return assetMap.get(code + '|' + subId).Consult_Fees__c;
    } else {
      return null;
    }
  }

  // One time load of all related defaults in to a map with Code|SubscriptionID
  private void loadAssets() {
    // TODO: Determine if we need to filter by Status = active...
    List<Id> accIds = new List<Id>();
    accIds.add(grp.Client_Account__c);
    for (Mbr_Group_Role__c payerGrpRole : [
      SELECT id, Role_Type__c, Source_Account__c
      FROM Mbr_Group_Role__c
      WHERE
        Mbr_Group__c = :grp.id
        AND (Role_Type__c = 'Payer'
        OR Role_Type__c = 'Contractee')
    ]) {
      accIds.add(payerGrpRole.Source_Account__c);
    }

    List<Asset> assets = [
      SELECT
        Id,
        Product2.ProductCode,
        Consult_Fees__c,
        SBQQ__RequiredBySubscription__c
      FROM Asset
      WHERE AccountId IN :accIds
    ];
    assetMap = new Map<String, Asset>();

    if (assets.size() > 0) {
      for (Asset a : assets) {
        if (a.Product2 != null) {
          assetMap.put(
            a.Product2.ProductCode + '|' + a.SBQQ__RequiredBySubscription__c,
            a
          );
        }
      }
    }
  }

  // If we came here from the group screen, we have to load related subscriptions by the related account
  private void loadSubscriptionsByAccount(Id accountId) {
    prodUnderContractList = [
      SELECT
        Id,
        Name,
        SBQQ__StartDate__c,
        Status__c,
        Consult_Type__c,
        Consult_Fees__c,
        Current_Membership_Fee__c,
        SBQQ__Product__r.ProductCode,
        SBQQ__Product__r.Name,
        Sort_Order__c,
        SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,
        SBQQ__Account__r.name
      FROM SBQQ__Subscription__c
      WHERE SBQQ__Account__c = :accountId
      ORDER BY Sort_Order__c
    ];

    List<Plan_Specific_Fees__c> prodInUse = [
      SELECT
        Id,
        Member_Group__c,
        Subscription__c,
        Product_Start_Date__c,
        Product_End_Date__c
      FROM Plan_Specific_Fees__c
      WHERE Member_Group__c = :groupProdRec.Member_Group__c
    ];

    Set<String> prodInUseKeys = new Set<String>();
    for (Plan_Specific_Fees__c psf : prodInUse) {
      prodInUseKeys.add(psf.Subscription__c);
    }

    subWrapperList = new List<subWrapper>();
    for (SBQQ__Subscription__c sub : prodUnderContractList) {
      subWrapper sw = new subWrapper();
      sw.sub = sub;
      sw.showSelect = !prodInUseKeys.contains(sub.Id);
      subWrapperList.add(sw);
    }

    subMap = new Map<Id, SBQQ__Subscription__c>();
    subMap.putAll(prodUnderContractList);
    allowSubSelection = true;
  }

  // If we came here from the group screen, we have to load related subscriptions by the related account
  private void loadSubscriptionsByGroup(Mbr_Group__c mbrGroup) {
    List<Id> accIds = new List<Id>();
    accIds.add(mbrGroup.Client_Account__c);
    for (Mbr_Group_Role__c payerGrpRole : [
      SELECT id, Role_Type__c, Source_Account__c
      FROM Mbr_Group_Role__c
      WHERE
        Mbr_Group__c = :mbrGroup.id
        AND (Role_Type__c = 'Payer'
        OR Role_Type__c = 'Contractee')
    ]) {
      accIds.add(payerGrpRole.Source_Account__c);
    }

    prodUnderContractList = [
      SELECT
        Id,
        Name,
        SBQQ__StartDate__c,
        Status__c,
        Consult_Type__c,
        Consult_Fees__c,
        Current_Membership_Fee__c,
        SBQQ__Product__r.ProductCode,
        SBQQ__Product__r.Name,
        Sort_Order__c,
        SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,
        SBQQ__Account__r.name
      FROM SBQQ__Subscription__c
      WHERE SBQQ__Account__c IN :accIds
      ORDER BY Sort_Order__c
    ];

    List<Plan_Specific_Fees__c> prodInUse = [
      SELECT
        Id,
        Member_Group__c,
        Subscription__c,
        Product_Start_Date__c,
        Product_End_Date__c
      FROM Plan_Specific_Fees__c
      WHERE Member_Group__c = :groupProdRec.Member_Group__c
    ];

    Set<String> prodInUseKeys = new Set<String>();
    for (Plan_Specific_Fees__c psf : prodInUse) {
      prodInUseKeys.add(psf.Subscription__c);
    }

    subWrapperList = new List<subWrapper>();
    for (SBQQ__Subscription__c sub : prodUnderContractList) {
      subWrapper sw = new subWrapper();
      sw.sub = sub;
      sw.showSelect = !prodInUseKeys.contains(sub.Id);
      subWrapperList.add(sw);
    }

    subMap = new Map<Id, SBQQ__Subscription__c>();
    subMap.putAll(prodUnderContractList);
    allowSubSelection = true;
  }

  // This is from a specific PSF, load the specific PSF info.
  private void loadSelectedSubscription(Id subId) {
    prodUnderContractList = [
      SELECT
        Id,
        Name,
        SBQQ__StartDate__c,
        Status__c,
        Consult_Type__c,
        Consult_Fees__c,
        Current_Membership_Fee__c,
        SBQQ__Product__r.Name,
        SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,
        SBQQ__Account__r.name,
        Sort_Order__c
      FROM SBQQ__Subscription__c
      WHERE Id = :subId
    ];

    subWrapperList = new List<subWrapper>();
    for (SBQQ__Subscription__c sub : prodUnderContractList) {
      subWrapper sw = new subWrapper();
      sw.sub = sub;
      sw.showSelect = false;
      subWrapperList.add(sw);
    }

    subMap = new Map<Id, SBQQ__Subscription__c>();
    subMap.putAll(prodUnderContractList);
    allowSubSelection = false;
    subscriptionTitle = 'Subscription';
  }

  // Save New/Existing PSF.
  public PageReference Save() {
    try {
      if (!validatePage()) {
        // validation failed- stop and let user review errors
        return null;
      }
      if (isNewSub) {
        insert groupProdRec;

        // Return to group page (the only place user could have come from)
        return new PageReference('/' + groupProdRec.Member_Group__c);
      } else {
        update groupProdRec;

        // Return to previous page
        if (ApexPages.currentPage().getParameters().get('retURL') != null) {
          return new PageReference(
            ApexPages.currentPage().getParameters().get('retURL')
          );
        } else {
          ApexPages.addMessage(
            new ApexPages.Message(ApexPages.Severity.INFO, 'Record Saved.')
          );
          return null;
        }
      }
    } catch (DmlException e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'Unable to save record. Message: ' + e.getMessage()
        )
      );
      return null;
    }
  }

  // Save New PSF.
  public PageReference SaveAndNew() {
    try {
      insert groupProdRec;
      PageReference newPage = new PageReference(
        '/' + ApexPages.currentPage().getUrl()
      );
      newPage.setRedirect(true);
      return newPage;
    } catch (DmlException e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'Unable to save record. Message: ' + e.getMessage()
        )
      );
      return null;
    }
  }

  public PageReference Cancel() {
    if (groupProdRec.Member_Group__c != null) {
      return new PageReference('/' + groupProdRec.Member_Group__c);
    } else {
      return new PageReference(
        '/' + ApexPages.currentPage().getParameters().get('retURL')
      );
    }
  }

  // Delete Existing PSF.
  public PageReference DeleteSub() {
    try {
      delete groupProdRec;
      return new PageReference('/' + groupProdRec.Member_Group__c);
    } catch (DmlException e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'Unable to delete record. Message: ' + e.getMessage()
        )
      );
      return null;
    }
  }

  private Boolean validatePage() {
    if (isGenMed) {
      if (
        !validateFees(
          groupProdRec.Consult_Fee_Mbr_Pd__c,
          groupProdRec.Consult_Fee_Plan_Pd__c,
          'GMCF',
          'Gen Med Consult'
        )
      ) {
        groupProdRec.Consult_Fee_Mbr_Pd__c.addError(
          'Sum does not equal default value.'
        );
        groupProdRec.Consult_Fee_Plan_Pd__c.addError(
          'Sum does not equal default value.'
        );
        return false;
      } else {
        return true;
      }
    } else if (isEMO2) {
      if (
        !validateFees(
          groupProdRec.Consult_Fee_Mbr_Pd__c,
          groupProdRec.Consult_Fee_Plan_Pd__c,
          'EMSCF',
          'EMS - Consult Fee'
        )
      ) {
        groupProdRec.Consult_Fee_Mbr_Pd__c.addError(
          'Sum does not equal default value.'
        );
        groupProdRec.Consult_Fee_Plan_Pd__c.addError(
          'Sum does not equal default value.'
        );
        return false;
      } else {
        return true;
      }
    } else if (isDerm) {
      if (
        !validateFees(
          groupProdRec.DERMConsult_Fee_Mbr_Pd__c,
          groupProdRec.DERMConsult_Fee_Plan_Pd__c,
          'DERMFEE',
          'Derm Consult Fee'
        )
      ) {
        groupProdRec.DERMConsult_Fee_Mbr_Pd__c.addError(
          'Sum does not equal default value.'
        );
        groupProdRec.DERMConsult_Fee_Plan_Pd__c.addError(
          'Sum does not equal default value.'
        );
        return false;
      } else {
        return true;
      }
    } else if (isBehavior) {
      Boolean isValid = true;

      if (
        !validateFees(
          groupProdRec.Consult_Fee_Initial_Diagnostic_Mbr_Pd__c,
          groupProdRec.Consult_Fee_Initial_Diagnostic_Plan_Pd__c,
          'BHP1T',
          'BH Consult Fee - Psychiatrist/MD- 1st visit only'
        )
      ) {
        groupProdRec.Consult_Fee_Initial_Diagnostic_Plan_Pd__c.addError(
          'Sum does not equal default value.'
        );
        groupProdRec.Consult_Fee_Initial_Diagnostic_Mbr_Pd__c.addError(
          'Sum does not equal default value.'
        );
        isValid = false;
      }
      if (
        !validateFees(
          groupProdRec.Consult_Fee_Ongoing_MD_Mbr_Pd__c,
          groupProdRec.Consult_Fee_Ongoing_MD_Plan_Pd__c,
          'BHPOT',
          'BH Consult Fee - Psychiatrist/MD- ONGOING visit'
        )
      ) {
        groupProdRec.Consult_Fee_Ongoing_MD_Mbr_Pd__c.addError(
          'Sum does not equal default value.'
        );
        groupProdRec.Consult_Fee_Ongoing_MD_Plan_Pd__c.addError(
          'Sum does not equal default value.'
        );
        isValid = false;
      }

      if (
        !validateFees(
          groupProdRec.Consult_Fee_Ongoing_Non_MD_Mbr_Pd__c,
          groupProdRec.Consult_Fee_Ongoing_Non_MD_Plan_Pd__c,
          'BHNPT',
          'BH Consult Fee - Non-Psychiatrist'
        )
      ) {
        groupProdRec.Consult_Fee_Ongoing_Non_MD_Mbr_Pd__c.addError(
          'Sum does not equal default value.'
        );
        groupProdRec.Consult_Fee_Ongoing_Non_MD_Plan_Pd__c.addError(
          'Sum does not equal default value.'
        );
        isValid = false;
      }
      return isValid;
    } else if (isTobacco) {
      if (
        !validateFees(
          groupProdRec.TC_Mbr_Case_Rate_Fee__c,
          groupProdRec.TC_Client_Case_Rate_Fee__c,
          'TCPROGFEE',
          'Tobacco Case Rate Fee'
        )
      ) {
        groupProdRec.TC_Mbr_Case_Rate_Fee__c.addError(
          'Sum does not equal default value.'
        );
        groupProdRec.TC_Client_Case_Rate_Fee__c.addError(
          'Sum does not equal default value.'
        );
        return false;
      } else {
        return true;
      }
    } else if (isGlobalCare) {
      if (
        !validateFees(
          groupProdRec.Consult_Fee_Mbr_Pd__c,
          groupProdRec.Consult_Fee_Plan_Pd__c,
          'GCCF',
          'Global Care Visit Fee'
        )
      ) {
        groupProdRec.Consult_Fee_Mbr_Pd__c.addError(
          'Sum does not equal default value.'
        );
        groupProdRec.Consult_Fee_Plan_Pd__c.addError(
          'Sum does not equal default value.'
        );
        return false;
      } else {
        return true;
      }
    } else if (isBackCare) {
      if (
        !validateFees(
          groupProdRec.Consult_Fee_Mbr_Pd__c,
          groupProdRec.Consult_Fee_Plan_Pd__c,
          'TDBCFEE',
          'Back Care Visit Fee'
        )
      ) {
        groupProdRec.Consult_Fee_Mbr_Pd__c.addError(
          'Sum does not equal default value.'
        );
        groupProdRec.Consult_Fee_Plan_Pd__c.addError(
          'Sum does not equal default value.'
        );
        return false;
      } else {
        return true;
      }
    } else if (isNutrition) {
      if (
        !validateFees(
          groupProdRec.Consult_Fee_Mbr_Pd__c,
          groupProdRec.Consult_Fee_Plan_Pd__c,
          'NUTFEE',
          'Back Care Visit Fee'
        )
      ) {
        groupProdRec.Consult_Fee_Mbr_Pd__c.addError(
          'Sum does not equal default value.'
        );
        groupProdRec.Consult_Fee_Plan_Pd__c.addError(
          'Sum does not equal default value.'
        );
        return false;
      } else {
        return true;
      }
    } else {
      // it's an isOther, so it's automatically valid
      return true;
    }
  }

  private Boolean validateFees(
    Decimal mbr,
    Decimal plan,
    String defaultCode,
    String feeDesc
  ) {
    Decimal fee = getDefaultAssetFee(defaultCode, selSubId);
    if (fee == null) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'No valid default fee found.'
        )
      );
      return false;
    } else {
      if (mbr == null || plan == null) {
        if (mbr == null) {
          ApexPages.addMessage(
            new ApexPages.Message(
              ApexPages.Severity.ERROR,
              'Member fee may not be null for ' + feeDesc
            )
          );
        }
        if (plan == null) {
          ApexPages.addMessage(
            new ApexPages.Message(
              ApexPages.Severity.ERROR,
              'Plan fee may not be null for ' + feeDesc
            )
          );
        }
        return false;
      }
      if (mbr + plan != fee) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            feeDesc +
              ' member + plan does not equal Default fee of $' +
              fee +
              ' (total: $' +
              (mbr + plan) +
              ')'
          )
        );
        return false;
      }
    }
    return true;
  }

  private void setGroupProductDefaults(Id subscriptionId) {
    // fill in the map for assets and set default values
    if (isGenMed) {
      Decimal fee = getDefaultAssetFee('GMCF', subscriptionId);
      if (fee != null) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.INFO,
            'Default fee $' + fee + ' for Consult Fee'
          )
        );
        if (groupProdRec.Consult_Fee_Mbr_Pd__c == null) {
          groupProdRec.Consult_Fee_Mbr_Pd__c = fee;
        }
      } else {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.WARNING,
            'No Default Fee found in Assets for Gen Med Consult Fee'
          )
        );
      }
      // Zero out Plan Paid fee if it hasn't been set
      if (groupProdRec.Consult_Fee_Plan_Pd__c == null) {
        groupProdRec.Consult_Fee_Plan_Pd__c = 0.0;
      }
    } else if (isEMO2) {
      Decimal fee = getDefaultAssetFee('EMSCF', subscriptionId);
      if (fee != null) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.INFO,
            'Default fee $' + fee + ' for Consult Fee'
          )
        );
        if (groupProdRec.Consult_Fee_Mbr_Pd__c == null) {
          groupProdRec.Consult_Fee_Mbr_Pd__c = fee;
        }
      } else {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.WARNING,
            'No Default Fee found in Assets for EMO2 Consult Fee'
          )
        );
      }
      // Zero out Plan Paid fee if it hasn't been set
      if (groupProdRec.Consult_Fee_Plan_Pd__c == null) {
        groupProdRec.Consult_Fee_Plan_Pd__c = 0.0;
      }
    } else if (isDerm) {
      Decimal fee = getDefaultAssetFee('DERMFEE', subscriptionId);
      if (fee != null) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.INFO,
            'Default fee $' + fee + ' for Derm Consult Fee'
          )
        );
        if (groupProdRec.DERMConsult_Fee_Mbr_Pd__c == null) {
          groupProdRec.DERMConsult_Fee_Mbr_Pd__c = fee;
        }
      } else {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.WARNING,
            'No Default Fee found in Assets for Derm Consult Fee'
          )
        );
      }
      // Zero out Plan Paid fee if null
      if (groupProdRec.DERMConsult_Fee_Plan_Pd__c == null) {
        groupProdRec.DERMConsult_Fee_Plan_Pd__c = 0.0;
      }
    } else if (isBehavior) {
      Decimal fee = getDefaultAssetFee('BHP1T', subscriptionId);
      if (fee != null) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.INFO,
            'Default fee $' +
              fee +
              ' for BH Consult Fee - Psych/MD-1stvisitonly'
          )
        );
        if (groupProdRec.Consult_Fee_Initial_Diagnostic_Mbr_Pd__c == null) {
          groupProdRec.Consult_Fee_Initial_Diagnostic_Mbr_Pd__c = fee;
        }
      } else {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.WARNING,
            'No Default Fee found in Assets for BH Consult Fee - Psychiatrist/MD- 1st visit only'
          )
        );
      }

      fee = getDefaultAssetFee('BHPOT', subscriptionId);
      if (fee != null) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.INFO,
            'Default fee $' + fee + ' Psych/MD-ONGOING-Total'
          )
        );
        if (groupProdRec.Consult_Fee_Ongoing_MD_Mbr_Pd__c == null) {
          groupProdRec.Consult_Fee_Ongoing_MD_Mbr_Pd__c = fee;
        }
      } else {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.WARNING,
            'No Default Fee found in Assets for Psych/MD-ONGOING-Total '
          )
        );
      }

      fee = getDefaultAssetFee('BHNPT', subscriptionId);
      if (fee != null) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.INFO,
            'Default fee $' + fee + ' for BH Consult Fee - Non-Psychiatrist'
          )
        );
        if (groupProdRec.Consult_Fee_Ongoing_Non_MD_Mbr_Pd__c == null) {
          groupProdRec.Consult_Fee_Ongoing_Non_MD_Mbr_Pd__c = fee;
        }
      } else {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.WARNING,
            'No Default Fee found in Assets for BH Consult Fee - Non-Psychiatrist'
          )
        );
      }

      // Zero out Plan Paid fees if null
      if (groupProdRec.Consult_Fee_Ongoing_Non_MD_Plan_Pd__c == null) {
        groupProdRec.Consult_Fee_Ongoing_Non_MD_Plan_Pd__c = 0.0;
      }
      if (groupProdRec.Consult_Fee_Ongoing_MD_Plan_Pd__c == null) {
        groupProdRec.Consult_Fee_Ongoing_MD_Plan_Pd__c = 0.0;
      }
      if (groupProdRec.Consult_Fee_Initial_Diagnostic_Plan_Pd__c == null) {
        groupProdRec.Consult_Fee_Initial_Diagnostic_Plan_Pd__c = 0.0;
      }
    } else if (isTobacco) {
      Decimal fee = getDefaultAssetFee('TCPROGFEE', subscriptionId);
      if (fee != null) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.INFO,
            'Default fee $' + fee + ' for Tobacco Case Rate Fee.'
          )
        );
        if (groupProdRec.TC_Mbr_Case_Rate_Fee__c == null) {
          groupProdRec.TC_Mbr_Case_Rate_Fee__c = fee;
        }
      } else {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.WARNING,
            'No Default Fee found in Assets for Tobacco Case Rate Fee'
          )
        );
      }
      if (groupProdRec.TC_Client_Case_Rate_Fee__c == null) {
        groupProdRec.TC_Client_Case_Rate_Fee__c = 0.0;
      }
    } else if (isGlobalCare) {
      Decimal fee = getDefaultAssetFee('GCCF', subscriptionId);
      if (fee != null) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.INFO,
            'Default fee $' + fee + ' for Global Care Consult Fee.'
          )
        );
        if (groupProdRec.Consult_Fee_Mbr_Pd__c == null) {
          groupProdRec.Consult_Fee_Mbr_Pd__c = fee;
        }
      } else {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.WARNING,
            'No Default Fee found in Assets for Global Care Consult Fee'
          )
        );
      }
      // Zero out Plan Paid fee if it hasn't been set
      if (groupProdRec.Consult_Fee_Plan_Pd__c == null) {
        groupProdRec.Consult_Fee_Plan_Pd__c = 0.0;
      }
    } else if (isBackCare) {
      Decimal fee = getDefaultAssetFee('TDBCFEE', subscriptionId);
      if (fee != null) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.INFO,
            'Default fee $' + fee + ' for Teladoc Back Care Consult Fee.'
          )
        );
        if (groupProdRec.Consult_Fee_Mbr_Pd__c == null) {
          groupProdRec.Consult_Fee_Mbr_Pd__c = fee;
        }
      } else {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.WARNING,
            'No Default Fee found in Assets for Teladoc Back Care Consult Fee'
          )
        );
      }
      // Zero out Plan Paid fee if it hasn't been set
      if (groupProdRec.Consult_Fee_Plan_Pd__c == null) {
        groupProdRec.Consult_Fee_Plan_Pd__c = 0.0;
      }
    } else if (isNutrition) {
      Decimal fee = getDefaultAssetFee('NUTFEE', subscriptionId);
      if (fee != null) {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.INFO,
            'Default fee $' + fee + ' for Nutrition Consult Fee.'
          )
        );
        if (groupProdRec.Consult_Fee_Mbr_Pd__c == null) {
          groupProdRec.Consult_Fee_Mbr_Pd__c = fee;
        }
      } else {
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.WARNING,
            'No Default Fee found in Assets for Nutrition Consult Fee'
          )
        );
      }
      // Zero out Plan Paid fee if it hasn't been set
      if (groupProdRec.Consult_Fee_Plan_Pd__c == null) {
        groupProdRec.Consult_Fee_Plan_Pd__c = 0.0;
      }
    }
  }

  public class subWrapper {
    public Boolean showSelect { get; set; }
    public SBQQ__Subscription__c sub { get; set; }
  }

  //private String sortOrder = 'CreatedDate';

  public List<Plan_Specific_Fees__History> getHistories() {
    List<Plan_Specific_Fees__History> psf = [
      SELECT CreatedDate, CreatedBy.Name, Field, OldValue, NewValue
      FROM Plan_Specific_Fees__History
      WHERE ParentId = :psfId
      ORDER BY CreatedDate DESC
    ];
    return psf;
  }
}