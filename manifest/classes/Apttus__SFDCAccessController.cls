/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class SFDCAccessController {
    global SFDCAccessController() {

    }
    global SFDCAccessController(Apttus.SFDCAccessController.SharingMode smode, Apttus.SFDCAccessController.OperationMode omode) {

    }
    global SFDCAccessController(Apttus.SFDCAccessController.SharingMode smode, Apttus.SFDCAccessController.OperationMode omode, Apttus.SFDCAccessController.OperationMode oarrmode) {

    }
    global void deleteAsUser(SObject someObj) {

    }
    global Apttus.SFDCAccessControlResults.DeleteResults deleteAsUser(List<SObject> someObjs) {
        return null;
    }
    global Apttus.SFDCAccessControlResults.InsertResults insertAsUser(List<SObject> someObjs, List<Schema.SObjectField> fieldsToSet) {
        return null;
    }
    global Apttus.SFDCAccessControlResults.InsertResults insertAsUser(List<SObject> someObjs, List<String> fieldsToSet) {
        return null;
    }
    global SObject insertAsUser(SObject someObj, List<Schema.SObjectField> fieldsToSet) {
        return null;
    }
    global SObject insertAsUser(SObject someObj, List<String> fieldsToSet) {
        return null;
    }
    global List<SObject> queryAsUser(String query) {
        return null;
    }
    global void setArrayOperationMode(Apttus.SFDCAccessController.OperationMode oarrmode) {

    }
    global void setOperationMode(Apttus.SFDCAccessController.OperationMode omode) {

    }
    global void setSharingMode(Apttus.SFDCAccessController.SharingMode smode) {

    }
    global Apttus.SFDCAccessControlResults.UpdateResults updateAsUser(Map<Id,SObject> objMap, List<Schema.SObjectField> fieldsToUpdate) {
        return null;
    }
    global Apttus.SFDCAccessControlResults.UpdateResults updateAsUser(Map<Id,SObject> objMap, List<String> fieldsToUpdate) {
        return null;
    }
    global SObject updateAsUser(SObject someObj, List<Schema.SObjectField> fieldsToUpdate) {
        return null;
    }
    global SObject updateAsUser(SObject someObj, List<String> fieldsToUpdate) {
        return null;
    }
global class AccessControlDmlException extends Exception {
}
global enum OperationMode {ALL_OR_NONE, BEST_EFFORT}
global enum SharingMode {INHERIT, WITH, WITHOUT}
}
