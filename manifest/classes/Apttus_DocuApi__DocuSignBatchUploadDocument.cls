/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class DocuSignBatchUploadDocument implements Database.AllowsCallouts, Database.Batchable<Apttus_DocuApi.DocuSignUtil.AttachmentWrapper>, Database.Stateful {
    global static Integer BatchSize;
    global static Integer counter;
    global DocuSignBatchUploadDocument(String iParentJobId, Apttus_DocuApi.DocuSignUtil.DocuSignEnvelopeData iDocuSignEnvelopeData, Apttus_DocuApi.DocuSignUtil.DocuSignAccessToken iDocuSignAccessToken, Apttus_DocuApi.DocuSignRESTService iDocuSignRESTService) {

    }
    global void execute(Database.BatchableContext info, List<Apttus_DocuApi.DocuSignUtil.AttachmentWrapper> scope) {

    }
    global void finish(Database.BatchableContext info) {

    }
    global System.Iterable start(Database.BatchableContext info) {
        return null;
    }
}
