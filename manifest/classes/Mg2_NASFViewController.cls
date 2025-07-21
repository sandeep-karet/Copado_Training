public with sharing class Mg2_NASFViewController {
  public List<PDFItem> asf { get; set; }
  public Id accountId { get; private set; }

  public Mbr_Group__c filterGroup { get; set; }
  public Set<Id> selectedGroupIds { get; set; }
  public String currDateTime { get; set; }

  //private Boolean isValid {get; set;}
  public Boolean showGroupSelect { get; set; }
  public String renderMode { get; set; }
  public String version { get; set; }

  public Mg2_NASFViewController() {
    PageReference page = System.currentPageReference();

    // First time setup
    filterGroup = new Mbr_Group__c();
    accountId = page.getParameters().get('aid');
    String render = apexpages.currentpage().getparameters().get('renderAs');
    renderMode = render;

    showGroupSelect = true;
    currDateTime = String.valueOf(DateTime.now());

    selectedGroupIds = new Set<Id>();

    // Get latest version from Metadata
    NASF_Metadata__mdt md = [SELECT Id, Value__c, Label FROM NASF_Metadata__mdt WHERE Label = 'NASF Version'];
    version = md.Value__c;
    Cookie idCookie = page.getCookies().get('g:' + accountId);
    String idValString;
    idValString = apexpages.currentpage().getparameters().get('Mbr_Group__c');

    if (idValString == null) {
      if (idCookie == null) {
        idValString = page.getParameters().get('ids');
      } else {
        idValString = idCookie.getValue();
      }
    }

    if (!String.isBlank(idValString)) {
      for (String s : idValString.split(',')) {
        selectedGroupIds.add(Id.valueOf(s));
      }
    }

    Mg2_NASFHelper.Mg2_NASFInfo rawNASFInfo = Mg2_NASFHelper.getNasfInfoByAccountId(
      accountId,
      selectedGroupIds
    );
    if (rawNASFInfo.errors != null) {
      asf = new List<PDFItem>();
      List<InfoRows> rows = new List<InfoRows>();
      PDFItem ai = new PDFItem();
      ai.infoType = 'detail';
      ai.header =
        'Errors in NASF Data for account: ' +
        rawNASFInfo.general_info.legal_name;
      asf.add(ai);
      for (Mg2_NASFHelper.valError e : rawNASFInfo.errors) {
        if (e.field_name == null) {
          ai.addRow('Error: ', e.error_msg);
        } else {
          ai.addRow('Field: ' + e.field_name, e.error_msg);
        }
      }
    } else {
      asf = loadAsfItems(rawNASFInfo);
    }
  }

  // Loads from web service nasfInfo object
  private List<PDFItem> loadAsfItems(Mg2_NASFHelper.Mg2_NASFInfo n) {
    List<PDFItem> result = new List<PDFItem>();
    List<InfoRows> rows = new List<InfoRows>();

    PDFItem ai = new PDFItem();
    ai.header = 'NEW ACCOUNT SETUP FORM: ' + n.general_info.legal_name;
    ai.infoType = 'major';
    result.add(ai);

    ai = new PDFItem();
    ai.header = 'General Information';
    ai.infoType = 'detail';

    //ai.addRow('NASF Version', version);
    ai.addRow('Client Legal Name', n.general_info.legal_name);
    ai.addRow('Client Friendly Name', n.general_info.friendly_name);

    ai.addRow('Client Account GUID', n.general_info.account_guid);
    ai.addRow(
      'Address',
      n.general_info.address_street +
        '<br />' +
        n.general_info.address_city +
        ', ' +
        n.general_info.address_state +
        '<br />' +
        n.general_info.address_postalcode
    );
    //result.add(new InfoRows('Client Legal Name',n.general_info.address_city));
    ai.addRow('Phone', n.general_info.phone);
    ai.addRow('Account Owner', n.general_info.sales_agent_name);
    ai.addRow('Account Manager', n.general_info.account_manager_name);
    ai.addRow('Account Business Type', n.general_info.account_type); // SFDCHUB-2128
    ai.addRow('Invoiced Person Type', n.general_info.invoiced_person_type);
    ai.addRow('Customer Type', n.general_info.customerType);
    ai.addRow('Business Region', n.general_info.business_region);

    ai.addRow(
      'Does this account receive the invoice?',
      boolToCheck(n.general_info.receive_invoice)
    );
    ai.addRow('Organization Hierachy ID', n.general_info.orgHierarchyId);
    ai.addRow(
      'Recipient Billing Org Id',
      n.general_info.recipient_billing_org_id
    );
    ai.addRow('Print Phone', n.general_info.printPhone);
    ai.addRow('Print Url', n.general_info.printUrl);

    ai.addRow(
      'Benefit Vendor Referrals',
      boolToCheck(n.general_info.benefit_vendor_referrals)
    );
    ai.addRow(
      'Clinical Integration Services',
      String.valueOf(n.general_info.clinical_integration)
    );
    ai.addRow('Incentives', String.valueOf(n.general_info.incentives));
    ai.addRow(
      'Incentives - Description',
      String.valueOf(n.general_info.incentives_description)
    );
    ai.addRow(
      'Special Instructions to Implementations',
      n.general_info.special_instructions_implementations
    );

    result.add(ai);

    // Loop through brokers and add to result
    for (Mg2_NASFHelper.brokerInfo bk : n.brokers) {
      ai = new PDFItem();
      ai.header = 'Broker Contact Information: ' + bk.name;
      ai.infoType = 'detail';
      rows = new List<InfoRows>();

      ai.addRow('Contact Name', bk.name);
      ai.addRow('Title', bk.title);

      ai.addRow('Phone', bk.phone);
      ai.addRow('Fax', bk.fax);

      //result.add(new InfoRows('Client Legal Name',n.general_info.address_city));
      ai.addRow('Email', bk.email);
      ai.addRow('Account Name', bk.account_name);

      ai.addRow('Location Name', bk.loc_name);
      ai.addRow('Location ID', bk.loc_id);
      ai.addRow('Location Address', bk.loc_address); //TODO: may need \n to <br />

      ai.addRow(
        'Start Date',
        bk.start_date == null ? '' : bk.start_date.format()
      );
      ai.addRow('End Date', bk.end_date == null ? '' : bk.end_date.format());

      ai.addRow('Commission %', String.valueOf(bk.commission_pct));
      ai.addRow(
        'Commission Flat Rate',
        String.valueOf(bk.commission_flat_rate)
      );

      result.add(ai);
    }

    ai = new PDFItem();
    ai.header = 'BILLING AND REPORTING INFO';
    ai.infoType = 'major';
    result.add(ai);

    //TODO: Check if account receives invoice first
    ai = new PDFItem();
    rows = new List<InfoRows>();
    ai.header = 'Billing';
    ai.infoType = 'detail';

    ai.addRow('Primary Billing Contact Name', n.billing_info.contact_name);
    ai.addRow(
      'Invoice Recipient Account',
      n.billing_info.recipient_account_name
    );
    ai.addRow(
      'Primary Billing Contact - Street',
      n.billing_info.address_street
    );
    ai.addRow('Primary Billing Contact - City', n.billing_info.address_city);
    ai.addRow(
      'Primary Billing Contact - State / Province',
      n.billing_info.address_state
    );
    ai.addRow(
      'Primary Billing Contact - ZIP / Postal Code',
      n.billing_info.address_postalcode
    );
    ai.addRow(
      'Primary Billing Contact - Country',
      n.billing_info.address_country
    );
    ai.addRow('Primary Billing Contact - Email', n.billing_info.contact_email);
    //ai.addRow('Invoice Delivery', n.billing_info.delivery);
    ai.addRow('Finance Category', n.billing_info.finance_category);
    //ai.addRow('Finance Sub Category', n.billing_info.finance_sub_category);
    ai.addRow('Payment Terms', n.billing_info.payment_terms);
    ai.addRow('Invoice Currency', n.billing_info.invoice_currency);
    ai.addRow('Invoice Language', n.billing_info.invoice_language);

    result.add(ai);

    ai = new PDFItem();
    rows = new List<InfoRows>();
    ai.header = 'Reporting';
    ai.infoType = 'detail';

    ai.addRow('Report Template', n.reporting_info.report_template);
    ai.addRow('Report Sorting', n.reporting_info.report_sorting);
    ai.addRow('Monthly Report Recipients', n.reporting_info.monthly_recipients);

    result.add(ai);

    ai = new PDFItem();
    ai.header = 'ACCOUNT RELATIONSHIPS';
    ai.infoType = 'major';
    result.add(ai);

    ai = new PDFItem();

    ai.header = 'Servicing Accounts';
    ai.infoType = 'table';

    List<String> tblheaders = new List<String>{
      'Svc. Account',
      'Svc. Account Role',
      'Svc. Contract Type',
      'Line of Business',
      'Ben. Sponsor Account',
      'Start Date',
      'End Date'
    };
    List<List<String>> tblrows = new List<List<String>>();
    for (Mg2_NASFHelper.svcAccountInfo sai : n.servicing_accounts) {
      String startDate = (sai.start_date == null
        ? ''
        : sai.start_date.format());
      String endDate = (sai.end_date == null ? '' : sai.end_date.format());
      String[] row = new List<String>{
        nullToBlank(sai.svc_account_name),
        nullToBlank(sai.svc_account_role),
        nullToBlank(sai.svc_contract_type),
        nullToBlank(sai.line_of_business),
        nullToBlank(sai.ben_spon_account_name),
        startDate,
        endDate
      };
      tblrows.add(row);
    }

    ai.rows = tblrows;
    ai.headers = tblheaders;
    result.add(ai);

    ai = new PDFItem();
    tblrows = new List<List<String>>();
    ai.header = 'Benefit Sponsor Accounts';
    ai.infoType = 'table';

    tblheaders = new List<String>{
      'Acct. Rel. Name',
      'Benefit Sponsor Account',
      'Svc. Account Role',
      'Start Date',
      'End Date'
    };
    tblrows = new List<List<String>>();
    for (Mg2_NASFHelper.benefitSponsorInfo bei : n.benefit_accounts) {
      String startDate = (bei.start_date == null
        ? ''
        : bei.start_date.format());
      String endDate = (bei.end_date == null ? '' : bei.end_date.format());

      String[] row = new List<String>{
        bei.rel_name,
        bei.ben_account_name,
        bei.svc_account_role,
        startDate,
        endDate
      };
      tblrows.add(row);
    }

    ai.rows = tblrows;
    ai.headers = tblheaders;
    result.add(ai);

    for (Mg2_NASFHelper.groupInfo grp : n.groups) {
      String grpNameWithId = grp.name;
      if (!String.isBlank(grp.legacy_id)) {
        grpNameWithId += ' [' + grp.legacy_id + ']';
      }

      ai = new PDFItem();
      ai.header = grp.id+': ' + grpNameWithId;
      ai.infoType = 'major';
      result.add(ai);

      ai = new PDFItem();
      rows = null;
      ai.header = 'Group Information';
      ai.infoType = 'table';
      tblheaders = new List<String>{
        //'Legacy Id',
        'Consult Billing Method',
        'Payer',
        'Benefit Sponsor',
        'Contractee'
      };
      tblrows = new List<List<String>>();
      List<String> row = new List<String>{
        //grp.legacy_id,
        grp.reimbursement_method,
        grp.payer,
        grp.benefit_sponsor,
        grp.contractee
      };
      tblrows.add(row);
      ai.rows = tblrows;
      ai.headers = tblheaders;
      result.add(ai);

  // Started Benefit Structures Section
      ai = new PDFItem();

      ai.header = 'Benefit Structures';
      ai.infoType = 'table';
    // Adding header to Benefit Structures table
      tblheaders = new List<String>{
        'Product Family',
        'Product Name',
        'Start Date',
        'End Date',
        'Bundle Type',
        'Membership Fee Type',
        'Membership Fee',
        'Member Visit Fee',
        'Client Visit Fee',
        'Print or Less',
        'USGH APP Opt-Out',
        'Vendor Partner',   // Added for SCDEV-5357
        'GLP-1 Model',
        'Promotion'         //added for SCDEV-5535
      };

      tblrows = new List<List<String>>();
      /*
            List<Product_Asset__mdt> prodAssetList = [SELECT Id, MasterLabel, Asset_Product_Code__c, Product_Label__c FROM Product_Asset__mdt];
            Map<String, Map<String, String>> prodAssetMap = new Map<String, Map<String, String>>(); 
            for (Product_Asset__mdt pa: prodAssetList) {
                List<String> assetProductCode = pa.Asset_Product_Code__c.split(',');
                List<String> assetLabel = pa.Product_Label__c.split(',');
                Map<String, String> codeLabelMap = new Map<String, String>(); 
                for (Integer i = 0; i < assetProductCode.size(); i++) {
                    codeLabelMap.put(assetProductCode[i], assetLabel[i]);
                }
                prodAssetMap.put(pa.MasterLabel, codeLabelMap);
            }
            
            List<Mg2_NASFHelper.psfInfo> standardPSF = new List<Mg2_NASFHelper.psfInfo>();
            List<Mg2_NASFHelper.psfInfo> nonStandardPSF = new List<Mg2_NASFHelper.psfInfo>();
            
            
            
            for (Mg2_NASFHelper.psfInfo psf : grp.structures) {
                if (prodAssetMap.containsKey(psf.product_code.toUpperCase())) {
                    nonStandardPSF.add(psf);
                } else {
                    standardPSF.add(psf);
                }
            }
            
            for (String prodCode: prodAssetMap.keySet()) {
                Map<String, List<Mg2_NASFHelper.psfInfo>> psfMap = new Map<String, List<Mg2_NASFHelper.psfInfo>>();
                for (Mg2_NASFHelper.psfInfo psf: nonStandardPSF) {
                    if (psf.product_code.toUpperCase() == prodCode) {
                        if (psfMap.containsKey(psf.subId)) {
                            psfMap.get(psf.subId).add(psf);
                            psfMap.put(psf.subId, (psfMap.get(psf.subId)));
                        } else {
                            List<Mg2_NASFHelper.psfInfo> newList = new List<Mg2_NASFHelper.psfInfo>();
                            newList.add(psf);
                            psfMap.put(psf.subId, newList);
                        }
                    }
                }
                
                for (String subId: psfMap.keySet()) {
                    String membershipFee = '';
                    if (psfMap.get(subId)[0].pepm_included) {
                        membershipFee = 'Included';
                    } else {
                        membershipFee = currency(psfMap.get(subId)[0].membership_fee, psfMap.get(subId)[0].currencyIsoCode);
                    }
                    row = new String[]{psfMap.get(subId)[0].family, psfMap.get(subId)[0].product_name, psfMap.get(subId)[0].start_date, 
                        psfMap.get(subId)[0].product_end_date, psfMap.get(subId)[0].fee_type, membershipFee, '', '',  String.ValueOf(psfMap.get(subId)[0].actual_Copay_May_Be_Less)
                        };
                            tblrows.add(row);
                    
                    for (Mg2_NASFHelper.psfInfo psf: psfMap.get(subId)) {
                        String astCode = psf.assetProductCode.toUpperCase();
                        for (String astInfo: prodAssetMap.get(prodCode).keyset()) {
                            if (astCode == astInfo) {
                                row = new String[]{ psf.family, prodAssetMap.get(prodCode).get(astInfo), psf.start_date, psf.product_end_date, '', '',
                                currency(psf.consult_fee_mbr_pd, psf.currencyIsoCode),
                                currency(psf.consult_fee_plan_pd, psf.currencyIsoCode)
                                };
                                    tblrows.add(row);
                            }
                        }
                    }
                }
            }
            
            for (Mg2_NASFHelper.psfInfo psf: standardPSF) {
                String memberFee, clientFee;
                if (psf.consult_fee_mbr_pd != null && psf.consult_fee_plan_pd != null) {
                    memberFee = currency(psf.consult_fee_mbr_pd,psf.currencyIsoCode);
                    clientFee = currency(psf.consult_fee_plan_pd,psf.currencyIsoCode);
                } else {
                    memberFee = '';
                    clientFee = '';
                }
                String membershipFee = '';
                if (psf.pepm_included) {
                    membershipFee = 'Included';
                } else {
                    membershipFee = currency(psf.membership_fee, psf.currencyIsoCode);
                }
                
                row = new String[]{psf.family, psf.product_name, psf.start_date, psf.product_end_date, psf.fee_type, 
                    membershipFee, memberFee, clientFee,  String.ValueOf(psf.actual_Copay_May_Be_Less)
                    };
                        tblrows.add(row);
            }
            */

      Map<String, List<Mg2_NASFHelper.psfInfo>> psfBhMap = new Map<String, List<Mg2_NASFHelper.psfInfo>>();
      Map<String, List<Mg2_NASFHelper.psfInfo>> psfMhMap = new Map<String, List<Mg2_NASFHelper.psfInfo>>();
      Map<String, List<Mg2_NASFHelper.psfInfo>> psfVpcMap = new Map<String, List<Mg2_NASFHelper.psfInfo>>();
      Map<String, List<Mg2_NASFHelper.psfInfo>> psfGeneralMap = new Map<String, List<Mg2_NASFHelper.psfInfo>>();
    // Adding rows to table to display values respictive to column
      for (Mg2_NASFHelper.psfInfo psf : grp.structures) {
        String memberFee, clientFee;
        String prodCode = psf.product_code.toUpperCase();

        if (psfGeneralMap.containsKey(psf.subId)) {
          psfGeneralMap.get(psf.subId).add(psf);
          psfGeneralMap.put(psf.subId, (psfGeneralMap.get(psf.subId)));
        } else {
          List<Mg2_NASFHelper.psfInfo> newList = new List<Mg2_NASFHelper.psfInfo>();
          newList.add(psf);
          psfGeneralMap.put(psf.subId, newList);
        }
        if (prodCode == 'BH' || (prodCode == 'MYSTR3' && !psf.teletherapy)) {
          if (psfBhMap.containsKey(psf.subId)) {
            psfBhMap.get(psf.subId).add(psf);
            psfBhMap.put(psf.subId, (psfBhMap.get(psf.subId)));
          } else {
            List<Mg2_NASFHelper.psfInfo> newList = new List<Mg2_NASFHelper.psfInfo>();
            newList.add(psf);
            psfBhMap.put(psf.subId, newList);
          }
        } else if (prodCode == 'MH') {
          if (psfMhMap.containsKey(psf.subId)) {
            psfMhMap.get(psf.subId).add(psf);
            psfMhMap.put(psf.subId, (psfMhMap.get(psf.subId)));
          } else {
            List<Mg2_NASFHelper.psfInfo> newList = new List<Mg2_NASFHelper.psfInfo>();
            newList.add(psf);
            psfMhMap.put(psf.subId, newList);
          }
        } else if (prodCode == 'PRIM360CARE') {
          if (psfVpcMap.containsKey(psf.subId)) {
            psfVpcMap.get(psf.subId).add(psf);
            psfVpcMap.put(psf.subId, (psfVpcMap.get(psf.subId)));
          } else {
            List<Mg2_NASFHelper.psfInfo> newList = new List<Mg2_NASFHelper.psfInfo>();
            newList.add(psf);
            psfVpcMap.put(psf.subId, newList);
          }
        } else {
          if (
            psf.consult_fee_mbr_pd != null &&
            psf.consult_fee_plan_pd != null
          ) {
            String feeCurrency = psf.AssetCurrency != null
              ? psf.AssetCurrency
              : psf.currencyIsoCode;
            memberFee = currency(psf.consult_fee_mbr_pd, feeCurrency);
            clientFee = currency(psf.consult_fee_plan_pd, feeCurrency);
          } else {
            memberFee = '';
            clientFee = '';
          }
          String membershipFee = '';
          if (psf.pepm_included) {
            membershipFee = 'Included';
          } else {
            membershipFee = currency(psf.membership_fee, psf.currencyIsoCode);
          }
          if (psf.product_code == 'MYSTR3') {
            //Adding values to row
            row = new List<String>{
              psf.family,
              psf.product_name + ' (Teletherapy Disabled)',
              psf.start_date,
              psf.product_end_date,
              psf.bundleType,
              psf.fee_type,
              membershipFee,
              memberFee,
              clientFee,
              String.ValueOf(psf.actual_Copay_May_Be_Less),
              String.ValueOf(psf.appOptOut),
              psf.VendorPartner,
              psf.glp1Model,
              psf.promotion           //added for SCDEV-5535
            };
          } else {
            row = new List<String>{
              psf.family,
              psf.product_name,
              psf.start_date,
              psf.product_end_date,
              psf.bundleType,
              psf.fee_type,
              membershipFee,
              memberFee,
              clientFee,
              String.valueOf(psf.actual_Copay_May_Be_Less),
              String.ValueOf(psf.appOptOut),
                    psf.VendorPartner,
              psf.glp1Model,
              psf.promotion               //added for SCDEV-5535
            };
          }
          tblrows.add(row);
        }
      }
      for (String subId : psfBhMap.keySet()) {
        String membershipFee = '';
        if (psfBhMap.get(subId)[0].pepm_included) {
          membershipFee = 'Included';
        } else {
          membershipFee = currency(
            psfBhMap.get(subId)[0].membership_fee,
            psfBhMap.get(subId)[0].currencyIsoCode
          );
        }
        if (psfBhMap.get(subId)[0].product_code == 'MYSTR3') {
          row = new List<String>{
            psfBhMap.get(subId)[0].family,
            psfBhMap.get(subId)[0].product_name + ' (Teletherapy Enabled)',
            psfBhMap.get(subId)[0].start_date,
            psfBhMap.get(subId)[0].product_end_date,
            psfBhMap.get(subId)[0].bundleType,
            psfBhMap.get(subId)[0].fee_type,
            membershipFee,
            '',
            '',
            String.ValueOf(psfBhMap.get(subId)[0].actual_Copay_May_Be_Less),
            String.ValueOf(psfBhMap.get(subId)[0].appOptOut), 
            psfBhMap.get(subId)[0].VendorPartner,    // Added for SCDEV-5357
            psfBhMap.get(subId)[0].glp1Model,
            psfBhMap.get(subId)[0].promotion               //added for SCDEV-5535

          };
        } else {
          row = new List<String>{
            psfBhMap.get(subId)[0].family,
            psfBhMap.get(subId)[0].product_name,
            psfBhMap.get(subId)[0].start_date,
            psfBhMap.get(subId)[0].product_end_date,
            psfBhMap.get(subId)[0].bundleType,
            psfBhMap.get(subId)[0].fee_type,
            membershipFee,
            '',
            '',
            String.ValueOf(psfBhMap.get(subId)[0].actual_Copay_May_Be_Less),
            String.ValueOf(psfBhMap.get(subId)[0].appOptOut),
            psfBhMap.get(subId)[0].vendorPartner,  // Added for SCDEV-5357
            psfBhMap.get(subId)[0].glp1Model,
            psfBhMap.get(subId)[0].promotion               //added for SCDEV-5535
          };
        }

        tblrows.add(row);
        for (Mg2_NASFHelper.psfInfo psf : psfBhMap.get(subId)) {
          String bhCode = psf.assetProductCode.toUpperCase();
          String feeCurrency = psf.AssetCurrency != null
            ? psf.AssetCurrency
            : psf.currencyIsoCode;
          if (bhCode == 'BHP1T') {
            row = new List<String>{
              psf.family,
              'Psychiatrist 1st Visit Fee',
              psf.start_date,
              psf.product_end_date,
              '',
              '',
              '',
              currency(psf.consult_fee_mbr_pd, feeCurrency),
              currency(psf.consult_fee_plan_pd, feeCurrency),
              '',
              '',
                    psf.vendorPartner,  // Added for SCDEV-5357
              '',
              psf.promotion               //added for SCDEV-5535
            };
            tblrows.add(row);
          } else if (bhCode == 'BHPOT') {
            row = new List<String>{
              psf.family,
              'Psychiatrist Ongoing Visit Fee',
              psf.start_date,
              psf.product_end_date,
              '',
              '',
              '',
              currency(psf.consult_fee_mbr_pd, feeCurrency),
              currency(psf.consult_fee_plan_pd, feeCurrency),
              '',
                    '',          // Added for SCDEV-5357
                    psf.vendorPartner,  // Added for SCDEV-5357
              '',
              psf.promotion               //added for SCDEV-5535
            };
            tblrows.add(row);
          } else if (bhCode == 'BHNPT') {
            row = new List<String>{
              psf.family,
              'Therapist Ongoing Visit Fee',
              psf.start_date,
              psf.product_end_date,
              '',
              '',
              '',
              currency(psf.consult_fee_mbr_pd, feeCurrency),
              currency(psf.consult_fee_plan_pd, feeCurrency),
              '',
                  '',    // Added for SCDEV-5357
                    psf.vendorPartner,  // Added for SCDEV-5357
              '',
              psf.promotion               //added for SCDEV-5535
            };
            tblrows.add(row);
          }
        }
      }

      for (String subId : psfMhMap.keySet()) {
        String membershipFee = '';
        if (psfMhMap.get(subId)[0].pepm_included) {
          membershipFee = 'Included';
        } else {
          membershipFee = currency(
            psfMhMap.get(subId)[0].membership_fee,
            psfMhMap.get(subId)[0].currencyIsoCode
          );
        }
        row = new List<String>{
          psfMhMap.get(subId)[0].family,
          psfMhMap.get(subId)[0].product_name,
          psfMhMap.get(subId)[0].start_date,
          psfMhMap.get(subId)[0].product_end_date,
          psfMhMap.get(subId)[0].bundleType,
          psfMhMap.get(subId)[0].fee_type,
          membershipFee,
          '',
          '',
          String.ValueOf(psfMhMap.get(subId)[0].actual_Copay_May_Be_Less),
          '',
              psfMhMap.get(subId)[0].vendorPartner,  // Added for SCDEV-5357
          '',
          psfMhMap.get(subId)[0].promotion               //added for SCDEV-5535
        };
        tblrows.add(row);
        for (Mg2_NASFHelper.psfInfo psf : psfMhMap.get(subId)) {
          String feeCurrency = psf.AssetCurrency != null
            ? psf.AssetCurrency
            : psf.currencyIsoCode;
          String bhCode = psf.assetProductCode.toUpperCase();
          if (bhCode == 'BHP1T') {
            row = new List<String>{
              psf.family,
              'Psychiatrist 1st Visit Fee',
              psf.start_date,
              psf.product_end_date,
              '',
              '',
              '',
              currency(psf.consult_fee_mbr_pd, feeCurrency),
              currency(psf.consult_fee_plan_pd, feeCurrency),
              '',
              '',
                    psf.vendorPartner,  // Added for SCDEV-5357
              '',
              psf.promotion               //added for SCDEV-5535
            };
            tblrows.add(row);
          } else if (bhCode == 'BHPOT') {
            row = new List<String>{
              psf.family,
              'Psychiatrist Ongoing Visit Fee',
              psf.start_date,
              psf.product_end_date,
              '',
              '',
              '',
              currency(psf.consult_fee_mbr_pd, feeCurrency),
              currency(psf.consult_fee_plan_pd, feeCurrency),
              '',
              '',
                    psf.vendorPartner,  // Added for SCDEV-5357
              '',
              psf.promotion               //added for SCDEV-5535
            };
            tblrows.add(row);
          } else if (bhCode == 'BHPOOT') {
            row = new List<String>{
              psf.family,
              'Psychologist Ongoing Visit Fee',
              psf.start_date,
              psf.product_end_date,
              '',
              '',
              '',
              currency(psf.consult_fee_mbr_pd, feeCurrency),
              currency(psf.consult_fee_plan_pd, feeCurrency),
              '',
              '',
                    psf.vendorPartner,  // Added for SCDEV-5357
              '',
              psf.promotion               //added for SCDEV-5535
            };
            tblrows.add(row);
          } else if (bhCode == 'BHNPT') {
            row = new List<String>{
              psf.family,
              'Therapist Ongoing Visit Fee',
              psf.start_date,
              psf.product_end_date,
              '',
              '',
              '',
              currency(psf.consult_fee_mbr_pd, feeCurrency),
              currency(psf.consult_fee_plan_pd, feeCurrency),
              '',
              '',
                    psf.vendorPartner,  // Added for SCDEV-5357
              '',
              psf.promotion               //added for SCDEV-5535
            };
            tblrows.add(row);
          }
        }
      }

      ai.rows = tblrows;
      ai.headers = tblheaders;
      result.add(ai);
      // END Benefit Structures Section


      ai = new PDFItem();

      ai.header = 'Benefit Structures - Primary 360 Care';
      ai.infoType = 'table';

      tblheaders = new List<String>{
        'Product Family',
        'Product Name',
        'Start Date',
        'End Date',
        'Bundle Type',
        'Membership Fee Type',
        'Membership Fee',
        'Member Visit Fee',
        'Client Visit Fee',
        'Print or Less',
        'PG',
        'GM 100% Covered',
        'MH 100% Covered',
        'DERM 100% Covered'
      };

      tblrows = new List<List<String>>();

      for (String subId : psfVpcMap.keySet()) {
        String membershipFee = '';
        if (psfVpcMap.get(subId)[0].pepm_included) {
          membershipFee = 'Included';
        } else {
          membershipFee = currency(
            psfVpcMap.get(subId)[0].membership_fee,
            psfVpcMap.get(subId)[0].currencyIsoCode
          );
        }
        row = new List<String>{
          psfVpcMap.get(subId)[0].family,
          psfVpcMap.get(subId)[0].product_name,
          psfVpcMap.get(subId)[0].start_date,
          psfVpcMap.get(subId)[0].product_end_date,
          psfVpcMap.get(subId)[0].bundleType,
          psfVpcMap.get(subId)[0].fee_type,
          membershipFee,
          '',
          '',
          String.ValueOf(psfVpcMap.get(subId)[0].actual_Copay_May_Be_Less),
          String.ValueOf(psfVpcMap.get(subId)[0].pg),
          String.ValueOf(psfVpcMap.get(subId)[0].gmCovered),
          String.ValueOf(psfVpcMap.get(subId)[0].mhCovered),
          String.ValueOf(psfVpcMap.get(subId)[0].dermCovered)
        };
        tblrows.add(row);
        for (Mg2_NASFHelper.psfInfo psf : psfVpcMap.get(subId)) {
          String feeCurrency = psf.AssetCurrency != null
            ? psf.AssetCurrency
            : psf.currencyIsoCode;
          String bhCode = psf.assetProductCode.toUpperCase();
          if (bhCode == 'NEWPATCF') {
            row = new List<String>{psf.family,'Primary Care Initial Visit Fee',psf.start_date,psf.product_end_date,'','','',
              currency(psf.consult_fee_mbr_pd, feeCurrency),currency(psf.consult_fee_plan_pd, feeCurrency), '','','', '', ''};
            tblrows.add(row);
          } else if (bhCode == 'PRIMCARECF') {
            row = new List<String>{psf.family,'Primary Care Ongoing Visit Fee', psf.start_date, psf.product_end_date,'','','',
            currency(psf.consult_fee_mbr_pd, feeCurrency),currency(psf.consult_fee_plan_pd, feeCurrency),'','','','',''};
            tblrows.add(row);
          } else if (bhCode == 'PRIMCAREACF') {
            row = new List<String>{psf.family,'Primary Care Annual Checkup Visit Fee',psf.start_date,psf.product_end_date,'','','',
            currency(psf.consult_fee_mbr_pd, feeCurrency),currency(psf.consult_fee_plan_pd, feeCurrency),'','','','',''};
            tblrows.add(row);
          }
          else if (bhCode == 'PRIMCAREFCF') {
            row = new List<String>{ psf.family,'Primary Care Initial Flex Visit Fee',psf.start_date,psf.product_end_date,
              '','','',currency(psf.consult_fee_mbr_pd, feeCurrency),currency(psf.consult_fee_plan_pd, feeCurrency),
              '','','','','' };
            tblrows.add(row);
          }
        }
      }

      ai.rows = tblrows;
      ai.headers = tblheaders;
      result.add(ai);

      ai = new PDFItem();

      ai.header = 'Product Account Information';
      ai.infoType = 'table';

      tblheaders = new List<String>{
        'Product Family',
        'Product Name',
        'Bill To Account',
        'Bill To Acc GUID',
        'Sold To Account',
        'Sold To Acc GUID',
        'Payer Account',
        'Payer Acc GUID',
        'Opportunity Name',
        'Opportunity GUID'
      };

      tblrows = new List<List<String>>();

      for (String subId : psfGeneralMap.keySet()) {
        row = new List<String>{
          psfGeneralMap.get(subId)[0].family,
          psfGeneralMap.get(subId)[0].product_name,
          psfGeneralMap.get(subId)[0].billToAcc,
          formatGuid(psfGeneralMap.get(subId)[0].billToAccGuid),
          psfGeneralMap.get(subId)[0].soldToAcc,
          formatGuid(psfGeneralMap.get(subId)[0].soldToAccGuid),
          psfGeneralMap.get(subId)[0].payerAcc,
          formatGuid(psfGeneralMap.get(subId)[0].payerAccGuid),
          psfGeneralMap.get(subId)[0].oppName,
          formatGuid(psfGeneralMap.get(subId)[0].oppGuid)
        };
        tblrows.add(row);
      }

      ai.rows = tblrows;
      ai.headers = tblheaders;
      result.add(ai);

      ai = new PDFItem();
      rows = new List<InfoRows>();
      ai.header = 'Additional Information: ' + grpNameWithId;
      ai.infoType = 'subdetail';

      ai.addRow('Company Tags', grp.company_tags);
      ai.addRow('Client Account Location', grp.client_location);
      ai.addRow('Domestic Country', grp.Domestic_Country);
      //Below values will be deprecated later for Contract Path LOB functionality
      //ai.addRow('Relationship Line of Business', grp.rel_line_of_business);
      //ai.addRow('Business Category', grp.business_category);
      ai.addRow('Admin Line of Business', grp.admin_line_of_business);
      ai.addRow('Plan Category', grp.plan_category);
      ai.addRow('Plan Type', grp.plan_type);
      ai.addRow('Eligibility Option', grp.eligibility_option);
      ai.addRow('Dependents Included', boolToCheck(grp.dependents_included));
      ai.addRow('Allow Retail Conversion', boolToCheck(grp.allow_conversion));
      //ai.addRow('CCR/CCDA', grp.ccr_ccda);
      ai.addRow('Allow Sexual Health', boolToCheck(grp.allow_sexual_health));
      ai.addRow('Allow Geofencing', boolToCheck(grp.allow_geofencing));
      ai.addRow('Allow Caregiver Program', boolToCheck(grp.allow_caregiver));
      ai.addRow('Teladoc Select', boolToCheck(grp.teladoc_select));
      ai.addRow('Health Assistant', boolToCheck(grp.Health_Assistant));
      ai.addRow(
        'Allow Minor Registration',
        boolToCheck(grp.Allow_Minor_Registration)
      );

      ai.addRow('OneApp Access', grp.oneApp_Access);
      system.debug(
        'grp.oneApp_Access ::' +
          grp.oneApp_Access +
          ' :: '
      );
      ai.addRow('Cross Billing', boolToCheck(grp.Cross_Billing));

      ai.addRow(
        'Enable Livongo Combined Eligibility',
        boolToCheck(grp.enable_lvn_combine_eligibility)
      );
      ai.addRow('Livongo Registration Code', grp.lvn_reg_code);
      ai.addRow('LV Client Code', grp.lvn_client_code);
      ai.addRow(
        'MyStrength Global Access Code',
        grp.mystrength_global_access_code
      );
      ai.addRow(
        'Enable Chronic Care Referrals',
        grp.enable_chronic_care_referrals
      );

      ai.addRow('Migration Group Number', grp.migration_group_number);
      ai.addRow('Special Instructions', grp.wk_special_instructions);

      result.add(ai);

      ai = new PDFItem();
      rows = new List<InfoRows>();
      ai.header = 'Welcome Kit: ' + grpNameWithId;
      ai.infoType = 'subdetail';

      ai.addRow('Client Name for Card:', grp.wk_client_name_on_card);
      ai.addRow('Tri-Branded with Logo', boolToCheck(grp.wk_tri_branded));
      ai.addRow('Send Card', boolToCheck(grp.wk_send_card));
      ai.addRow('Co-Branded with Logo', boolToCheck(grp.wk_co_branded));
      ai.addRow('Mail Class', grp.wk_mail_class);
      //ai.addRow('Print URL', grp.wk_print_url);
      //ai.addRow('Print or Less', boolToCheck(grp.wk_print_or_less));
      //ai.addRow('Print Phone', grp.wk_phone);
      //ai.addRow('Welcome Kit Language', grp.wk_language);
      ai.addRow('Print Template ID #', grp.wk_template);

      result.add(ai);
      // end group loop
    }
    return result;
  }

  // Generic PDF section, can contain detail or a table
  public class PDFItem {
    public String infoType { get; set; }
    public String header { get; set; }
    public List<InfoRows> infoRows { get; set; }
    public List<String> headers { get; set; }
    public List<List<String>> rows { get; set; }

    public PDFItem() {
      infoRows = new List<InfoRows>();
    }

    public void addRow(String key, String val) {
      InfoRows row = new InfoRows(key, val, infoRows.size());
      infoRows.add(row);
    }
  }

  // Generic row of information (name/value pairs)
  public class InfoRows {
    public InfoRows(String label, String val, Integer ix) {
      name = label;
      value = val;
      index = ix;
    }
    public String name { get; set; }
    public String value { get; set; }
    public Integer index { get; set; }
  }

  private String boolToCheck(String val) {
    Boolean boolVal = false;
    if (val != null) {
      boolVal = (val.toLowerCase() == 'true' || val.toLowerCase() == 'yes');
    }
    return boolToCheck(boolVal);
  }

  private String boolToCheck(Boolean val) {
    // another option would be to use an outputField...
    if (val == null) {
      val = false;
    }
    return val
      ? '<img height="13px" src="/resource/1531253479000/CheckChecked" />'
      : '<img height="13px" src="/resource/1531268306000/CheckUncheckedGrey" />';
  }

  private String currency(Decimal i, String currencyIsoCode) {
    String num = String.valueOf(i);
    String s = (Decimal.valueOf(num == null || num.trim() == '' ? '0' : num)
        .setScale(2) + 0.001)
      .format();
    return currencyIsoCode + ' ' + s.substring(0, s.length() - 1);
  }

  private String nullToBlank(String s) {
    return (s == null ? '' : s);
  }

  private String formatGuid(String g) {
    if (g != null && g != '') {
      return g.left(9) +
        '\n' +
        g.substring(9, 18) +
        '\n' +
        g.substring(18, 27) +
        '\n' +
        g.right(9);
    } else {
      return g;
    }
  }

  public class prodAssetObj {
    public List<String> assetCode { get; set; }
    public List<String> label { get; set; }
    public prodAssetObj(List<String> assetCode, List<String> label) {
      this.assetCode = assetCode;
      this.label = label;
    }
  }
}