public class QItem_Opp_Parser extends QItem_BaseParser {
  public JSONParser parser;
  public String jsonString { get; set; }
  public Account_Parser QItemAcct { get; set; }
  public Opportunity_Parser QItemOpp { get; set; }
  public Account_Parser QItemCarrierAcct { get; set; }
  public Contact_Parser QItemCon { get; set; }
  public OppLineItem_Parser QItemOppli { get; set; }
  public static Map<String, String> parsingErrors { get; set; }
  public String CreatedbyId { get; set; }
  public String Createddate { get; set; }

  public void Parse(String jsonString) {
    parser = System.JSON.createParser(jsonString);
    parsingErrors = new Map<String, String>();
    while (parser.nextToken() != System.JSONToken.END_OBJECT) {
      if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
        String fieldName = parser.getText();
        System.debug('Field Name ' + fieldName);
        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
          String fieldValue = parser.getText();
          System.debug('Field Value ' + fieldValue);
          if (fieldValue.toUpperCase() == 'NULL') {
            continue;
          }
          switch on fieldName {
            when 'CreatedbyId' {
              CreatedbyId = parser.getText();
            }
            when 'Createddate' {
              Createddate = parser.getText();
            }
            when 'Account' {
              QItemAcct = new Account_Parser();
              QItemAcct.Parse(parser);
            }
            when 'Opportunity' {
              QItemOpp = new Opportunity_Parser();
              QItemOpp.Parse(parser);
            }
            when 'PrimaryCarrierAccount' {
              QItemCarrierAcct = new Account_Parser();
              QItemCarrierAcct.Parse(parser);
            }
            when 'OpportunityLineItem' {
              QItemOppli = new OppLineItem_Parser();
              QItemOppli.Parse(parser);
            }
            when 'Contact' {
              QItemCon = new Contact_Parser();
              QItemCon.Parse(parser);
            }
            when else {
              System.debug(LoggingLevel.WARN, 'Ignore field : ' + fieldName);
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