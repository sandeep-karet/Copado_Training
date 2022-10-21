global class clientOverviewServices {
    
    @InvocableMethod
    public static List<Id> copyChildRecords(List<List<String>> sourceInformation){
      
        if(sourceInformation.get(0).size() == 3){

            String destinationId; //Id of record to copy child records to
            String sourceObjectName = sourceInformation.get(0).get(0);
            List<String> childObjectNames = sourceInformation.get(0).get(1).split(',');
            String parentId = sourceInformation.get(0).get(2);
            
            List<ChildRelationship> childRecords = CloneListUtil.getChildRecordNames(sourceObjectName, childObjectNames, parentId);
            
            if(CloneListUtil.verifyChildObjectSelected(childRecords)) {//Verify if any of the child objects have been selected
                
                Boolean parentError = false;
                    Database.SaveResult saveParentResult = CloneListUtil.createCloneParentRecord(String.escapeSingleQuotes(parentId));//clone parent record
                    if(saveParentResult.isSuccess()) {//If successful show Id, if not show error
                        destinationId = saveParentResult.getId();//Newly created destination Id
                    }         
                //Verify that the source sObject type is the same as the destination sObject type
                if(!parentError) {
                    String destinationName = CloneListUtil.getObjectNameBasedOnPrefix(String.escapeSingleQuotes(destinationId));
                    String objectName = CloneListUtil.getObjectNameBasedOnPrefix(String.escapeSingleQuotes(parentId));
                    
                    if(destinationName != '') {
                        if(objectName == destinationName) {
                            try {
                                CloneListUtil.createCloneChildRecords(String.escapeSingleQuotes(parentId), String.escapeSingleQuotes(destinationId), childRecords);
                                return new List<String>{String.escapeSingleQuotes(destinationId)};
                                    
                            } catch(Exception e) {}
                        }
                    }
                }
            }
        }
        return null;
	}

}