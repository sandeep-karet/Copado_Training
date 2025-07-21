@RestResource(urlMapping='/Sfdc2Eds/*')
global class EdsMwUtil {
  @HttpGet
  global static String doGet() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    String group_guid = req.requestURI.substring(
      req.requestURI.lastIndexOf('/') + 1
    );
    return gatherFlowData(group_guid);
  }

  public static String gatherFlowData(String group_guid) {
    MwResponseShape tmpMrs = new MwResponseShape();

    // Member group will provide next step
    List<Mbr_Group__c> groups_found = [
      SELECT
        id,
        name,
        Card_Name__c,
        Teladoc_Select__c,
        Active_Date__c,
        Group_Number__c,
        guid__c,
        Logo_Tag_ID__c,
        Client_Account__c,
        Name__c,
        Eligibility_Option__c,
        Consult_Billing_Method__c,
        Allow_Conversion_to_Retail__c,
        Allow_Geo_Fencing__c,
        OneAppAccess__c,
        Cross_Billing__c,
        Sexual_Health_Opt_Out__c,
        Allow_Caregiver_Program__c,
        WK_Send_Card_Date__c,
        Shipping_Class__c,
        WK_Template__c,
        Migration_Group_Number__c,
        Elig_Dep_Inc_In_File__c,
        Livongo_Registration_code__c,
        //Livongo_Client_Code__c, **Deprecated**
        LV_Client_Code__c,
        Enable_Livongo_Combined_Eligibility__c,
        MyStrength_Global_Access_Code__c,
        Enable_Chronic_Care_Referrals__c
      FROM Mbr_Group__c
      WHERE guid__c = :group_guid
    ];

    // size of 0 means group does not exist
    if (groups_found.size() > 0) {
      tmpMrs.member_group = groups_found[0];

      // Check for Payer/BSP
      List<Mbr_Group_Role__c> mg_roles = [
        SELECT id, mbr_group__c, source_account__c, Role_Type__c
        FROM mbr_group_role__c
        WHERE
          mbr_group__c = :tmpMrs.member_group.Id
          AND Role_Type__c IN ('Payer', 'Benefit Sponsor')
        ORDER BY createddate ASC
      ];

      // we order the soql above in ascending order so latest version of payer/bsp overrides whatever other roles may exist
      Map<String, Mbr_Group_Role__c> mg_roles_map = new Map<String, Mbr_Group_Role__c>();
      for (Mbr_Group_Role__c tmpMgr : mg_roles) {
        mg_roles_map.put(tmpMgr.Role_Type__c, tmpMgr);
      }
      // If there is a payer role lookup their account
      if (mg_roles_map.containsKey('Payer')) {
        Id payer_account_id = mg_roles_map.get('Payer').source_account__c;
        tmpMrs.payer = fetchAccountInfo(payer_account_id);
      }

      // If there is a bsp role lookup
      if (mg_roles_map.containsKey('Benefit Sponsor')) {
        Id bsp_account_id = mg_roles_map.get('Benefit Sponsor')
          .source_account__c;
        tmpMrs.bsp = fetchAccountInfo(bsp_account_id);
      }
      // Contractee Info
      tmpMrs.contractee = fetchAccountInfo(
        tmpMrs.member_group.client_account__c
      );

      if (
        tmpMrs.bsp ==
        null // FALLBACK Default is contractee
      )
        tmpMrs.bsp = tmpMrs.contractee;

      // Account Relationship Info
      //if(tmpMrs.bsp != null) {
      List<Acct_Rel__c> tmp_acct_rels = [
        SELECT
          id,
          name,
          Relationship_Type__c,
          Contract_Type__c,
          Start_Date__c,
          End_Date__c,
          Broker_Contact__c,
          Broker_Flat_Rate__c,
          Broker_Percentage__c,
          Broker_Location__c,
          Svc_Acct__c,
          Benefit_Sponsor__c
        FROM Acct_Rel__c
        WHERE
          Svc_Acct__c = :tmpMrs.contractee.Id
          //and Benefit_Sponsor__c = :tmpMrs.bsp.Id
          AND Relationship_Type__c = 'Contractee'
          AND Contract_Type__c = 'Direct'
        //and svc_acct__r.account_type__c = 'Employer'
        ORDER BY createddate DESC
      ];

      // If we have no contractee/direct relationship then we cannot continue
      if (tmp_acct_rels.size() > 0) {
        tmpMrs.contractee_rel = tmp_acct_rels[0];
      }
      //}

      List<Plan_Specific_Fees__c> tmp_psfs = [
        SELECT
          id,
          Member_Group__c,
          Product__c,
          Name,
          Product_Start_Date__c,
          PG__c,
          GM_100_Covered__c,
          MH_100_Covered__c,
          DERM_100_Covered__c,
          Product_End_Date__c,
          Subscription__c,
          Current_Membership_Fee__c,
          Consult_Fee_Mbr_Pd__c,
          Consult_Fee_Plan_Pd__c,
          Bill_to_Account__c,
          Bill_To_Account_GUID__c,
          Payer_Account__c,
          Payer_Account_GUID__c,
          Sold_to_Account__c,
          Sold_To_Account_GUID__c,
          Sold_to_Account__r.Name,
          Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Opp_Guid__c,
          Subscription__r.SBQQ__Product__r.Family,
          Subscription__r.SBQQ__Product__r.ProductCode,
          Subscription__r.Revenue_Effective_Date__c,
          Subscription__r.SBQQ__Product__r.StockKeepingUnit,
          Subscription__r.SBQQ__QuoteLine__r.SBQQ__Product__c,
          Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__c,
          Actual_Copay_May_Be_Less__c,
          USGH_APP_Opt_Out__c,
          Subscription__r.Vendor_Partner__c, // Added for 5357
          Subscription__r.Bundle_Type__c,
          Asset_Name__c,
          PSF_ProductCode__c
        FROM Plan_Specific_Fees__c
        WHERE Member_Group__c = :tmpMrs.member_group.Id
      ];

      Set<Id> subscription_ids = new Set<Id>();
      for (Plan_Specific_Fees__c tmpPsf : tmp_psfs) {
        subscription_ids.add(tmpPsf.Subscription__c);
      }

      tmpMrs.subscriptions = [
        SELECT
          id,
          SBQQ__ProductName__c,
          Name,
          SBQQ__Quantity__c,
          Membership_Fee__c,
          Consult_Type__c,
          Current_Membership_Fee__c,
          Fee_Type__c,
          SBQQ__Contract__c,
          SBQQ__QuoteLine__c,
          SBQQ__QuoteLine__r.SBQQ__Product__c
        FROM SBQQ__Subscription__c
        WHERE id IN :subscription_ids
      ];

      // Inventory the member group psfs
      Plan_Specific_Fees__c psf_emo = null;
      Plan_Specific_Fees__c psf_bd_emp = null;
      for (Plan_Specific_Fees__c tmpPsf : tmp_psfs) {
        if (tmpPsf.Subscription__r.SBQQ__Product__r.ProductCode == 'EMO') {
          psf_emo = tmpPsf;
          tmpMrs.psf_emo = tmpPsf;
        }
        if (
          tmpPsf.Subscription__r.SBQQ__Product__r.ProductCode ==
          'BD-USEMP-BUNDLE'
        ) {
          psf_bd_emp = tmpPsf;
          tmpMrs.psf_bd_emp = tmpPsf;
        }
      }

      // If both psf do not exist then remove ALL bundled items in BD-USEMP-BUNDLE from psf list
      // The tricky part of this is locating the bd-usemp-bundle from the emo if it is missing
      if (psf_emo == null && psf_bd_emp == null) {
        // no emo/bundle issues
        tmpMrs.psfs = tmp_psfs;
      } else {
        if (psf_emo != null && psf_bd_emp != null) {
          // If we have both emo/bundle then copy membership_fee__c from bundle to emo and remove bundle psf
          //psf_emo.Membership_fee__c = psf_bd_emp.Membership_fee__c; //TODO: find a way to override this value before transmission
          List<Plan_Specific_Fees__c> filtered_psf = new List<Plan_Specific_Fees__c>();
          for (Plan_Specific_Fees__c tmpPsf : tmp_psfs) {
            if (tmpPsf.Id != psf_bd_emp.Id)
              filtered_psf.add(tmpPsf);
          }
          tmpMrs.psfs = filtered_psf;
        } else {
          Id target_quote = null;
          if (psf_emo == null) {
            target_quote = psf_bd_emp.Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__c;
          }
          if (
            psf_bd_emp ==
            null // Without the bundle we must find the quote based on the emo quoteline
          )
            target_quote = psf_emo.Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__c;

          // Find the quoteline defining what the bundle should be
          List<SBQQ__QuoteLine__c> bd_usemp_quotelines = [
            SELECT
              id,
              SBQQ__Product__c,
              SBQQ__Product__r.ProductCode,
              Membership_Fee__c
            FROM SBQQ__QuoteLine__c
            WHERE
              SBQQ__Quote__c = :target_quote
              AND SBQQ__Product__r.ProductCode = 'BD-USEMP-BUNDLE'
          ];
          if (bd_usemp_quotelines.size() > 0) {
            // Find all product options for the bundle
            List<SBQQ__ProductOption__c> bundled_options = [
              SELECT id, SBQQ__ProductCode__c
              FROM SBQQ__ProductOption__c
              WHERE
                SBQQ__ConfiguredSKU__c = :bd_usemp_quotelines[0]
                  .SBQQ__Product__c
                AND SBQQ__Bundled__c = TRUE
            ];

            Set<String> bundled_product_codes = new Set<String>();
            bundled_product_codes.add('BD-USEMP-BUNDLE');
            for (SBQQ__ProductOption__c tmpPo : bundled_options)
              bundled_product_codes.add(tmpPo.SBQQ__ProductCode__c);

            System.debug('Bundle product codes: ' + bundled_product_codes);
            // A missing emo/bundle psf is an incomplete member group so remove all bundle items
            List<Plan_Specific_Fees__c> filtered_psf = new List<Plan_Specific_Fees__c>();
            for (Plan_Specific_Fees__c tmpPsf : tmp_psfs) {
              if (
                !bundled_product_codes.contains(
                  tmpPsf.Subscription__r.SBQQ__Product__r.ProductCode
                )
              )
                filtered_psf.add(tmpPsf);
            }
            System.Debug('Filtered psfs: ' + filtered_psf);
            System.Debug('*** BUNDLE/EMO error (psfs have been filtered) ***');
            //[2019-07-25] - RGoyal opted to send blank psf if emo/bundle info messing.
            tmpMrs.psfs = new List<Plan_Specific_Fees__c>();
            //tmpMrs.psfs = filtered_psf;
          } else {
            // at this point we have no bundle on the quote and emo is standalone.  *** SHOULD NOT HAPPEN ***
            System.debug(
              '*** BUNDLE/EMO error (no quoteline for bd-bundle) ***'
            );
            tmpMrs.psfs = new List<Plan_Specific_Fees__c>();
          }
        }
      }
    }
    //} // If contractee
    String outgoing_json = FlowJsonGenerator.generateJSONContent(tmpMrs);
    AcctGrpConParsing_Item__c tmp_item = new AcctGrpConParsing_Item__c(
      Item_key__c = group_guid,
      Item_data__c = outgoing_json,
      Source__c = 'FLOW',
      batch_key__c = String.valueOf(DateTime.now().gettime())
    );
    insert tmp_item;
    return outgoing_json;
  }
  private static Account fetchAccountInfo(Id account_id) {
    List<Account> tmpAccts = [
      SELECT
        id,
        guid__c,
        source__c,
        Friendly_Account_Name__c,
        Primary_Billing_Contact__r.Name,
        Primary_Billing_Contact__r.FirstName,
        Primary_Billing_Contact__r.LastName,
        Primary_Billing_Contact_Email__c,
        Primary_Billing_Contact_Phone__c,
        Primary_Billing_Contact__r.Account.Name,
        Account_Manager__r.FirstName,
        Account_Manager__r.LastName,
        Account_Manager__r.username,
        Account_Manager__r.Name,
        Primary_Billing_Contact__r.MailingStreet,
        Primary_Billing_Contact__r.MailingCity,
        Primary_Billing_Contact__r.MailingState,
        Primary_Billing_Contact__r.MailingPostalCode,
        Primary_Billing_Contact__r.MailingCountry,
        name,
        BillingStreet,
        BillingCity,
        BillingState,
        BillingPostalCode,
        BillingCountry,
        Owner.FirstName,
        Owner.LastName,
        Owner.username,
        Owner.email,
        Report_Template__c,
        Report_Sorting__c,
        Payment_Terms__c,
        Report_Recipient_Emails__c,
        Account_Type__c,
        Allow_Flow__c,
        Client_Channel_Segment__c,
        Account_Sub_Type__c,
        CurrencyISOCode,
        Language__c,
        Business_Region__c,
        Print_Url__c,
        Print_Phone__c,
        Invoiced_Person_Type__c
      FROM Account
      WHERE id = :account_id
    ];
    if (tmpAccts.size() > 0) {
      if (tmpAccts[0].Primary_Billing_Contact__c != null) {
        tmpAccts[0]
          .Primary_Billing_Contact__r.MailingState = AddressUtils.convertStateAbbrev(
          tmpAccts[0].Primary_Billing_Contact__r.MailingState
        );
        tmpAccts[0]
          .Primary_Billing_Contact__r.MailingCountry = AddressUtils.convertCountryAbbrev(
          tmpAccts[0].Primary_Billing_Contact__r.MailingCountry
        );
      }
      tmpAccts[0].BillingState = AddressUtils.convertStateAbbrev(
        tmpAccts[0].BillingState
      );
      tmpAccts[0].BillingCountry = AddressUtils.convertCountryAbbrev(
        tmpAccts[0].BillingCountry
      );
      return tmpAccts[0];
    } else {
      return null;
    }
  }
}