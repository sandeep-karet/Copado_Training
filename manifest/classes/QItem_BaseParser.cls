public without sharing virtual class QItem_BaseParser {
  public Map<String, String> parsingErrors = new Map<String, String>();
  public Set<String> fieldDeltas = new Set<String>();
  public QItem_BaseParser() {
    parsingErrors = new Map<String, String>();
  }
  public virtual void Parse(JSONParser parser) {
  }

  public Map<String, String> createMapping(String objApi) {
    List<Msg_Bus_Mapping__mdt> fieldMapping = [
      SELECT LVN_API_Name__c, TDH_API_Name__c
      FROM Msg_Bus_Mapping__mdt
      WHERE Obj_Api__c = :objApi
    ];
    Map<String, String> fieldMap = new Map<String, String>();
    for (Msg_Bus_Mapping__mdt mapping : fieldMapping) {
      fieldMap.put(mapping.TDH_API_Name__c, mapping.LVN_API_Name__c);
    }
    return fieldMap;
  }

  public Map<String, Map<String, String>> pickListMapping(String objApi) {
    List<Msg_Bus_Picklist_Mapping__mdt> fieldMapping = [
      SELECT PickList_Field_API_Name__c, PickList_Mapping__c
      FROM Msg_Bus_Picklist_Mapping__mdt
      WHERE Object_API_Name__c = :objApi
    ];
    Map<String, Map<String, String>> valueMapping = new Map<String, Map<String, String>>();
    for (Msg_Bus_Picklist_Mapping__mdt mapping : fieldMapping) {
      Map<String, String> picklistMap = (Map<String, String>) JSON.deserialize(
        mapping.PickList_Mapping__c,
        Map<String, String>.class
      );
      valueMapping.put(mapping.PickList_Field_API_Name__c, picklistMap);
    }
    return valueMapping;
  }

  public String getUserId(String tdhId) {
    //List<User> lvnUser = [SELECT Id FROM User WHERE Source_ID__c =: tdhId];
    List<User> lvnUser = [SELECT Id FROM User WHERE id = :tdhId];
    if (lvnUser.size() == 1) {
      return lvnUser[0].Id;
    } else {
      return null;
    }
  }
  public String getOwner(String tdhId) {
    String defaultOwnerEmail = System.Label.Default_LV_Owner;
    String mulesoftIntegrationUser = System.Label.Mulesoft_Integration_User;
    Boolean isOwnerInactive = false;
    String DefaultownerId;
    //for(User u : [Select Id,IsActive,Username From User Where Username = :defaultOwnerEmail OR Id = :tdhId]) {
    for (User u : [
      SELECT Id, IsActive, Username
      FROM User
      WHERE
        (Username = :defaultOwnerEmail
        OR Id = :tdhId)
        AND Username != :mulesoftIntegrationUser
    ]) {
      if (u.Id == tdhId && !u.isActive)
        isOwnerInactive = true;
      if (u.Username == defaultOwnerEmail)
        DefaultownerId = u.Id;
    }
    if (isOwnerInactive) {
      return DefaultownerId;
    } else {
      return tdhId;
    }
  }

  // yieldBoolean - helper function to coerce a string into a boolean using TDH practices
  public Boolean yieldBoolean(String fieldName, String fieldValue) {
    Boolean returnValue = false;
    try {
      if (fieldValue == 'Y') {
        returnValue = true;
      } else if (fieldValue == 'N') {
        returnValue = false;
      } else {
        returnValue = Boolean.valueOf(fieldValue);
      }
    } catch (System.Exception sx) {
      parsingErrors.put(
        'INVALID_BOOLEAN',
        fieldName + '=' + fieldValue + ': ' + sx
      );
    }
    return returnValue;
  }
  // Recursive object parser
  public void consumeObject(System.JSONParser parser) {
    Integer depth = 0;
    do {
      System.JSONToken curr = parser.getCurrentToken();
      if (
        curr == System.JSONToken.START_OBJECT ||
        curr == System.JSONToken.START_ARRAY
      ) {
        depth++;
      } else if (
        curr == System.JSONToken.END_OBJECT ||
        curr == System.JSONToken.END_ARRAY
      ) {
        depth--;
      }
    } while (depth > 0 && parser.nextToken() != null);
  }
  // Coerce field value into local metadata type including limited conversion
  public Object FetchTypedValue(
    String objectName,
    String fieldName,
    String StringValue
  ) {
    String fieldTypeName = TypeForField(objectName, fieldName);
    switch on fieldTypeName {
      when 'STRING', 'ID' {
        return StringValue;
      }
      when 'BOOLEAN' {
        if (String.isBlank(StringValue)) {
          return false;
        } else {
          return Boolean.valueOf(StringValue);
        }
      }
      when 'INTEGER' {
        if (String.isBlank(StringValue)) {
          return 0;
        } else {
          return Integer.valueOf(StringValue);
        }
      }
      when 'DATETIME' {
        if (String.isBlank(StringValue)) {
          return null;
        } else {
          return parseIsoDate(StringValue, fieldName);
        }
      }
      when 'DATE' {
        if (String.isBlank(StringValue)) {
          return null;
        } else {
          return Date.valueOf(parseIsoDate(StringValue, fieldName));
        }
      }
      when 'DECIMAL' {
        if (String.isBlank(StringValue))
          return 0;
        else {
          return Decimal.valueOf(StringValue);
        }
      }
      when 'DOUBLE' {
        if (String.isBlank(StringValue))
          return 0;
        else {
          return Double.valueOf(StringValue);
        }
      }
    }
    return null;
  }

  public Datetime parseIsoDate(String dateString, String key) {
    if (dateString == null) {
      return null;
    }
    Datetime newDateTime = null;
    try {
      dateString = dateString.replace('T', ' ').substring(0, 19);
      newDateTime = Datetime.valueOfGmt(dateString);
    } catch (Exception ex) {
      parsingErrors.put('INVALID_DATE_TIME', key + ': ' + ex);
      return null;
    }
    return newDateTime;
  }

  private static Map<String, Map<String, String>> mappedObjInfo = new Map<String, Map<String, String>>();
  public static String TypeForField(String objectName, String fieldName) {
    String tmpObjName = objectName.toUpperCase();
    String tmpFldName = fieldName.toUpperCase();
    // Check if we already have a map for this object. If not make one
    fieldsForObject(objectName);
    Map<String, String> tmpMap = mappedObjInfo.get(tmpObjName);
    if (tmpMap.containsKey(tmpFldName))
      return tmpMap.get(tmpFldName);
    else
      return null;
  }

  public static Map<String, String> fieldsForObject(String objectName) {
    String tmpObjName = objectName.toUpperCase();
    // Check if we already have a map for this object. If not make one
    if (!mappedObjInfo.containsKey(tmpObjName)) {
      System.debug(
        LoggingLevel.FINEST,
        'OBJECT MAP NOT FOUND FOR: ' + tmpObjName
      );
      List<DescribeSObjectResult> dsor = Schema.describeSObjects(
        new List<String>{ tmpObjName }
      );
      for (DescribeSObjectResult tmpDsor : dsor) {
        Map<String, String> tmpMap = new Map<String, String>();
        Map<String, SObjectField> mappedSof = tmpDsor.fields.getMap();
        for (SObjectField tmpSof : mappedSof.values()) {
          DescribeFieldResult tmpDfr = tmpSof.getDescribe();
          tmpMap.put(tmpDfr.name.toUpperCase(), tmpDfr.soapType.name());
        }
        mappedObjInfo.put(tmpObjName, tmpMap);
      }
    }

    return mappedObjInfo.get(tmpObjName);
  }
}