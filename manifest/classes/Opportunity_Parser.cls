public with sharing class Opportunity_Parser extends QItem_BaseParser {
  public LVGO__Opportunity__c Opp { get; set; }
  public String TdhOppId { get; set; }
  public Opportunity_Parser() {
    super();
    Opp = new LVGO__Opportunity__c();
  }
  public override void Parse(JSONParser parser) {
    Opp = new LVGO__Opportunity__c();
    SObject oppObj = (SObject) Opp;
    Map<String, String> oppEtlMap = createMapping('LVGO__Opportunity__c');
    for (String key : oppEtlMap.keyset()) {
      system.debug('MappingKey' + key);
    }
    Map<String, Map<String, String>> valueMapping = pickListMapping(
      'LVGO__Opportunity__c'
    );
    while (parser.nextToken() != System.JSONToken.END_OBJECT) {
      if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
        String fieldName = parser.getText();
        System.debug('Opportunity_Parser FieldName ' + fieldName);
        if (oppEtlMap.containsKey(fieldName)) {
          String mappedFieldName = oppEtlMap.get(fieldName);
          System.debug('Opportunity_Parser MappedfieldName ' + mappedFieldName);
          if (fieldName != 'Id')
            fieldDeltas.add(mappedFieldName);
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            String fieldValue = parser.getText();
            if (fieldName == 'Id')
              TdhOppId = parser.getText();
            system.debug('FIELDNAME::' + fieldName);
            if (valueMapping.containsKey(oppEtlMap.get(fieldName))) {
              fieldValue = valueMapping.get(oppEtlMap.get(fieldName))
                .get(fieldValue);
            }
            if (
              fieldName == 'Opp_Guid__c' &&
              (String.isBlank(fieldValue) || !MB_QxfrUtils.isGuid(fieldValue))
            ) {
              parsingErrors.put('OPP_GUID', 'Blank or invalid.');
            }
            if (fieldName == 'OwnerId') {
              if (getOwner(fieldValue) != null) {
                oppObj.put(
                  mappedFieldName,
                  FetchTypedValue(
                    'LVGO__Opportunity__c',
                    mappedFieldName,
                    getOwner(fieldValue)
                  )
                );
              } else {
                parsingErrors.put(
                  'Opportunity OwnerId',
                  'User Id is invalid in LVN.'
                );
              }
            } else if (fieldName == 'CIM__c') {
              if (getUserId(fieldValue) != null) {
                oppObj.put(
                  mappedFieldName,
                  FetchTypedValue(
                    'LVGO__Opportunity__c',
                    mappedFieldName,
                    getUserId(fieldValue)
                  )
                );
              } else {
                parsingErrors.put(
                  'Opportunity_CIM__c',
                  'User Id is invalid in LVN.'
                );
              }
            } else if (fieldName == 'ContractOps_Owner__c') {
              if (getUserId(fieldValue) != null) {
                oppObj.put(
                  mappedFieldName,
                  FetchTypedValue(
                    'LVGO__Opportunity__c',
                    mappedFieldName,
                    getUserId(fieldValue)
                  )
                );
              } else {
                parsingErrors.put(
                  'ContractOps_Owner__c',
                  'User Id is invalid in LVN.'
                );
              }
            } else if (fieldName == 'Client_Manager__c') {
              if (getUserId(fieldValue) != null) {
                oppObj.put(
                  mappedFieldName,
                  FetchTypedValue(
                    'LVGO__Opportunity__c',
                    mappedFieldName,
                    getUserId(fieldValue)
                  )
                );
              } else {
                parsingErrors.put(
                  'Opportunity CSM__c',
                  'User Id is invalid in LVN.'
                );
              }
            } else if (fieldName == 'Num_of_Broker_Rel__c') {
              Integer count = Integer.valueOf(fieldValue);
              if (count == 0) {
                oppObj.put(mappedFieldName, false);
              } else {
                oppObj.put(mappedFieldName, true);
              }
            } else {
              system.debug('FieldValue ' + fieldValue);
              system.debug(
                'MAPPEDFIELDNAME::' +
                  mappedFieldName +
                  '||' +
                  'FIELDVALUE::' +
                  fieldValue
              );
              oppObj.put(
                mappedFieldName,
                FetchTypedValue(
                  'LVGO__Opportunity__c',
                  mappedFieldName,
                  fieldValue
                )
              );
            }
          } else {
            oppObj.put(mappedFieldName, null);
          }
        } else {
          switch on fieldName {
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
    LVGO__Opportunity__c shellOpp,
    LVGO__Opportunity__c existingOpp,
    LVGO__Account__c existingAcct
  ) {
    Boolean isUpdate = false;
    for (String field : fields) {
      if (shellOpp.get(field) != existingOpp.get(field)) {
        existingOpp.put(field, shellOpp.get(field));
        isUpdate = true;
      }
    }
    if (
      existingOpp.LVGO__Account__r.LVGO__TD_Acct_Guid__c !=
      existingAcct.LVGO__TD_Acct_Guid__c
    ) {
      existingOpp.LVGO__Account__c = existingAcct.Id;
      isUpdate = true;
    }
    return isUpdate;
  }
}