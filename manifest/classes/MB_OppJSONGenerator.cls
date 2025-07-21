// TDH SIDE
public without sharing class MB_OppJSONGenerator {
  public static JSONGenerator generateJSONContent(String guid) {
    Msg_Bus_Fields__mdt fields = [
      SELECT
        Account_Fields__c,
        Contact_Fields__c,
        Opportunity_Fields__c,
        Opportunity_Line_Item_Fields__c
      FROM Msg_Bus_Fields__mdt
      WHERE Parser_Name__c = 'Opportunity_Parser'
      LIMIT 1
    ];
    List<String> oppFields = fields.Opportunity_Fields__c.replaceAll('\\s+', '')
      .split(',');
    List<String> acctFields = fields.Account_Fields__c.replaceAll('\\s+', '')
      .split(',');
    //List<String> conFields = fields.Contact_Fields__c.replaceAll( '\\s+', '').split(',');
    List<String> oppliFields = fields.Opportunity_Line_Item_Fields__c.replaceAll(
        '\\s+',
        ''
      )
      .split(',');

    String oppQuery = 'SELECT ';
    for (Integer i = 0; i < oppFields.size(); i++) {
      if (oppFields.size() - 1 == i) {
        oppQuery =
          oppQuery +
          oppFields[i] +
          ' FROM Opportunity WHERE Opp_Guid__c = \'' +
          guid +
          '\'';
      } else {
        oppQuery = oppQuery + oppFields[i] + ', ';
      }
    }
    system.debug(oppQuery);
    Opportunity opp = Database.query(oppQuery);

    String acctQuery = 'SELECT ';
    for (Integer i = 0; i < acctFields.size(); i++) {
      if (acctFields.size() - 1 == i) {
        acctQuery =
          acctQuery +
          acctFields[i] +
          ' FROM Account WHERE Id = \'' +
          opp.AccountId +
          '\'';
      } else {
        acctQuery = acctQuery + acctFields[i] + ', ';
      }
    }
    Account acct = Database.query(acctQuery);

    Account carrierAcct = null;
    String carrierAcctQuery = 'SELECT ';
    if (opp.Primary_Carrier_Account__c != null) {
      String primAcctGuid = [
        SELECT Svc_Acct__r.Guid__c
        FROM Acct_Rel__c
        WHERE Id = :opp.Primary_Carrier__c
      ]
      .Svc_Acct__r.Guid__c;
      for (Integer i = 0; i < acctFields.size(); i++) {
        if (acctFields.size() - 1 == i) {
          carrierAcctQuery =
            carrierAcctQuery +
            acctFields[i] +
            ' FROM Account WHERE Guid__c = \'' +
            primAcctGuid +
            '\'';
        } else {
          carrierAcctQuery = carrierAcctQuery + acctFields[i] + ', ';
        }
      }
      carrierAcct = Database.query(carrierAcctQuery);
    } 
    /*SCDEV-4859 - Changes Begin
    else if (
      opp.Parent_Opportunity__c != null &&
      opp.Parent_Opportunity__r.Sub_Type__c == 'TPA/Reseller'
    ) {
      List<Acct_Rel__c> resellerAcctRel = [
        SELECT Svc_Acct__r.Guid__c
        FROM Acct_Rel__c
        WHERE
          Svc_Acct__c = :opp.Parent_Opportunity__r.AccountId
          AND Relationship_Type__c = 'Contractee'
          AND Contract_Type__c = 'Reseller'
          AND Benefit_Sponsor__c = :opp.AccountId
      ];
      if (!resellerAcctRel.isEmpty()) {
        for (Integer i = 0; i < acctFields.size(); i++) {
          if (acctFields.size() - 1 == i) {
            carrierAcctQuery =
              carrierAcctQuery +
              acctFields[i] +
              ' FROM Account WHERE Guid__c = \'' +
              resellerAcctRel[0].Svc_Acct__r.Guid__c +
              '\'';
          } else {
            carrierAcctQuery = carrierAcctQuery + acctFields[i] + ', ';
          }
        }
        carrierAcct = Database.query(carrierAcctQuery);
      }
    }
	SCDEV-4859 Changes End*/

    String oppliQuery = 'SELECT ';
    for (Integer i = 0; i < oppliFields.size(); i++) {
      if (oppliFields.size() - 1 == i) {
        oppliQuery =
          oppliQuery +
          oppliFields[i] +
          ' FROM OpportunityLineItem WHERE OpportunityId = \'' +
          opp.Id +
          '\'';
      } else {
        oppliQuery = oppliQuery + oppliFields[i] + ', ';
      }
    }
    List<String> byPassList = new List<String>{
      'Primary_Carrier__r.Svc_Acct__r.GUID__c',
      'Parent_Opportunity__r.Sub_Type__c',
      'Parent_Opportunity__r.AccountId'
    };
    List<OpportunityLineItem> oppliList = Database.query(oppliQuery);
    List<OpportunityLineItem> lvnPppliList = new List<OpportunityLineItem>();
    List<String> lvnProdCode = new List<String>();
    List<Product2> prodList = [
      SELECT Id, ProductCode
      FROM Product2
      WHERE Family LIKE '%Livongo%'
    ];
    for (Product2 prod : prodList) {
      lvnProdCode.add(prod.ProductCode);
    }

    for (OpportunityLineItem oppli : oppliList) {
      if (lvnProdCode.contains(oppli.ProductCode)) {
        lvnPppliList.add(oppli);
      }
    }

    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();
    gen.writeStringField('CreatedbyId', UserInfo.getUserId());
    gen.writeStringField('Createddate', String.valueOf(system.now()));

    gen.writeFieldName('Account');
    gen.writeStartObject();
    for (String acctField : acctFields) {
      if (acctField == 'Name') {
        if (acct.get(acctField) == null) {
          gen.writeNullField('Name');
        } else {
          String accName = String.valueOf(acct.get(acctField));
          accName = accName.length() > 80 ? accName.substring(0, 80) : accName;
          gen.writeStringField('Name', accName);
        }
      }
      if (acct.get(acctField) != null) {
        gen.writeStringField(
          acctField,
          (String) String.valueOf(acct.get(acctField))
        );
      } else {
        gen.writeNullField(acctField);
      }
    }
    if (opp.get('Primary_Carrier_LOB__c') != null) {
      gen.writeStringField(
        'LOB',
        (String) String.valueOf(opp.get('Primary_Carrier_LOB__c'))
      );
    } else {
      gen.writeNullField('LOB');
    }
    gen.writeEndObject();

    gen.writeFieldName('Opportunity');
    gen.writeStartObject();
    for (String oppField : oppFields) {
      if (!byPassList.contains(oppField)) {
        if (opp.get(oppField) != null) {
          if (oppField == 'Client_Manager__c') {
            String managerId = [
              SELECT Id
              FROM USER
              WHERE Name = :String.valueOf(opp.get(oppField))
            ]
            .Id;
            gen.writeStringField(oppField, (String) String.valueOf(managerId));
          } else if (oppField == 'Name') {
            if (opp.get('Name') == null) {
              gen.writeNullField('Name');
            } else {
              String OppName = (String.valueOf(opp.get(oppField)));
              OppName = OppName.length() > 80
                ? OppName.substring(0, 80)
                : OppName;
              gen.writeStringField('Name', OppName);
              //gen.writeStringField('Name', (String) (String.valueOf(opp.get(oppField))));
            }
          } else {
            gen.writeStringField(
              oppField,
              (String) String.valueOf(opp.get(oppField))
            );
          }
        } else {
          gen.writeNullField(oppField);
        }
      }
    }
    gen.writeEndObject();

    if (carrierAcct != null) {
      gen.writeFieldName('PrimaryCarrierAccount');
      gen.writeStartObject();
      for (String acctField : acctFields) {
        if (carrierAcct.get(acctField) != null) {
          gen.writeStringField(
            acctField,
            (String) String.valueOf(carrierAcct.get(acctField))
          );
        } else {
          gen.writeNullField(acctField);
        }
      }
      gen.writeEndObject();
    }

    gen.writeFieldName('OpportunityLineItem');
    gen.writeStartArray();
    for (OpportunityLineItem oppli : lvnPppliList) {
      gen.writeStartObject();
      for (String oppliField : oppliFields) {
        system.debug('oppliField:: ' + oppliField);
        switch on oppliField {
          when 'Anchor__c' {
            if (oppli.Anchor__c == null) {
              gen.writeNullField('Anchor');
            } else {
              gen.writeStringField(
                'Anchor',
                (String) String.valueOf(oppli.get(oppliField))
              );
            }
          }
          when 'SBQQ__QuoteLine__r.SBQQ__EffectiveSubscriptionTerm__c' {
            if (
              oppli.SBQQ__QuoteLine__r.SBQQ__EffectiveSubscriptionTerm__c ==
              null
            ) {
              gen.writeNullField('SubscriptionTerm');
            } else {
              gen.writeStringField(
                'SubscriptionTerm',
                (String) String.valueOf(
                  oppli.SBQQ__QuoteLine__r.SBQQ__EffectiveSubscriptionTerm__c
                )
              );
            }
          }
          when 'Membership_fee__c' {
            if (oppli.Membership_fee__c == null) {
              gen.writeNullField('SalesPrice');
            } else {
              gen.writeStringField(
                'SalesPrice',
                (String) String.valueOf(oppli.get(oppliField))
              );
            }
          }
          when 'SBQQ__QuoteLine__r.Parent_Product_Code__c' {
            if (oppli.SBQQ__QuoteLine__r.Parent_Product_Code__c == null) {
              gen.writeNullField('ParentsProductCode');
            } else {
              gen.writeStringField(
                'ParentsProductCode',
                (String) String.valueOf(
                  oppli.SBQQ__QuoteLine__r.Parent_Product_Code__c
                )
              );
            }
          }
          when 'SBQQ__QuoteLine__r.GrandParent_Product_Code__c' {
            if (oppli.SBQQ__QuoteLine__r.GrandParent_Product_Code__c == null) {
              gen.writeNullField('GrandParentsProductCode');
            } else {
              gen.writeStringField(
                'GrandParentsProductCode',
                (String) String.valueOf(
                  oppli.SBQQ__QuoteLine__r.GrandParent_Product_Code__c
                )
              );
            }
          }
          when 'SBQQ__QuoteLine__r.Participant_Quantity__c' {
            if (oppli.SBQQ__QuoteLine__r.Participant_Quantity__c == null) {
              gen.writeNullField('ParticipantQuantity');
            } else {
              gen.writeStringField(
                'ParticipantQuantity',
                (String) String.valueOf(
                  Math.Round(oppli.SBQQ__QuoteLine__r.Participant_Quantity__c)
                )
              );
            }
          }
          when 'SBQQ__QuoteLine__r.Admin_Fee__c' {
            if (oppli.SBQQ__QuoteLine__r.Admin_Fee__c == null) {
              gen.writeNullField('AdminFee');
            } else {
              gen.writeStringField(
                'AdminFee',
                (String) String.valueOf(
                  Math.Round(oppli.SBQQ__QuoteLine__r.Admin_Fee__c)
                )
              );
            }
          }
          when 'SBQQ__QuoteLine__r.At_Risk_PPPM__c' {
            if (oppli.SBQQ__QuoteLine__r.At_Risk_PPPM__c == null) {
              gen.writeNullField('AtRiskFee');
            } else {
              gen.writeStringField(
                'AtRiskFee',
                (String) String.valueOf(
                  Math.Round(oppli.SBQQ__QuoteLine__r.At_Risk_PPPM__c)
                )
              );
            }
          }
          when 'SBQQ__QuoteLine__r.Up_Front_Fee__c' {
            if (oppli.SBQQ__QuoteLine__r.Up_Front_Fee__c == null) {
              gen.writeNullField('UpFrontFee');
            } else {
              gen.writeStringField(
                'UpFrontFee',
                (String) String.valueOf(
                  Math.Round(oppli.SBQQ__QuoteLine__r.Up_Front_Fee__c)
                )
              );
            }
          }
          when 'SBQQ__QuoteLine__r.Disable_Teletherapy__c' {
            if (oppli.SBQQ__QuoteLine__r.Disable_Teletherapy__c == null) {
              gen.writeNullField('DisableTeletherapy');
            } else {
              gen.writeStringField(
                'DisableTeletherapy',
                (String) String.valueOf(
                  oppli.SBQQ__QuoteLine__r.Disable_Teletherapy__c
                )
              );
            }
          }
          when 'SBQQ__QuoteLine__r.Disable_Coaching__c' {
            if (oppli.SBQQ__QuoteLine__r.Disable_Coaching__c == null) {
              gen.writeNullField('DisableBHCoaching');
            } else {
              gen.writeStringField(
                'DisableBHCoaching',
                (String) String.valueOf(
                  oppli.SBQQ__QuoteLine__r.Disable_Coaching__c
                )
              );
            }
          }
          when 'Net_ARR__c' {
            if (oppli.Net_ARR__c == null) {
              gen.writeNullField('NetArr');
            } else {
              gen.writeStringField(
                'NetArr',
                (String) String.valueOf(oppli.get(oppliField))
              );
            }
          }
    	 when 'Product_Rollup__c' {                                   //Added By rushikesh 5537
            if (oppli.Product_Rollup__c == null) {
              gen.writeNullField('ProductRollup');
            } else {
              gen.writeStringField(
                'ProductRollup',
                (String) String.valueOf(oppli.get(oppliField))
              );
            }
          } 
          when 'Name' {
            if (oppli.Name == null) {
              gen.writeNullField('Name');
            } else {
              String oppLiName = String.valueOf(oppli.get(oppliField));
              oppLiName = oppLiName.length() > 80
                ? oppLiName.substring(0, 80)
                : oppLiName;
              gen.writeStringField('Name', oppLiName);
              //gen.writeStringField('Name', (String) (String.valueOf(oppli.get(oppliField))));
            }
          }
          when else {
            if (oppli.get(oppliField) != null) {
              system.debug('oppliField::: ' + oppliField);
              system.debug(
                'fieldName:: ' + (String) String.valueOf(oppli.get(oppliField))
              );
              gen.writeStringField(
                oppliField,
                (String) String.valueOf(oppli.get(oppliField))
              );
            } else {
              gen.writeNullField(oppliField);
            }
          }
        }
      }
      gen.writeEndObject();
    }
    gen.writeEndArray();
    /*
        gen.writeFieldName('Contact');
        gen.writeStartArray();
        for(Contact con : conList){
            gen.writeStartObject();
            for (String conField : conFields) {
                if (con.get(conField) != null) {
                    gen.writeStringField(conField, (String) con.get(conField));
                }
            }
            gen.writeEndObject();
        }
        gen.writeEndArray();
        */
    gen.writeEndObject();

    String pretty = gen.getAsString();
    system.debug(pretty);

    return gen;
  }

  public static JSONGenerator generateDeleteJSON(String guid) {
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();
    gen.writeStringField('CreatedbyId', UserInfo.getUserId());
    gen.writeStringField('Createddate', String.valueOf(system.now()));

    gen.writeFieldName('Opportunity');
    gen.writeStartObject();
    gen.writeStringField('Opp_Guid__c', (String) guid);
    gen.writeEndObject();
    return gen;
  }
}