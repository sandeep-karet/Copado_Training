public class PromotionApprovalSubmitter {
    @InvocableMethod(label='Submit Promotion for Approval')
    public static void submitForApproval(List<Id> promotionIds) {
        if (promotionIds.isEmpty()) {
            return;
        }

        Id promotionId = promotionIds[0];
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Rollback requested for Promotion');
        req.setObjectId(promotionId);

        try {
            Approval.ProcessResult result = Approval.process(req);
            if (result.isSuccess()) {
                System.debug('Successfully submitted for approval');
            } else {
                System.debug('Error submitting for approval: ' + result.getErrors()[0].getMessage());
            }
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
        }
    }
}