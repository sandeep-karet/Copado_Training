public class PromotionApprovalController {
    @AuraEnabled
    public static String submitForApproval(Id promotionId) {
        try {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting promotion for approval');
            req.setObjectId(promotionId);

            Approval.ProcessResult result = Approval.process(req);

            if (result.isSuccess()) {
                return 'Success';
            } else {
                return 'Error: ' + result.getErrors()[0].getMessage();
            }
        } catch (Exception e) {
            return 'Error: ' + e.getMessage();
        }
    }
}