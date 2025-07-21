public with sharing class F1BMbrGroupParser extends F1BBaseParser {
  public Mbr_Group__c ephMbrGroup { get; set; }
  public String ReportCategory { get; set; }
  public String SfdcPayerGuid { get; set; }
  public F1BWelcomeKitParser f1bpwk { get; set; }
  public List<PsfDataWrapper> f1bpsf { get; set; }

  public F1BMbrGroupParser() {
    super();
    ephMbrGroup = new Mbr_Group__c();
  }
  public override void Parse(JSONParser parser) {
    ephMbrGroup = new Mbr_Group__c();
    SObject grpObject = (SObject) ephMbrGroup;
    while (parser.nextToken() != System.JSONToken.END_OBJECT) {
      if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
        String fieldName = parser.getText();
        List<String> f1bKeyWord = F1b_Remove_Setting__c.getOrgDefaults()
          .Key_Word__c.split(';');
        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
          String fieldValue = parser.getText();
          if (mbrGrpEtlMap.containsKey(fieldName)) {
            if (fieldName == 'GUID') {
              if (
                String.isBlank(fieldValue) || !GlobalIdUtils.isGuid(fieldValue)
              ) {
                parsingErrors.put('GROUP_GUID', 'Blank or invalid.');
              }
            }
            String mappedFieldName = mbrGrpEtlMap.get(fieldName);
            fieldDeltas.add(mappedFieldName);
            if (f1bKeyWord.contains(fieldValue.toUpperCase().trim())) {
              grpObject.put(
                mappedFieldName,
                FetchTypedValue('Mbr_Group__c', mappedFieldName, null)
              );
            } else {
              grpObject.put(
                mappedFieldName,
                FetchTypedValue('Mbr_Group__c', mappedFieldName, fieldValue)
              );
            }
          } else {
            switch on fieldName {
              when 'SFDCPayerGUID' {
                if (
                  f1bKeyWord.contains(parser.getText().toUpperCase().trim())
                ) {
                  SfdcPayerGuid = null;
                } else {
                  SfdcPayerGuid = parser.getText();
                }
              }
              when 'ReportCategory' {
                if (
                  f1bKeyWord.contains(parser.getText().toUpperCase().trim())
                ) {
                  ReportCategory = null;
                } else {
                  ReportCategory = parser.getText();
                }
              }
              when 'AllowGeoFencing', 'AllowConversion', 'AllowCaregiver', 'AllowSexualHealthOptOut','AllowHealthAssistant','WKCardincludesLogo','ConsultMessageWK','CrossBilling','EnableLivongoCombinedEligibility' {
                  if(mbrGrpBoolFieldMap.ContainsKey(fieldName)){
                          String mappedFieldName = mbrGrpBoolFieldMap.get(fieldName);
                          ephMbrGroup.put(mappedFieldName,yieldBoolean(fieldName,parser.getText()));
                          fieldDeltas.add(mappedFieldName);
                  }               
              }
              when 'OneAppAccess' {
                  if(parser.getText() == 'true') {
                     ephMbrGroup.OneAppAccess__c = 'Yes'; 
                  }
                  else if(parser.getText() == 'false') {
                     ephMbrGroup.OneAppAccess__c = 'No';
                  }
                fieldDeltas.add('OneAppAccess__c');
              }
              when 'Products' {
                f1bpsf = F1BPsfParser.arrayOfProducts(parser, parsingErrors);
              }
              when 'WelcomeKit' {
                f1bpwk = new F1BWelcomeKitParser();
                f1bpwk.Parse(parser, ephMbrGroup);
              }
              when 'LVClientMemberCodeLookup' {
                  String livongoClientCode = parser.getText();
                  if(String.isNotBlank(livongoClientCode)) {  
                      ephMbrGroup.LV_Client_Member_Code__c = [Select Id,LVGO__ClientMemberCode__c FROM LVGO__ClientMemberCode__c Where LVGO__ClientMemberCode__c =:livongoClientCode]?.Id;
                 	  fieldDeltas.add('LV_Client_Member_Code__c');
                  }
              }
              when else {
                System.debug(
                  LoggingLevel.WARN,
                  'Group_Z consuming unrecognized property: ' + fieldName
                );
                consumeObject(parser);
              }
            }
          }
        }
      }
    }
    System.debug(LoggingLevel.FINE, 'Member Group: ' + parsingErrors);
  }

  public static Boolean CalculateDelta(
    Set<String> fields,
    Mbr_Group__c shellGrp,
    Mbr_Group__c existingGrp
  ) {
    Boolean isSame = false;
    for (String field : fields) {
      if (shellGrp.get(field) != existingGrp.get(field)) {
        system.debug(field);
        existingGrp.put(field, shellGrp.get(field));
        isSame = true;
      }
    }
    return isSame;
  }

    private static Map<String, String> mbrGrpBoolFieldMap = new Map<String, String>{
        'AllowHealthAssistant'=>'Health_Assistant__c',
            'AllowCaregiver'=>'Allow_Caregiver_Program__c',
            'AllowGeoFencing'=>'Allow_Geo_Fencing__c',
            'AllowConversion'=>'Allow_Conversion_To_Retail__c',
            'AllowSexualHealthOptOut'=>'Sexual_Health_Opt_Out__c',
            'WKCardincludesLogo' => 'WK_Card_Includes_Logo__c',
            'ConsultMessageWK' => 'Consult_Message_on_WK__c',
            'CrossBilling' => 'Cross_Billing__c' ,
		    'EnableLivongoCombinedEligibility'=> 'Enable_Livongo_Combined_Eligibility__c'       //SCDEV-5872    
            };   
  private static Map<String, String> mbrGrpEtlMap = new Map<String, String>{
    'GroupID' => 'Group_Number__c',
    'GUID' => 'Guid__c',
    'GroupName' => 'Name__c',
    //'GroupStartDate' => 'Active_Date__c',
    'GroupEndDate' => 'Termination_Date__c',
    'CardName' => 'Card_Name__c',
    'ConsultBillingMethod' => 'Consult_Billing_Method__c',
    'Status' => 'Status__c',
    'Eligibility' => 'Eligibility_Option__c',
    'SpecialInstructions' => 'Any_Special_Instructions__c',
    'LogoTagId' => 'Logo_Tag_ID__c',
    'EligibilityDependentsIncludedInFile' => 'Elig_Dep_Inc_In_File__c',
    'ReportCategory' => 'F1BReporting_Category__c',
    'DisclaimerCustom' => 'Disclaimer_Custom__c',
    'WelcomeLetterConsultMessage' => 'Welcome_Letter_Consult_Message__c',
    'Logo1gId' => 'Logo1_ID__c',
    'Logo3gId' => 'Logo3_ID__c',
    'Logo4gId' => 'Logo4_ID__c',
    'AltLogo1gId' => 'AltLogo1_ID__c',
    'AltLogo2gId' => 'AltLogo2_ID__c',
    'MKConsultArea' => 'MK_consultarea__c',
    'CardTemplate' => 'Card_Template__c',
    'CoBrandWithLogo' => 'Co_Brand_with_Logo__c',
    'LineOfBusiness' => 'Admin_Line_of_Business__c',
    'LivongoRegistrationCode' =>'Livongo_Registration_code__c',           //SCDEV-5872
    'EnableChronicCareReferrals' =>'Enable_Chronic_Care_Referrals__c'    //SCDEV-5872
  };
}