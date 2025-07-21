// Shape of incoming data
public without sharing class PostingData {
  public String groupId;
  public Map<String, String> accountInfo = null;
  public Map<String, String> groupInfo = null;
  public PostingData() {
    accountInfo = new Map<String, String>();
    groupInfo = new Map<String, String>();
  }
}