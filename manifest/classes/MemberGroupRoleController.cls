public with sharing class MemberGroupRoleController {
  // Page properties
  public Mbr_Group__c selGroup { get; set; }
  public Mbr_Group__c oldGroup { get; set; }
  public List<RoleWrapper> roleList { get; set; }
  public List<SelectOption> validRoleTypes { get; set; }
  public RoleWrapper newRoleWrapper { get; set; }
  public List<Plan_Specific_Fees__c> psfList { get; set; }

  // Parameters
  public Id selRoleId { get; set; }
  public Integer selRoleIndex { get; set; }
  public String sectiontitle { get; set; }
  public String sectionsubtitle { get; set; }

  // Rendering hints
  public Boolean isNew { get; set; }
  public Boolean hasRoles { get; set; }
  public Boolean canAddRole { get; set; }
  public Boolean hasAccount { get; set; }
  public Boolean isClone { get; set; }
  public Boolean hasPSFs { get; set; }

  // Class properties
  private ApexPages.StandardController sc { get; set; }
  private Id gid;

  // Controller primarily for MemberGroup page, but manages rules for Group roles as well
  public MemberGroupRoleController(ApexPages.StandardController stdCntrl) {
    sc = stdCntrl;
    gid = stdCntrl.getId();
    hasPSFs = false;

    Mbr_Group__c tmpMemberGroup = (Mbr_Group__c) stdCntrl.getRecord();
    isClone = (ApexPages.currentPage().getParameters().get('clone') == '1');
    // see if account was set from the referring page
    hasAccount = (tmpMemberGroup.getPopulatedFieldsAsMap()
      .containsKey('Client_Account__c'));

    if (gid == null) {
      Id clientId = apexpages.currentpage()
        .getparameters()
        .get('Client_Account_Manager__c');

      // Create a new member group
      selGroup = new Mbr_Group__c();
      if (clientId != null) {
        selGroup.Client_Account__c = clientId;
      }
      selGroup.Logo1_ID__c = 'MK_TDH_HZ_2';
      setLogoUrls();

      roleList = new List<RoleWrapper>();
      if (hasAccount) {
        selGroup.Client_Account__c = tmpMemberGroup.Client_Account__c;
      }
      isNew = true;
      hasRoles = false;
      // note, there can be no existing roles, but we do need to set the values
      // for the available role type SelectList.
      sectionsubtitle = 'New Member Group';
      sectiontitle = 'Member Group';
    } else {
      isNew = false;
      // Get info about the existing member group
      selGroup = [
        SELECT
          Id,
          Name,
          MSU_Group__c,
          Active_Date__c,
          Termination_Date__c,
          Status__c,
          Actual_Copay_May_Be_Less__c,
          Group_Number__c,
          AF_Included__c,
          Client_Account__c,
          Any_Special_Instructions__c,
          Consult_Billing_Method__c,
          Elig_Dep_Inc_In_File__c,
          Elig_By_Third_Party__c,
          Eligibility_Option__c,
          Client_Account_Manager__c,
          Consult_Included__c,
          Request_Date__c,
          Purchase_Order_Number__c,
          Purchase_Order_Required__c,
          Allow_Caregiver_Program__c,
          Allow_Conversion_to_Retail__c,
          Allow_Geo_Fencing__c,
          Sexual_Health_Opt_Out__c,
          Other_Company_Names__c,
          Logo_Tag_ID__c,
          Logo__c,
          Logo1__c,
          Logo1_ID__c,
          Logo2__c,
          Logo2_ID__c,
          Logo3__c,
          Logo3_ID__c,
          Logo4__c,
          Logo4_ID__c,
          AltLogo1_ID__c,
          AltLogo1__c,
          AltLogo2_ID__c,
          AltLogo2__c,
          WK_Retroactive__c,
          WK_Retroactive_Date__c,
          Card_Template__c,
          WK_Send_Card_Date__c,
          Est_MSU_Cnt__c,
          Shipping_Class__c,
          WK_Template__c,
          Name__c,
          Migration_Group_Number__c,
          Teladoc_Select__c,
          Health_Assistant__c,
          WK_Mail_to__c,
          WK_Mail_to_Address__c,
          Consult_Message__c,
          Welcome_Letter_Consult_Message__c,
          Consult_Message_on_WK__c,
          Client_Form_Number__c,
          MK_Welcomemessage__c,
          MK_consultarea__c,
          Card_Name__c,
          Company_Copy__c,
          Communication_Mode__c,
          MK_Idcardfront1__c,
          WK_Includes_Insert__c,
          Insert_Document_Name__c,
          CMSCode__c,
          Disclaimer_Teladoc__c,
          Disclaimer_Client__c,
          Disclaimer_Custom__c,
          Plan_Type__c,
          Plan_Category__c,
          Client_Account_Location__c,
          Client_Account_Relationship__c,
          Profile_Name__c,
          Is_Valid_MSU_Group__c,
          Line_Of_Business__c,
          CreatedById,
          LastModifiedById,
          Tri_Brand_with_Logo__c,
          Co_Brand_with_Logo__c,
          WK_Card_Includes_Logo__c,
          Eligibility_File_Source__c,
          MK_Idcardfront2__c,
          Preferred_Eligibility_Language__c,
          Service_Brand__c
        FROM Mbr_Group__c
        WHERE Id = :gid
      ];
      setLogoUrls();
      if (isClone) {
        oldGroup = selGroup;
        selGroup = selGroup.clone(false);
        // clear group number and migration number
        selGroup.Group_Number__c = null;
        selGroup.Migration_Group_Number__c = null;
        sectionsubtitle = 'Member Group Clone ';
        sectiontitle = oldGroup.Name + ': ' + oldGroup.Name__c;
        selGroup.Name__c = null;

        psfList = [
          SELECT Id, Name, Product__c, Membership_fee__c, Subscription__r.Name
          FROM Plan_Specific_Fees__c
          WHERE Member_Group__c = :gid
        ];
        if (psfList != null && psfList.size() > 0) {
          hasPSFs = true;
        }
      } else {
        sectionsubtitle = 'Member Group Edit ';
        sectiontitle = selGroup.Name;
      }
    }

    // This object is used by the new role section to create a new role under the group
    loadRoles();

    // Reset the "Role to Add"
    newRoleWrapper = new RoleWrapper();
    newRoleWrapper.newItemIndex = null;
  }

  private void loadRoles() {
    // Default Load role call overload - will load roles and types
    loadRoles(true);
  }

  private void loadRoles(Boolean includeTypes) {
    // This will load associated roles and merge with staged roles
    List<RoleWrapper> tmpRoleWrappers = new List<RoleWrapper>();
    // store in temp variable any "new" roles temporarily, if applicable
    if (roleList != null) {
      for (RoleWrapper rw : roleList) {
        if (rw.isNewItem == true) {
          tmpRoleWrappers.add(rw);
        }
      }
    }

    // Rebuild the list
    roleList = new List<RoleWrapper>();
    // Add all new/unsaved ones to the top
    for (RoleWrapper rw : tmpRoleWrappers) {
      // add each item and set an index
      rw.newItemIndex = roleList.size() + 1;
      roleList.add(rw);
    }

    if (!isNew) {
      // Load existing roles if we have an ID
      List<Mbr_Group_Role__c> groupRoles = [
        SELECT
          Id,
          Name,
          Role_Type__c,
          Source_Account__c,
          Source_Contact__c,
          Mbr_Group__c
        FROM Mbr_Group_Role__c
        WHERE Mbr_Group__r.Id = :gid
      ];

      // Put persisted/existing roles at the bottom
      for (Mbr_Group_Role__c r : groupRoles) {
        RoleWrapper nrw = new RoleWrapper();
        if (isClone) {
          nrw.newItemIndex = roleList.size() + 1;
          nrw.isNewItem = true;
          nrw.role = r.clone(false);
          System.debug(
            'role ID is ' + nrw.role + ' index: ' + nrw.newItemIndex
          );
        } else {
          nrw.isNewItem = false;
          nrw.newItemIndex = null;
          nrw.role = r;
        }
        roleList.add(nrw);
      }
    }
    // there will be always one row for adding new roles
    hasRoles = (roleList.size() > 0);
    if (includeTypes) {
      loadRoleTypes();
    }
  }

  private void loadRoleTypes() {
    hasRoles = (roleList.size() > 0);
    Set<String> rolesInUse = new Set<String>();
    if (hasRoles) {
      // build a set of types in use
      for (RoleWrapper g : roleList) {
        rolesInUse.add(g.role.Role_Type__c);
      }
    }
    validRoleTypes = new List<SelectOption>();
    validRoleTypes.add(new SelectOption('', '--None--'));

    // Build a valid role list - all picklist items except those in use
    Schema.DescribeFieldResult fieldResult = Mbr_Group_Role__c.Role_Type__c.getDescribe();
    List<Schema.PicklistEntry> rts = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry f : rts) {
      if (!rolesInUse.contains(f.getValue())) {
        validRoleTypes.add(new SelectOption(f.getLabel(), f.getValue()));
      }
    }

    System.debug('all the roles: ' + validRoleTypes);
    canAddRole = (validRoleTypes.size() > 1);
  }

  public PageReference setActiveDate() {
    if (selGroup.Active_Date__c == null && selGroup.Status__c == 'ACTIVE') {
      selGroup.Active_Date__c = Date.today();
    }
    return null;
  }

  public PageReference save() {
    if (!validatePage()) {
      return null;
    }
    try {
      // Try to edit the item AND create staged groups
      Mbr_Group_Role__c newRole = newRoleWrapper.role;
      // first upsert the group, and handle specific errors such as dupes gracefully

      setLogoUrls();
      upsert selGroup;
      if (newRole.Role_Type__c != null && newRole.Source_Account__c != null) {
        if (newRole.Mbr_Group__c == null) {
          newRole.Mbr_Group__c = selGroup.Id;
        }
        insert newRole;
      }

      if (hasRoles) {
        List<Mbr_Group_Role__c> roles = new List<Mbr_Group_Role__c>();
        for (RoleWrapper gw : roleList) {
          if (gw.role.Mbr_Group__c == null) {
            gw.role.Mbr_Group__c = selGroup.Id;
          }
          roles.add(gw.role);
        }
        upsert roles;

        // reset the role list, since ALL will come from SF after the save
        roleList = new List<RoleWrapper>();
      }

      if (isNew) {
        PageReference newPage = new PageReference('/' + selGroup.Id);
        newPage.setRedirect(true);
        return newPage;
      } else {
        loadRoles();
      }

      // Reset the new role
      newRoleWrapper = new RoleWrapper();
      if (isClone) {
        // Get all PSF columns, and insert PSF dupes now
        List<Plan_Specific_Fees__c> psfList = [
          SELECT
            Id,
            Actual_Copay_May_Be_Less__c,
            Associated_Acct_ID__c,
            Client_Retail_Fee__c,
            Consult_Fee_Initial_Diagnostic_Mbr_Pd__c,
            Consult_Fee_Initial_Diagnostic_Plan_Pd__c,
            Consult_Fee_Mbr_Pd__c,
            Consult_Fee_Ongoing_MD_Mbr_Pd__c,
            Consult_Fee_Ongoing_MD_Plan_Pd__c,
            Consult_Fee_Ongoing_Non_MD_Mbr_Pd__c,
            Consult_Fee_Ongoing_Non_MD_Plan_Pd__c,
            Consult_Fee_Plan_Pd__c,
            Consult_Frequency__c,
            Consults_per_Family__c,
            Current_Membership_Fee__c,
            DERMConsult_Fee_Mbr_Pd__c,
            DERMConsult_Fee_Plan_Pd__c,
            Group_Number__c,
            Implementation_Status_of_Pdt_Under_Contr__c,
            Membership_fee__c,
            Product_Under_Contract__c,
            Product__c,
            Revenue_Effective_fm_Pdt_Under_Contr__c,
            Subscribed_Asset__c,
            Subscription__c,
            TC_Client_Case_Rate_Fee__c,
            TC_Mbr_Case_Rate_Fee__c,
            Teladoc_Net_Fee__c,
            Types_of_Lives__c
          FROM Plan_Specific_Fees__c
          WHERE Member_Group__c = :gid
        ];

        // Clone, attach to this group, then insert
        List<Plan_Specific_Fees__c> newPSFs = psfList.deepClone(false);
        for (Plan_Specific_Fees__c p : newPSFs) {
          p.Member_Group__c = selGroup.Id;
        }
        insert newPSFs;

        // Go to the page now that it's saved
        PageReference newPage = new PageReference('/' + selGroup.Id);
        newPage.setRedirect(true);
        return newPage;
      }

      String retURL = ApexPages.currentPage().getParameters().get('retURL');
      if (String.isBlank(retURL)) {
        return sc.view();
      } else {
        PageReference pageRef = new PageReference(retURL);
        pageRef.setRedirect(true);
        return pageRef;
      }
    } catch (DmlException dmle) {
      Integer totalCount = dmle.getNumDml();
      for (Integer i = 0; i < totalCount; i++) {
        if (dmle.getDmlType(i) == StatusCode.DUPLICATE_VALUE) {
          //Note: This is where I should be able to determine field names.
          ApexPages.addMessage(
            new ApexPages.Message(
              ApexPages.Severity.ERROR,
              'Name and Group Number require unique values.  A duplicate value has been found in Salesforce.'
            )
          );
        }
        ApexPages.addMessage(
          new ApexPages.Message(ApexPages.Severity.ERROR, dmle.getMessage())
        );
      }
      return null;
    } catch (Exception e) {
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.ERROR,
          'Unable to save group.  Error: ' + e.getMessage()
        )
      );
      return null;
    }
  }

  public PageReference validateLogos() {
    setLogoUrls();
    return null;
  }

  private Boolean validatePage() {
    Mbr_Group_Role__c newRole = newRoleWrapper.role;
    Boolean isValid = true;
    isValid = setLogoUrls();

    // if there is an attempt to add a new role, but role + account are not set, this isn't valid
    if (
      !String.isBlank(newRole.Role_Type__c) && newRole.Source_Account__c == null
    ) {
      //newRoleWrapper.flagSourceAccount();
      newRoleWrapper.role.Source_Account__c.addError(
        'Source account is required to add a new role.'
      );
      //newRoleWrapper.role.addError();
      //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Source account is required to add a new role.'));
      isValid = false;
    }

    if (
      String.isBlank(newRole.Role_Type__c) && newRole.Source_Account__c != null
    ) {
      newRoleWrapper.role.Role_Type__c.addError(
        'Source account is required to add a new role.'
      );
      newRoleWrapper.flagRoleType(); // custom select list will not work correctly with addError
      //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'A Role Type is required to add a new role.'));
      isValid = false;
    }

    if (!isValid) {
      return false;
    }

    // Check for dupe types now...  this can't really happen since only valid values are available, but this can be used alternatively, if you don't restrict values.
    for (RoleWrapper r : roleList) {
      if (r.role.Role_Type__c == newRole.Role_Type__c) {
        r.role.Role_Type__c.addError(
          'New role must have a unique Role Type. ' +
            r.role.Role_Type__c +
            ' in use by ' +
            r.role.Name +
            '.'
        );
        //was here: ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,));
        return false;
      }
    }

    // Check for dupe types in the existing role list...  this can't really happen since only valid values are available, but this can be used alternatively, if you don't restrict values.
    if (hasRoles) {
      Boolean hasDupes = false;
      Set<String> rolesInUse = new Set<String>();
      Set<String> dupeRoles = new Set<String>();
      for (RoleWrapper r : roleList) {
        if (rolesInUse.contains(r.role.Role_Type__c)) {
          hasDupes = true;
          dupeRoles.add(r.role.Role_Type__c);
        }
        rolesInUse.add(r.role.Role_Type__c);
      }
      if (hasDupes) {
        // flag items for the browser
        for (RoleWrapper r : roleList) {
          if (dupeRoles.contains(r.role.Role_Type__c)) {
            // This will add a red outline to dupe role types
            r.role.Role_Type__c.addError('Duplicate role type.');
            //r.flagRoleType();
          }
        }
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Duplicate Role Types may not be saved.  Duplicates found are outlined in red.'));
        return false;
      }
    }

    return true;
  }

  public PageReference cancel() {
    Id clientId = apexpages.currentpage()
      .getparameters()
      .get('Client_Account_Manager__c');
    String retUrl;
    if (clientId != null) {
      retUrl =
        URL.getOrgDomainUrl().toExternalForm() +
        '/' +
        String.valueOf(clientId);
      system.debug(retUrl);
    } else {
      retUrl = ApexPages.currentPage().getParameters().get('retURL');
      if (String.isBlank(retUrl)) {
        retUrl = '/' + gid;
      }
    }

    PageReference newPage = new PageReference(retUrl);
    newPage.setRedirect(true);
    return newPage;
  }

  private Boolean setLogoUrls() {
    Boolean valid = true;
    Set<String> Ids = new Set<String>();
    Ids.add(selGroup.Logo_Tag_ID__c);
    Ids.add(selGroup.Logo1_ID__c);
    Ids.add(selGroup.Logo2_ID__c);
    Ids.add(selGroup.Logo3_ID__c);
    Ids.add(selGroup.Logo4_ID__c);
    Ids.add(selGroup.AltLogo1_ID__c);
    Ids.add(selGroup.AltLogo2_ID__c);

    logo_setting__c ls = logo_setting__c.getOrgDefaults();

    if (ls.isDocument__c) {
      transient List<Document> docs = [
        SELECT Id, Name
        FROM Document
        WHERE Name IN :Ids
      ];
      System.debug(docs.size());
      Map<String, Document> docMap = new Map<String, Document>();
      for (Document d : docs) {
        docMap.put(d.Name, d);
      }
      if (docMap.containsKey(selGroup.Logo_Tag_ID__c)) {
        Document d = docMap.get(selGroup.Logo_Tag_ID__c);
        selGroup.Logo__c = genLogoUrl(d.Id);
      } else if (String.isBlank(selGroup.Logo_Tag_ID__c)) {
        selGroup.Logo__c = '';
      } else {
        selGroup.Logo_Tag_ID__c.addError('Invalid Document Name');
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Document ID not valid for Logo Tag ID'
          )
        );
        selGroup.Logo__c = '';
        valid = false;
      }
      if (docMap.containsKey(selGroup.Logo1_ID__c)) {
        Document d = docMap.get(selGroup.Logo1_ID__c);
        selGroup.Logo1__c = genLogoUrl(d.Id);
      } else if (String.isBlank(selGroup.Logo1_ID__c)) {
        selGroup.Logo1__c = '';
      } else {
        selGroup.Logo1_ID__c.addError('Invalid Document Name');
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Document ID not valid for Logo Tag ID'
          )
        );
        selGroup.Logo1__c = '';
        valid = false;
      }
      if (docMap.containsKey(selGroup.Logo2_ID__c)) {
        Document d = docMap.get(selGroup.Logo2_ID__c);
        selGroup.Logo2__c = genLogoUrl(d.Id);
      } else if (String.isBlank(selGroup.Logo2_ID__c)) {
        selGroup.Logo2__c = '';
      } else {
        selGroup.Logo2_ID__c.addError('Invalid Document Name');
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Document ID not valid for Logo Tag ID'
          )
        );
        selGroup.Logo2__c = '';
        valid = false;
      }
      if (docMap.containsKey(selGroup.Logo3_ID__c)) {
        Document d = docMap.get(selGroup.Logo3_ID__c);
        selGroup.Logo3__c = genLogoUrl(d.Id);
      } else if (String.isBlank(selGroup.Logo3_ID__c)) {
        selGroup.Logo3__c = '';
      } else {
        selGroup.Logo3_ID__c.addError('Invalid Document Name');
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Document ID not valid for Logo Tag ID'
          )
        );
        selGroup.Logo3__c = '';
        valid = false;
      }
      if (docMap.containsKey(selGroup.Logo4_ID__c)) {
        Document d = docMap.get(selGroup.Logo4_ID__c);
        selGroup.Logo4__c = genLogoUrl(d.Id);
      } else if (String.isBlank(selGroup.Logo4_ID__c)) {
        selGroup.Logo4__c = '';
      } else {
        selGroup.Logo4_ID__c.addError('Invalid Document Name');
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Document ID not valid for Logo Tag ID'
          )
        );
        selGroup.Logo4__c = '';
        valid = false;
      }
      if (docMap.containsKey(selGroup.AltLogo1_ID__c)) {
        Document d = docMap.get(selGroup.AltLogo1_ID__c);
        selGroup.AltLogo1__c = genLogoUrl(d.Id);
      } else if (String.isBlank(selGroup.AltLogo1_ID__c)) {
        selGroup.AltLogo1__c = '';
      } else {
        selGroup.AltLogo1_ID__c.addError('Invalid Document Name');
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Document ID not valid for Logo Tag ID'
          )
        );
        selGroup.AltLogo1__c = '';
        valid = false;
      }
      if (docMap.containsKey(selGroup.AltLogo2_ID__c)) {
        Document d = docMap.get(selGroup.AltLogo2_ID__c);
        selGroup.AltLogo2__c = genLogoUrl(d.Id);
      } else if (String.isBlank(selGroup.AltLogo2_ID__c)) {
        selGroup.AltLogo2__c = '';
      } else {
        selGroup.AltLogo2_ID__c.addError('Invalid Document Name');
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Document ID not valid for Logo Tag ID'
          )
        );
        selGroup.AltLogo2__c = '';
        valid = false;
      }
      return valid;
    } else {
      ID workspaceId = [SELECT Id FROM ContentWorkspace WHERE Name = 'Logos'][0]
      .Id;
      transient List<ContentVersion> docs = [
        SELECT ContentDocument.Id, Title
        FROM ContentVersion USING SCOPE EVERYTHING
        WHERE ContentDocument.ParentId = :workspaceId AND Title IN :Ids
      ];
      System.debug(docs.size());
      Map<String, ContentVersion> docMap = new Map<String, ContentVersion>();
      for (ContentVersion d : docs) {
        docMap.put(d.title, d);
      }
      if (docMap.containsKey(selGroup.Logo_Tag_ID__c)) {
        ContentVersion d = docMap.get(selGroup.Logo_Tag_ID__c);
        selGroup.Logo__c = genLogoFile(d.ContentDocument.Id);
      } else if (String.isBlank(selGroup.Logo_Tag_ID__c)) {
        selGroup.Logo__c = '';
      } else {
        selGroup.Logo_Tag_ID__c.addError('Invalid Document Name');
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Document ID not valid for Logo Tag ID'
          )
        );
        selGroup.Logo__c = '';
        valid = false;
      }
      if (docMap.containsKey(selGroup.Logo1_ID__c)) {
        ContentVersion d = docMap.get(selGroup.Logo1_ID__c);
        selGroup.Logo1__c = genLogoFile(d.ContentDocument.Id);
      } else if (String.isBlank(selGroup.Logo1_ID__c)) {
        selGroup.Logo1__c = '';
      } else {
        selGroup.Logo1_ID__c.addError('Invalid Document Name');
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Document ID not valid for Logo Tag ID'
          )
        );
        selGroup.Logo1__c = '';
        valid = false;
      }
      if (docMap.containsKey(selGroup.Logo2_ID__c)) {
        ContentVersion d = docMap.get(selGroup.Logo2_ID__c);
        selGroup.Logo2__c = genLogoFile(d.ContentDocument.Id);
      } else if (String.isBlank(selGroup.Logo2_ID__c)) {
        selGroup.Logo2__c = '';
      } else {
        selGroup.Logo2_ID__c.addError('Invalid Document Name');
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Document ID not valid for Logo Tag ID'
          )
        );
        selGroup.Logo2__c = '';
        valid = false;
      }
      if (docMap.containsKey(selGroup.Logo3_ID__c)) {
        ContentVersion d = docMap.get(selGroup.Logo3_ID__c);
        selGroup.Logo3__c = genLogoFile(d.ContentDocument.Id);
      } else if (String.isBlank(selGroup.Logo3_ID__c)) {
        selGroup.Logo3__c = '';
      } else {
        selGroup.Logo3_ID__c.addError('Invalid Document Name');
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Document ID not valid for Logo Tag ID'
          )
        );
        selGroup.Logo3__c = '';
        valid = false;
      }
      if (docMap.containsKey(selGroup.Logo4_ID__c)) {
        ContentVersion d = docMap.get(selGroup.Logo4_ID__c);
        selGroup.Logo4__c = genLogoFile(d.ContentDocument.Id);
      } else if (String.isBlank(selGroup.Logo4_ID__c)) {
        selGroup.Logo4__c = '';
      } else {
        selGroup.Logo4_ID__c.addError('Invalid Document Name');
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Document ID not valid for Logo Tag ID'
          )
        );
        selGroup.Logo4__c = '';
        valid = false;
      }
      if (docMap.containsKey(selGroup.AltLogo1_ID__c)) {
        ContentVersion d = docMap.get(selGroup.AltLogo1_ID__c);
        selGroup.AltLogo1__c = genLogoFile(d.ContentDocument.Id);
      } else if (String.isBlank(selGroup.AltLogo1_ID__c)) {
        selGroup.AltLogo1__c = '';
      } else {
        selGroup.AltLogo1_ID__c.addError('Invalid Document Name');
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Document ID not valid for Logo Tag ID'
          )
        );
        selGroup.AltLogo1__c = '';
        valid = false;
      }
      if (docMap.containsKey(selGroup.AltLogo2_ID__c)) {
        ContentVersion d = docMap.get(selGroup.AltLogo2_ID__c);
        selGroup.AltLogo2__c = genLogoFile(d.ContentDocument.Id);
      } else if (String.isBlank(selGroup.AltLogo2_ID__c)) {
        selGroup.AltLogo2__c = '';
      } else {
        selGroup.AltLogo2_ID__c.addError('Invalid Document Name');
        ApexPages.addMessage(
          new ApexPages.Message(
            ApexPages.Severity.ERROR,
            'Document ID not valid for Logo Tag ID'
          )
        );
        selGroup.AltLogo2__c = '';
        valid = false;
      }
      return valid;
    }
  }

  private String genLogoUrl(Id docId) {
    // width of image is reduced, but original image is not lost, for download, etc.
    return '<img src=\'/servlet/servlet.ImageServer?id=' +
      docId +
      '&oid=' +
      UserInfo.getOrganizationId() +
      '\' width="28%"/>';
  }

  private static String genLogoFile(Id fileId) {
    return '<img src=\'/sfc/servlet.shepherd/document/download/' +
      fileId +
      '\' width="28%"/>';
  }

  public PageReference addRole() {
    Boolean isValid = (true);
    // validation / highlight issues
    if (String.isBlank(newRoleWrapper.role.Role_Type__c)) {
      isValid = false;
      newRoleWrapper.flagRoleType(); // add Error doesn't work correctly here, since it's a custom list
      newRoleWrapper.role.Role_Type__c.addError('Role Type must be selected.');
      //errMsg = 'Role Type must be selected.';
    }
    if (newRoleWrapper.role.Source_Account__c == null) {
      isValid = false;
      newRoleWrapper.role.Source_Account__c.addError(
        'Source Account must be selected.'
      );
    }
    if (!isValid) {
      return null;
    }

    // add a valid role to the pending list
    Mbr_Group_Role__c roleToAdd = new Mbr_Group_Role__c();
    roleToAdd.Role_Type__c = newRoleWrapper.role.Role_Type__c;
    roleToAdd.Source_Account__c = newRoleWrapper.role.Source_Account__c;
    roleToAdd.Source_Contact__c = newRoleWrapper.role.Source_Contact__c;
    RoleWrapper rw = new RoleWrapper(roleToAdd);
    rw.isNewItem = true;
    rw.newItemIndex = roleList.size() + 1;
    if (roleList.size() == 0) {
      roleList.add(rw);
    } else {
      roleList.add(0, rw);
    }

    // Reset the new role
    newRoleWrapper = new RoleWrapper();
    ApexPages.addMessage(
      new ApexPages.Message(
        ApexPages.Severity.INFO,
        'New role added. Save must be clicked in order to store new role in Salesforce.'
      )
    );
    loadRoleTypes();
    return null;
  }

  public PageReference deleteRole() {
    if (selRoleIndex != null) {
      // remove a "staged" role
      for (Integer i = 0; i < roleList.size(); i++) {
        if (roleList[i].newItemIndex == selRoleIndex) {
          roleList.remove(i);
          break;
        }
      }
    } else if (selRoleId != null) {
      // delete a role from the database
      Mbr_Group_Role__c role = [
        SELECT Id, Name
        FROM Mbr_Group_Role__c
        WHERE Id = :selRoleId
      ];
      delete role;
      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.INFO,
          'Role ' + role.Name + ' has been deleted '
        )
      );
    }
    loadRoles();
    selRoleId = null;
    selRoleIndex = null;
    return null;
  }

  public PageReference newPSF() {
    // Redirect to PSF page
    String redirectUrl = '/apex/psfByProduct?gid=' + selGroup.Id;
    PageReference newPage = new PageReference(redirectUrl);
    newPage.setRedirect(true);
    return newPage;
  }

  public class RoleWrapper {
    public RoleWrapper() {
      role = new Mbr_Group_Role__c();
    }
    public RoleWrapper(Mbr_Group_Role__c initRole) {
      role = initRole;
    }
    // addError won't work, since it's a custom picklist
    private void flagRoleType() {
      roleTypeStyle = 'border: 2px solid #c00;';
    }

    public Boolean isNewItem { get; set; }
    public Integer newItemIndex { get; set; }
    public Mbr_Group_Role__c role { get; set; }
    public transient String roleTypeStyle { get; set; }
    public transient String sourceAccountStyle { get; set; }
  }

  //validation to throw the error on Source Account == Client account
  public static void validateExistingAccountRole(List<Mbr_Group_Role__c> mbr) {
    Set<id> memberGroupSet = new Set<Id>();
    for (Mbr_Group_Role__c mbrRoles : mbr) {
      if (!memberGroupSet.contains(mbrRoles.Mbr_Group__c)) {
        memberGroupSet.add(mbrRoles.Mbr_Group__c);
      }
    }
    Map<Id, Mbr_Group__c> mbrGroup = new Map<Id, Mbr_Group__c>(
      [
        SELECT id, Client_Account__c
        FROM Mbr_Group__c
        WHERE Id IN :memberGroupSet
      ]
    );

    /* if(mbrGroup != null && mbrGroup.size() > 0) {
            System.debug('Mbr Group map values' + mbrGroup.values());

            for (Mbr_Group_Role__c mbrRoles : mbr) {
                if (mbrRoles.Source_Account__c == mbrGroup.get(mbrRoles.Mbr_Group__c).Client_Account__c && mbrRoles.Role_Type__c != 'Payer') {
                    mbrRoles.Source_Account__c.addError('Client Account on the Member Group cannot be used as Source Account');
                }
            }
        } */
  }
}