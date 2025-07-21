public class F1BMainParser extends F1BBaseParser {
  public JSONParser parser;
  public String jsonString { get; set; }
  public Account benefitSponsor { get; set; }
  public F1BContactParser f1bcp { get; set; }
  public F1BMbrGroupParser f1bmg { get; set; }
  public static Map<String, String> parsingErrors { get; set; }
  public String MessageId { get; set; }
  public String BenefitSponsorID { get; set; }
  public Datetime EndDate { get; set; }
  public String ParentOrganizationID { get; set; }
  public String ParentOrganizationName { get; set; }
  public String ParentGuid { get; set; }
  public String PrintPhone { get; set; }
  public String PrintUrl { get; set; }
  public Datetime startDate { get; set; }

  public void Parse(String jsonString) {
    parser = System.JSON.createParser(jsonString);
    parsingErrors = new Map<String, String>();
    benefitSponsor = new Account();
    List<String> f1bKeyWord = F1b_Remove_Setting__c.getOrgDefaults()
      .Key_Word__c.split(';');
    SObject bspObject = (SObject) benefitSponsor;
    while (parser.nextToken() != System.JSONToken.END_OBJECT) {
      if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
        String fieldName = parser.getText();
        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
          String fieldValue = parser.getText();
          if (fieldValue.toUpperCase() == 'NULL') {
            continue;
          }
          // Determine where to store the value
          if (acctEtlMap.containsKey(fieldName)) {
            if (fieldName == 'GUID') {
              if (
                String.isBlank(fieldValue) || !GlobalIdUtils.isGuid(fieldValue)
              ) {
                parsingErrors.put('BspGuid', 'Blank or invalid.');
              }
            }

            if (fieldName == 'State') {
              fieldValue = AddressUtils.convertStateFull(fieldValue);
            }
            if (fieldName == 'Country') {
              fieldValue = AddressUtils.convertCountryFull(fieldValue);
            }

            if (fieldName == 'PreferredLanguage') {
              switch on fieldValue {
                when 'EN', 'English' {
                  fieldValue = 'English';
                }
                when 'SP', 'Spanish' {
                  fieldValue = 'Spanish';
                }
                when 'FR', 'French' {
                  fieldValue = 'French';
                }
                when null {
                  fieldValue = null;
                }
                when else {
                  parsingErrors.put('PreferredLanguage', 'invalid.');
                }
              }
            }
            String mappedFieldName = acctEtlMap.get(fieldName);
            fieldDeltas.add(mappedFieldName);
            if (f1bKeyWord.contains(fieldValue.toUpperCase().trim())) {
              bspObject.put(
                mappedFieldName,
                FetchTypedValue('Account', mappedFieldName, null)
              );
            } else {
              bspObject.put(
                mappedFieldName,
                FetchTypedValue('Account', mappedFieldName, fieldValue)
              );
            }
          } else {
            switch on fieldName {
              when 'StartDate' {
                if (
                  f1bKeyWord.contains(parser.getText().toUpperCase().trim())
                ) {
                  startDate = null;
                } else {
                  startDate = parseIsoDate(parser.getText(), fieldName);
                }
              }
              when 'MessageId' {
                if (
                  f1bKeyWord.contains(parser.getText().toUpperCase().trim())
                ) {
                  MessageId = null;
                } else {
                  MessageId = parser.getText();
                }
              }
              when 'BenefitSponsorID' {
                if (
                  f1bKeyWord.contains(parser.getText().toUpperCase().trim())
                ) {
                  BenefitSponsorID = null;
                } else {
                  BenefitSponsorID = parser.getText();
                }
              }
              when 'ParentOrganizationID' {
                if (
                  f1bKeyWord.contains(parser.getText().toUpperCase().trim())
                ) {
                  ParentOrganizationID = null;
                } else {
                  ParentOrganizationID = parser.getText();
                }
              }
              when 'ParentOrganizationName' {
                if (
                  f1bKeyWord.contains(parser.getText().toUpperCase().trim())
                ) {
                  ParentOrganizationName = null;
                } else {
                  ParentOrganizationName = parser.getText();
                }
              }
              when 'EndDate' {
                if (
                  f1bKeyWord.contains(parser.getText().toUpperCase().trim())
                ) {
                  EndDate = null;
                } else {
                  EndDate = parseIsoDate(parser.getText(), fieldName);
                }
              }
              when 'ParentGuid' {
                ParentGuid = parser.getText();
                if (
                  String.isBlank(ParentGuid) ||
                  !GlobalIdUtils.isGuid(ParentGuid)
                ) {
                  parsingErrors.put('ParentGuid', 'Blank or invalid.');
                }
              }
              when 'Group' {
                f1bmg = new F1BMbrGroupParser();
                f1bmg.Parse(parser);
              }
              when 'Contacts' {
                f1bcp = new F1BContactParser();
                f1bcp.Parse(parser);
              }
              when 'PrintPhone' {
                if (
                  f1bKeyWord.contains(parser.getText().toUpperCase().trim())
                ) {
                  PrintPhone = null;
                } else {
                  PrintPhone = parser.getText();
                }
              }
              when 'PrintUrl' {
                if (
                  f1bKeyWord.contains(parser.getText().toUpperCase().trim())
                ) {
                  PrintUrl = null;
                } else {
                  PrintUrl = parser.getText();
                }
              }
              when else {
                consumeObject(parser);
              }
            }
          }
        }
      }
    }

    // parsingErrors.putAll(MemberGroup.groupErrors);
    System.debug(LoggingLevel.FINE, 'Parsing Errors: ' + parsingErrors);
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

  public static Boolean CalculateDelta(
    Set<String> fields,
    Account shellAcct,
    Account existingAcct,
    Account subscriptionAccount
  ) {
    Boolean isSame = false;
    for (String field : fields) {
      if (shellAcct.get(field) != existingAcct.get(field)) {
        existingAcct.put(field, shellAcct.get(field));
        isSame = true;
      }
    }
    if (existingAcct.Account_Manager__c == null) {
      existingAcct.Account_Manager__c = subscriptionAccount.Account_Manager__c;
      isSame = true;
    }
    return isSame;
  }

  private static Map<String, String> acctEtlMap = new Map<String, String>{
    'GUID' => 'Guid__c',
    'BenefitSponsorLegalName' => 'Account_Legal_Name__c',
    'BenefitSponsorFriendlyName' => 'Friendly_Account_Name__c',
    'SalesRep' => 'OwnerId',
    'AccountManager' => 'Account_Manager__c',
    'AccountStatus' => 'Type',
    'Address1' => 'BillingStreet',
    'City' => 'BillingCity',
    'State' => 'BillingState',
    'ZipPostal' => 'BillingPostalCode',
    'Country' => 'BillingCountry',
    //'StartDate' => 'Revenue_Effective_Date__c',
    'PreferredLanguage' => 'Language__c',
    'EmployeeEstLives' => 'Total_US_Employees_Benefits_Enrolled__c',
    'TotalEstLives' => 'Members__c',
    'SpecialInstructions' => 'Special_Instructions_for_Implementatio__c',
    'SFBusinessRegion' => 'Business_Region__c'
  };
}