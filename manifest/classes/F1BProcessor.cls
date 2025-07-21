public class F1BProcessor {
  public static void ProcessEntry(F1BMainParser f1bp, Id agcpiId) {
    Map<String, Object> results = new Map<String, Object>();
    results.put('parsing_errors', null);
    results.put('dml_errors', null);
    Map<String, String> parsingErrors = new Map<String, String>();
    List<AcctGrpConParse_Exception__c> oldAgcpe = [
      SELECT id
      FROM AcctGrpConParse_Exception__c
      WHERE agcpi__c = :agcpiId
    ];
    delete oldAgcpe;
    if (f1bp == null || f1bp.parsingErrors.size() > 0) {
      parsingErrors.put(
        'BAD_ITEM_DATA',
        'The item data provided for [' + agcpiId + '] was invalid.'
      );
    } else {
      if (F1bUtils_v2.FetchExistingData(f1bp, agcpiId)) {
        String defaultPrintPhone = '1-800-Teladoc (835-2362)';
        Boolean isUpdateAcct = false;
        Boolean isUpdateGrp = false;
        //Boolean dupErrorByPass = false;
        Account subscriptionAccount = null;
        Account bspAccount = new Account();
        Acct_Rel__c acctRel = null;
        Mbr_Group__c mbrGroup = new Mbr_Group__c();
        List<String> printUrlPickVal = new List<String>();
        Schema.DescribeFieldResult fieldResult = Account.Standard_Print_Url__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
          printUrlPickVal.add(pickListVal.getLabel());
        }
        Map<String, Plan_Specific_Fees__c> newPsfMap = new Map<String, Plan_Specific_Fees__c>();
        Map<String, List<Plan_Specific_Fees__c>> newBHPsfMap = new Map<String, List<Plan_Specific_Fees__c>>();
        Map<String, List<Plan_Specific_Fees__c>> newp360PsfMap = new Map<String, List<Plan_Specific_Fees__c>>();
        Map<String, List<Plan_Specific_Fees__c>> newMHPsfMap = new Map<String, List<Plan_Specific_Fees__c>>();
        // fetch parents
        if (F1bUtils_v2.existingMappedAccounts.containsKey(f1bp.ParentGuid)) {
          subscriptionAccount = F1bUtils_v2.existingMappedAccounts.get(
            f1bp.ParentGuid
          );
          // create or update bsp account
          if (subscriptionAccount != null) {
            if (
              F1bUtils_v2.existingMappedAccounts.containsKey(
                f1bp.benefitSponsor.Guid__c
              )
            ) {
              isUpdateAcct = F1BMainParser.CalculateDelta(
                f1bp.fieldDeltas,
                f1bp.benefitSponsor,
                F1bUtils_v2.existingMappedAccounts.get(
                  f1bp.benefitSponsor.Guid__c
                ),
                subscriptionAccount
              );
              if (
                f1bp.PrintUrl != null &&
                printUrlPickVal.contains(f1bp.PrintUrl) &&
                (F1bUtils_v2.existingMappedAccounts.get(
                    f1bp.benefitSponsor.Guid__c
                  )
                  .Standard_Print_Url__c != f1bp.PrintUrl)
              ) {
                F1bUtils_v2.existingMappedAccounts.get(
                    f1bp.benefitSponsor.Guid__c
                  )
                  .Standard_Print_Url__c = f1bp.PrintUrl;
                F1bUtils_v2.existingMappedAccounts.get(
                    f1bp.benefitSponsor.Guid__c
                  )
                  .Custom_Print_Url__c = null;
                isUpdateAcct = true;
              } else if (
                f1bp.PrintUrl != null &&
                !printUrlPickVal.contains(f1bp.PrintUrl) &&
                (F1bUtils_v2.existingMappedAccounts.get(
                    f1bp.benefitSponsor.Guid__c
                  )
                  .Custom_Print_Url__c != f1bp.PrintUrl)
              ) {
                F1bUtils_v2.existingMappedAccounts.get(
                    f1bp.benefitSponsor.Guid__c
                  )
                  .Standard_Print_Url__c = 'Custom';
                F1bUtils_v2.existingMappedAccounts.get(
                    f1bp.benefitSponsor.Guid__c
                  )
                  .Custom_Print_Url__c = f1bp.PrintUrl;
                isUpdateAcct = true;
              } else if (f1bp.PrintUrl == null) {
                F1bUtils_v2.existingMappedAccounts.get(
                    f1bp.benefitSponsor.Guid__c
                  )
                  .Standard_Print_Url__c = null;
                F1bUtils_v2.existingMappedAccounts.get(
                    f1bp.benefitSponsor.Guid__c
                  )
                  .Custom_Print_Url__c = null;
                isUpdateAcct = true;
              }

              if (
                f1bp.PrintPhone != null &&
                f1bp.PrintPhone !=
                F1bUtils_v2.existingMappedAccounts.get(
                    f1bp.benefitSponsor.Guid__c
                  )
                  .Print_Phone__c
              ) {
                F1bUtils_v2.existingMappedAccounts.get(
                    f1bp.benefitSponsor.Guid__c
                  )
                  .Custom_Print_Phone__c = f1bp.PrintPhone;
                isUpdateAcct = true;
              } else if (
                f1bp.PrintPhone != null &&
                f1bp.PrintPhone == defaultPrintPhone
              ) {
                F1bUtils_v2.existingMappedAccounts.get(
                    f1bp.benefitSponsor.Guid__c
                  )
                  .Custom_Print_Phone__c = null;
                isUpdateAcct = true;
              } else if (f1bp.PrintPhone == null) {
                F1bUtils_v2.existingMappedAccounts.get(
                    f1bp.benefitSponsor.Guid__c
                  )
                  .Custom_Print_Phone__c = null;
                isUpdateAcct = true;
              }
              bspAccount = F1bUtils_v2.existingMappedAccounts.get(
                f1bp.benefitSponsor.Guid__c
              );
              bspAccount.Name = bspAccount.Account_Legal_Name__c;
            } else {
              if (
                f1bp.PrintUrl != null && printUrlPickVal.contains(f1bp.PrintUrl)
              ) {
                bspAccount.Standard_Print_Url__c = f1bp.PrintUrl;
              } else if (
                f1bp.PrintUrl != null &&
                !printUrlPickVal.contains(f1bp.PrintUrl)
              ) {
                bspAccount.Standard_Print_Url__c = 'Custom';
                bspAccount.Custom_Print_Url__c = f1bp.PrintUrl;
              }

              if (
                f1bp.PrintPhone != null &&
                f1bp.PrintPhone != defaultPrintPhone
              ) {
                bspAccount.Custom_Print_Phone__c = f1bp.PrintPhone;
              }
              F1BMainParser.CalculateDelta(
                f1bp.fieldDeltas,
                f1bp.benefitSponsor,
                bspAccount,
                subscriptionAccount
              );
              bspAccount.CurrencyIsoCode = 'USD';
              bspAccount.Account_Type__c = 'Employer';
              if (bspAccount.OwnerId == null) {
                bspAccount.OwnerId = F1bUtils_v2.existingMappedAccounts.get(
                    f1bp.ParentGuid
                  )
                  .OwnerId;
              }
              bspAccount.Type = 'Customer';
              bspAccount.Name = f1bp.benefitSponsor.Account_Legal_Name__c;
              try {
                insert bspAccount;
              } catch (exception e) {
                /*
                                if (e.getMessage().Contains('DUPLICATES_DETECTED, You are creating a duplicate record. We recommend you use an existing record instead')) {
                                    dupErrorByPass = true;   
                                    F1bUtils_v2.LogException(agcpiId, 'ACCOUNT', 'REVIEW_REQUIRED', 'CANNOT_CREATE_ACCOUNT', 
                                                             'Due to duplication rule, this account is not created, review and create account, account relationship, payer, contact, or member group role records if needed'
                                                             );
                                } else {
                                    F1bUtils_v2.LogException(agcpiId, 'ACCOUNT', 'DML_ERROR', 'CANNOT_CREATE_ACCOUNT', e.getMessage());
                                }	
								*/
                F1bUtils_v2.LogException(
                  agcpiId,
                  'ACCOUNT',
                  'DML_ERROR',
                  'CANNOT_CREATE_ACCOUNT',
                  e.getMessage()
                );
                bspAccount = null;
              }
            }
          }
          // create or fetch acct rel
          if (bspAccount != null)
            acctRel = F1bUtils_v2.Create_AcctRel(
              subscriptionAccount,
              bspAccount,
              agcpiId,
              f1bp
            );
          // create or update mbr group
          if (acctRel != null && f1bp.f1bmg != null) {
            // if ((acctRel != null && f1bp.f1bmg != null) || dupErrorByPass && f1bp.f1bmg != null) {
            if (f1bp.f1bmg.f1bpwk != null)
              f1bp.f1bmg.fieldDeltas.addAll(f1bp.f1bmg.f1bpwk.fieldDeltas);
            if (F1bUtils_v2.existingGroup != null) {
              isUpdateGrp = F1BMbrGroupParser.CalculateDelta(
                f1bp.f1bmg.fieldDeltas,
                f1bp.f1bmg.ephMbrGroup,
                F1bUtils_v2.existingGroup
              );
              if (
                f1bp.f1bmg.f1bpwk != null &&
                f1bp.f1bmg.f1bpwk.DisclaimerClient != null &&
                F1bUtils_v2.existingDisclaimers.get(
                  f1bp.f1bmg.f1bpwk.DisclaimerClient
                ) != F1bUtils_v2.existingGroup.Disclaimer_client__c
              ) {
                F1bUtils_v2.existingGroup.Disclaimer_client__c = F1bUtils_v2.existingDisclaimers.get(
                  f1bp.f1bmg.f1bpwk.DisclaimerClient
                );
                isUpdateGrp = true;
              } else if (
                f1bp.f1bmg.f1bpwk != null &&
                f1bp.f1bmg.f1bpwk.DisclaimerClient == null
              ) {
                F1bUtils_v2.existingGroup.Disclaimer_client__c = null;
                isUpdateGrp = true;
              }
              if (
                f1bp.f1bmg.f1bpwk != null &&
                f1bp.f1bmg.f1bpwk.DisclaimerTeladoc != null &&
                F1bUtils_v2.existingDisclaimers.get(
                  f1bp.f1bmg.f1bpwk.DisclaimerTeladoc
                ) != F1bUtils_v2.existingGroup.Disclaimer_Teladoc__c
              ) {
                F1bUtils_v2.existingGroup.Disclaimer_Teladoc__c = F1bUtils_v2.existingDisclaimers.get(
                  f1bp.f1bmg.f1bpwk.DisclaimerTeladoc
                );
                isUpdateGrp = true;
              } else if (
                f1bp.f1bmg.f1bpwk != null &&
                f1bp.f1bmg.f1bpwk.DisclaimerTeladoc == null
              ) {
                F1bUtils_v2.existingGroup.Disclaimer_client__c = null;
                isUpdateGrp = true;
              }
              mbrGroup = F1bUtils_v2.existingGroup;
              mbrGroup = F1bUtils_v2.wkDate(mbrGroup);
            } else {
              if (
                f1bp.f1bmg.f1bpwk != null &&
                f1bp.f1bmg.f1bpwk.DisclaimerClient != null
              ) {
                mbrGroup.Disclaimer_client__c = F1bUtils_v2.existingDisclaimers.get(
                  f1bp.f1bmg.f1bpwk.DisclaimerClient
                );
              }
              if (
                f1bp.f1bmg.f1bpwk != null &&
                f1bp.f1bmg.f1bpwk.DisclaimerTeladoc != null
              ) {
                mbrGroup.Disclaimer_Teladoc__c = F1bUtils_v2.existingDisclaimers.get(
                  f1bp.f1bmg.f1bpwk.DisclaimerTeladoc
                );
              }
              F1BMbrGroupParser.CalculateDelta(
                f1bp.f1bmg.fieldDeltas,
                f1bp.f1bmg.ephMbrGroup,
                mbrGroup
              );
              mbrGroup.Active_Date__c = system.today();
              mbrGroup.Status__c = 'Active';
              mbrGroup.Domestic_Country__c = 'USA';
              mbrGroup.Logo1_ID__c = 'MK_TDH_HZ_2';
              mbrGroup.Client_Account__c = subscriptionAccount.Id;
              mbrGroup = F1bUtils_v2.wkDate(mbrGroup);
              try {
                insert mbrGroup;
              } catch (exception e) {
                F1bUtils_v2.LogException(
                  agcpiId,
                  'MBR_GROUP__C',
                  'DML_ERROR',
                  'CANNOT_CREATE_MEMBERGROUP',
                  e.getMessage()
                );
                mbrGroup = null;
              }
            }
          }
          // create mbr group role
          if (
            f1bp.benefitSponsor.Guid__c != f1bp.ParentGuid &&
            mbrGroup != null &&
            bspAccount != null &&
            subscriptionAccount != null
          ) {
            F1bUtils_v2.createMbrGroupRole(
              f1bp,
              subscriptionAccount,
              bspAccount,
              mbrGroup,
              agcpiId,
              'Benefit Sponsor'
            );
          }
          // create payer
          if (
            f1bp.f1bmg != null &&
            !String.IsBlank(f1bp.f1bmg.SfdcPayerGuid) &&
            mbrGroup != null &&
            bspAccount != null &&
            subscriptionAccount != null
          ) {
            F1bUtils_v2.createPayer(
              f1bp,
              subscriptionAccount,
              mbrGroup,
              agcpiId
            );
          }
          // create contact
          if (
            subscriptionAccount != null &&
            bspAccount != null &&
            mbrGroup != null
          ) {
            F1bUtils_v2.createContacts(
              f1bp,
              subscriptionAccount,
              bspAccount,
              mbrGroup.Id,
              agcpiId
            );
          }
          // psf start here:
          if (
            f1bp.f1bmg != null &&
            f1bp.f1bmg.f1bpsf != null &&
            subscriptionAccount != null &&
            bspAccount != null &&
            acctRel != null &&
            mbrGroup != null
          ) {
            // fetch all current psf under group and create key for each psf
            F1bUtils_v2.PsfRoles(mbrGroup.Id, agcpiId);
            // create a map for all subs/asset under parent acct
            F1bUtils_v2.createNoneBhSubAssetMap(f1bp.ParentGuid);
            BundleClass.createBhMhSubAssetMap(f1bp.ParentGuid);

            // use findsub method to see if the psf data send in is correct and valid
            Map<String, Plan_Specific_Fees__c> validPSFMap = new Map<String, Plan_Specific_Fees__c>();
            Map<String, Plan_Specific_Fees__c> bhPsfMap = new Map<String, Plan_Specific_Fees__c>();
            Map<String, Plan_Specific_Fees__c> p360PsfMap = new Map<String, Plan_Specific_Fees__c>();
            Map<String, Plan_Specific_Fees__c> mhPsfMap = new Map<String, Plan_Specific_Fees__c>();
            for (PsfDataWrapper psfData : f1bp.f1bmg.f1bpsf) {
              if (
                psfData.subProdCode != 'BH' &&
                psfData.subProdCode != 'MH' &&
                psfData.subProdCode != 'PRIM360CARE'
              ) {
                Plan_Specific_Fees__c newPsf = (F1bUtils_v2.findSub(
                  psfData.opportunityGUID,
                  psfData.subProdCode,
                  psfData.psf,
                  psfData.sub
                ));
                if (newPsf != null) {
                  validPSFMap.put(psfData.subProdCode, newPsf);
                } else {
                  F1bUtils_v2.LogException(
                    agcpiId,
                    'PLAN_SPECIFIC_FEES__C',
                    'ERROR',
                    'INCORRECT_PRODUCT_DATA',
                    'Cannot find matching subscription or asset for productCode: ' +
                    psfData.subProdCode
                  );
                }
              } else if (psfData.subProdCode == 'BH') {
                if (
                  psfData.AssetProdCode == 'BHP1T' ||
                  psfData.AssetProdCode == 'BHPOT' ||
                  psfData.AssetProdCode == 'BHNPT'
                ) {
                  bhPsfMap.put(psfData.AssetProdCode, psfData.psf);
                }
                if (bhPsfMap.size() == 3) {
                  BundleClass bhBundle = new BundleClass();
                  Map<String, Plan_Specific_Fees__c> updatedBhPsfMap = bhBundle.findBH(
                    bhPsfMap,
                    psfData.sub,
                    psfData.opportunityGUID
                  );
                  if (updatedBhPsfMap != null) {
                    Map<String, List<Plan_Specific_Fees__c>> newKey = bhBundle.buildNewKey(
                      'BH',
                      updatedBhPsfMap
                    );
                    newBHPsfMap.putAll(newKey);
                  } else {
                    F1bUtils_v2.LogException(
                      agcpiId,
                      'PLAN_SPECIFIC_FEES__C',
                      'ERROR',
                      'INCORRECT_PRODUCT_DATA',
                      'Cannot find matching subscription or asset for productCode: ' +
                      psfData.subProdCode
                    );
                  }
                }
              } else if (psfData.subProdCode == 'PRIM360CARE') {
                if (
                  psfData.AssetProdCode == 'PRIMCARECF' ||
                  psfData.AssetProdCode == 'PRIMCAREACF' ||
                  psfData.AssetProdCode == 'NEWPATCF' ||
                  psfData.AssetProdCode == 'PRIMCAREFCF'
                ) {
                  p360PsfMap.put(psfData.AssetProdCode, psfData.psf);
                }
                if (p360PsfMap.size() == 4) {
                  BundleClass bhBundle = new BundleClass();
                  Map<String, Plan_Specific_Fees__c> updatedp360PsfMap = bhBundle.findp360(
                    p360PsfMap,
                    psfData.sub,
                    psfData.opportunityGUID
                  );
                  if (updatedp360PsfMap != null) {
                    Map<String, List<Plan_Specific_Fees__c>> newKey = bhBundle.buildNewKey(
                      'PRIM360CARE',
                      updatedp360PsfMap
                    );
                    newp360PsfMap.putAll(newKey);
                  } else {
                    F1bUtils_v2.LogException(
                      agcpiId,
                      'PLAN_SPECIFIC_FEES__C',
                      'ERROR',
                      'INCORRECT_PRODUCT_DATA',
                      'Cannot find matching subscription or asset for productCode: ' +
                      psfData.subProdCode
                    );
                  }
                }
              } else if (psfData.subProdCode == 'MH') {
                if (
                  psfData.AssetProdCode == 'BHP1T' ||
                  psfData.AssetProdCode == 'BHPOT' ||
                  psfData.AssetProdCode == 'BHPOOT' ||
                  psfData.AssetProdCode == 'BHNPT'
                ) {
                  mhPsfMap.put(psfData.AssetProdCode, psfData.psf);
                }
                if (mhPsfMap.size() == 4) {
                  BundleClass mhBundle = new BundleClass();
                  Map<String, Plan_Specific_Fees__c> updatedMhPsfMap = mhBundle.findMH(
                    mhPsfMap,
                    psfData.sub,
                    psfData.opportunityGUID
                  );
                  if (updatedMhPsfMap != null) {
                    Map<String, List<Plan_Specific_Fees__c>> newKey = mhBundle.buildNewKey(
                      'MH',
                      updatedMhPsfMap
                    );
                    newMHPsfMap.putAll(newKey);
                  } else {
                    F1bUtils_v2.LogException(
                      agcpiId,
                      'PLAN_SPECIFIC_FEES__C',
                      'ERROR',
                      'INCORRECT_PRODUCT_DATA',
                      'Cannot find matching subscription or asset for productCode: ' +
                      psfData.subProdCode
                    );
                  }
                }
              }
            }
            // create key for none bh psf data that send to us
            for (String prodKey : validPSFMap.keyset()) {
              String key = F1bUtils_v2.creatingPsfKey(validPSFMap.get(prodKey));
              newPsfMap.put(key, validPSFMap.get(prodKey));
            }

            // comparing incoming psf and current psf, remove the identical ones
            if (F1bUtils_v2.existingPsf != null) {
              for (String key : newPsfMap.keySet()) {
                if (F1bUtils_v2.existingPsf.containsKey(key)) {
                  newPsfMap.remove(key);
                  F1bUtils_v2.existingPsf.remove(key);
                }
              }
            }
            // comparing incoming BH psf and current BH psf, remove the identical ones
            if (BundleClass.existingp360Psf != null) {
              for (String key : newp360PsfMap.keySet()) {
                if (BundleClass.existingp360Psf.containsKey(key)) {
                  newBHPsfMap.remove(key);
                  BundleClass.existingp360Psf.remove(key);
                }
              }
            }
            // comparing incoming MH psf and current MH psf, remove the identical ones
            if (BundleClass.existingMHPsf != null) {
              for (String key : newMHPsfMap.keySet()) {
                if (BundleClass.existingMHPsf.containsKey(key)) {
                  newBHPsfMap.remove(key);
                  BundleClass.existingMHPsf.remove(key);
                }
              }
            }
          }
        } else {
          F1bUtils_v2.LogException(
            agcpiId,
            'ACCOUNT',
            'ERROR',
            'NO_PARENT_ACCOUNT',
            'Servicing Account GUID: ' + f1bp.ParentGuid + ' does not exist.'
          );
        }
        // This section is for updating acct, grp, account relationship, delete and insert psf

        if (isUpdateAcct) {
          try {
            update bspAccount;
          } catch (exception e) {
            F1bUtils_v2.LogException(
              agcpiId,
              'ACCOUNT',
              'DML_ERROR',
              'CANNOT_UPDATE_BSPACCOUNT',
              e.getMessage()
            );
          }
        }

        if (isUpdateGrp) {
          try {
            update mbrGroup;
          } catch (exception e) {
            F1bUtils_v2.LogException(
              agcpiId,
              'MBR_GROUP__C',
              'DML_ERROR',
              'CANNOT_UPDATE_MEMBERGROUP',
              e.getMessage()
            );
          }
        }

        if (subscriptionAccount != null && bspAccount != null) {
          F1bUtils_v2.updateEndDate(f1bp, agcpiId);
        }

        if (F1bUtils_v2.existingPsf != null) {
          Database.DeleteResult[] dr = Database.delete(
            F1bUtils_v2.existingPsf.values(),
            false
          );
          boolean isError = false;
          for (Database.DeleteResult rowSr : dr) {
            if (!rowSr.isSuccess()) {
              isError = true;
              for (Database.Error rowError : rowSr.getErrors()) {
                F1bUtils_v2.LogException(
                  agcpiId,
                  'PLAN_SPECIFIC_FEES__C',
                  'ERROR',
                  'PSF_DELETE_FAILED',
                  rowError.getMessage()
                );
              }
            }
          }
          if (!isError) {
          }
          F1bUtils_v2.existingPsf.clear();
        }

        if (BundleClass.existingBHPsf != null) {
          BundleClass.deletePsf(BundleClass.existingBHPsf, agcpiId);
        }
        if (BundleClass.existingp360Psf != null) {
          BundleClass.deletePsf(BundleClass.existingp360Psf, agcpiId);
        }

        if (BundleClass.existingMHPsf != null) {
          BundleClass.deletePsf(BundleClass.existingMHPsf, agcpiId);
        }

        // clone psf to handle master detail field not writeable issue
        List<Plan_Specific_Fees__c> createPSFList = new List<Plan_Specific_Fees__c>();
        for (Plan_Specific_Fees__c psf : newPsfMap.values()) {
          Plan_Specific_Fees__c clonePSF = psf.clone(false);
          clonePSF.Member_Group__c = mbrGroup.Id;
          createPSFList.add(clonePSF);
        }
        Database.SaveResult[] sr = Database.insert(createPSFList, false);
        for (Database.SaveResult rowSr : sr) {
          if (!rowSr.isSuccess()) {
            for (Database.Error rowError : rowSr.getErrors()) {
              F1bUtils_v2.LogException(
                agcpiId,
                'PLAN_SPECIFIC_FEES__C',
                'ERROR',
                'PSF_INSERT_FAILED',
                rowError.getMessage()
              );
            }
          }
        }

        if (mbrGroup != null) {
          BundleClass.insertPsf(newBHPsfMap, mbrGroup.Id, agcpiId);
          BundleClass.insertPsf(newp360PsfMap, mbrGroup.Id, agcpiId);
          BundleClass.insertPsf(newMHPsfMap, mbrGroup.Id, agcpiId);
        }
      }
    }

    // insert all agcpe
    F1bUtils_v2.CommitDelta();
    // final update on agcpi record
    List<AcctGrpConParse_Exception__c> agcpe = [
      SELECT Exception_Type__c, Short_Desc__c, SObject__c, Full_Desc__c
      FROM AcctGrpConParse_Exception__c
      WHERE agcpi__c = :agcpiId
    ];
    results.put('dml_errors', agcpe);
    system.debug('dml errors' + agcpe);

    AcctGrpConParsing_Item__c agcpi_target = [
      SELECT id, processed__c, parsing_results__c
      FROM AcctGrpConParsing_Item__c
      WHERE id = :agcpiId
    ];
    agcpi_target.processed__c = true;

    results.put('parsing_errors', parsingErrors);
    system.debug('parsing errors' + parsingErrors);
    agcpi_target.parsing_results__c = JSON.serialize(results);
    update agcpi_target;
  }
}