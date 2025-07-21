public class Contact_Parser extends QItem_BaseParser {
  public List<LVGO__Contact__c> conList { get; set; }
  public Contact_Parser() {
    super();
    conList = new List<LVGO__Contact__c>();
  }

  public override void Parse(JSONParser parser) {
    if (parser.getCurrentToken() == null)
      parser.nextToken();
    while (parser.nextToken() != System.JSONToken.END_ARRAY) {
      LVGO__Contact__c tmpContact = new LVGO__Contact__c();
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String fieldName = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            String fieldValue = parser.getText();
            Map<String, String> conEtlMap = createMapping('LVGO__Contact__c');
            if (conEtlMap.containsKey(fieldName)) {
              String mappedFieldName = conEtlMap.get(fieldName);
              fieldDeltas.add(mappedFieldName);
              tmpContact.put(
                mappedFieldName,
                FetchTypedValue('LVGO__Contact__c', mappedFieldName, fieldValue)
              );
            } else {
              System.debug(LoggingLevel.WARN, 'Ignore field: ' + fieldName);
              consumeObject(parser);
            }
          }
        }
      }
      conList.add(tmpContact);
    }
  }
}