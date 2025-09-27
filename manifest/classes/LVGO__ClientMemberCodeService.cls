public class ClientMemberCodeService {
    public static void chatterTechOps(List<ClientMemberCode__c> cmcList, String operationType) {
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        CollaborationGroup chatterGroup = [SELECT Id, Name from CollaborationGroup WHERE Name = 'TechOps' LIMIT 1];
        for (ClientMemberCode__c cmc : cmcList) {
            if (operationType == 'Insert') {
                String inputText = '\nNew ' + 'Client Member Code ' + cmc.get('Name') +' has been created \n Code: ' + cmc.ClientMemberCode__c;
                ConnectApi.FeedItemInput feedItemInput = createFeed(inputText, chatterGroup.Id, cmc.Id);
                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
                batchInputs.add(batchInput); 
            }
            else if (operationType == 'Delete') {
                String inputText = '\nClient Member Code ' + cmc.get('Name') +' has been deleted \n Code: ' + cmc.ClientMemberCode__c;
                ConnectApi.FeedItemInput feedItemInput = createFeed(inputText, chatterGroup.Id, cmc.Account_Id__c);
                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
                batchInputs.add(batchInput);
            } 
        }
        ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchinputs);
    }
    
    public static ConnectApi.FeedItemInput createFeed(String inputText, Id mentionId, Id recordId) {
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        mentionSegmentInput.id = mentionId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);

        textSegmentInput.text = inputText;
        messageBodyInput.messageSegments.add(textSegmentInput);

        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = recordId == null ? 'me' : recordId;
        return feedItemInput;
    }
}