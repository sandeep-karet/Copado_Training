trigger G2LCRM_Item_Before on G2LCRM_Item__c (before insert, before update) {
  // prevent duplicate entries

  for (G2LCRM_Item__c currentItem : Trigger.new) {
    // prevent bogus guid
    if (GlobalIdUtils.isGuid(currentItem.Source_Trnx_Id__c)) {
      // calculate md5 of body
      Blob myBlob = Blob.valueOf(currentItem.Body__c);
      Blob md5hash = Crypto.generateDigest('MD5', myBlob);
      currentItem.Key_Trnx__c = EncodingUtil.convertToHex(md5hash);
    } else {
      currentItem.addError('INVALID_GUID: ' + currentItem.Source_Trnx_Id__c);
    }

  }


}