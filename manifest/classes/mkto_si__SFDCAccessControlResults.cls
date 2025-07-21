/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global virtual class SFDCAccessControlResults {
global class AccessControlResultsException extends Exception {
}
global class DeleteResults extends mkto_si.SFDCAccessControlResults {
    global DeleteResults(List<Database.DeleteResult> results) {

    }
    global List<Database.DeleteResult> getResults() {
        return null;
    }
    global Boolean wasSuccessful() {
        return null;
    }
}
global class InsertResults extends mkto_si.SFDCAccessControlResults {
    global InsertResults(List<SObject> objects, List<Database.SaveResult> results) {

    }
    global List<SObject> getInsertedObjects() {
        return null;
    }
    global List<Database.SaveResult> getResults() {
        return null;
    }
    global Boolean wasSuccessful() {
        return null;
    }
}
global class UpdateResults extends mkto_si.SFDCAccessControlResults {
    global UpdateResults(List<SObject> objects, List<Database.SaveResult> results) {

    }
    global List<Database.SaveResult> getResults() {
        return null;
    }
    global List<SObject> getUpdatedObjects() {
        return null;
    }
    global Boolean wasSuccessful() {
        return null;
    }
}
global class UpsertResults extends mkto_si.SFDCAccessControlResults {
    global UpsertResults(List<SObject> objects, List<Database.UpsertResult> results) {

    }
    global List<Database.UpsertResult> getResults() {
        return null;
    }
    global List<SObject> getUpsertedObjects() {
        return null;
    }
    global Boolean wasSuccessful() {
        return null;
    }
}
}
