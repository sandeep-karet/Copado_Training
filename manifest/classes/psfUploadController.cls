public with sharing class psfUploadController {
  @AuraEnabled
  public static String getCSV() {
    ContentDocument doc = [
      SELECT Id
      FROM ContentDocument
      WHERE Title = 'PSF Upload Template'
    ];
    return doc.Id;
  }

  @AuraEnabled
  public static List<psfWrapper> readCSVFile(Id idContentDocument) {
    List<psfWrapper> psfWrapper = new List<psfWrapper>();
    List<Plan_Specific_Fees__c> psfList = new List<Plan_Specific_Fees__c>();

    List<Product_Asset__mdt> prodAssetList = [
      SELECT Id, MasterLabel, Asset_Product_Code__c, Product_Label__c
      FROM Product_Asset__mdt
    ];
    Map<String, Map<String, String>> prodAssetMap = new Map<String, Map<String, String>>();
    for (Product_Asset__mdt pa : prodAssetList) {
      List<String> assetProductCode = pa.Asset_Product_Code__c.split(',');
      List<String> assetLabel = pa.Product_Label__c.split(',');
      Map<String, String> codeLabelMap = new Map<String, String>();
      for (Integer i = 0; i < assetProductCode.size(); i++) {
        codeLabelMap.put(assetProductCode[i], assetLabel[i]);
      }
      prodAssetMap.put(pa.MasterLabel, codeLabelMap);
    }
    if (idContentDocument != null) {
      // getting File Data based on document id
      ContentVersion objVersion = [
        SELECT Id, VersionData
        FROM ContentVersion
        WHERE ContentDocumentId = :idContentDocument
      ];
      // split the file data
      List<String> lstCSVLines = objVersion.VersionData.toString().split('\n');
      List<String> subIdList = new List<String>();
      for (String csvLine : lstCSVLines) {
        List<String> csvRowData = csvLine.split(',');
        subIdList.add(csvRowData[5]);
      }
      Map<String, String> assetIdMap = new Map<String, String>();
      Map<String, Map<String, Asset>> subAstMap = new Map<String, Map<String, Asset>>();
      for (SBQQ__Subscription__c sub : [
        SELECT
          Id,
          Sbqq__product__r.productCode,
          (
            SELECT Id, Consult_Fees__c, Product2.ProductCode
            FROM SBQQ__ChildAssets__r
          )
        FROM SBQQ__Subscription__c
        WHERE Id IN :subIdList
      ]) {
        for (Asset asset : sub.SBQQ__ChildAssets__r) {
          assetIdMap.put(asset.Id, asset.Product2.ProductCode);
          String subkey = (sub.Id + asset.Product2.ProductCode)
            .trim()
            .toUpperCase();
          Map<String, Asset> tempMap = new Map<String, Asset>();
          tempMap.put(sub.sbqq__product__r.productCode, asset);
          subAstMap.put(subkey, tempMap);
        }
      }

      Map<String, Map<String, Plan_Specific_Fees__c>> psfMap = new Map<String, Map<String, Plan_Specific_Fees__c>>();
      Map<String, Map<String, List<Plan_Specific_Fees__c>>> psfProdCodeMap = new Map<String, Map<String, List<Plan_Specific_Fees__c>>>();
      Map<String, String> MbSubIdmap = new Map<String, String>();
      for (Integer i = 1; i < lstCSVLines.size(); i++) {
        Plan_Specific_Fees__c psf = new Plan_Specific_Fees__c();
        List<String> csvRowData = lstCSVLines[i].split(',');
        psf.Member_Group__c = csvRowData[0];
        psf.Product_Start_Date__c = date.parse(csvRowData[1]);
        psf.Actual_Copay_May_Be_Less__c = Boolean.valueOf(csvRowData[2]);
        psf.Consult_Fee_Plan_Pd__c = Decimal.valueOf(csvRowData[3]);
        psf.Consult_Fee_Mbr_Pd__c = Decimal.valueOf(csvRowData[4]);
        psf.Subscription__c = csvRowData[5];
        String key = (csvRowData[5] + csvRowData[6]).trim().toUpperCase();
        String subProdCode;

        if (subAstMap.containsKey(key)) {
          for (String pc : subAstMap.get(key).keyset()) {
            subProdCode = pc;
          }
          if (
            Decimal.valueOf(csvRowData[3]) + Decimal.valueOf(csvRowData[4]) !=
            subAstMap.get(key).get(subProdCode).Consult_Fees__c
          ) {
            psfWrapper.add(
              new psfWrapper(
                psf,
                'Incorrect Fee Split',
                assetIdMap.get(subAstMap.get(key).get(subProdCode).Id)
              )
            );
            continue;
          }
          psf.Asset__c = subAstMap.get(key).get(subProdCode).Id;
        }

        if (
          prodAssetMap.containsKey(subProdCode) &&
          prodAssetMap.get(subProdCode)
            .containsKey(csvRowData[6].trim().toUpperCase())
        ) {
          if (psfMap.containsKey(csvRowData[5])) {
            psfMap.get(csvRowData[5])
              .put(
                csvRowData[6].trim().toUpperCase() + '_' + csvRowData[0],
                psf
              );
          } else {
            Map<String, Plan_Specific_Fees__c> codeMap = new Map<String, Plan_Specific_Fees__c>();
            codeMap.put(
              csvRowData[6].trim().toUpperCase() + '_' + csvRowData[0],
              psf
            );
            psfMap.put(csvRowData[5], codeMap);
          }

          if (psfProdCodeMap.containsKey(csvRowData[5])) {
            Map<String, List<Plan_Specific_Fees__c>> tempMap1 = psfProdCodeMap.get(
              csvRowData[5]
            );
            if (tempMap1.containsKey(csvRowData[0])) {
              List<Plan_Specific_Fees__c> psList1 = tempMap1.get(csvRowData[0]);
              psList1.add(psf);
              tempMap1.put(csvRowData[0], psList1);
            } else {
              tempMap1.put(
                csvRowData[0],
                new List<Plan_Specific_Fees__c>{ psf }
              );
              psfProdCodeMap.put(csvRowData[5], tempMap1);
            }
          } else {
            Map<String, List<Plan_Specific_Fees__c>> tempMap = new Map<String, List<Plan_Specific_Fees__c>>();
            tempMap.put(csvRowData[0], new List<Plan_Specific_Fees__c>{ psf });
            psfProdCodeMap.put(csvRowData[5], tempMap);
          }
          if (!MbSubIdmap.containsKey(csvRowData[5])) {
            MbSubIdmap.put(csvRowData[5], csvRowData[0]);
          }
        } else {
          psfList.add(psf);
        }
      }

      Map<Id, SBQQ__Subscription__c> subMap = new Map<Id, SBQQ__Subscription__c>(
        [
          SELECT Id, Sbqq__product__r.productCode
          FROM SBQQ__Subscription__c
          WHERE Id IN :subIdList
        ]
      );

      for (String psfCode : psfProdCodeMap.keyset()) {
        Integer assetCount = prodAssetMap.get(
            subMap.get(psfCode).Sbqq__product__r.productCode
          )
          .size();
        if (
          psfProdCodeMap.get(psfCode).get(MbSubIdmap.get(psfCode)).size() !=
          assetCount
        ) {
          for (Plan_Specific_Fees__c psfRecord : psfMap.get(psfCode).values()) {
            psfWrapper.add(
              new psfWrapper(
                psfRecord,
                subMap.get(psfCode).Sbqq__product__r.productCode +
                  ' product must have all ' +
                  assetCount +
                  ' correct psf records',
                assetIdMap.get(psfRecord.Asset__c)
              )
            );
          }
        } else {
          for (Plan_Specific_Fees__c psfRecord : psfMap.get(psfCode).values()) {
            psfList.add(psfRecord);
          }
        }
      }

      /*
                if (subProdCode == 'BH' && csvRowData[6].contains('BH')) {      
                    if (bhMap.containsKey(csvRowData[5])) {
                        bhMap.get(csvRowData[5]).put(csvRowData[6], psf); 
                    } else {
                        Map<String, Plan_Specific_Fees__c> bhCode = new Map<String, Plan_Specific_Fees__c>();
                        bhCode.put(csvRowData[6], psf);
                        bhMap.put(csvRowData[5], bhCode);
                    }
                } else if (subProdCode == 'MH' && csvRowData[6].contains('BH')) {
                    if (mhMap.containsKey(csvRowData[5])) {
                        mhMap.get(csvRowData[5]).put(csvRowData[6], psf); 
                    } else {
                        Map<String, Plan_Specific_Fees__c> mhCode = new Map<String, Plan_Specific_Fees__c>();
                        mhCode.put(csvRowData[6], psf);
                        mhMap.put(csvRowData[5], mhCode);
                    }
                } else {   
                    psfList.add(psf);
                }     
				*/

      /*
            for (String bhPSF : bhMap.keyset()) {
                if (bhMap.get(bhPSF).size() != 3) {
                    for (Plan_Specific_Fees__c psfRecord : bhMap.get(bhPSF).values()) {
                        psfWrapper.add(new psfWrapper(psfRecord, 'BH product must have all 3 correct psf records'));
                    }
                } else {
                    for (Plan_Specific_Fees__c psfRecord : bhMap.get(bhPSF).values()) {
                        psfList.add(psfRecord);
                    }
                }
            }
            
            for (String mhPSF : mhMap.keyset()) {
                if (mhMap.get(mhPSF).size() != 4) {
                    for (Plan_Specific_Fees__c psfRecord : mhMap.get(mhPSF).values()) {
                        psfWrapper.add(new psfWrapper(psfRecord, 'MH product must have all 4 correct psf records'));
                    }
                } else {
                    for (Plan_Specific_Fees__c psfRecord : mhMap.get(mhPSF).values()) {
                        psfList.add(psfRecord);
                    }
                }
            }
            */
      try {
        if (!psfList.isEmpty()) {
          Database.SaveResult[] psfRecords = Database.insert(psfList, false);
          for (Integer i = 0; i < psfRecords.size(); i++) {
            String astCode = assetIdMap.containsKey(psfList[i].Asset__c) != null
              ? assetIdMap.get(psfList[i].Asset__c)
              : null;
            if (psfRecords.get(i).isSuccess()) {
              psfWrapper.add(new psfWrapper(psfList[i], '', astCode));
            } else if (!psfRecords.get(i).isSuccess()) {
              String errorMsg;
              for (Database.Error rowError : psfRecords[i].getErrors()) {
                errorMsg = rowError.getMessage();
              }
              psfWrapper.add(new psfWrapper(psfList[i], errorMsg, astCode));
            }
          }
        }
      } catch (Exception ex) {
        throw new AuraHandledException(ex.getMessage());
      }
    }
    return psfWrapper;
  }

  @AuraEnabled
  public static void deleteDoc(Id idContentDocument) {
    ContentDocument doc = [
      SELECT Id
      FROM ContentDocument
      WHERE Id = :idContentDocument
    ];
    delete doc;
  }

  public class psfWrapper {
    @auraEnabled
    public Plan_Specific_Fees__c psf { get; set; }
    @auraEnabled
    public String error { get; set; }
    @auraEnabled
    public String prodCode { get; set; }
    public psfWrapper(
      Plan_Specific_Fees__c psf,
      String error,
      String prodCode
    ) {
      this.psf = psf;
      this.error = error;
      this.prodCode = prodCode;
    }
  }
}