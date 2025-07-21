public class F1BWelcomeKitParser extends F1BBaseParser {
  // TODO: Cleanup instance variables replaced by sobject
  public String DisclaimerClient { get; set; }
  public String DisclaimerTeladoc { get; set; }

  public F1BWelcomeKitParser() {
    super();
  }
  public void Parse(JSONParser parser, Mbr_Group__c targetGroup) {
    while (parser.nextToken() != System.JSONToken.END_OBJECT) {
      if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
        List<String> f1bKeyWord = F1b_Remove_Setting__c.getOrgDefaults()
          .Key_Word__c.split(';');
        String fieldName = parser.getText();
        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
          String fieldValue = parser.getText();
          if (grpWKEtlMap.containsKey(fieldName)) {
            String mappedFieldName = grpWKEtlMap.get(fieldName);
            fieldDeltas.add(mappedFieldName);
            if (f1bKeyWord.contains(fieldValue.toUpperCase().trim())) {
              targetGroup.put(
                mappedFieldName,
                FetchTypedValue('Mbr_Group__c', mappedFieldName, null)
              );
            } else {
              targetGroup.put(
                mappedFieldName,
                FetchTypedValue('Mbr_Group__c', mappedFieldName, fieldValue)
              );
            }
          } else {
            System.debug(
              LoggingLevel.WARN,
              'Contact_Z consuming unrecognized property: ' + fieldName
            );
            consumeObject(parser);
          }

          switch on fieldName {
            when 'RetroFlag' {
              targetGroup.Wk_Retroactive__c = yieldBoolean(
                'RetroFlag',
                parser.getText()
              );
              fieldDeltas.add('Wk_Retroactive__c');
            }
            when 'CardLogo' {
              targetGroup.Wk_Card_Includes_Logo__c = yieldBoolean(
                'CardLogo',
                parser.getText()
              );
              fieldDeltas.add('Wk_Card_Includes_Logo__c');
            }
            when 'IncludesInsert' {
              targetGroup.Wk_Includes_Insert__c = yieldBoolean(
                'IncludesInsert',
                parser.getText()
              );
              fieldDeltas.add('Wk_Includes_Insert__c');
            }
            when 'CoBrandLogo' {
              try {
                if (parser.getText() == 'Y' || parser.getText() == 'y')
                  targetGroup.Co_Brand_with_Logo__c = 'Yes';
                else if (parser.getText() == 'N' || parser.getText() == 'n')
                  targetGroup.Co_Brand_with_Logo__c = 'No';
              } catch (exception e) {
                if (parser.getBooleanValue())
                  targetGroup.Co_Brand_with_Logo__c = 'Yes';
                else
                  targetGroup.Co_Brand_with_Logo__c = 'No';
              }
              fieldDeltas.add('Co_Brand_with_Logo__c');
            }
            when 'DisclaimerClient' {
              if (f1bKeyWord.contains(parser.getText().toUpperCase().trim())) {
                DisclaimerClient = null;
              } else {
                DisclaimerClient = parser.getText();
              }
            }
            when 'DisclaimerTeladoc' {
              if (f1bKeyWord.contains(parser.getText().toUpperCase().trim())) {
                DisclaimerTeladoc = null;
              } else {
                DisclaimerTeladoc = parser.getText();
              }
            }
            when else {
              System.debug(
                LoggingLevel.WARN,
                'WelcomeKit_Z consuming unrecognized property: ' + fieldName
              );
              consumeObject(parser);
            }
          }
        }
      }
    }
    System.debug(LoggingLevel.FINE, 'WelcomeKit: ' + parsingErrors);
  }

  private static Map<String, String> grpWKEtlMap = new Map<String, String>{
    'PrintMailClass' => 'Shipping_Class__c',
    'TemplateID' => 'Wk_Template__c',
    'SendDate' => 'Wk_Send_Card_Date__c',
    'RetroDate' => 'Wk_Retroactive_Date__c',
    'CardIssuedTo' => 'Wk_Mail_To__c',
    'CardTemplate' => 'Card_Template__c',
    'CoBrandLogo' => 'Co_Brand_With_Logo__c',
    'CommunicationMode' => 'Communication_Mode__c',
    'IDCardFront1' => 'Mk_IdcardFront1__c',
    'TeladocBrand' => 'Service_Brand__c'
  };
}