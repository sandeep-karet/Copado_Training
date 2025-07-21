/**
* Company : PwC.
* @description : L2O_AssetTriggerHelperService will be executed from the L2O_AssetTriggerHandler and will update GUID field on Asset
* *****************************************************************************************************************************************
* History : 
* @date 02/07/2023
* @author Vaishnavi H
*/
public class L2O_AssetTriggerHelperService {
        /**
        * @name  setGUID
        * @description setGUID
        * @param newAssets for trigger.new Asset
        **/
    public void setGUID(List<Asset> newAssets) {
        
        Set<String> allGuids = new Set<String>();
        for (Asset tempAsset : newAssets) {
            
            // Create new GUID if asset is new or has invalid GUID
            
            if (String.isBlank(tempAsset.L2O_GUID__c) || !L2O_GlobalIdUtils.isGuid(tempAsset.L2O_GUID__c)) {
                tempAsset.L2O_GUID__c = L2O_GlobalIdUtils.generateGuid();
                allGuids.add(tempAsset.L2O_GUID__c);
            }
            
            else {
                allGuids.add(tempAsset.L2O_GUID__c);
            }
            
        }
    }

}