/**
 * Created by jpatel on 11/7/18.
 */

global class MergeAttachments implements Database.Batchable<sObject> {
  global Database.QueryLocator start(Database.BatchableContext BC) {
    String query = 'select id,former_guid__c,Location_HQ__r.id from location__c';
    return Database.getQueryLocator(query);
  }

  global void execute(
    Database.BatchableContext BC,
    List<Location__c> locationList
  ) {
    List<Account> accounts2Update = new List<Account>();
    List<Account> delAccounts = new List<Account>();

    List<Task> updateTasks = new List<Task>();
    List<Attachment> newAttachmentsList = new List<Attachment>();
    List<Attachment> deleteAttachmentsList = new List<Attachment>();

    Set<String> guids = new Set<String>();
    Map<String, Id> guid2AccountMap = new Map<String, Id>();
    Map<Id, String> acc2GuidMap = new Map<Id, String>();

    for (Location__c loc : locationList) {
      guids.add(loc.former_guid__c);
      guid2AccountMap.put(loc.former_guid__c, loc.id);
    }

    for (Account acc : [
      SELECT id, guid__c
      FROM account
      WHERE guid__c IN :guid2AccountMap.keySet()
    ]) {
      delAccounts.add(acc);
      acc2GuidMap.put(acc.id, acc.guid__c);
    }

    AggregateResult[] attResults = [
      SELECT parentid, count(id)
      FROM attachment
      WHERE parentid IN :acc2GuidMap.keySet()
      GROUP BY parentid
      ORDER BY count(id) DESC
    ];
    for (AggregateResult ar : attResults) {
      System.debug(
        'Account ID ' +
          ar.get('parentid') +
          '  AttachmentCount' +
          ar.get('expr0')
      );
    }

    list<Attachment> atts = [
      SELECT
        id,
        name,
        Body,
        ParentId,
        parent.name,
        ContentType,
        Description,
        IsDeleted,
        IsPrivate
      FROM attachment
      WHERE parentid IN :acc2GuidMap.keySet()
    ];
    System.debug(atts.size());
    for (Attachment att : atts) {
      System.debug(
        'Attachmentid ' +
          att.id +
          ' ParentId ' +
          att.parentid +
          ' ParentName ' +
          att.parent.name
      );
      //att.parentid = guid2AccountMap.get(guid2AccountMap.get(acc2GuidMap.get(att.parentid)));
      System.debug(guid2AccountMap);
      System.debug(
        'ParentId ' + guid2AccountMap.get(acc2GuidMap.get(att.parentid))
      );
      Attachment newattachment = new Attachment(
        name = att.name,
        Body = att.Body,
        ParentId = guid2AccountMap.get(acc2GuidMap.get(att.parentid)),
        ContentType = att.contentType,
        Description = att.Description,
        IsPrivate = att.IsPrivate
      );
      newAttachmentsList.add(newattachment);
      deleteAttachmentsList.add(att);
    }

    if (newAttachmentsList != null && newAttachmentsList.size() > 0) {
      Database.insert(newAttachmentsList, true);
    }

    if (deleteAttachmentsList != null && deleteAttachmentsList.size() > 0) {
      Database.delete(deleteAttachmentsList, true);
    }
  }

  global void finish(Database.BatchableContext BC) {
    // execute any post-processing operations
  }
}