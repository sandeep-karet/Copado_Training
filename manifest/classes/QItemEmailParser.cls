// TDH Side: Parser for Email notification
public class QItemEmailParser extends QItem_BaseParser {
  public JSONParser parser;
  public Opportunity_Parser QItemOpp { get; set; }

  public void Parse(String jsonString) {
    parser = System.JSON.createParser(jsonString);
    parsingErrors = new Map<String, String>();
    while (parser.nextToken() != System.JSONToken.END_OBJECT) {
      if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
        String fieldName = parser.getText();
        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
          String fieldValue = parser.getText();
          if (fieldValue.toUpperCase() == 'NULL') {
            continue;
          }
          switch on fieldName {
            when 'Opportunity' {
              QItemOpp = new Opportunity_Parser();
              QItemOpp.Parse(parser);
            }
            when else {
              System.debug(
                LoggingLevel.WARN,
                'JSON2Apex consuming unrecognized property: ' + fieldName
              );
              consumeObject(parser);
            }
          }
        }
      }
    }
  }

  public static void consumeObject(System.JSONParser parser) {
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
}