global class Mg2_NASFHelper {
  global static Mg2_NASFInfo getNasfInfoByAccountId(
    String accountId,
    Set<Id> selectedGroupIds
  ) {
    Mg2_NASFInfo nasf = new Mg2_NASFInfo();
    if (selectedGroupIds == null) {
      selectedGroupIds = new Map<Id, Mbr_Group__c>(
          [SELECT Id FROM Mbr_Group__c WHERE Client_Account__c = :accountId]
        )
        .keySet();
    }

    Account accountInfo = [
      SELECT
        Id,
        Name,
        Friendly_Account_Name__c,
        Account_Type__c,
        Total_US_Employees_Benefits_Enrolled__c,
        Print_Phone__c,
        Print_Url__c,
        BillingStreet,
        BillingCity,
        BillingState,
        BillingPostalCode,
        BillingCountry,
        Billing_Org_ID__c,
        Receives_Invoice__c,
        Account_Manager__c,
        Hierarchy__c,
        OwnerId,
        States_of_Operation__c,
        GUID__c,
        Phone,
        Description,
        Owner.Name,
        Account_Manager__r.Name,
        BillingAddress,
        Report_Recipient_Emails__c,
        Report_Sorting__c,
        Report_Template__c,
        Special_Instructions_for_Implementatio__c,
        Primary_Billing_Contact__r.Name,
        Primary_Billing_Contact_Email__c,
        Primary_Billing_Contact_Phone__c,
        Primary_Billing_Contact__r.Account.Name,
        Primary_Billing_Contact__r.MailingStreet,
        Primary_Billing_Contact__r.MailingCity,
        Primary_Billing_Contact__r.MailingState,
        Primary_Billing_Contact__r.MailingPostalCode,
        Primary_Billing_Contact__r.MailingCountry,
        Benefit_Vendor_Referrals__c,
        Clinical_Integration_Services__c,
        Members__c,
        Business_Unit__c,
        Invoiced_Person_Type__c,
        Business_Region__c,
        Payment_Terms__c,
        CurrencyIsoCode,
        Language__c,
        Client_Channel_Segment__c,
        Customer_Type__c,
        Incentives__c,
        Incentives_Description__c
      FROM Account
      WHERE Id = :accountId
    ];

    List<Acct_Rel__c> brokerInfoList = [
      SELECT
        Id,
        Broker_Contact__r.Name,
        Svc_Acct__r.Name,
        Broker_Contact__r.Title,
        Broker_Contact__r.Phone,
        Broker_Contact__r.Fax,
        Broker_Contact__r.Email,
        Broker_Loc_Name__c,
        Broker_Location__c,
        Start_Date__c,
        End_Date__c,
        Broker_Percentage__c,
        Broker_Flat_Rate__c,
        Broker_Location__r.Name,
        Broker_Location__r.Address__c
      FROM Acct_Rel__c
      WHERE
        Benefit_Sponsor__c = :accountId
        AND Relationship_Type__c = 'Broker'
        AND Start_Date__c < TODAY
        AND (End_Date__c = NULL
        OR End_Date__c > TODAY)
    ];

    Map<Id, Mbr_Group__c> groupMap = new Map<Id, Mbr_Group__c>(
      [
        SELECT
          Id,
          Name,
          Name__c,
          Group_Number__c,
          Client_Account__c,
          Client_Account__r.Name,
          Client_Account__r.Company_Tags__c,
          Eligibility_Option__c,
          Allow_Caregiver_Program__c,
          Allow_Geo_Fencing__c,
          Teladoc_Select__c,
          OneAppAccess__c,
          Cross_Billing__c,
          Actual_Copay_May_Be_Less__c,
          Any_Special_Instructions__c,
          Domestic_Country__c,
          Allow_Conversion_to_Retail__c,
          Elig_Dep_Inc_In_File__c,
          Card_Name__c,
          Tri_Brand_with_Logo__c,
          WK_Send_Card_Date__c,
          Card_Template__c,
          Shipping_Class__c,
          WK_Template__c,
          Co_Brand_with_Logo__c,
          Consult_Billing_Method__c,
          Sexual_Health_Opt_Out__c,
          Other_Company_Names__c,
          Client_Account_Location__r.name,
          Plan_Type__c,
          Admin_Line_of_business__c,
          Plan_Category__c,
          Health_Assistant__c,
          Allow_Minor_Registration__c,
          Client_Account_Relationship__r.Line_of_Business__c,
          Migration_Group_Number__c,
          Livongo_Registration_code__c,
          //Livongo_Client_Code__c, **Deprecated**
          LV_Client_Code__c,
          Enable_Livongo_Combined_Eligibility__c,
          MyStrength_Global_Access_Code__c,
          Enable_Chronic_Care_Referrals__c
        FROM Mbr_Group__c
        WHERE Client_Account__c = :accountId AND Id IN :selectedGroupIds
      ]
    );
    List<Mbr_Group_Role__c> roles = [
      SELECT
        Id,
        Name,
        Mbr_Group__c,
        Role_Type__c,
        Source_Account__c,
        Source_Contact__c,
        Source_Account__r.Name,
        Source_Contact__r.Name
      FROM Mbr_Group_Role__c
      WHERE Mbr_Group__c IN :groupMap.keySet()
    ];

    List<Acct_Rel__c> servicingAccounts = [
      SELECT
        Id,
        Name,
        Svc_Acct__r.Name,
        Relationship_Type__c,
        Contract_Type__c,
        Line_of_Business__c,
        Start_Date__c,
        End_Date__c,
        Benefit_Sponsor__r.name,
        lastmodifieddate
      FROM Acct_Rel__c
      WHERE Benefit_Sponsor__c = :accountId
      ORDER BY lastmodifieddate DESC
      LIMIT 100
    ];
    // SFDCHUB-2128: scope benefit accounts to servicing accounts mentioned in group roles
    Set<Id> group_role_svc_acct_ids = new Set<Id>();
    for (Mbr_Group_Role__c tmpMbrGroupRole : roles) {
      group_role_svc_acct_ids.add(tmpMbrGroupRole.Source_Account__c);
    }
    List<Acct_Rel__c> benefitAccounts = [
      SELECT
        Id,
        Name,
        Benefit_Sponsor__r.Name,
        Relationship_Type__c,
        Start_Date__c,
        End_Date__c,
        lastmodifieddate
      FROM Acct_Rel__c
      WHERE
        Svc_Acct__c = :accountId
        AND Benefit_Sponsor__c IN :group_role_svc_acct_ids
      ORDER BY lastmodifieddate DESC
      LIMIT 100
    ];

    // This map contains a key with 'groupid:role' - note all keys are lowercase
    Map<String, Mbr_Group_Role__c> roleMap = new Map<String, Mbr_Group_Role__c>();
    for (Mbr_Group_Role__c r : roles) {
      roleMap.put(r.Mbr_Group__c + ':' + r.Role_Type__c.toLowerCase(), r);
    }

    List<Plan_Specific_Fees__c> allPSFs = new List<Plan_Specific_Fees__c>();
    allPSFs = [
      SELECT
        Id,
        Name,
        Asset__r.Product2.ProductCode,
        Subscription__c,
        Subscription__r.SBQQ__Bundled__c,
        Subscription__r.SBQQ__StartDate__c,
        Subscription__r.Revenue_Effective_Date__c,
        Member_Group__c,
        Group_Number__c,
        Subscription__r.Fee_Type_Formula__c,
        Subscription__r.Fee_Type__c,
        Subscription__r.Current_Membership_Fee__c,
        Current_Membership_Fee__c,
        Product__c,
        Membership_fee__c,
        Subscription__r.SBQQ__Product__r.ProductCode,
        Subscription__r.SBQQ__Product__r.Family,
        Subscription__r.SBQQ__Product__r.Name,
        Subscription__r.Membership_Fee__c,
        Consult_Fee_Mbr_Pd__c,
        Consult_Fee_Plan_Pd__c,
        Subscription__r.Sort_Order__c,
        Subscription__r.CurrencyIsoCode,
        Actual_Copay_May_Be_Less__c,
        Product_Start_Date__c,
        Product_End_Date__c,
        Subscription__r.Bundle_Type__c,
        Asset__r.CurrencyIsoCode,
        Disable_Coaching__c,
        Disable_Teletherapy__c,
        PG__c,
        GM_100_Covered__c,
        MH_100_Covered__c,
        DERM_100_Covered__c,
        Bill_to_Account__c,
        Bill_to_Account__r.Name,
        Bill_To_Account_GUID__c,
        Sold_to_Account__c,
        Sold_to_Account__r.Name,
        Sold_To_Account_GUID__c,
        Payer_Account__c,
        Payer_Account__r.Name,
        Payer_Account_GUID__c,
        USGH_APP_Opt_Out__c,
        GLP_1_Model__c,
        Promotion__c,                       //added for SCDEV-5535
        Subscription__r.Vendor_Partner__c, // Added for SCDEV-5357
        Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name,
        Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Opp_Guid__c
      FROM Plan_Specific_Fees__c
      WHERE Member_Group__c IN :groupMap.keySet()
      ORDER BY Subscription__r.Sort_Order__c
      //TODO: Order By ? Name, then Bundled, add Family column, then name
    ];
    Map<Id, List<Plan_Specific_Fees__c>> PSFbyGroupMap = new Map<Id, List<Plan_Specific_Fees__c>>();
    for (Plan_Specific_Fees__c psf : allPSFs) {
      List<Plan_Specific_Fees__c> psfList;
      if (PSFbyGroupMap.containsKey(psf.Member_Group__c)) {
        psfList = (List<Plan_Specific_Fees__c>) PSFbyGroupMap.get(
          psf.Member_Group__c
        );
      } else {
        psfList = new List<Plan_Specific_Fees__c>();
      }
      psfList.add(psf);
      PSFbyGroupMap.put(psf.Member_Group__c, psfList);
    }

    List<valError> tmpErrors = new List<valError>();

    // Create list of fields that are required when the form is created
    //TODO: Validate Business Unit, Billing Org ID, Does this account receive invoice?, Billing Address, and Business Region
    List<String> accountRequiredFields = new List<String>{
      'Primary_Billing_Contact__c',
      'Account_Type__c', //TODO: 20190210 - SFDCHUB-2115
      //'Report_Sorting__c',
      //'Report_Template__c',
      //'Report_Recipient_Emails__c',
      'Friendly_Account_Name__c',
      'Phone',
      'Account_Manager__c',
      'Primary_Billing_Contact__c',
      'Primary_Billing_Contact_Email__c',
      'Receives_Invoice__c',
      //'Report_Recipient_Emails__c',
      //'Report_Sorting__c',
      //'Report_Template__c',
      'BillingStreet',
      'BillingState',
      'BillingCountry',
      'BillingPostalCode', //TODO: Confirm apex uses this compound field.
      //'Billing_Org_ID__c',
      //'Business_Unit__c',
      'Business_Region__c',
      'Print_Phone__c',
      'Print_URL__c'
    };
    validate(
      accountInfo,
      accountRequiredFields,
      servicingAccounts,
      benefitAccounts,
      tmpErrors
    );

    if (tmpErrors.size() > 0) {
      nasf.errors = tmpErrors;
    } else {
      nasf.errors = null;
    }

    // MAP Results to NASF object
    nasf.general_info = mapGeneralInfo(accountInfo);
    nasf.brokers = mapBrokerList(brokerInfoList);
    nasf.groups = mapGroupInfo(groupMap.values(), PSFbyGroupMap, roleMap);
    nasf.servicing_accounts = mapServiceInfo(servicingAccounts);
    nasf.benefit_accounts = mapBenAccounts(benefitAccounts);
    nasf.reporting_info = mapReportInfo(accountInfo);
    nasf.billing_info = mapBillingInfo(accountInfo, servicingAccounts);

    return nasf;
  }

  private static void validate(
    SObject sObj,
    List<String> fieldLabels,
    List<Acct_Rel__c> serviceAcct,
    List<Acct_Rel__c> benAcct,
    List<valError> errs
  ) {
    // First, look for required fields missing
    for (String fieldLabel : fieldLabels) {
      String objName = sObj.getSObjectType().getDescribe().getName();
      String value = String.valueOf(sObj.get(fieldLabel));
      if (value == null) {
        valError e = new valError();
        e.error_msg = 'Field Required';
        e.field_label = fieldLabel;
        e.src_sfid = sObj.Id;
        Map<String, Schema.SObjectType> global_describe = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = global_describe.get(objName)
          .getDescribe()
          .fields.getMap();
        e.field_name = fieldMap.get(fieldLabel).getDescribe().getLabel();
        errs.add(e);
      }
    }

    Boolean isContractee = false;
    for (Acct_Rel__c acctRel : serviceAcct) {
      if (acctRel.Relationship_Type__c == 'Contractee') {
        isContractee = true;
        break;
      }
    }
    for (Acct_Rel__c bensponRel : benAcct) {
      if (bensponRel.Relationship_Type__c == 'Contractee') {
        isContractee = true;
        break;
      }
    }
    if (!isContractee) {
      valError e = new valError();
      e.error_msg = 'At least one Contractee Relationship is Required';
      e.field_label = null;
      e.src_sfid = sObj.Id;
      errs.add(e);
    }

    /*if (benAcct == null || benAcct.size() == 0) {
            valError e = new valError();
            e.error_msg = 'At least one Benefit Sponsor Account Relationships is Required';
            e.field_label = null;
            e.src_sfid = sObj.Id;
            errs.add(e);
        }*/
    /*if (serviceAcct == null || serviceAcct.size() == 0) {
            valError e = new valError();
            e.error_msg = 'At least one Servicing Account Relationship is Required';
            e.field_label = null;
            e.src_sfid = sObj.Id;
            errs.add(e);
        }else{
        }*/
  }

  private static List<brokerInfo> mapBrokerList(List<Acct_Rel__c> rels) {
    List<brokerInfo> brokerItems = new List<brokerInfo>();
    for (Acct_Rel__c ar : rels) {
      brokerInfo b = new brokerInfo();
      b.name = ar.Broker_Contact__r.Name;
      b.title = ar.Broker_Contact__r.Title;
      b.phone = ar.Broker_Contact__r.Phone;
      b.fax = ar.Broker_Contact__r.Fax;
      b.email = ar.Broker_Contact__r.Email;
      b.account_name = ar.Svc_Acct__r.Name;
      b.loc_name = ar.Broker_Loc_Name__c;
      b.loc_id = ar.Broker_Location__r.Name;
      b.loc_address = ar.Broker_Location__r.Address__c;
      b.start_date = ar.Start_Date__c;
      b.end_date = ar.End_Date__c;
      b.commission_flat_rate = ar.Broker_Flat_Rate__c;
      b.commission_pct = ar.Broker_Percentage__c;
      brokerItems.add(b);
    }
    return brokerItems;
  }

  private static List<svcAccountInfo> mapServiceInfo(List<Acct_Rel__c> rels) {
    List<svcAccountInfo> svcAccounts = new List<svcAccountInfo>();
    for (Acct_Rel__c ar : rels) {
      svcAccountInfo newSvcAccount = new svcAccountInfo();
      newSvcAccount.rel_name = ar.Name;
      newSvcAccount.svc_account_name = nullToBlank(ar.Svc_Acct__r.Name);
      newSvcAccount.ben_spon_account_name = nullToBlank(
        ar.Benefit_Sponsor__r.name
      );
      newSvcAccount.svc_account_role = nullToBlank(ar.Relationship_Type__c);
      newSvcAccount.svc_contract_type = nullToBlank(ar.Contract_Type__c);
      newSvcAccount.line_of_business = nullToBlank(ar.Line_of_Business__c);
      newSvcAccount.start_date = ar.Start_Date__c;
      newSvcAccount.end_date = ar.End_Date__c;
      /*if (ar.Relationship_Type__c == 'Contractee') {
                newSvcAccount.finance_category = nullToBlank(ar.Finance_Category__c);
            }*/
      svcAccounts.add(newSvcAccount);
    }
    return svcAccounts;
  }

  private static List<benefitSponsorInfo> mapBenAccounts(
    List<Acct_Rel__c> rels
  ) {
    List<benefitSponsorInfo> benAccounts = new List<benefitSponsorInfo>();
    for (Acct_Rel__c ar : rels) {
      benefitSponsorInfo newBenAccount = new benefitSponsorInfo();
      newBenAccount.rel_name = ar.Name;
      newBenAccount.ben_account_name = nullToBlank(ar.Benefit_Sponsor__r.Name);
      newBenAccount.svc_account_role = nullToBlank(ar.Relationship_Type__c);
      newBenAccount.start_date = ar.Start_Date__c;
      newBenAccount.end_date = ar.End_Date__c;
      benAccounts.add(newBenAccount);
    }
    return benAccounts;
  }

  private static reportingInfo mapReportInfo(Account accountInfo) {
    reportingInfo ri = new reportingInfo();

    ri.report_template = accountInfo.Report_Template__c;
    ri.report_sorting = accountInfo.Report_Sorting__c;
    ri.monthly_recipients = accountInfo.Report_Recipient_Emails__c;

    return ri;
  }

  private static billingInfo mapBillingInfo(
    Account accountInfo,
    List<Acct_Rel__c> servicingAccounts
  ) {
    billingInfo bi = new billingInfo();
    // TODO: Fill out billing here when billing contact is available
    //bi.contact_name = accountInfo.Primary_Billing_Contact__r.Name;
    bi.contact_name = accountInfo.Primary_Billing_Contact__r.Name;
    bi.recipient_account_name = accountInfo.Primary_Billing_Contact__r.Account.Name;
    bi.address_street = accountInfo.Primary_Billing_Contact__r.MailingStreet;
    bi.address_city = accountInfo.Primary_Billing_Contact__r.MailingCity;
    bi.address_state = accountInfo.Primary_Billing_Contact__r.MailingState;
    bi.address_postalcode = accountInfo.Primary_Billing_Contact__r.MailingPostalCode;
    bi.address_country = accountInfo.Primary_Billing_Contact__r.MailingCountry;
    bi.contact_email = accountInfo.Primary_Billing_Contact_Email__c;
    bi.finance_category = accountInfo.Client_Channel_Segment__c;
    //bi.delivery = ' * tbd * ';
    /*for (Acct_Rel__c r : servicingAccounts) {
            if (r.Relationship_Type__c != null && r.Relationship_Type__c.toLowerCase() == 'contractee') {
                bi.finance_category = r.Finance_Category__c;
                break;
            }

        }*/

    //bi.finance_sub_category = ' * tbd * ';
    bi.group_name = ' * tbd - same as parent grp? * ';
    bi.payment_terms = accountInfo.Payment_Terms__c;
    bi.invoice_currency = accountInfo.currencyIsoCode;
    bi.invoice_language = accountInfo.language__c;
    return bi;
  }

  private static generalInfo mapGeneralInfo(Account accountInfo) {
    generalInfo gi = new generalInfo();
    gi.legal_name = accountInfo.Name;
    gi.friendly_name = accountInfo.Friendly_Account_Name__c;
    gi.account_guid = accountInfo.GUID__c;
    gi.address_street = accountInfo.BillingStreet;
    gi.address_city = accountInfo.BillingCity;
    gi.address_state = accountInfo.BillingState;
    gi.address_postalcode = accountInfo.BillingPostalCode;
    gi.address_country = accountInfo.BillingCountry;
    gi.account_manager_name = accountInfo.Account_Manager__r.Name;
    gi.sales_agent_name = accountInfo.Owner.Name;
    gi.account_type = accountInfo.Account_Type__c;
    gi.Invoiced_Person_Type = accountInfo.Invoiced_Person_Type__c;
    gi.receive_invoice = accountInfo.Receives_Invoice__c;
    gi.recipient_billing_org_id = accountInfo.Billing_Org_ID__c;
    gi.printPhone = accountInfo.Print_Phone__c;
    gi.printUrl = accountInfo.Print_URL__c;
    gi.special_instructions_implementations = accountInfo.Special_Instructions_for_Implementatio__c;
    gi.phone = accountInfo.Phone;
    gi.benefit_vendor_referrals = accountInfo.Benefit_Vendor_Referrals__c;
    gi.clinical_integration = accountInfo.Clinical_Integration_Services__c;
    gi.incentives = accountInfo.incentives__c;
    gi.incentives_description = accountInfo.Incentives_Description__c;
    gi.orgHierarchyId = accountInfo.Hierarchy__c;
    gi.customerType = accountInfo.Customer_Type__c;
    gi.business_region = accountInfo.Business_Region__c;
    return gi;
  }

  private static List<groupInfo> mapGroupInfo(
    List<Mbr_Group__c> grpList,
    Map<Id, List<Plan_Specific_Fees__c>> PSFbyGroupMap,
    Map<String, Mbr_Group_Role__c> roleMap
  ) {
    List<groupInfo> grps = new List<groupInfo>();
    for (Mbr_Group__c grp : grpList) {
      groupInfo grpinfo = new groupInfo();

      grpinfo.id = grp.Name;
      grpinfo.sfid = grp.Id;
      grpinfo.name = grp.Name__c;
      grpinfo.legacy_id = nullToBlank(grp.Group_Number__c);
      grpinfo.reimbursement_method = nullToBlank(grp.Consult_Billing_Method__c);
      /* SCDEV-4686 [Starts] */
      grpinfo.oneApp_Access = grp.OneAppAccess__c;
      /* SCDEV-4686 [Starts] */
      Mbr_Group_Role__c role = roleMap.get(grp.Id + ':' + 'payer');
      grpinfo.payer = (role == null ? '' : role.Source_Account__r.Name);

      role = roleMap.get(grp.Id + ':' + 'benefit sponsor');
      grpinfo.benefit_sponsor = (role == null
        ? ''
        : role.Source_Account__r.Name);

      role = roleMap.get(grp.Id + ':' + 'contractee');
      grpinfo.contractee = (role == null ? '' : role.Source_Account__r.Name);

      grpinfo.company_tags =
        nullToBlank(grp.Other_Company_Names__c) +
        nullToBlank(grp.Client_Account__r.Company_Tags__c);
      grpinfo.eligibility_option = grp.Eligibility_Option__c;
      grpinfo.dependents_included = grp.Elig_Dep_Inc_In_File__c;
      grpinfo.allow_conversion = grp.Allow_Conversion_to_Retail__c;

      grpinfo.allow_sexual_health = grp.Sexual_Health_Opt_Out__c;
      grpinfo.allow_geofencing = grp.Allow_Geo_Fencing__c;
      grpinfo.allow_caregiver = grp.Allow_Caregiver_Program__c;
      grpinfo.teladoc_select = grp.Teladoc_Select__c;
      grpinfo.Health_Assistant = grp.Health_Assistant__c;
      grpinfo.Allow_Minor_Registration = grp.Allow_Minor_Registration__c;
      grpinfo.wk_group_name = grp.Name__c;
      grpinfo.wk_client_name_on_card = grp.Card_Name__c;
      grpinfo.wk_tri_branded = grp.Tri_Brand_with_Logo__c;
      //grpinfo.wk_send_card = nullToBlank(String.valueOf(grp.WK_Send_Card_Date__c));
      if (grp.Card_Template__c == null) {
        grpinfo.wk_send_card = false;
      } else {
        grpinfo.wk_send_card = (grp.Card_Template__c == 'Logo Card' ||
          grp.Card_Template__c == 'STND Card')
          ? true
          : false;
      }
      grpinfo.wk_co_branded = grp.Co_Brand_with_Logo__c;
      grpinfo.wk_mail_class = grp.Shipping_Class__c;
      grpinfo.Cross_Billing = grp.Cross_Billing__c;
      grpinfo.wk_print_or_less = grp.Actual_Copay_May_Be_Less__c;
      grpinfo.wk_template = grp.WK_Template__c;
      grpinfo.wk_special_instructions = grp.Any_Special_Instructions__c;
      grpinfo.client_location = grp.client_account_location__r.name;
      grpinfo.Domestic_Country = grp.Domestic_Country__c;
      grpinfo.plan_category = grp.plan_category__c;
      grpinfo.plan_type = grp.plan_type__c;
      grpinfo.admin_line_of_business = grp.Admin_Line_of_business__c;
      grpinfo.rel_line_of_business = grp.Client_Account_Relationship__r.Line_of_Business__c ==
        null
        ? 'N/A'
        : grp.Client_Account_Relationship__r.Line_of_Business__c;
      grpinfo.migration_group_number = grp.Migration_Group_Number__c;
      grpinfo.lvn_reg_code = grp.Livongo_Registration_code__c;
      //grpinfo.lvn_client_code = grp.Livongo_Client_Code__c;
      grpinfo.lvn_client_code = grp.LV_Client_Code__c;
      grpinfo.enable_lvn_combine_eligibility = grp.Enable_Livongo_Combined_Eligibility__c;
      grpinfo.mystrength_global_access_Code = grp.MyStrength_Global_Access_Code__c;
      grpinfo.enable_chronic_care_referrals = grp.Enable_Chronic_Care_Referrals__c;
      //grpinfo.business_category = grp.Relationship_Business_Category__c;

      List<psfInfo> psfInfoByGroup = new List<psfInfo>();
      if (PSFbyGroupMap.containsKey(grp.Id)) {
        List<Plan_Specific_Fees__c> psflist = PSFbyGroupMap.get(grp.Id);
        for (Plan_Specific_Fees__c psf : psflist) {
          psfInfo pi = new psfInfo();
          //pi.family = psf.Product_Under_Contract__r.ProductFamily;
          pi.id = psf.Id;
          pi.name = nullToBlank(psf.Name);
          pi.product_name = nullToBlank(psf.Product__c);
          pi.family = nullToBlank(psf.Subscription__r.SBQQ__Product__r.Family);
          pi.product_code = nullToBlank(
            psf.Subscription__r.SBQQ__Product__r.ProductCode
          );
          pi.assetProductCode = nullToBlank(psf.Asset__r.Product2.ProductCode);
          pi.subId = psf.Subscription__c;
          pi.pepm_included = Boolean.valueOf(
            psf.Subscription__r.SBQQ__Bundled__c
          );
          //pi.start_date = nullToBlank(String.valueOf(psf.Subscription__r.SBQQ__StartDate__c));
          pi.start_date = nullToBlank(
            String.valueOf(psf.Product_Start_Date__c)
          );
          pi.product_end_date = nullToBlank(
            String.valueOf(psf.Product_End_Date__c)
          );
          pi.revenue_effective_date = nullToBlank(
            String.valueOf(psf.Subscription__r.Revenue_Effective_Date__c)
          );
          pi.fee_type = nullToBlank(psf.Subscription__r.Fee_Type__c);
          pi.membership_fee = psf.Subscription__r.current_Membership_fee__c;
          pi.CurrencyIsoCode = psf.Subscription__r.CurrencyIsoCode;
          pi.actual_Copay_May_Be_Less = psf.Actual_Copay_May_Be_Less__c;
          pi.consult_fee_mbr_pd = psf.Consult_Fee_Mbr_Pd__c;
          pi.consult_fee_plan_pd = psf.Consult_Fee_Plan_Pd__c;
          pi.bundleType = nullToBlank(psf.Subscription__r.Bundle_Type__c);
          pi.AssetCurrency = psf.Asset__r.CurrencyIsoCode;
          pi.coaching = psf.Disable_Coaching__c;
          pi.teletherapy = psf.Disable_Teletherapy__c;
          pi.pg = psf.PG__c;
          pi.gmCovered = psf.GM_100_Covered__c;
          pi.mhCovered = psf.MH_100_Covered__c;
          pi.dermCovered = psf.DERM_100_Covered__c;
          pi.billToAcc = nullToBlank(psf.Bill_to_Account__r.Name);
          pi.soldToAcc = nullToBlank(psf.Sold_to_Account__r.Name);
          pi.payerAcc = nullToBlank(psf.Payer_Account__r.Name);
          pi.billToAccGuid = nullToBlank(psf.Bill_To_Account_GUID__c);
          pi.soldToAccGuid = nullToBlank(psf.Sold_To_Account_GUID__c);
          pi.payerAccGuid = nullToBlank(psf.Payer_Account_GUID__c);
          pi.oppName = nullToBlank(
            psf.Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Name
          );
          pi.oppGuid = nullToBlank(
            psf.Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Opp_Guid__c
          );
          pi.appOptOut = psf.USGH_APP_Opt_Out__c;
          pi.glp1Model = nullToBlank(psf.GLP_1_Model__c);
          psfInfoByGroup.add(pi);
          pi.vendorPartner = nullToBlank(psf.Subscription__r.Vendor_Partner__c); // Added for SCDEV-5357
          pi.promotion = nullToBlank(psf.Promotion__c);                          //added for SCDEV-5535

        }
      }
      grpinfo.structures = psfInfoByGroup;
      grps.add(grpinfo);
    }
    return grps;
  }

  global class Mg2_NASFInfo {
    public List<valError> errors { get; set; }
    public List<brokerInfo> brokers { get; set; }
    public List<groupInfo> groups { get; set; }
    public List<svcAccountInfo> servicing_accounts { get; set; }
    public List<benefitSponsorInfo> benefit_accounts { get; set; }
    public reportingInfo reporting_info { get; set; }
    public generalInfo general_info { get; set; }
    public billingInfo billing_info { get; set; }
  }

  global class psfInfo {
    public String id { get; set; }
    public String name { get; set; }
    public String family { get; set; }
    public String product_name { get; set; }
    public String product_code { get; set; }
    public Boolean pepm_included { get; set; }
    public String start_date { get; set; }
    public String product_end_date { get; set; }
    public String revenue_effective_date { get; set; }
    public String fee_type { get; set; }
    public Decimal membership_fee { get; set; }
    public String CurrencyIsoCode { get; set; }
    public Boolean actual_Copay_May_Be_Less { get; set; }
    public String assetProductCode { get; set; }
    public String subId { get; set; }
    public Decimal consult_fee_mbr_pd { get; set; }
    public Decimal consult_fee_plan_pd { get; set; }
    public String bundleType { get; set; }
    public String AssetCurrency { get; set; }
    public Boolean coaching { get; set; }
    public Boolean teletherapy { get; set; }
    public Boolean pg { get; set; }
    public Boolean gmCovered { get; set; }
    public Boolean mhCovered { get; set; }
    public Boolean dermCovered { get; set; }
    public String billToAcc { get; set; }
    public String soldToAcc { get; set; }
    public String payerAcc { get; set; }
    public String billToAccGuid { get; set; }
    public String soldToAccGuid { get; set; }
    public String payerAccGuid { get; set; }
    public String oppName { get; set; }
    public String oppGuid { get; set; }
    public Boolean appOptOut { get; set; }
    public String glp1Model { get; set; }
    public String vendorPartner{ get; set; } // Added for SCDEV-5357
    public String promotion { get; set; }           ////added for SCDEV-5535
  }

  global class groupInfo {
    public List<psfInfo> structures { get; set; }

    public String id { get; set; }
    public String sfid { get; set; }

    public String name { get; set; }
    public String reimbursement_method { get; set; }
    public String payer { get; set; }
    public String benefit_sponsor { get; set; }
    public String contractee { get; set; }
    public String legacy_id { get; set; }

    public String company_tags { get; set; }

    public String eligibility_option { get; set; }
    public Boolean dependents_included { get; set; }
    public Boolean allow_conversion { get; set; }
    // public String ccr_ccda { get; set; }
    public Boolean allow_sexual_health { get; set; }
    public Boolean allow_geofencing { get; set; }
    public Boolean allow_caregiver { get; set; }
    public Boolean teladoc_select { get; set; }
    public Boolean Health_Assistant { get; set; }
    public Boolean Allow_Minor_Registration { get; set; }

    public String wk_group_name { get; set; }
    public String wk_client_name_on_card { get; set; }
    public String wk_tri_branded { get; set; }
    public Boolean wk_send_card { get; set; }
    public String wk_co_branded { get; set; }
    public String wk_mail_class { get; set; }
    // public String wk_print_url { get; set; }
    public String oneApp_Access { get; set; }
    public Boolean Cross_Billing { get; set; }
    public Boolean wk_print_or_less { get; set; }
    // public String wk_phone { get; set; }
    // public String wk_language { get; set; }
    public String wk_template { get; set; }
    public String wk_special_instructions { get; set; }
    public String migration_group_number { get; set; }
    public String client_location { get; set; }
    public String Domestic_Country { get; set; }
    public String plan_type { get; set; }
    public String plan_category { get; set; }
    public String Admin_Line_of_business { get; set; }
    public String rel_line_of_business { get; set; }
    public String lvn_reg_code { get; set; }
    public String lvn_client_code { get; set; }
    public Boolean enable_lvn_combine_eligibility { get; set; }
    public String mystrength_global_access_code { get; set; }
    public String enable_chronic_care_referrals { get; set; }
    //public String business_category { get; set; }
  }

  global class brokerInfo {
    public String name { get; set; }
    public String title { get; set; }
    public String phone { get; set; }
    public String fax { get; set; }
    public String email { get; set; }
    public String account_name { get; set; }
    public String loc_name { get; set; }
    public String loc_id { get; set; }
    public String loc_address { get; set; }
    public Date start_date { get; set; }
    public Date end_date { get; set; }
    public Double commission_pct { get; set; }
    public Double commission_flat_rate { get; set; }
  }

  global class generalInfo {
    public String legal_name { get; set; }
    public String friendly_name { get; set; }
    public String account_guid { get; set; }
    public String address_street { get; set; }
    public String address_city { get; set; }
    public String address_state { get; set; }
    public String address_postalcode { get; set; }
    public String address_country { get; set; }
    // consider address string as a courtesy to the web service consumer

    public String phone { get; set; }
    public String account_manager_name { get; set; }
    public String account_owner_name { get; set; }
    public String sales_agent_name { get; set; }
    public String account_type { get; set; }
    public String invoiced_person_type { get; set; }
    public String receive_invoice { get; set; }
    public String recipient_billing_org_id { get; set; }
    public String printPhone { get; set; }
    public String printUrl { get; set; }
    public String special_instructions_implementations { get; set; }
    public String orgHierarchyId { get; set; }
    public String customerType { get; set; }

    public Boolean benefit_vendor_referrals { get; set; }
    public Boolean clinical_integration { get; set; }
    public Boolean incentives { get; set; }
    public String incentives_description { get; set; }
    public String business_region { get; set; }
  }

  global class billingInfo {
    public String contact_name { get; set; }
    public String recipient_account_name { get; set; }
    public String address_street { get; set; }
    public String address_city { get; set; }
    public String address_state { get; set; }
    public String address_postalcode { get; set; }
    public String address_country { get; set; }
    public String contact_email { get; set; }
    //public String delivery { get; set; }
    public String finance_category { get; set; }
    //public String finance_sub_category { get; set; }
    public String group_name { get; set; }
    public String payment_terms { get; set; }
    public String invoice_currency { get; set; }
    public String invoice_language { get; set; }
    //public String business_region { get; set; }
  }

  global class reportingInfo {
    public String report_template { get; set; }
    public String report_sorting { get; set; }
    public String monthly_recipients { get; set; }
  }

  global class svcAccountInfo {
    public String rel_name { get; set; }
    public String svc_account_name { get; set; }
    public String ben_spon_account_name { get; set; }
    public String svc_account_role { get; set; }
    public String svc_contract_type { get; set; }
    public String line_of_business { get; set; }
    //public String finance_category { get; set; }
    public Date start_date { get; set; }
    public Date end_date { get; set; }
  }

  global class benefitSponsorInfo {
    public String rel_name { get; set; }
    public String ben_account_name { get; set; }
    public String svc_account_role { get; set; }
    public Date start_date { get; set; }
    public Date end_date { get; set; }
  }

  global class valError {
    public String src_sfid { get; set; }
    public String error_msg { get; set; }
    public String field_label { get; set; }
    public String field_name { get; set; }
  }

  // Returns empty string if null, otherwise returns string
  private static String nullToBlank(String orig) {
    return orig == null ? '' : orig;
  }
}