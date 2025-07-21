public with sharing class Account_Parser extends QItem_BaseParser {
  public LVGO__Account__c Acct { get; set; }
  public String TdhAcctId { get; set; }
  public String RecordType { get; set; }
  public Account_Parser() {
    super();
    Acct = new LVGO__Account__c();
  }

  public override void Parse(JSONParser parser) {
    Acct = new LVGO__Account__c();
    SObject acctObj = (SObject) Acct;
    Map<String, String> acctEtlMap = createMapping('LVGO__Account__c');
    Map<String, Map<String, String>> valueMapping = pickListMapping(
      'LVGO__Account__c'
    );
    while (parser.nextToken() != System.JSONToken.END_OBJECT) {
      if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
        String fieldName = parser.getText();
        System.debug('Account_Parser FieldName ' + fieldName);
        if (acctEtlMap.containsKey(fieldName)) {
          String mappedFieldName = acctEtlMap.get(fieldName);
          System.debug('Account Parser MappedfieldName ' + mappedFieldName);
          if (fieldName != 'Id')
            fieldDeltas.add(mappedFieldName);
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            String fieldValue = parser.getText();
            if (valueMapping.containsKey(acctEtlMap.get(fieldName))) {
              fieldValue = valueMapping.get(acctEtlMap.get(fieldName))
                .get(fieldValue);
            }
            if (fieldName == 'Id')
              TdhAcctId = parser.getText();
            if (
              fieldName == 'Guid__c' &&
              (String.isBlank(fieldValue) || !MB_QxfrUtils.isGuid(fieldValue))
            ) {
              parsingErrors.put('Guid__c', 'Blank or invalid.');
            }
            if (fieldName == 'OwnerId') {
              if (getOwner(fieldValue) != null) {
                acctObj.put(
                  mappedFieldName,
                  FetchTypedValue(
                    'LVGO__Account__c',
                    mappedFieldName,
                    getOwner(fieldValue)
                  )
                );
              } else {
                parsingErrors.put(
                  'Account OwnerId',
                  'User Id is invalid in LVN.'
                );
              }
            } else if (fieldName == 'CIM__c') {
              if (getUserId(fieldValue) != null) {
                acctObj.put(
                  mappedFieldName,
                  FetchTypedValue(
                    'LVGO__Account__c',
                    mappedFieldName,
                    getUserId(fieldValue)
                  )
                );
              } else {
                parsingErrors.put('CIM__c', 'User Id is invalid in LVN.');
              }
            } else if (fieldName == 'Account_Manager__c') {
              if (getUserId(fieldValue) != null) {
                acctObj.put(
                  mappedFieldName,
                  FetchTypedValue(
                    'LVGO__Account__c',
                    mappedFieldName,
                    getUserId(fieldValue)
                  )
                );
              } else {
                parsingErrors.put(
                  'Account_Manager__c',
                  'User Id is invalid in LVN.'
                );
              }
            } else {
              system.debug('FieldValue ' + fieldValue);
              acctObj.put(
                mappedFieldName,
                FetchTypedValue('LVGO__Account__c', mappedFieldName, fieldValue)
              );
            }
          } else {
            acctObj.put(mappedFieldName, null);
          }
        } else {
          switch on fieldName {
            when 'Livongo_Account_Record_Type__c' {
              if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                String fieldValue = parser.getText();
                RecordType = fieldValue;
              }
            }
            when else {
              System.debug(LoggingLevel.WARN, 'Ignore field: ' + fieldName);
              consumeObject(parser);
            }
          }
        }
      }
    }
  }

  public static Boolean CalculateDelta(
    Set<String> fields,
    LVGO__Account__c shellAcct,
    LVGO__Account__c existingAcct
  ) {
    Boolean isUpdate = false;
    for (String field : fields) {
      if (
        field == 'LVGO__Payer_Lines_of_Business__c' &&
        shellAcct.get(field) != null
      ) {
        if (
          existingAcct.get(field) == null ||
          !String.valueOf(existingAcct.get(field))
            .contains(String.valueOf(shellAcct.get(field)))
        ) {
          String currentValue = existingAcct.get(field) != null
            ? String.valueOf(existingAcct.get(field))
            : '';
          existingAcct.put(field, shellAcct.get(field) + ';' + currentValue);
          isUpdate = true;
        }
      } else if (shellAcct.get(field) != existingAcct.get(field)) {
        existingAcct.put(field, shellAcct.get(field));
        isUpdate = true;
      }
    }
    return isUpdate;
  }
}