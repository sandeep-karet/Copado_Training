/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
@RestResource(urlMapping='/EmailMergeField/*')
global class CMDocusignEmailMergeField {
    global CMDocusignEmailMergeField() {

    }
    @HttpGet
    global static List<Apttus_CMDSign.CMDocusignEmailMergeField.CMDocusignEmailMergeFieldResponseWrapper> doGetEmailMergeField() {
        return null;
    }
global class CMDocusignEmailDetailsWrapper {
    global String emailBody {
        get;
        set;
    }
    global String emailSubject {
        get;
        set;
    }
    global Id emailTemplateId {
        get;
        set;
    }
    global CMDocusignEmailDetailsWrapper(Id templateId, String body, String subject) {

    }
}
global class CMDocusignEmailMergeFieldResponseWrapper {
    global Id docusignRecipientId {
        get;
        set;
    }
    global Apttus_CMDSign.CMDocusignEmailMergeField.CMDocusignEmailDetailsWrapper mailDetails {
        get;
        set;
    }
    global CMDocusignEmailMergeFieldResponseWrapper() {

    }
}
}
