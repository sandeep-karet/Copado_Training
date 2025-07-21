public with sharing class RevertUserEmailsBatchable implements Database.Batchable<SObject> {
  public Set<Id> userIds = new Set<Id>();
  String query;

  public RevertUserEmailsBatchable(Set<Id> userIds) {
    this.userIds = userIds;
    query = 'SELECT ID,Username,Email FROM USER WHERE Id in:userIds';
  }

  public Database.QueryLocator start(Database.BatchableContext context) {
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext context, List<User> users) {
    for (User u : users) {
      System.resetPassword(u.id, true);
    }
  }

  public void finish(Database.BatchableContext context) {
    System.debug('RevertUserEmailsBatchable finish');
  }
}