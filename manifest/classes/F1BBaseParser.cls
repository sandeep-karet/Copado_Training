public virtual class F1BBaseParser {
  public Map<String, String> parsingErrors = new Map<String, String>();
  public Set<String> fieldDeltas = new Set<String>();
  public Boolean needUpdate;
  public F1BBaseParser() {
    parsingErrors = new Map<String, String>();
  }
  public virtual void Parse(JSONParser parser) {
  }
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
  public Object FetchTypedValue(
    String objectName,
    String fieldName,
    String StringValue
  ) {
    String fieldTypeName = ObjectInfo.TypeForField(objectName, fieldName);
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
}