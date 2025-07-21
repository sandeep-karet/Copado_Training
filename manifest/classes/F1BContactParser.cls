public class F1BContactParser extends F1BBaseParser {
  public List<Map<String, Contact>> bspContacts { get; set; }
  // Control of parser starts here
  public F1BContactParser() {
    super();
    bspContacts = new List<Map<String, Contact>>();
  }

  public override void Parse(JSONParser parser) {
    if (parser.getCurrentToken() == null)
      parser.nextToken();
    while (parser.nextToken() != System.JSONToken.END_ARRAY) {
      Contact tmpContact = new Contact();
      Map<String, Contact> tmpConMap = new Map<String, Contact>();
      String typeKey;
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String fieldName = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            String fieldValue = parser.getText();
            if (conEtlMap.containsKey(fieldName)) {
              String mappedFieldName = conEtlMap.get(fieldName);
              fieldDeltas.add(mappedFieldName);
              tmpContact.put(
                mappedFieldName,
                FetchTypedValue('Contact', mappedFieldName, fieldValue)
              );
            } else {
              switch on fieldName {
                when 'Type' {
                  typeKey = parser.getText();
                }
              }
              System.debug(
                LoggingLevel.WARN,
                'Contact_Z consuming unrecognized property: ' + fieldName
              );
              consumeObject(parser);
            }
          }
        }
      }
      tmpConMap.put(typeKey, tmpContact);
      bspContacts.add(tmpConMap);
    }
  }

  private static Map<String, String> conEtlMap = new Map<String, String>{
    'FirstName' => 'FirstName',
    'LastName' => 'LastName',
    'Email' => 'Email',
    'Phone' => 'Phone'
  };
}