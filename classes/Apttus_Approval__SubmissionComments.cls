/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class SubmissionComments {
    @WebService
    webService Integer commentsCount;
    @WebService
    webService String commentsLevel;
    global static String PROCESS_LEVEL_COMMENTS;
    @WebService
    webService String processComment;
    @WebService
    webService String processCommentLabel;
    @WebService
    webService Boolean processCommentMandatory;
    @WebService
    webService String processName;
    global static String STEP_LEVEL_COMMENTS;
    @WebService
    webService List<Apttus_Approval.SubmissionComments.StepComment> stepCommentList;
    global SubmissionComments() {

    }
    global void addStepComment(Apttus_Approval.SubmissionComments.StepComment comment) {

    }
    global Integer getCommentsCount() {
        return null;
    }
    global String getProcessComment() {
        return null;
    }
    global String getProcessCommentLabel() {
        return null;
    }
    global String getProcessName() {
        return null;
    }
    global List<Apttus_Approval.SubmissionComments.StepComment> getStepCommentList() {
        return null;
    }
    global Boolean isProcessLevelComment() {
        return null;
    }
    global Boolean isProcessLevelCommentMandatory() {
        return null;
    }
    global Boolean isStepLevelComment() {
        return null;
    }
    global static Apttus_Approval.SubmissionComments parse(String jsonString) {
        return null;
    }
    global void setProcessComment(String comment) {

    }
    global void setProcessCommentMandatory() {

    }
    global String toJSON() {
        return null;
    }
global class StepComment {
    @WebService
    webService String stepComment;
    @WebService
    webService String stepCommentLabel;
    @WebService
    webService String stepName;
    global StepComment() {

    }
    global String getStepComment() {
        return null;
    }
    global String getStepCommentLabel() {
        return null;
    }
    global String getStepName() {
        return null;
    }
    global void setStepComment(String comment) {

    }
}
}
