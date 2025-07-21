public without sharing class MsgBusErrorReporting_Controller {
  public class qitemWrapper {
    @auraEnabled
    public String oppId { get; set; }
    @auraEnabled
    public String acctId { get; set; }
    @auraEnabled
    public String createdBy { get; set; }
    @auraEnabled
    public DateTime createdDate { get; set; }
    @auraEnabled
    public String status { get; set; }
    @auraEnabled
    public String result { get; set; }

    public qitemWrapper(
      String oppId,
      String acctId,
      String createdBy,
      DateTime createdDate,
      String status,
      String result
    ) {
      this.oppId = oppId;
      this.acctId = acctId;
      this.createdBy = createdBy;
      this.createdDate = createdDate;
      this.status = status;
      this.result = result;
    }
  }

  public class responseWrapper {
    public Map<String, String> parsing_errors;
    public Map<Id, Q_Item_Exception__c> dml_errors;
  }

  @auraEnabled
  public static List<qitemWrapper> getQItem(
    String oppId,
    Datetime startDate,
    Datetime endDate,
    String createdBy
  ) {
    List<qitemWrapper> qItemList = new List<qitemWrapper>();
    String qitemQuery = 'SELECT Id, createdby.name, createddate, Teladoc_Opp_Id__c, Teladoc_Account_Id__c, payload__c, result__c, status__c FROM Q_Item__c WHERE Opportunity__r.Message_Bus_Error__c = true and status__c = \'Processed with error\'';
    if (oppId != '' && oppId != null) {
      qitemQuery = qitemQuery + ' AND Teladoc_Opp_Id__c = \'' + oppId + '\'';
    }
    if (startDate != null) {
      qitemQuery = qitemQuery + ' AND CreatedDate >=: startDate';
    }
    if (endDate != null) {
      qitemQuery = qitemQuery + ' AND CreatedDate <=: endDate';
    }
    if (createdBy != '' && createdBy != null) {
      qitemQuery =
        qitemQuery +
        ' AND CreatedBy.Name LIKE \'%' +
        createdBy +
        '%\'';
    }

    qitemQuery = qitemQuery + ' ORDER BY CreatedDate DESC';
    List<Q_Item__c> qlist = Database.query(qitemQuery);
    for (Q_Item__c q : qlist) {
      String msg = '';
      responseWrapper errorWrapper = (responseWrapper) JSON.deserialize(
        q.Result__c,
        responseWrapper.class
      );
      for (Q_Item_Exception__c dml : errorWrapper.dml_errors.values()) {
        msg = msg + dml.Short_Desc__c + ': ' + dml.Full_Desc__c + '\n';
      }
      for (String parse : errorWrapper.parsing_errors.values()) {
        msg = msg + parse + '\n';
      }
      qItemList.add(
        new qitemWrapper(
          q.Teladoc_Opp_Id__c,
          q.Teladoc_Account_Id__c,
          q.createdby.name,
          q.createddate,
          q.status__c,
          msg
        )
      );
    }
    return qItemList;
  }
}