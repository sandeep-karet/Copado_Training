public with sharing class F1BPsfParser extends F1BBaseParser {
  public class PSFData {
    public String ProductCode { get; set; }
    public String ProductVisitType { get; set; }
    public DateTime ProductEffectiveDate { get; set; }
    public DateTime ProductTermDate { get; set; }
    public Decimal MemberFee { get; set; }
    public Boolean CouldAmountBeLess { get; set; }
    public Decimal MembershipFee { get; set; } // sub
    public String FeeType { get; set; } // sub
    public Decimal TotalConsultFees { get; set; } // assets
    public String OpportunityGuid { get; set; } // sub
    public Boolean AppOptOut { get; set; }

    public Map<String, String> productErrors { get; set; }

    public PSFData(JSONParser parser, String product_code) {
      productErrors = new Map<String, String>();
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'ProductCode') {
              ProductCode = parser.getText();
            } else if (text == 'ProductVisitType') {
              ProductVisitType = parser.getText();
            } else if (text == 'ProductEffectiveDate') {
              ProductEffectiveDate = F1bUtils_v2.parseIsoDate(
                parser.getText(),
                text + '_' + product_code,
                productErrors
              );
            } else if (text == 'ProductTermDate') {
              ProductTermDate = F1bUtils_v2.parseIsoDate(
                parser.getText(),
                text + '_' + product_code,
                productErrors
              );
            } else if (text == 'MemberFee') {
              try {
                MemberFee = parser.getDecimalValue();
              } catch (System.Exception sx) {
                productErrors.put(
                  'INVALID_DECIMAL' + '_' + product_code,
                  text + '_' + product_code + ': ' + sx
                );
              }
            } else if (text == 'CouldAmountBeLess') {
              try {
                CouldAmountBeLess = parser.getBooleanValue();
              } catch (System.Exception sx) {
                productErrors.put(
                  'INVALID_BOOLEAN' + '_' + product_code,
                  text + '_' + product_code + ': ' + sx
                );
              }
            }
              else if (text == 'AppOptOut') {
              try {
                AppOptOut = parser.getBooleanValue();
              } catch (System.Exception sx) {
                productErrors.put(
                  'INVALID_BOOLEAN' + '_' + product_code,
                  text + '_' + product_code + ': ' + sx
                );
              }
            }else if (text == 'MembershipFee') {
              try {
                MembershipFee = parser.getDecimalValue();
              } catch (System.Exception sx) {
                productErrors.put(
                  'INVALID_DECIMAL' + '_' + product_code,
                  text + '_' + product_code + ': ' + sx
                );
              }
            } else if (text == 'FeeType') {
              FeeType = parser.getText();
            } else if (text == 'TotalConsultFees') {
              try {
                TotalConsultFees = parser.getDecimalValue();
              } catch (System.Exception sx) {
                productErrors.put(
                  'INVALID_DECIMAL' + '_' + product_code,
                  text + '_' + product_code + ': ' + sx
                );
              }
            } else if (text == 'OpportunityGuid') {
              OpportunityGuid = parser.getText();
            } else {
              System.debug(
                LoggingLevel.WARN,
                'Products consuming unrecognized property: ' +
                  '_' +
                  product_code +
                  text +
                  '_' +
                  product_code
              );
              F1BMainParser.consumeObject(parser);
            }
          }
        }
      }
      System.debug(LoggingLevel.FINE, 'Products: ' + productErrors);
    }
  }

  private static List<PSFData> buildEmoAndBndlBundle(
    List<PSFData> psfDataList
  ) {
    // Hold existing emo/bndl entries
    PSFData emoPsf = null;
    PSFData bndlPsf = null;

    // Hold non emo/bndl entries
    List<PSFData> basePsf = new List<PSFData>();
    for (PSFData psfIter : psfDataList) {
      if (psfIter.ProductCode == 'EMO') {
        emoPsf = psfIter;
        continue;
      }
      if (psfIter.ProductCode == 'BD-USEMP-BUNDLE') {
        bndlPsf = psfIter;
        continue;
      }
      basePsf.add(psfIter);
    }

    // Return if both emo/bndl exist
    if (emoPsf != null && bndlPsf != null) {
      return psfDataList;
    }

    // Now handle exceptions
    // If EMO was specified and BD-USEMP-BUNDLE is missing we add it
    if (emoPsf != null && bndlPsf == null) {
      // Clone emo fee
      bndlPsf = emoPsf.clone();
      bndlPsf.ProductCode = 'BD-USEMP-BUNDLE';
      // Zero emo fees because they are currently stored on the BUNDLE
      emoPsf.MemberFee = 0.0;
      emoPsf.MembershipFee = 0.0;
      emoPsf.TotalConsultFees = 0.0;

      basePsf.add(bndlPsf);
      basePsf.add(emoPsf);
      return basePsf;
    }
    // If all else fails return what we parsed without augmentation
    return psfDataList;
  }
  public static List<PsfDataWrapper> arrayOfProducts(
    System.JSONParser p,
    Map<String, String> groupErrors
  ) {
    List<PSFData> res = new List<PSFData>();
    Map<String, String> productErrors = new Map<String, String>();
    integer psf_line_count = 0;
    if (p.getCurrentToken() == null)
      p.nextToken();
    while (p.nextToken() != System.JSONToken.END_ARRAY) {
      PSFData tmpPsfData = new PSFData(p, String.valueOf(psf_line_count++));
      System.debug(LoggingLevel.FINE, 'Product: ' + tmpPsfData.ProductCode);
      System.debug(
        LoggingLevel.FINE,
        'PSF Errors: ' + tmpPsfData.productErrors
      );
      groupErrors.putAll(tmpPsfData.productErrors);
      res.add(tmpPsfData);
    }
    res = buildEmoAndBndlBundle(res);
    List<PSFData> oneAssetList = new List<PSFData>();
    List<PSFData> BHList = new List<PSFData>();
    List<PSFData> PRIME360List = new List<PSFData>();
    List<PSFData> MHList = new List<PSFData>();
    for (PSFData data : res) {
      if (data.ProductCode == 'BH')
        BHList.add(data);
      else if (
        data.ProductCode ==
        'PRIM360CARE' //Venu SCDEV2474
      )
        PRIME360List.add(data);
      else if (data.ProductCode == 'MH')
        MHList.add(data);
      else
        oneAssetList.add(data);
    }

    List<PsfDataWrapper> PsfDataWrapper = new List<PsfDataWrapper>();

    if (BHList.size() != 0 && BHList.size() != 3) {
      groupErrors.put(
        'Invalid BH Products',
        'BH product requires 3 total records'
      );
    } else if (PRIME360List.size() != 0 && PRIME360List.size() != 4) {
      //Venu SCDEV2474
      groupErrors.put(
        'Invalid PRIME 360 Products',
        'PRIME 360 product requires 4 total records'
      );
      
    } else if (MHList.size() != 0 && MHList.size() != 4) {
      groupErrors.put(
        'Invalid MH Products',
        'MH product requires 4 total records'
      );
    } else {
      for (PSFData psf : oneAssetList) {
        system.debug('psfData' + psf.TotalConsultFees + psf.MemberFee);
        SBQQ__Subscription__c subData = new SBQQ__Subscription__c(
          Fee_Type__c = psf.FeeType,
          Current_Membership_Fee__c = psf.MembershipFee
        );
        Plan_Specific_Fees__c psfData = new Plan_Specific_Fees__c(
          Actual_Copay_May_Be_Less__c = psf.CouldAmountBeLess,
          USGH_APP_Opt_Out__c = (psf.AppOptOut !=null && psf.AppOptOut)? true : false,
          Product_End_Date__c = Date.valueOf(psf.ProductTermDate),
          Product_Start_Date__c = Date.valueOf(psf.ProductEffectiveDate),
          Consult_Fee_Mbr_Pd__c = psf.MemberFee,
          Consult_Fee_Plan_Pd__c = (psf.TotalConsultFees - psf.MemberFee)
        );
        PsfDataWrapper.add(
          new PsfDataWrapper(
            psf.OpportunityGuid,
            psf.ProductCode,
            null,
            subData,
            psfData
          )
        );
      }
      for (PSFData psf : BHList) {
        SBQQ__Subscription__c subData = new SBQQ__Subscription__c(
          Fee_Type__c = psf.FeeType,
          Current_Membership_Fee__c = psf.MembershipFee
        );
        Plan_Specific_Fees__c psfData = new Plan_Specific_Fees__c(
          Actual_Copay_May_Be_Less__c = psf.CouldAmountBeLess,
              USGH_APP_Opt_Out__c = (psf.AppOptOut !=null && psf.AppOptOut)? true : false,
          Product_End_Date__c = Date.valueOf(psf.ProductTermDate),
          Product_Start_Date__c = Date.valueOf(psf.ProductEffectiveDate),
          Consult_Fee_Mbr_Pd__c = psf.MemberFee,
          Consult_Fee_Plan_Pd__c = (psf.TotalConsultFees - psf.MemberFee)
        );
        PsfDataWrapper.add(
          new PsfDataWrapper(
            psf.OpportunityGuid,
            psf.ProductCode,
            psf.ProductVisitType,
            subData,
            psfData
          )
        );
      }
      for (PSFData psf : PRIME360List) {
        SBQQ__Subscription__c subData = new SBQQ__Subscription__c(
          Fee_Type__c = psf.FeeType,
          Current_Membership_Fee__c = psf.MembershipFee
        );
        Plan_Specific_Fees__c psfData = new Plan_Specific_Fees__c(
          Actual_Copay_May_Be_Less__c = psf.CouldAmountBeLess,
          USGH_APP_Opt_Out__c = (psf.AppOptOut !=null && psf.AppOptOut)? true : false,
          Product_End_Date__c = Date.valueOf(psf.ProductTermDate),
          Product_Start_Date__c = Date.valueOf(psf.ProductEffectiveDate),
          Consult_Fee_Mbr_Pd__c = psf.MemberFee,
          Consult_Fee_Plan_Pd__c = (psf.TotalConsultFees - psf.MemberFee)
        );
        PsfDataWrapper.add(
          new PsfDataWrapper(
            psf.OpportunityGuid,
            psf.ProductCode,
            psf.ProductVisitType,
            subData,
            psfData
          )
        );
      }
      for (PSFData psf : MHList) {
        SBQQ__Subscription__c subData = new SBQQ__Subscription__c(
          Fee_Type__c = psf.FeeType,
          Current_Membership_Fee__c = psf.MembershipFee
        );
        Plan_Specific_Fees__c psfData = new Plan_Specific_Fees__c(
          Actual_Copay_May_Be_Less__c = psf.CouldAmountBeLess,
          USGH_APP_Opt_Out__c = (psf.AppOptOut !=null && psf.AppOptOut)? true : false,
          Product_End_Date__c = Date.valueOf(psf.ProductTermDate),
          Product_Start_Date__c = Date.valueOf(psf.ProductEffectiveDate),
          Consult_Fee_Mbr_Pd__c = psf.MemberFee,
          Consult_Fee_Plan_Pd__c = (psf.TotalConsultFees - psf.MemberFee)
        );
        PsfDataWrapper.add(
          new PsfDataWrapper(
            psf.OpportunityGuid,
            psf.ProductCode,
            psf.ProductVisitType,
            subData,
            psfData
          )
        );
      }
    }
    return PsfDataWrapper;
  }
}