public class StringUtilsBatch implements Database.Batchable<SObject>, Database.Stateful {
  private String queryString;
  public String fieldName;
  public String objectName;
  public Integer updatedRecords;
  public StringUtilsBatch(String objectName, String fieldName) {
    this.fieldName = fieldName;
    this.objectName = objectName;
    queryString = 'Select Id,' + fieldName + ' from ' + objectName;
    updatedRecords = 0;
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(queryString);
  }

  public void execute(Database.BatchableContext BC, List<sObject> scope) {
    for (sobject s : scope) {
      String updatedString;
      if (s.get(fieldName) != null) {
        updatedString = String.valueof(s.get(fieldName));
        if (
          updatedString.contains('\\n') ||
          updatedString.contains('\\r') ||
          updatedString.contains('\\t')
        ) {
          updatedString = updatedString.replace('\\n', '\n')
            .replace('\\r', '\r');
          updatedString = updatedString.replace('\\t', ' ');
          s.put(fieldName, updatedString);
        }
      }
    }

    List<Database.SaveResult> results = Database.update(scope, false);
    for (Database.SaveResult r : results) {
      if (r.isSuccess()) {
        updatedRecords += 1;
      }
    }
  }

  public void finish(Database.BatchableContext BC) {
    System.debug('Records updated' + updatedRecords);
  }
}