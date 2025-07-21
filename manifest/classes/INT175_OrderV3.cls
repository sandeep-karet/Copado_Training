/**
 * Name: INT175_OrderV3
 *
 * JIRA          CHANGED DATE    CHANGED BY         DESCRIPTION
 *---------------------------------------------------------------------------------
 * SCDEV-2944    09-May-2023     Rajalakshmi R       Map Broker Commision fields to Opportunity Contact role
 * SCDEV-3371    31-May-2023     Rajalakshmi R       Map contacts to the account under ContactAccount Payload
 * SCDEV-4018    12-Sep-2023     Elambaruthi T       LCRM: Modify G2LCRM(Current) Process to accept the "PreSale" payload - Added logic to handle Quote information of payload.
 * SCDEV-4859 	 19-Feb-2024	 Rajalakshmi.R		 Map Opportunity Sub type and Sub type detail
 */
public class INT175_OrderV3 {
  public static Map<String, Map<String, String>> fieldMap { get; set; }
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

  public class Order {
    public String orderGUID { get; set; }
    public String orderId { get; set; }
    public String contractId { get; set; }
    public String orderNumber { get; set; }
    public String orderStatus { get; set; }
    public String orderType { get; set; }
    public String accountGUID { get; set; }
    public String accountId { get; set; }
    public String billToContactId { get; set; }
    public String shipToContactId { get; set; }
    public String ownerId { get; set; }
    public String activatedById { get; set; }
    public String effectiveDate { get; set; }
    public String activatedOrderDatetime { get; set; }
    public Double noOfOrderProducts { get; set; }
    public Double noOfOrderProductsActivated { get; set; }
    public Double orderBookings { get; set; }
    public Double totalAmount { get; set; }
    public String currencyIsoCode { get; set; }
    public List<Addresses> addresses { get; set; }
    public List<Contacts> contacts { get; set; }
    public List<Opportunities> opportunities { get; set; }
    public Contract contract { get; set; }
    public String paymentTerm { get; set; }
    /* SCDEV-4018 changes [Starts] */
    public Quote quote { get; set; }
    /* SCDEV-4018 changes [Ends] */
    public Order(JSONParser parser) {
      INT175_OrderV3.fieldMap = new Map<String, map<String, String>>();
      Map<String, String> fieldvalueMap = new Map<String, String>();
      INT175_OrderV3.fieldMap.put('order', fieldvalueMap);
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (
              text != 'contacts' &&
              text != 'opportunities' &&
              text != 'addresses'
            )
              fieldvalueMap.put(text, parser.getText());
            if (text == 'orderGUID') {
              orderGUID = parser.getText();
            } else if (text == 'orderId') {
              orderId = parser.getText();
            } else if (text == 'contractId') {
              contractId = parser.getText();
            } else if (text == 'paymentTerm') {
              paymentTerm = parser.getText();
            } else if (text == 'orderNumber') {
              orderNumber = parser.getText();
            } else if (text == 'orderStatus') {
              orderStatus = parser.getText();
            } else if (text == 'orderType') {
              orderType = parser.getText();
            } else if (text == 'accountGUID') {
              accountGUID = parser.getText();
            } else if (text == 'accountId') {
              accountId = parser.getText();
            } else if (text == 'billToContactId') {
              billToContactId = parser.getText();
            } else if (text == 'shipToContactId') {
              shipToContactId = parser.getText();
            } else if (text == 'ownerId') {
              ownerId = parser.getText();
            } else if (text == 'activatedById') {
              activatedById = parser.getText();
            } else if (text == 'effectiveDate') {
              effectiveDate = parser.getText();
            } else if (text == 'activatedOrderDatetime') {
              activatedOrderDatetime = parser.getText();
            } else if (text == 'noOfOrderProducts') {
              noOfOrderProducts = parser.getDoubleValue();
            } else if (text == 'noOfOrderProductsActivated') {
              noOfOrderProductsActivated = parser.getDoubleValue();
            } else if (text == 'orderBookings') {
              orderBookings = parser.getDoubleValue();
            } else if (text == 'totalAmount') {
              totalAmount = parser.getDoubleValue();
            } else if (text == 'currencyIsoCode') {
              currencyIsoCode = parser.getText();
            } else if (text == 'addresses') {
              addresses = arrayOfAddresses(parser);
            } else if (text == 'contacts') {
              contacts = arrayOfContacts(parser);
            } else if (text == 'opportunities') {
              opportunities = arrayOfOpportunities(parser);
            } else if (text == 'contract') {
              contract = new Contract(parser);
            }
            /* SCDEV-4018 changes [Starts] */
            else if (text == 'quote') {
              quote = new Quote(parser);
            }
            /* SCDEV-4018 changes [Ends] */
            else {
              System.debug(
                LoggingLevel.WARN,
                'Order consuming unrecognized property: ' + text
              );
              consumeObject(parser);
            }
          }
        }
      }
    }
  }

  public class contactAccount {
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

    public contactAccount(JSONParser parser) {
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
    public Boolean isDoNotCall { get; set; }
    public Boolean isAddToNurture { get; set; }
    public Boolean isClientCommunicationRecipient { get; set; }
    public Boolean isCommunicationOptOut { get; set; }
    public Boolean isDeleted { get; set; }
    public Boolean isFaxOptOut { get; set; }
    public Boolean isMicrosoftInvolved { get; set; }
    public Boolean isOptintoB2BCommunication { get; set; }
    public Boolean isReferral { get; set; }
    public Boolean isSyncToMarketoNurture { get; set; }
    public Boolean isUnSyncFromSFDC { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String leadSource { get; set; }
    public String createdById { get; set; }
    public String ownerId { get; set; }
    public String photoId { get; set; }
    public String lastModifiedById { get; set; }
    public String createdDatetime { get; set; }
    public String lastModifiedDatetime { get; set; }
    public Boolean isEmailOptOut { get; set; }
    public Boolean isEmailBounced { get; set; }
    public Boolean hasEventsandWebinars { get; set; }
    public Boolean hasNewsletters { get; set; }
    public Boolean hasProductAnnouncement { get; set; }
    public Boolean hasPromoContent { get; set; }
    public Boolean isBouncedEmail { get; set; }
    public List<Addresses> addresses { get; set; }
    public String mobile { get; set; }
    public String primaryEmail { get; set; }
    public contactAccount contactAccount { get; set; }

    public Contacts(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'contactGUID') {
              contactGUID = parser.getText();
            } else if (text == 'contactId') {
              contactId = parser.getText();
            } else if (text == 'mobile') {
              mobile = parser.getText();
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
            } else if (text == 'isSyncToMarketoNurture') {
              isSyncToMarketoNurture = parser.getBooleanValue();
            } else if (text == 'isUnSyncFromSFDC') {
              isUnSyncFromSFDC = parser.getBooleanValue();
            } else if (text == 'firstName') {
              firstName = parser.getText();
            } else if (text == 'lastName') {
              lastName = parser.getText();
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
              createdDatetime = parser.getText();
            } else if (text == 'lastModifiedDatetime') {
              lastModifiedDatetime = parser.getText();
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
            } else if (text == 'contactAccount') {
              contactAccount = new contactAccount(parser);
            } else {
              System.debug(
                LoggingLevel.WARN,
                'Contacts consuming unrecognized property: ' + text
              );
              consumeObject(parser);
            }
          }
        }
      }
    }
  }

  public class Addresses_Z {
    public Addresses_Z(JSONParser parser) {
      Map<String, String> fieldvalueMap = new Map<String, String>();
      INT175_OrderV3.FieldMap.put('order.addresses', fieldvalueMap);

      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            {
              fieldvalueMap.put(text, parser.getText());
              System.debug(
                LoggingLevel.WARN,
                'Addresses_Z consuming unrecognized property: ' + text
              );
              consumeObject(parser);
            }
          }
        }
      }
    }
  }

  public class Contacts_Z {
    public String contactGUID { get; set; }
    public String contactId { get; set; }
    public Boolean isDoNotCall { get; set; }
    public Boolean isAddToNurture { get; set; }
    public Boolean isClientCommunicationRecipient { get; set; }
    public Boolean isCommunicationOptOut { get; set; }
    public Boolean isDeleted { get; set; }
    public Boolean isFaxOptOut { get; set; }
    public Boolean isMicrosoftInvolved { get; set; }
    public Boolean isOptintoB2BCommunication { get; set; }
    public Boolean isReferral { get; set; }
    public Boolean isSyncToMarketoNurture { get; set; }
    public Boolean isUnSyncFromSFDC { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String contactRole { get; set; }
    public String leadSource { get; set; }
    public String createdById { get; set; }
    public String ownerId { get; set; }
    public String photoId { get; set; }
    public String lastModifiedById { get; set; }
    public String createdDatetime { get; set; }
    public String lastModifiedDatetime { get; set; }
    public Boolean isEmailOptOut { get; set; }
    public Boolean isEmailBounced { get; set; }
    public Boolean hasEventsandWebinars { get; set; }
    public Boolean hasNewsletters { get; set; }
    public Boolean hasProductAnnouncement { get; set; }
    public Boolean hasPromoContent { get; set; }
    public Boolean isBouncedEmail { get; set; }
    public List<Addresses> addresses { get; set; }
    public String mobile { get; set; }
    public String primaryEmail { get; set; }
    public Decimal brokerPercentage { get; set; }
    public Decimal brokerFlatRate { get; set; }
    public Decimal chronicCarePercentage { get; set; }
    public Decimal chronicCareFlatRate { get; set; }
    public contactAccount contactAccount { get; set; }

    public Contacts_Z(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'contactGUID') {
              contactGUID = parser.getText();
            } else if (text == 'contactId') {
              contactId = parser.getText();
            } else if (text == 'mobile') {
              mobile = parser.getText();
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
            } else if (text == 'isSyncToMarketoNurture') {
              isSyncToMarketoNurture = parser.getBooleanValue();
            } else if (text == 'isUnSyncFromSFDC') {
              isUnSyncFromSFDC = parser.getBooleanValue();
            } else if (text == 'firstName') {
              firstName = parser.getText();
            } else if (text == 'lastName') {
              lastName = parser.getText();
            } else if (text == 'contactRole') {
              contactRole = parser.getText();
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
              createdDatetime = parser.getText();
            } else if (text == 'lastModifiedDatetime') {
              lastModifiedDatetime = parser.getText();
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
            } else if (text == 'brokerPercentage') {
              brokerPercentage = parser.getDecimalValue();
            } else if (text == 'brokerFlatRate') {
              brokerFlatRate = parser.getDecimalValue();
            } else if (text == 'chronicCarePercentage') {
              chronicCarePercentage = parser.getDecimalValue();
            } else if (text == 'chronicCareFlatRate') {
              chronicCareFlatRate = parser.getDecimalValue();
            } else if (text == 'contactAccount') {
              contactAccount = new contactAccount(parser);
            } else {
              System.debug(
                LoggingLevel.WARN,
                'Contacts_Z consuming unrecognized property: ' + text
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

  public INT175_OrderV3(JSONParser parser) {
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
              'INT175_OrderV3 consuming unrecognized property: ' + text
            );
            consumeObject(parser);
          }
        }
      }
    }
  }

  public class Opportunities {
    public String accountGUID { get; set; }
    public String opportunityId { get; set; }
    public String opportunityGUID { get; set; }
    public String healthPlanSubtype { get; set; }
    public String healthPlanAdministration { get; set; }
    public String opportunityType { get; set; }
    public String opportunitySubType { get; set; }
    public String opportunitySubTypeDetail { get; set; }
    public Double opportunityAmount { get; set; }
    public Double annualRecurringRevenue { get; set; }
    public String ownerId { get; set; }
    public String pricebookId { get; set; }
    public Double bookingsTotal { get; set; }
    public String businessRegion { get; set; }
    public String channelSegment { get; set; }
    public Date closeDate { get; set; }
    public String contractPath { get; set; }
    public String contractPathSubtype { get; set; }
    public String contractingAccount { get; set; }
    public String createdById { get; set; }
    public Datetime createdDatetime { get; set; }
    public Double estimatedFirstYearRevenue { get; set; }
    public Double estimatedInYearRevenue { get; set; }
    public Double estimatedOneTimeRevenue { get; set; }
    public Boolean isExcludedFromTerritoryFilter { get; set; }
    public Double expectedRevenue { get; set; }
    public String forecastCategory { get; set; }
    public String forecastCategoryName { get; set; }
    public Boolean hasOpportunityLineItem { get; set; }
    public Boolean isSplit { get; set; }
    public Boolean isAccountAmendAssets { get; set; }
    public Double initialNumOfLives { get; set; }
    public String lastActivityDate { get; set; }
    public String lastCloseDateChangedHistoryId { get; set; }
    public String leadSource { get; set; }
    public Boolean isMicrosoftInvolved { get; set; }
    public String opportunityName { get; set; }
    public Boolean isOrdered { get; set; }
    public Double probability { get; set; }
    public Integer pushCount { get; set; }
    public Boolean isReferral { get; set; }
    public Boolean isROIAnalysisCompleted { get; set; }
    public String segment { get; set; }
    public String stageName { get; set; }
    public String subChannelSegment { get; set; }
    public String subtype { get; set; }
    public Double totalContractValue { get; set; }
    public Boolean isContactRoleExist { get; set; }
    public Boolean hasClosedByRipAndReplace { get; set; }
    public String currencyIsoCode { get; set; }
    public String consultantInvolvedInDeal { get; set; }
    public String contractingAccountName { get; set; }
    public List<Contacts_Z> contacts { get; set; }
    public List<Users> users { get; set; }

    // manual
    public String amendedContractId { get; set; }
    public Decimal priorAnnualRecurringRevenueValue { get; set; }
    public Decimal priorBookingsTotalValue { get; set; }
    public Decimal priorEstimatedOneTimeRevenue { get; set; }
    public Decimal priorNetAnnualRecurringRevenue { get; set; }
    public Decimal priorTotalContractValue { get; set; }
    public String salesType { get; set; }
    public Date revenueEffectiveDate { get; set; }
    public String clientLineOfBusiness { get; set; }

    public Opportunities(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'accountGUID') {
              accountGUID = parser.getText();
            } else if (text == 'revenueEffectiveDate') {
              revenueEffectiveDate = parser.getDateValue();
            } else if (text == 'clientLineOfBusiness') {
              clientLineOfBusiness = parser.getText();
            } else if (text == 'amendedContractId') {
              amendedContractId = parser.getText();
            } else if (text == 'priorAnnualRecurringRevenueValue') {
              priorAnnualRecurringRevenueValue = parser.getDecimalValue();
            } else if (text == 'priorBookingsTotalValue') {
              priorBookingsTotalValue = parser.getDecimalValue();
            } else if (text == 'priorEstimatedOneTimeRevenue') {
              priorEstimatedOneTimeRevenue = parser.getDecimalValue();
            } else if (text == 'priorNetAnnualRecurringRevenue') {
              priorNetAnnualRecurringRevenue = parser.getDecimalValue();
            } else if (text == 'priorTotalContractValue') {
              priorTotalContractValue = parser.getDecimalValue();
            } else if (text == 'salesType') {
              salesType = parser.getText();
            } else if (text == 'opportunityId') {
              opportunityId = parser.getText();
            } else if (text == 'opportunityGUID') {
              opportunityGUID = parser.getText();
            } else if (text == 'healthPlanSubtype') {
              healthPlanSubtype = parser.getText();
            } else if (text == 'healthPlanAdministration') {
              healthPlanAdministration = parser.getText();
            } else if (text == 'opportunityType') {
              opportunityType = parser.getText();
            } 
            //SCDEV-4589 Changes Begin
            else if (text == 'subtype'){
              opportunitySubType = parser.getText();  
            } else if (text == 'subtypeDetail'){
               opportunitySubTypeDetail = parser.getText(); 
            }
            //SCDEV-4589 Changes End
            
            else if (text == 'opportunityAmount') {
              opportunityAmount = parser.getDoubleValue();
            } else if (text == 'annualRecurringRevenue') {
              annualRecurringRevenue = parser.getDoubleValue();
            } else if (text == 'ownerId') {
              ownerId = parser.getText();
            } else if (text == 'pricebookId') {
              pricebookId = parser.getText();
            } else if (text == 'bookingsTotal') {
              bookingsTotal = parser.getDoubleValue();
            } else if (text == 'businessRegion') {
              businessRegion = parser.getText();
            } else if (text == 'channelSegment') {
              channelSegment = parser.getText();
            } else if (text == 'closeDate') {
              closeDate = parser.getDateValue();
            } else if (text == 'contractPath') {
              contractPath = parser.getText();
            } else if (text == 'contractPathSubtype') {
              contractPathSubtype = parser.getText();
            } else if (text == 'contractingAccount') {
              contractingAccount = parser.getText();
            } else if (text == 'createdById') {
              createdById = parser.getText();
            } else if (text == 'createdDatetime') {
              createdDatetime = parser.getDateTimeValue();
            } else if (text == 'estimatedFirstYearRevenue') {
              estimatedFirstYearRevenue = parser.getDoubleValue();
            } else if (text == 'estimatedInYearRevenue') {
              estimatedInYearRevenue = parser.getDoubleValue();
            } else if (text == 'estimatedOneTimeRevenue') {
              estimatedOneTimeRevenue = parser.getDoubleValue();
            } else if (text == 'isExcludedFromTerritoryFilter') {
              isExcludedFromTerritoryFilter = parser.getBooleanValue();
            } else if (text == 'expectedRevenue') {
              expectedRevenue = parser.getDoubleValue();
            } else if (text == 'forecastCategory') {
              forecastCategory = parser.getText();
            } else if (text == 'forecastCategoryName') {
              forecastCategoryName = parser.getText();
            } else if (text == 'hasOpportunityLineItem') {
              hasOpportunityLineItem = parser.getBooleanValue();
            } else if (text == 'isSplit') {
              isSplit = parser.getBooleanValue();
            } else if (text == 'isAccountAmendAssets') {
              isAccountAmendAssets = parser.getBooleanValue();
            } else if (text == 'initialNumOfLives') {
              initialNumOfLives = parser.getDoubleValue();
            } else if (text == 'lastActivityDate') {
              lastActivityDate = parser.getText();
            } else if (text == 'lastCloseDateChangedHistoryId') {
              lastCloseDateChangedHistoryId = parser.getText();
            } else if (text == 'leadSource') {
              leadSource = parser.getText();
            } else if (text == 'isMicrosoftInvolved') {
              isMicrosoftInvolved = parser.getBooleanValue();
            } else if (text == 'opportunityName') {
              opportunityName = parser.getText();
            } else if (text == 'isOrdered') {
              isOrdered = parser.getBooleanValue();
            } else if (text == 'probability') {
              probability = parser.getDoubleValue();
            } else if (text == 'pushCount') {
              pushCount = parser.getIntegerValue();
            } else if (text == 'isReferral') {
              isReferral = parser.getBooleanValue();
            } else if (text == 'isROIAnalysisCompleted') {
              isROIAnalysisCompleted = parser.getBooleanValue();
            } else if (text == 'segment') {
              segment = parser.getText();
            } else if (text == 'stageName') {
              stageName = parser.getText();
            } else if (text == 'subChannelSegment') {
              subChannelSegment = parser.getText();
            } else if (text == 'subtype') {
              subtype = parser.getText();
            } else if (text == 'totalContractValue') {
              totalContractValue = parser.getDoubleValue();
            } else if (text == 'isContactRoleExist') {
              isContactRoleExist = parser.getBooleanValue();
            } else if (text == 'hasClosedByRipAndReplace') {
              hasClosedByRipAndReplace = parser.getBooleanValue();
            } else if (text == 'currencyIsoCode') {
              currencyIsoCode = parser.getText();
            } else if (text == 'consultantInvolvedInDeal') {
              consultantInvolvedInDeal = parser.getText();
            } else if (text == 'contractingAccountName') {
              contractingAccountName = parser.getText(); 
            } else if (text == 'contacts') {
              contacts = arrayOfContacts_Z(parser);
            } else if (text == 'users') {
              users = arrayOfUsers(parser);
            } else {
              System.debug(
                LoggingLevel.WARN,
                'Opportunities consuming unrecognized property: ' + text
              );
              consumeObject(parser);
            }
          }
        }
      }
    }
  }

  public class Users {
    public String teamRole { get; set; }
    public String email { get; set; }
    public String userId { get; set; }
    public Boolean isActive { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String userName { get; set; }
    public String userType { get; set; }
    public String userRoleId { get; set; }

    public List<Addresses_Z> addresses { get; set; }

    public Users(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'teamRole') {
              teamRole = parser.getText();
            } else if (text == 'email') {
              email = parser.getText();
            } else if (text == 'userId') {
              userId = parser.getText();
            } else if (text == 'userRoleId') {
              userRoleId = parser.getText();
            } else if (text == 'isActive') {
              isActive = parser.getBooleanValue();
            } else if (text == 'firstName') {
              firstName = parser.getText();
            } else if (text == 'lastName') {
              lastName = parser.getText();
            } else if (text == 'userName') {
              userName = parser.getText();
            } else if (text == 'userType') {
              userType = parser.getText();
            } else if (text == 'addresses') {
              addresses = arrayOfAddresses_Z(parser);
            } else {
              System.debug(
                LoggingLevel.WARN,
                'Users consuming unrecognized property: ' + text
              );
              consumeObject(parser);
            }
          }
        }
      }
    }
  }

  public class Contract {
    public String contractGUID { get; set; }
    public String contractId { get; set; }
    public String contractNumber { get; set; }
    public String contractStatus { get; set; }
    public Integer contractTerm { get; set; }
    public String ownerId { get; set; }
    public Double activeContract { get; set; }
    public Boolean isAutoRenew { get; set; }
    public Boolean isMasterContract { get; set; }
    public Boolean isRenewalQuoted { get; set; }
    public String ownerEmail { get; set; }
    public Double remainingDays { get; set; }
    public Boolean renewalForecast { get; set; }
    public String renewalOpportunity { get; set; }
    public String renewalPricebookId { get; set; }
    public Double renewalTerm { get; set; }

    public Contract(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'contractGUID') {
              contractGUID = parser.getText();
            } else if (text == 'contractId') {
              contractId = parser.getText();
            } else if (text == 'contractNumber') {
              contractNumber = parser.getText();
            } else if (text == 'contractStatus') {
              contractStatus = parser.getText();
            } else if (text == 'contractTerm') {
              contractTerm = parser.getIntegerValue();
            } else if (text == 'ownerId') {
              ownerId = parser.getText();
            } else if (text == 'activeContract') {
              activeContract = parser.getDoubleValue();
            } else if (text == 'isAutoRenew') {
              isAutoRenew = parser.getBooleanValue();
            } else if (text == 'isMasterContract') {
              isMasterContract = parser.getBooleanValue();
            } else if (text == 'isRenewalQuoted') {
              isRenewalQuoted = parser.getBooleanValue();
            } else if (text == 'ownerEmail') {
              ownerEmail = parser.getText();
            } else if (text == 'remainingDays') {
              remainingDays = parser.getDoubleValue();
            } else if (text == 'renewalForecast') {
              renewalForecast = parser.getBooleanValue();
            } else if (text == 'renewalOpportunity') {
              renewalOpportunity = parser.getText();
            } else if (text == 'renewalPricebookId') {
              renewalPricebookId = parser.getText();
            } else if (text == 'renewalTerm') {
              renewalTerm = parser.getDoubleValue();
            } else {
              System.debug(
                LoggingLevel.WARN,
                'Contract consuming unrecognized property: ' + text
              );
              consumeObject(parser);
            }
          }
        }
      }
    }
  }

  /* SCDEV-4018 changes [Starts] */
  public class Quote {
    public Date quoteStartDate { get; set; }
    public String quoteId { get; set; }
    public String ownerId { get; set; }

    public Quote(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'quoteStartDate') {
              quoteStartDate = parser.getDateValue();
            } else if (text == 'quoteId') {
              quoteId = parser.getText();
            } else if (text == 'ownerId') {
              ownerId = parser.getText();
            } else {
              System.debug(
                LoggingLevel.WARN,
                'Quote consuming unrecognized property: ' + text
              );
              consumeObject(parser);
            }
          }
        }
      }
    }
  }
  /* SCDEV-4018 changes [Ends] */

  public class Body {
    public Order order { get; set; }

    public Body(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'order') {
              order = new Order(parser);
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

  public static INT175_OrderV3 parse(String json) {
    System.JSONParser parser = System.JSON.createParser(json);
    return new INT175_OrderV3(parser);
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

  private static List<Opportunities> arrayOfOpportunities(System.JSONParser p) {
    List<Opportunities> res = new List<Opportunities>();
    if (p.getCurrentToken() == null)
      p.nextToken();
    while (p.nextToken() != System.JSONToken.END_ARRAY) {
      res.add(new Opportunities(p));
    }
    return res;
  }

  private static List<Addresses_Z> arrayOfAddresses_Z(System.JSONParser p) {
    List<Addresses_Z> res = new List<Addresses_Z>();
    if (p.getCurrentToken() == null)
      p.nextToken();
    while (p.nextToken() != System.JSONToken.END_ARRAY) {
      res.add(new Addresses_Z(p));
    }
    return res;
  }

  private static List<Contacts_Z> arrayOfContacts_Z(System.JSONParser p) {
    List<Contacts_Z> res = new List<Contacts_Z>();
    if (p.getCurrentToken() == null)
      p.nextToken();
    while (p.nextToken() != System.JSONToken.END_ARRAY) {
      res.add(new Contacts_Z(p));
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

  private static List<Addresses> arrayOfAddresses(System.JSONParser p) {
    List<Addresses> res = new List<Addresses>();
    if (p.getCurrentToken() == null)
      p.nextToken();
    while (p.nextToken() != System.JSONToken.END_ARRAY) {
      res.add(new Addresses(p));
    }
    return res;
  }

  private static List<Users> arrayOfUsers(System.JSONParser p) {
    List<Users> res = new List<Users>();
    if (p.getCurrentToken() == null)
      p.nextToken();
    while (p.nextToken() != System.JSONToken.END_ARRAY) {
      res.add(new Users(p));
    }
    return res;
  }
}