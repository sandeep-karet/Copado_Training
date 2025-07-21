public class INT175_AccountV3 {
  public class Addresses {
    public String type { get; set; }
    public String city { get; set; }
    public String country { get; set; }
    public String countryCode { get; set; }
    public String postalCode { get; set; }
    public String state { get; set; }
    public String stateCode { get; set; }
    public String street { get; set; }

    public Addresses(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'type') {
              type = parser.getText();
            } else if (text == 'city') {
              city = parser.getText();
            } else if (text == 'country') {
              country = parser.getText();
            } else if (text == 'countryCode') {
              countryCode = parser.getText();
            } else if (text == 'postalCode') {
              postalCode = parser.getText();
            } else if (text == 'state') {
              state = parser.getText();
            } else if (text == 'stateCode') {
              stateCode = parser.getText();
            } else if (text == 'street') {
              street = parser.getText();
            } else {
              System.debug(
                LoggingLevel.WARN,
                'Addresses consuming unrecognized property: ' + text
              );
              consumeObject(parser);
            }
          }
        }
      }
    }
  }

  public class Account {
    public String accountGUID { get; set; }
    public String accountId { get; set; }
    public String accountName { get; set; }
    public String accountType { get; set; }
    public String accountSubType { get; set; }
    public String accountStatus { get; set; }
    public String accountSource { get; set; }
    public String accountSize { get; set; }
    public String businessRegion { get; set; }
    public String contractCoTermination { get; set; }
    public Boolean hasPreserveStructureBundled { get; set; }
    public Boolean isAssetQuantitiesCombined { get; set; }
    public Boolean isCoTermedContractsCombined { get; set; }
    public Decimal totalUSEmployeesBenefitsEnrolled { get; set; }
    public String ownerId { get; set; }
    public String currencyIsoCode { get; set; }
    public List<Addresses> addresses { get; set; }
    public List<Contacts> contacts { get; set; }
    public List<Contacts> users { get; set; }
    public Integer noOfEmployees { get; set; }
    public String phone { get; set; }
    public String industryType { get; set; }

    public Account(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'accountGUID') {
              accountGUID = parser.getText();
            } else if (text == 'totalUSEmployeesBenefitsEnrolled') {
              totalUSEmployeesBenefitsEnrolled = parser.getDecimalValue();
            } else if (text == 'accountId') {
              accountId = parser.getText();
            } else if (text == 'accountName') {
              accountName = parser.getText();
            } else if (text == 'noOfEmployees') {
              noOfEmployees = parser.getIntegerValue();
            } else if (text == 'phone') {
              phone = parser.getText();
            } else if (text == 'industryType') {
              industryType = parser.getText();
            } else if (text == 'accountType') {
              accountType = parser.getText();
            } else if (text == 'accountSubType') {
              accountSubType = parser.getText();
            } else if (text == 'accountStatus') {
              accountStatus = parser.getText();
            } else if (text == 'accountSource') {
              accountSource = parser.getText();
            } else if (text == 'accountSize') {
              accountSize = parser.getText();
            } else if (text == 'businessRegion') {
              businessRegion = parser.getText();
            } else if (text == 'contractCoTermination') {
              contractCoTermination = parser.getText();
            } else if (text == 'hasPreserveStructureBundled') {
              hasPreserveStructureBundled = parser.getBooleanValue();
            } else if (text == 'isAssetQuantitiesCombined') {
              isAssetQuantitiesCombined = parser.getBooleanValue();
            } else if (text == 'isCoTermedContractsCombined') {
              isCoTermedContractsCombined = parser.getBooleanValue();
            } else if (text == 'ownerId') {
              ownerId = parser.getText();
            } else if (text == 'currencyIsoCode') {
              currencyIsoCode = parser.getText();
            } else if (text == 'addresses') {
              addresses = arrayOfAddresses(parser);
              system.debug('addresses::: ' + addresses);
            } else if (text == 'contacts') {
              contacts = arrayOfContacts(parser);
            } else if (text == 'users') {
              users = arrayOfContacts(parser);
            } else {
              System.debug(
                LoggingLevel.WARN,
                'Account consuming unrecognized property: ' + text
              );
              consumeObject(parser);
            }
          }
        }
      }
    }
  }

  public class Header {
    public String cdmName { get; set; }
    public String sourceSystemName { get; set; }
    public String sourceTrnxId { get; set; }
    public String muid { get; set; }
    public String createDatetime { get; set; }
    public String action { get; set; }

    public Header(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'cdmName') {
              cdmName = parser.getText();
            } else if (text == 'sourceSystemName') {
              sourceSystemName = parser.getText();
            } else if (text == 'sourceTrnxId') {
              sourceTrnxId = parser.getText();
            } else if (text == 'muid') {
              muid = parser.getText();
            } else if (text == 'createDatetime') {
              createDatetime = parser.getText();
            } else if (text == 'action') {
              action = parser.getText();
            } else {
              System.debug(
                LoggingLevel.WARN,
                'Header consuming unrecognized property: ' + text
              );
              consumeObject(parser);
            }
          }
        }
      }
    }
  }

  public class Contacts {
    public String contactGUID { get; set; }
    public String contactId { get; set; }
    public String mobile { get; set; }
    public Boolean isDoNotCall { get; set; }
    public Boolean isAddToNurture { get; set; }
    public Boolean isClientCommunicationRecipient { get; set; }
    public Boolean isCommunicationOptOut { get; set; }
    public Boolean isDeleted { get; set; }
    public Boolean isFaxOptOut { get; set; }
    public Boolean isMicrosoftInvolved { get; set; }
    public Boolean isOptintoB2BCommunication { get; set; }
    public Boolean isReferral { get; set; }
    public Boolean isSynctoMarketoNurture { get; set; }
    public Boolean isUnsyncFromSFDC { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String nextStepComments { get; set; }
    public String leadSource { get; set; }
    public String createdById { get; set; }
    public String ownerId { get; set; }
    public String photoId { get; set; }
    public String lastModifiedById { get; set; }
    public DateTime createdDatetime { get; set; }
    public DateTime lastModifiedDatetime { get; set; }
    public Boolean isEmailOptOut { get; set; }
    public Boolean isEmailBounced { get; set; }
    public Boolean hasEventsandWebinars { get; set; }
    public Boolean hasNewsletters { get; set; }
    public Boolean hasProductAnnouncement { get; set; }
    public Boolean hasPromoContent { get; set; }
    public Boolean isBouncedEmail { get; set; }
    public List<Addresses> addresses { get; set; }
    public String contactRole { get; set; }
    public String phone { get; set; }
    public String primaryEmail { get; set; }

    public Contacts(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'contactGUID') {
              contactGUID = parser.getText();
            } else if (text == 'contactRole') {
              contactRole = parser.getText();
            } else if (text == 'contactId') {
              contactId = parser.getText();
            } else if (text == 'mobile') {
              mobile = parser.getText();
            } else if (text == 'phone') {
              phone = parser.getText();
            } else if (text == 'primaryEmail') {
              primaryEmail = parser.getText();
            } else if (text == 'isDoNotCall') {
              isDoNotCall = parser.getBooleanValue();
            } else if (text == 'isAddToNurture') {
              isAddToNurture = parser.getBooleanValue();
            } else if (text == 'isClientCommunicationRecipient') {
              isClientCommunicationRecipient = parser.getBooleanValue();
            } else if (text == 'isCommunicationOptOut') {
              isCommunicationOptOut = parser.getBooleanValue();
            } else if (text == 'isDeleted') {
              isDeleted = parser.getBooleanValue();
            } else if (text == 'isFaxOptOut') {
              isFaxOptOut = parser.getBooleanValue();
            } else if (text == 'isMicrosoftInvolved') {
              isMicrosoftInvolved = parser.getBooleanValue();
            } else if (text == 'isOptintoB2BCommunication') {
              isOptintoB2BCommunication = parser.getBooleanValue();
            } else if (text == 'isReferral') {
              isReferral = parser.getBooleanValue();
            } else if (text == 'isSynctoMarketoNurture') {
              isSynctoMarketoNurture = parser.getBooleanValue();
            } else if (text == 'isUnsyncFromSFDC') {
              isUnsyncFromSFDC = parser.getBooleanValue();
            } else if (text == 'firstName') {
              firstName = parser.getText();
            } else if (text == 'lastName') {
              lastName = parser.getText();
            } else if (text == 'nextStepComments') {
              nextStepComments = parser.getText();
            } else if (text == 'leadSource') {
              leadSource = parser.getText();
            } else if (text == 'createdById') {
              createdById = parser.getText();
            } else if (text == 'ownerId') {
              ownerId = parser.getText();
            } else if (text == 'photoId') {
              photoId = parser.getText();
            } else if (text == 'lastModifiedById') {
              lastModifiedById = parser.getText();
            } else if (text == 'createdDatetime') {
              createdDatetime = parser.getDateTimeValue();
            } else if (text == 'lastModifiedDatetime') {
              lastModifiedDatetime = parser.getDateTimeValue();
            } else if (text == 'isEmailOptOut') {
              isEmailOptOut = parser.getBooleanValue();
            } else if (text == 'isEmailBounced') {
              isEmailBounced = parser.getBooleanValue();
            } else if (text == 'hasEventsandWebinars') {
              hasEventsandWebinars = parser.getBooleanValue();
            } else if (text == 'hasNewsletters') {
              hasNewsletters = parser.getBooleanValue();
            } else if (text == 'hasProductAnnouncement') {
              hasProductAnnouncement = parser.getBooleanValue();
            } else if (text == 'hasPromoContent') {
              hasPromoContent = parser.getBooleanValue();
            } else if (text == 'isBouncedEmail') {
              isBouncedEmail = parser.getBooleanValue();
            } else if (text == 'addresses') {
              addresses = arrayOfAddresses(parser);
            } else {
              System.debug(
                LoggingLevel.WARN,
                'Contacts consuming unrecognized property: [' + text + ']'
              );
              consumeObject(parser);
            }
          }
        }
      }
    }
  }

  public Header header { get; set; }
  public Body body { get; set; }

  public INT175_AccountV3(JSONParser parser) {
    while (parser.nextToken() != System.JSONToken.END_OBJECT) {
      if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
        String text = parser.getText();
        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
          if (text == 'header') {
            header = new Header(parser);
          } else if (text == 'body') {
            body = new Body(parser);
          } else {
            System.debug(
              LoggingLevel.WARN,
              'INT175_AccountV2 consuming unrecognized property: ' + text
            );
            consumeObject(parser);
          }
        }
      }
    }
  }

  public class Body {
    public Account account { get; set; }

    public Body(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'account') {
              account = new Account(parser);
            } else {
              System.debug(
                LoggingLevel.WARN,
                'Body consuming unrecognized property: ' + text
              );
              consumeObject(parser);
            }
          }
        }
      }
    }
  }

  public static INT175_AccountV3 parse(String json) {
    System.JSONParser parser = System.JSON.createParser(json);
    return new INT175_AccountV3(parser);
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

  private static List<Addresses> arrayOfAddresses(System.JSONParser p) {
    List<Addresses> res = new List<Addresses>();
    if (p.getCurrentToken() == null)
      p.nextToken();
    while (p.nextToken() != System.JSONToken.END_ARRAY) {
      res.add(new Addresses(p));
    }
    return res;
  }

  private static List<Addresses> arrayOfAddresses2(System.JSONParser p) {
    List<Addresses> res = new List<Addresses>();
    if (p.getCurrentToken() == null)
      p.nextToken();
    //system.debug('p.getCurrentToken:: ' + p.getCurrentToken());
    //system.debug('p.getNextToken:: ' + p.nextToken());

    while (p.nextToken() != System.JSONToken.END_ARRAY) {
      res.add(new Addresses(p));
    }
    return res;
  }
  private static List<Contacts> arrayOfContacts(System.JSONParser p) {
    List<Contacts> res = new List<Contacts>();
    if (p.getCurrentToken() == null)
      p.nextToken();
    while (p.nextToken() != System.JSONToken.END_ARRAY) {
      res.add(new Contacts(p));
    }
    return res;
  }
}