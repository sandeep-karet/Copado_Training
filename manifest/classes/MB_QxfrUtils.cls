/**
 * Name: MB_QxfrUtils
 *
 * JIRA          CHANGED DATE    CHANGED BY         DESCRIPTION
 *---------------------------------------------------------------------------------
 * SCDEV-3337    13-jul-2023		Rajalakshmi R       LV Org Msg bus fix
 */

public class MB_QxfrUtils {
  public static List<Q_Item_Exception__c> exceptionsFound { get; set; }
  public static LVGO__Account__c existingAcct { get; set; }
  public static LVGO__Opportunity__c existingOpp { get; set; }
  public static Map<String, List<LVGO__OpportunityLineItem__c>> existingOppli {
    get;
    set;
  }
  public static Map<String, LVGO__OpportunityLineItem__c> newOppli { get; set; }
  public static LVGO__Account__c contractAcct { get; set; }
  public static LVGO__Account__c LvnAcct { get; set; }
  public static String LvnPriceBookId { get; set; }
  public static Id DownMarketId { get; set; }
  public static final String TD_ACCID = System.Label.MB_TdAccId;
  public class responseWrapper {
    public Map<String, String> parsing_errors;
    public Map<Id, Q_Item_Exception__c> dml_errors;
  }

  public static void LogException(
    Id qItemId,
    String objectName,
    String exceptionType,
    String shortDesc,
    String fullDesc
  ) {
    if (exceptionsFound == null) {
      exceptionsFound = new List<Q_Item_Exception__c>();
    }
    exceptionsFound.add(
      new Q_Item_Exception__c(
        Q_Item__c = qItemId,
        Exception_Type__c = exceptionType,
        Short_Desc__c = shortDesc,
        SObject__c = objectName,
        Full_Desc__c = fullDesc
      )
    );
    system.debug(LoggingLevel.FINER, shortDesc + fullDesc);
  }

  public static void updateLvnAcctId(String lvId, String tdId, String Source) {
    List<Account> acct = [SELECT Id FROM Account WHERE Id = :tdId LIMIT 1];
    if (!acct.isEmpty()) {
      system.debug('LVID in Acc::: ' + lvId);
      //SCDEV-3337 Changes Begin
      if (Source == 'LVNORG')
        acct[0].LVN_Account_URL__c = lvId;
      else
        acct[0].LV_Island_Account_URL__c = lvId;
      //SCDEV-3337 Chanes End
      update acct;
    }
  }

  public static void updateSourceId(String lvId, String tdId, String Source) {
    List<Opportunity> opp = [
      SELECT Id
      FROM Opportunity
      WHERE Id = :tdId
      LIMIT 1
    ];
    if (!opp.isEmpty()) {
      //SCDEV-3337 Changes Begin
      if (Source == 'LVNORG')
        opp[0].Source_Id__c = lvId;
      else
        opp[0].LV_Island_Source_Id__c = lvId;
      //SCDEV-3337 Changes End
      update opp;
    }
  }

  public static String parseError(String result) {
    String msg = '';
    responseWrapper errorWrapper = (responseWrapper) JSON.deserialize(
      result,
      responseWrapper.class
    );
    for (Q_Item_Exception__c dml : errorWrapper.dml_errors.values()) {
      msg = msg + dml.Short_Desc__c + ': ' + dml.Full_Desc__c + '\n';
    }
    for (String parse : errorWrapper.parsing_errors.values()) {
      msg = msg + parse + '\n';
    }
    return msg;
  }

  public static Boolean checkOppId(String oppId) {
    List<Opportunity> opp = [
      SELECT Id
      FROM Opportunity
      WHERE Id = :oppId
      LIMIT 1
    ];
    return opp.size() == 0 ? false : true;
  }

  public static void CommitDelta() {
    if (exceptionsFound != null) {
      try {
        insert exceptionsFound;
        exceptionsFound.clear();
      } catch (exception e) {
        system.debug(
          LoggingLevel.FINER,
          'QItem Exception insert failed: ' + e.getMessage()
        );
      }
    }
  }

  public static void FetchExistingData(
    QItem_Opp_Parser qitemp,
    String qItemId
  ) {
    List<Msg_Bus_Mapping__mdt> acctField = [
      SELECT LVN_API_Name__c
      FROM Msg_Bus_Mapping__mdt
      WHERE Obj_Api__c = 'LVGO__Account__c'
    ];
    List<Msg_Bus_Mapping__mdt> oppField = [
      SELECT LVN_API_Name__c
      FROM Msg_Bus_Mapping__mdt
      WHERE Obj_Api__c = 'LVGO__Opportunity__c'
    ];
    List<Msg_Bus_Mapping__mdt> oppliField = [
      SELECT LVN_API_Name__c
      FROM Msg_Bus_Mapping__mdt
      WHERE Obj_Api__c = 'LVGO__OpportunityLineItem__c'
    ];
    DownMarketId = [
      SELECT Id
      FROM RecordType
      WHERE SobjectType = 'LVGO__Account__c' AND Name = 'Downmarket Client'
    ]
    .Id;
    // need to confrim this is the correct account
    LvnAcct = [SELECT Id FROM LVGO__Account__c WHERE Name = 'Livongo'];
    LvnPriceBookId = [SELECT Id FROM pricebook2 WHERE Name = 'Livongo'].Id;
    if (qitemp.QItemCarrierAcct != null) {
      List<LVGO__Account__c> contractAccount = [
        SELECT Id
        FROM LVGO__Account__c
        WHERE
          LVGO__TD_Acct_Guid__c = :qitemp.QItemCarrierAcct.Acct.LVGO__TD_Acct_Guid__c
      ];
      if (contractAcct == null) {
        contractAcct = new LVGO__Account__c();
      }
      if (contractAccount.size() != 0) {
        if (contractAccount[0].Id == TD_ACCID) {
          contractAcct = LvnAcct;
        } else {
          contractAcct = contractAccount[0];
        }
      } else if (contractAccount.size() == 0) {
        contractAcct = qitemp.QItemCarrierAcct.Acct;
        contractAcct.Id = null;
        contractacct.RecordTypeId = Schema.Sobjecttype.LVGO__Account__c.getRecordTypeInfosByName()
          .get('Partner Account')
          .getRecordTypeId();
        try {
          insert contractAcct;
        } catch (exception e) {
          LogException(
            qItemId,
            'LVGO__ACCOUNT__C',
            'DML_ERROR',
            'CANNOT_CREATE_PRIMARYCARRIERACCOUNT',
            e.getMessage()
          );
          contractAcct = null;
        }
      }
    } else {
      contractAcct = null;
    }

    String acctQuery = 'SELECT ';
    for (Integer i = 0; i < acctField.size(); i++) {
      if (acctField.size() - 1 == i) {
        acctQuery =
          acctQuery +
          acctField[i].LVN_API_Name__c +
          ' FROM LVGO__Account__c WHERE LVGO__TD_Acct_Guid__c = \'' +
          qitemp.QItemAcct.Acct.LVGO__TD_Acct_Guid__c +
          '\'';
      } else {
        acctQuery = acctQuery + acctField[i].LVN_API_Name__c + ', ';
      }
    }
    List<LVGO__Account__c> oldAcct = Database.query(acctQuery);
    system.debug('oldAcct ' + oldAcct);

    String oppQuery = 'SELECT Id,LVGO__Account__r.LVGO__TD_Acct_Guid__c, LVGO__Pre_Contracting_Contract_Paper__c, LVGO__BillingPartner__c, LVGO__Contract_Path__c, ';
    for (Integer i = 0; i < oppField.size(); i++) {
      if (oppField.size() - 1 == i) {
        oppQuery =
          oppQuery +
          oppField[i].LVN_API_Name__c +
          ' FROM LVGO__Opportunity__c WHERE LVGO__TD_Opp_Guid__c = \'' +
          qitemp.QItemOpp.Opp.LVGO__TD_Opp_Guid__c +
          '\'';
      } else {
        oppQuery = oppQuery + oppField[i].LVN_API_Name__c + ', ';
      }
    }
    List<LVGO__Opportunity__c> oldOpp = Database.query(oppQuery);
    system.debug('oldOPP ' + oldOpp);

    List<LVGO__OpportunityLineItem__c> oldOLI = new List<LVGO__OpportunityLineItem__c>();
    if (oldOpp.size() > 0) {
      String oppliQuery = 'SELECT LVGO__ProductCode__c, LVGO__Product2__c, LVGO__Disable_Teletherapy__c, LVGO__Disable_BH_Coaching__c, ';
      for (Integer i = 0; i < oppliField.size(); i++) {
        if (oppliField.size() - 1 == i) {
          oppliQuery =
            oppliQuery +
            oppliField[i].LVN_API_Name__c +
            ' FROM LVGO__OpportunityLineItem__c WHERE LVGO__Opportunity__c = \'' +
            oldOpp[0].Id +
            '\'';
        } else {
          oppliQuery = oppliQuery + oppliField[i].LVN_API_Name__c + ', ';
        }
      }
      System.debug('OppliQuery ' + oppliQuery);
      oldOLI = Database.query(oppliQuery);
    }

    system.debug('vENU oldOLI ' + oldOLI);

    if (oldAcct.size() > 0) {
      if (existingAcct == null) {
        existingAcct = new LVGO__Account__c();
      }
      existingAcct = oldAcct[0];
    }

    if (oldOpp.size() > 0) {
      if (existingOpp == null) {
        existingOpp = new LVGO__Opportunity__c();
      }
      existingOpp = oldOpp[0];
    }

    if (oldOLI.size() > 0) {
      if (existingOppli == null) {
        existingOppli = new Map<String, List<LVGO__OpportunityLineItem__c>>();
      }
      for (LVGO__OpportunityLineItem__c oppli : oldOLI) {
        oppli.LVGO__UnitPrice__c = oppli.LVGO__UnitPrice__c == null
          ? 0
          : oppli.LVGO__UnitPrice__c;
        oppli.LVGO__Quantity__c = oppli.LVGO__Quantity__c == null
          ? 0
          : oppli.LVGO__Quantity__c;
        oppli.LVGO__Product_Participants__c = oppli.LVGO__Product_Participants__c ==
          null
          ? 0
          : oppli.LVGO__Product_Participants__c;
        oppli.LVGO__Gross_Program_ARR_Copy__c = oppli.LVGO__Gross_Program_ARR_Copy__c ==
          null
          ? 0
          : oppli.LVGO__Gross_Program_ARR_Copy__c;
        oppli.LVGO__Estimated_Partner_Admin_Fees__c = oppli.LVGO__Estimated_Partner_Admin_Fees__c ==
          null
          ? 0
          : oppli.LVGO__Estimated_Partner_Admin_Fees__c;
        oppli.LVGO__Up_Front_Per_Member__c = oppli.LVGO__Up_Front_Per_Member__c ==
          null
          ? 0
          : oppli.LVGO__Up_Front_Per_Member__c;
        oppli.LVGO__Estimated_At_Risk_PPPM__c = oppli.LVGO__Estimated_At_Risk_PPPM__c ==
          null
          ? 0
          : oppli.LVGO__Estimated_At_Risk_PPPM__c;
        oppli.LVGO__Program_ARR_Copy__c = oppli.LVGO__Program_ARR_Copy__c ==
          null
          ? 0
          : oppli.LVGO__Program_ARR_Copy__c;

		 oppli.LVGO__Product_Rollup__c = oppli.LVGO__Product_Rollup__c ==    //Added By rushikesh 5537
          null
          ? null
          : oppli.LVGO__Product_Rollup__c;
        system.debug('vENU qitemp.oldoli ' + oppli);
        system.debug('vENU qitemp.oldoli ' + oppli.LVGO__UnitPrice__c);
        system.debug(
          'vENU qitemp.oldoli ' + oppli.LVGO__Product_Participants__c
        );

        String Key =
          oppli.LVGO__Product2__c +
          '_' +
          String.valueOf(oppli.LVGO__UnitPrice__c.setscale(2)) +
          '_' +
          String.valueOf(oppli.LVGO__Quantity__c.setscale(2)) +
          '_' +
          String.valueOf(oppli.LVGO__Product_Participants__c.setscale(2)) +
          '_' +
          String.valueOf(oppli.LVGO__Gross_Program_ARR_Copy__c.setscale(2)) +
          '_' +
          String.valueOf(
            oppli.LVGO__Estimated_Partner_Admin_Fees__c.setscale(2)
          ) +
          '_' +
          String.valueOf(oppli.LVGO__Up_Front_Per_Member__c.setscale(2)) +
          '_' +
          String.valueOf(oppli.LVGO__Estimated_At_Risk_PPPM__c.setscale(2)) +
          '_' +
 		String.valueOf(oppli.LVGO__Product_Rollup__c) +   //Added By rushikesh 5537
        '_' +
          String.valueOf(
            oppli.LVGO__Program_ARR_Copy__c.setscale(2) +
              '_' +
              String.valueOf(oppli.LVGO__Disable_Teletherapy__c) +
              '_' +
              String.valueOf(oppli.LVGO__Disable_BH_Coaching__c)
          );
        if (existingOppli.containsKey(key)) {
          existingOppli.get(key).add(oppli);
        } else {
          List<LVGO__OpportunityLineItem__c> newList = new List<LVGO__OpportunityLineItem__c>();
          newList.add(oppli);
          existingOppli.put(key, newList);
        }
      }
    }

    if (newOppli == null) {
      newOppli = new Map<String, LVGO__OpportunityLineItem__c>();
    }

    for (LVGO__OpportunityLineItem__c oppli : qitemp.QItemOppli.oppliList) {
      oppli.LVGO__UnitPrice__c = oppli.LVGO__UnitPrice__c == null
        ? 0
        : oppli.LVGO__UnitPrice__c;
      oppli.LVGO__Quantity__c = oppli.LVGO__Quantity__c == null
        ? 0
        : oppli.LVGO__Quantity__c;
      oppli.LVGO__Product_Participants__c = oppli.LVGO__Product_Participants__c ==
        null
        ? 0
        : oppli.LVGO__Product_Participants__c;
      oppli.LVGO__Gross_Program_ARR_Copy__c = oppli.LVGO__Gross_Program_ARR_Copy__c ==
        null
        ? 0
        : oppli.LVGO__Gross_Program_ARR_Copy__c;
      oppli.LVGO__Estimated_Partner_Admin_Fees__c = oppli.LVGO__Estimated_Partner_Admin_Fees__c ==
        null
        ? 0
        : oppli.LVGO__Estimated_Partner_Admin_Fees__c;
      oppli.LVGO__Up_Front_Per_Member__c = oppli.LVGO__Up_Front_Per_Member__c ==
        null
        ? 0
        : oppli.LVGO__Up_Front_Per_Member__c;
      oppli.LVGO__Estimated_At_Risk_PPPM__c = oppli.LVGO__Estimated_At_Risk_PPPM__c ==
        null
        ? 0
        : oppli.LVGO__Estimated_At_Risk_PPPM__c;
      oppli.LVGO__Program_ARR_Copy__c = oppli.LVGO__Program_ARR_Copy__c == null
        ? 0
        : oppli.LVGO__Program_ARR_Copy__c;
  	 oppli.LVGO__Product_Rollup__c = oppli.LVGO__Product_Rollup__c == null    //Added By rushikesh 5537
        ? null
        : oppli.LVGO__Product_Rollup__c;
      String Key =
        oppli.LVGO__Product2__c +
        '_' +
        String.valueOf(oppli.LVGO__UnitPrice__c.setscale(2)) +
        '_' +
        String.valueOf(oppli.LVGO__Quantity__c.setscale(2)) +
        '_' +
        String.valueOf(oppli.LVGO__Product_Participants__c.setscale(2)) +
        '_' +
        String.valueOf(oppli.LVGO__Gross_Program_ARR_Copy__c.setscale(2)) +
        '_' +
        String.valueOf(
          oppli.LVGO__Estimated_Partner_Admin_Fees__c.setscale(2)
        ) +
        '_' +
        String.valueOf(oppli.LVGO__Up_Front_Per_Member__c.setscale(2)) +
        '_' +
        String.valueOf(oppli.LVGO__Estimated_At_Risk_PPPM__c.setscale(2)) +
        '_' +
        String.valueOf(oppli.LVGO__Program_ARR_Copy__c.setscale(2)) +
        '_' +
	    String.valueOf(oppli.LVGO__Product_Rollup__c) +   //Added By rushikesh 5537
        '_' +
        String.valueOf(oppli.LVGO__Disable_Teletherapy__c) +
        '_' +
        String.valueOf(oppli.LVGO__Disable_BH_Coaching__c);

      newOppli.put(key, oppli);
      system.debug('vENU qitemp.QItemOppli.oppliList ' + oppli);
      system.debug(
        'vENU qitemp.QItemOppli.oppliList ' + oppli.LVGO__UnitPrice__c
      );
      system.debug(
        'vENU qitemp.QItemOppli.oppliList ' +
        oppli.LVGO__Product_Participants__c
      );
    }
  }

  public static void sendSystemError() {
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    List<String> toAddresses = new List<String>();
    toAddresses.addAll(Label.TD_Salesforce_Support_Email.split(','));
    mail.setToAddresses(toAddresses);
    mail.setSenderDisplayName('Message Bus System');
    mail.setSubject('[ATTENTION REQUIRED]: Message Bus Potential System Error');
    mail.setHtmlBody(
      'Dev team please check on message bus for potential system error'
    );
    if (!Test.isRunningTest()) {
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
    }
  }

  @TestVisible
  public static Boolean isGuid(String guid) {
    if (String.isBlank(guid))
      return false;
    String guidRegEx = '[A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-F0-9]{12}';
    Pattern guidPattern = Pattern.compile(guidRegEx);
    Matcher guidMatcher = guidPattern.matcher(guid.toUpperCase());
    Boolean result = guidMatcher.matches();
    return result;
  }
}