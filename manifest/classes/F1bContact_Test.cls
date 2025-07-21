public class F1bContact_Test {
  public static void noContactData() {
    SBQQ.TriggerControl.disable();
    List<AcctGrpConParsing_Item__c> agcpiList = [
      SELECT Id, Item_Data__c
      FROM AcctGrpConParsing_Item__c
    ];
    F1BMainParser f1bp = new F1BMainParser();
    f1bp.parse(agcpiList[0].Item_Data__c);
    F1bp_Test.buildData(f1bp);
    Contact dataContact = [SELECT Id FROM Contact];
    f1bp.f1bcp = null;
    Test.startTest();
    F1BProcessor.ProcessEntry(f1bp, agcpiList[0].Id);
    //System.assertEquals(0, [ SELECT Count() FROM Contact WHERE Id != :dataContact.Id ]);
    Test.stopTest();
    SBQQ.TriggerControl.enable();
  }

  public static void marketUserCheckboxCheck_Test() {
    List<AcctGrpConParsing_Item__c> agcpiList = [
      SELECT Id, Item_Data__c
      FROM AcctGrpConParsing_Item__c
    ];
    F1BMainParser f1bp = new F1BMainParser();
    f1bp.parse(agcpiList[0].Item_Data__c);
    F1bp_Test.buildData(f1bp);
    Contact dataContact = [SELECT Id FROM Contact];
    Test.startTest();
    F1BProcessor.ProcessEntry(f1bp, agcpiList[0].Id);
    //System.assertEquals(1, [ SELECT Count() FROM Contact WHERE Marketing_Site_User__c = True AND Id != :dataContact.Id ]);
    //System.assertEquals(1, [ SELECT Count() FROM Contact WHERE Marketing_Site_User__c = False AND Id != :dataContact.Id ]);
    Test.stopTest();
  }

  public static void dupContactError_Test() {
    List<AcctGrpConParsing_Item__c> agcpiList = [
      SELECT Id, Item_Data__c
      FROM AcctGrpConParsing_Item__c
    ];
    F1BMainParser f1bp = new F1BMainParser();
    f1bp.parse(agcpiList[0].Item_Data__c);
    F1bp_Test.buildData(f1bp);
    Contact con = new Contact(
      lastName = 'test',
      firstName = 'test',
      Email = 'test@tsSst.com'
    );
    insert con;
    Map<String, Contact> mapCon = new Map<String, Contact>();
    mapCon.put('SAE', con);
    List<Map<String, Contact>> contactList = new List<Map<String, Contact>>();
    contactList.add(mapCon);
    f1bp.f1bcp.bspContacts = contactList;
    Test.startTest();
    F1BProcessor.ProcessEntry(f1bp, agcpiList[0].Id);
    //System.assertEquals(0, [SELECT Count() FROM AcctGrpConParse_Exception__c WHERE Short_Desc__c = 'CANNOT_CREATE_CONTACT' ]);
    Test.stopTest();
  }

  public static void updateContact() {
    List<AcctGrpConParsing_Item__c> agcpiList = [
      SELECT Id, Item_Data__c
      FROM AcctGrpConParsing_Item__c
    ];
    F1BMainParser f1bp = new F1BMainParser();
    f1bp.parse(agcpiList[0].Item_Data__c);
    F1bp_Test.buildData(f1bp);
    Contact con = new Contact(
      lastName = 'test',
      firstName = 'test',
      Email = 'test@tsSst.com',
      Marketing_Site_User__c = false
    );
    insert con;
    Map<String, Contact> mapCon = new Map<String, Contact>();
    mapCon.put('Marketing', con);
    List<Map<String, Contact>> contactList = new List<Map<String, Contact>>();
    contactList.add(mapCon);
    f1bp.f1bcp.bspContacts = contactList;
    Test.startTest();
    F1BProcessor.ProcessEntry(f1bp, agcpiList[0].Id);
    //System.assertEquals(true, [SELECT Marketing_Site_User__c FROM Contact WHERE Id =: con.Id].Marketing_Site_User__c);
    Test.stopTest();
  }

  /*
    public static void createMktUser() {
        Account acct = TestDataFactory.createParentAccount();
        Account ParentAcct = [SELECT Id FROM Account WHERE Name = 'National General'];
		List<AcctGrpConParsing_Item__c> agcpiList = [SELECT Id, Item_Data__c FROM AcctGrpConParsing_Item__c ];
		F1BMainParser f1bp = new F1BMainParser();
		f1bp.parse(agcpiList[0].Item_Data__c);
		F1bp_Test.buildData(f1bp);
        Test.startTest();
        Contact con = new Contact(lastName = 'test', firstName = 'test', Email = 'test@tsSst.com', Marketing_Site_User__c = true, AccountId = acct.Id);
		insert con;
        Acct_Rel__c acctRel = new Acct_Rel__c(Benefit_Sponsor__c = acct.Id, Svc_Acct__c = ParentAcct.Id, Relationship_Type__c = 'Contractee', 
                                              Contract_Type__c = 'Direct', Start_Date__c = date.today());
        insert acctRel;
		Map<String, Contact> mapCon = new Map<String, Contact>();
		mapCon.put('Marketing', con);
		List<Map<String, Contact>> contactList = new List<Map<String, Contact>>();
		contactList.add(mapCon);
		f1bp.f1bcp.bspContacts = contactList;
        system.debug(f1bp.ParentGuid);
		F1BProcessor.ProcessEntry(f1bp, agcpiList[0].Id);
		System.assertEquals(1, [SELECT count() FROM Mkt_Site_User__c]);
		Test.stopTest();
	}
	*/
}