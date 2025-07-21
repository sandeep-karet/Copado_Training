@IsTest
private class ContactTrigger_Test {
  @IsTest
  static void testBehavior() {
    Account umrAcct = TestDataFactory.createUMR();
    Account a = TestDataFactory.createAccountUMR();
    List<Mbr_Group__c> mg = TestDataFactory.createMbrGroup(a.Id);

    Mbr_Group__c g = [
      SELECT Id, Status__c, Active_Date__c
      FROM Mbr_Group__c
      WHERE Id = :mg[0].Id
    ];
    Mbr_Group__c g2 = [
      SELECT Id, Status__c, Active_Date__c
      FROM Mbr_Group__c
      WHERE Id = :mg[1].Id
    ];

    //System.assert(g.Active_Date__c == null);
    //System.assert(g2.Active_Date__c != null);

    g.Status__c = 'ACTIVE';
    update g;
    g = [
      SELECT Id, Status__c, Active_Date__c
      FROM Mbr_Group__c
      WHERE Id = :g.Id
    ];

    Datetime lastActive = g2.Active_Date__c;

    g.Status__c = 'TERMED';
    update g;
    g = [
      SELECT Id, Status__c, Active_Date__c
      FROM Mbr_Group__c
      WHERE Id = :g.Id
    ];

    //System.assert(g.Active_Date__c == lastActive);

    g.Status__c = 'ACTIVE';
    update g;
    g = [
      SELECT Id, Status__c, Active_Date__c
      FROM Mbr_Group__c
      WHERE Id = :g.Id
    ];

    Account aRef = TestDataFactory.createParentAccount();
    aRef.Source_Id__c = 'TestAcct1';
    update aRef;

    Account a2 = TestDataFactory.createAccount(
      'BioHorizons Implant Systems, Inc'
    );
    aRef.Source_Id__c = 'TestAcct1';
    update aRef;

    Contact tmpCon = TestDataFactory.createContactDynamicVals(
      'AMkt',
      'User',
      'Test.User@teladoc.com',
      aRef.Id
    );
    tmpCon.Marketing_Site_User__c = true;
    tmpCon.Contact_Status__c = 'Active';
    insert tmpCon;

    Contact tmpCon2 = TestDataFactory.createContactDynamicVals(
      'AMkt',
      'User2',
      'Test.User2@teladoc.com',
      aRef.Id
    );
    tmpCon2.Marketing_Site_User__c = true;
    tmpCon2.Contact_Status__c = 'Inactive - Deceased';
    insert tmpCon2;

    Mbr_Group__c tmpGroup = new Mbr_Group__c(
      Name__c = 'Test Group',
      Client_Account__c = a2.Id,
      Client_Account__r = aRef,
      Status__c = 'ACTIVE'
    );
    Database.SaveResult[] sr = Database.insert(new List<SObject>{ tmpGroup });

    Contact nonMsuCon;
    List<Contact> manyCons = TestDataFactory.createMultipleContacts(
      aRef.Id,
      true
    );
    nonMsuCon = manyCons[0];
    // Change the last nonMSU to MSU user to test the update trigger behavior
    nonMsuCon.Marketing_Site_User__c = false;
    upsert nonMsuCon;
    nonMsuCon.Marketing_Site_User__c = true;
    upsert nonMsuCon;
    manyCons = [
      SELECT
        Id,
        FirstName,
        LastName,
        Marketing_Site_Username__c,
        Marketing_Site_Date_Status_Updated__c
      FROM Contact
      WHERE LastName = 'Smith'
    ];

    try {
      Mkt_Site_User__c msu1 = TestDataFactory.createMktSiteUser(
        tmpCon.Id,
        tmpGroup.Id
      );
      Mkt_Site_User__c msu2 = TestDataFactory.createMktSiteUser(
        tmpCon2.Id,
        tmpGroup.Id
      );
    } catch (Exception e) {
      // should be invalid
    }

    manyCons = [
      SELECT
        Id,
        Name,
        FirstName,
        LastName,
        Marketing_Site_Username__c,
        Marketing_Site_User__c,
        Marketing_Site_Date_Status_Updated__c
      FROM Contact
      WHERE LastName = 'Smith'
    ];

    // List all contacts that have been loaded
    for (Contact c : manyCons) {
      if (c.Marketing_Site_User__c == true) {
        System.debug(
          'CON:' +
            c.Name +
            ' -> ' +
            c.Marketing_Site_Username__c +
            ' MKT User? ' +
            c.Marketing_Site_User__c
        );
      }
    }

    tmpCon.Marketing_Site_User__c = false;
    tmpCon2.Marketing_Site_User__c = false;

    try {
      Mkt_Site_User__c msu3 = TestDataFactory.createMktSiteUser(
        tmpCon.Id,
        tmpGroup.Id
      );
      Mkt_Site_User__c msu4 = TestDataFactory.createMktSiteUser(
        tmpCon2.Id,
        tmpGroup.Id
      );
      Mkt_Site_User__c msu5 = TestDataFactory.createMktSiteUser(
        tmpCon2.Id,
        tmpGroup.Id
      );
    } catch (Exception e) {
      System.debug('Should fail: ' + e.getMessage());
    }
  }

  @IsTest
  static void testPersonatorResultCodeDesc() {
    Test.startTest();

    Contact conObj = new Contact();
    conObj.FirstName = 'Test Name';
    conObj.LastName = 'LastName';
    conObj.Email = 'test@testtee.com';
    conObj.OtherCountry = 'United States';
    conObj.OtherCountryCode = 'US';
    insert conObj;

    conObj.Mailing_Address_Personator_Result_Codes__c = 'SP01';
    conObj.Other_Address_Personator_Result_Codes__c = 'AE07';
    update conObj;

    Contact updatedCon = [
      SELECT
        Id,
        Mailing_Address_Status_Message__c,
        Other_Address_Status_Message__c
      FROM Contact
      LIMIT 1
    ];
    system.assertEquals(
      'SP01 - No Action',
      updatedCon.Mailing_Address_Status_Message__c
    );
    system.assertEquals(
      'AE07 - Missing Minimum Address',
      updatedCon.Other_Address_Status_Message__c
    );
    Test.stopTest();
  }
}