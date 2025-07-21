public class MassPsfMigration {
  List<Plan_Specific_Fees__c> psfToUpdate = new List<Plan_Specific_Fees__c>();
  List<Plan_Specific_Fees__c> psfToInsert = new List<Plan_Specific_Fees__c>();

  Map<String, Plan_Specific_Fees__c> parentPsf = new Map<String, Plan_Specific_Fees__c>();
  Map<String, Plan_Specific_Fees__c> currentPsf = new Map<String, Plan_Specific_Fees__c>();
  // PSF needing conversion
  List<String> productKeys = new List <String>{ 'BH', 'TC', 'DERM', 'MH'};
  Map<String, List<String>> assetKeys = new Map<String, List<String>>();

  public void ProcessRecords(Id memberGroupId){

    assetKeys.put('BH' , new List<String>{ 'BHP1T','BHPOT','BHNPT'});
    assetKeys.put('MH', new List<String>{ 'BHPOT', 'BHPOOT','BHNPT'});
    assetKeys.put('TC', new List<String>{ 'TCPROGFEE'});
    assetKeys.put('DERM', new List<String>{ 'DERMFEE'});


    Set<String> assetProductCodes = new Set<String>();
    for(String tmpAssetKey : assetKeys.keySet()){
      for(String tmpProd : assetKeys.get(tmpAssetKey)){
        assetProductCodes.add(tmpProd);
      }
    }

    Set<Id> subscriptionIdsInUse = new Set<Id>();
    List<Plan_Specific_Fees__c> scopedPsf =
    [SELECT Id, Member_Group__c, Asset__c, Actual_Copay_May_Be_Less__c, Consult_Fee_Initial_Diagnostic_Mbr_Pd__c, Consult_Fee_Initial_Diagnostic_Plan_Pd__c
        , Consult_Fee_Mbr_Pd__c, Consult_Fee_Plan_Pd__c, Consult_Fee_Ongoing_MD_Mbr_Pd__c, Consult_Fee_Ongoing_MD_Plan_Pd__c
        , Consult_Fee_Ongoing_Non_MD_Mbr_Pd__c, Consult_Fee_Ongoing_Non_MD_Plan_Pd__c, DERMConsult_Fee_Mbr_Pd__c, DERMConsult_Fee_Plan_Pd__c
        , TC_Client_Case_Rate_Fee__c, TC_Mbr_Case_Rate_Fee__c, Subscription__r.sbqq__Product__r.ProductCode, Subscription__c, Product_Start_Date__c, Product_End_Date__c
    FROM Plan_Specific_Fees__c
    where  subscription__r.sbqq__product__r.productcode in :productKeys
    and member_group__c = :memberGroupId];

    // Exist if no psf exist meeting criteria
    if(scopedPsf.size() == 0)
      return;

    // Map group + sub productcode and gather subscription ids
    for(Plan_Specific_Fees__c tmpPsf : scopedPsf){
      subscriptionIdsInUse.add(tmpPsf.subscription__c);
      parentPsf.put(tmpPsf.member_group__c + '_' + tmpPsf.subscription__r.sbqq__product__r.productcode, tmpPsf);
    }

    // Pull all assets for subscriptions
    List<Asset> subscribedAssets = [select id, product2.productcode, consult_fees__c, sbqq__requiredbysubscription__c, Product2Id
    from asset
    where sbqq__RequiredBySubscription__c in :subscriptionIdsInUse];

    // Map assets for psf-level search
    Map<String, Asset> mappedAssets = new Map<String, Asset>();
    for(Asset tmpAsset : subscribedAssets){
      mappedAssets.put(tmpAsset.sbqq__RequiredBySubscription__c + '_' + tmpAsset.product2.productcode, tmpAsset);
    }
    if(assetProductCodes.size() > 0){
      List<Plan_Specific_Fees__c> existingPsf =
      [SELECT Id, Member_Group__c, Asset__c, Actual_Copay_May_Be_Less__c, Consult_Fee_Initial_Diagnostic_Mbr_Pd__c, Consult_Fee_Initial_Diagnostic_Plan_Pd__c
          , Consult_Fee_Mbr_Pd__c, Consult_Fee_Plan_Pd__c, Consult_Fee_Ongoing_MD_Mbr_Pd__c, Consult_Fee_Ongoing_MD_Plan_Pd__c
          , Consult_Fee_Ongoing_Non_MD_Mbr_Pd__c, Consult_Fee_Ongoing_Non_MD_Plan_Pd__c, DERMConsult_Fee_Mbr_Pd__c, DERMConsult_Fee_Plan_Pd__c
          , TC_Client_Case_Rate_Fee__c, TC_Mbr_Case_Rate_Fee__c, Asset__r.Product2.ProductCode , Subscription__c, Product_Start_Date__c, Product_End_Date__c
      FROM Plan_Specific_Fees__c
      where  member_group__c = :memberGroupId and Asset__r.Product2.ProductCode in :assetProductCodes];

      for(Plan_Specific_Fees__c tmpPsf : existingPsf){
        currentPsf.put(tmpPsf.Member_Group__c + '_' + tmpPsf.Asset__r.Product2.ProductCode, tmpPsf);
      }
      //system.debug('ParentPSF:' + parentPsf.keyset());

      for(String tmpKeyPrefix : parentPsf.keySet()){
        String[] keys = tmpKeyPrefix.split('_'); // 0 = member group id, 1 = parent productcode
        //system.debug('keys: ' + keys);
        List<String> apk = assetKeys.get(keys[1]);
        //system.debug('APK: '+ apk);
        for(String tmpKey : apk){
          string targetKey = keys[0] + '_' + tmpKey;
          if(currentPsf.containsKey(targetKey)){
            system.debug('Found existing psf for: ' + targetKey);
          } else {
            // Grab current 'parent' psf
            Plan_Specific_Fees__c sourcePsf = parentPsf.get(tmpKeyPrefix);
            switch on keys[1] {
              when 'BH'{
                string targetAssetKey = sourcePsf.Subscription__c + '_' + tmpKey;
                Asset targetAsset = mappedAssets.get(targetAssetKey);
                if(targetAsset != null){
                  Plan_Specific_Fees__c newPsf = new Plan_Specific_Fees__c(
                      Member_Group__c = sourcePsf.Member_Group__c,
                      Subscription__c = sourcePsf.subscription__c,
                      Asset__c = targetAsset.Id,
                      Product_Start_Date__c = sourcePsf.Product_Start_Date__c,
                      Product_End_Date__c = sourcePsf.Product_End_Date__c,
                      Actual_Copay_May_Be_Less__c = sourcePsf.Actual_Copay_May_Be_Less__c);
                  switch on tmpKey {
                    when 'BHP1T' {
                      newPsf.Consult_Fee_Mbr_Pd__c = sourcePsf.Consult_Fee_Initial_Diagnostic_Mbr_Pd__c;
                      newPsf.Consult_Fee_Plan_Pd__c = sourcePsf.Consult_Fee_Initial_Diagnostic_Plan_Pd__c;
                    }
                    when 'BHPOT' {
                      newPsf.Consult_Fee_Mbr_Pd__c = sourcePsf.Consult_Fee_Ongoing_MD_Mbr_Pd__c;
                      newPsf.Consult_Fee_Plan_Pd__c = sourcePsf.Consult_Fee_Ongoing_MD_Plan_Pd__c;
                    }
                    when 'BHNPT' {
                      newPsf.Consult_Fee_Mbr_Pd__c = sourcePsf.Consult_Fee_Ongoing_Non_MD_Mbr_Pd__c;
                      newPsf.Consult_Fee_Plan_Pd__c = sourcePsf.Consult_Fee_Ongoing_Non_MD_Plan_Pd__c;
                    }
                  }
                  psfToInsert.add(newPsf);
                } else {
                  system.debug('No asset found for: ' + targetAssetKey);
                }
              }
              when 'MH'{

              }
              when 'TC'{
                string targetAssetKey = sourcePsf.Subscription__c + '_' + tmpKey;
                Asset targetAsset = mappedAssets.get(targetAssetKey);
                if(targetAsset != null){
                  sourcePsf.Asset__c = targetAsset.Id;
                  sourcePsf.Consult_Fee_Mbr_Pd__c = sourcePsf.TC_Mbr_Case_Rate_Fee__c;
                  sourcePsf.Consult_Fee_Plan_Pd__c = sourcePsf.TC_Client_Case_Rate_Fee__c;
                  psfToUpdate.add(sourcePsf);
                } else {
                  system.debug('No asset found for: ' + targetAssetKey);
                }
              }
              when 'DERM'{
                string targetAssetKey = sourcePsf.Subscription__c + '_' + tmpKey;
                Asset targetAsset = mappedAssets.get(targetAssetKey);
                if(targetAsset != null){
                  sourcePsf.Asset__c = targetAsset.Id;
                  sourcePsf.Consult_Fee_Mbr_Pd__c = sourcePsf.DERMConsult_Fee_Mbr_Pd__c;
                  sourcePsf.Consult_Fee_Plan_Pd__c = sourcePsf.DERMConsult_Fee_Plan_Pd__c;
                  psfToUpdate.add(sourcePsf);
                } else {
                  system.debug('No asset found for: ' + targetAssetKey);
                }
              }
            }
          }
        }
      }

      // Commit changes if any exist
      if(psfToUpdate.size() > 0 || psfToInsert.size() > 0) {
        AcctGrpConParsing_Item__c newAgcpi = new AcctGrpConParsing_Item__c(Batch_Time__c = DateTime.now(),
            Batch_Key__c = String.valueOf(DateTime.now().getTime()), Item_Key__c = memberGroupId, Processed__c = true,
        Source__c = 'PSFMIG');
        insert newAgcpi;

        List<AcctGrpConParse_Exception__c> newAgcpe = new List<AcctGrpConParse_Exception__c>();

        if (psfToUpdate.size() > 0) {
          system.debug('PSF to update: ' + psfToUpdate.size());
          Database.SaveResult[] sr = Database.update(psfToUpdate, false);
          for(Database.SaveResult tmpSr : sr){
            if(!tmpSr.isSuccess()){
              for(Database.Error dbe: tmpSr.getErrors()){
                newAgcpe.add(createException(newAgcpi.Id, 'ERROR','Plan_Specific_Fees__c','PSF_UPD', dbe.message));
              }
            }
          }
        }
        if (psfToInsert.size() > 0) {
          system.debug('PSF to insert: ' + psfToInsert.size());
          Database.SaveResult[] sr = Database.insert(psfToInsert, false);
          for(Database.SaveResult tmpSr : sr){
            if(!tmpSr.isSuccess()){
              for(Database.Error dbe: tmpSr.getErrors()){
                newAgcpe.add(createException(newAgcpi.Id, 'ERROR','Plan_Specific_Fees__c','PSF_INS', dbe.message));
              }
            }
          }
        }
        if(newAgcpe.size() > 0)
          Database.insert(newAgcpe, false);
      }
    }
  }
  AcctGrpConParse_Exception__c createException(Id sourceAgcpi, String exType, String sObjectName, String shortDesc, String fullDesc) {
    AcctGrpConParse_Exception__c tmpAgcpe = new AcctGrpConParse_Exception__c();
    tmpAgcpe.Agcpi__c = sourceAgcpi;
    tmpAgcpe.Exception_Type__c = exType.trim().toUpperCase();
    tmpAgcpe.sobject__c = sObjectName.trim().toUpperCase();
    tmpAgcpe.Short_Desc__c = shortDesc.left(64).trim().toUpperCase();
    if (fullDesc.length() > 255) {
      tmpAgcpe.Full_Desc__c = fullDesc.substring(0, 255);
    } else {
      tmpAgcpe.Full_Desc__c = fullDesc;

    }
    return tmpAgcpe;
  }
}