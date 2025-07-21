/**
 * Name: GCRM_Process_OrderV3
 *
 * JIRA          CHANGED DATE    CHANGED BY         DESCRIPTION
 *---------------------------------------------------------------------------------
 * SCDEV-4291    19-Oct-2023     Elambaruthi T       LCRM - Process QuoteLine ID value in Post Launch payload
 */
public class INT175_OrderItemV3 {
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
  /*
  public class Subscriptions_Y {
    public String subscriptionId { get; set; }
    public Double subscriptionNumber { get; set; }
    public String subscriptionPricing { get; set; }
    public String subscriptionType { get; set; }
    public String bundleType { get; set; }
    public String consultType { get; set; }
    public String contractNumber { get; set; }
    public String feeType { get; set; }
    public Boolean isAnchor { get; set; }
    public Boolean isBundled { get; set; }
    public String optionType { get; set; }
    public String orderProductId { get; set; }
    // SCDEV-4291 Modified [Starts] 
    public String originalQuoteLineId { get; set; } // to be removed 
    public String QuoteLineId { get; set; }
    // SCDEV-4291 Modified [Ends] 
    public String ownerId { get; set; }
    public Double participantQuantity { get; set; }
    public String productOption { get; set; }
    public Double prorateMultiplier { get; set; }
    public Double renewalPrice { get; set; }
    public Double renewalQuantity { get; set; }
    public String requiredById { get; set; }
    public String requiredByProduct { get; set; }
    public String currencyIsoCode { get; set; }

    public Subscriptions_Y(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'subscriptionId') {
              subscriptionId = parser.getText();
            } else if (text == 'subscriptionNumber') {
              subscriptionNumber = parser.getDoubleValue();
            } else if (text == 'subscriptionPricing') {
              subscriptionPricing = parser.getText();
            } else if (text == 'subscriptionType') {
              subscriptionType = parser.getText();
            } else if (text == 'bundleType') {
              bundleType = parser.getText();
            } else if (text == 'consultType') {
              consultType = parser.getText();
            } else if (text == 'contractNumber') {
              contractNumber = parser.getText();
            } else if (text == 'feeType') {
              feeType = parser.getText();
            } else if (text == 'isAnchor') {
              isAnchor = parser.getBooleanValue();
            } else if (text == 'isBundled') {
              isBundled = parser.getBooleanValue();
            } else if (text == 'optionType') {
              optionType = parser.getText();
            } else if (text == 'orderProductId') {
              orderProductId = parser.getText();
            } else if (text == 'originalQuoteLineId') {
              originalQuoteLineId = parser.getText(); // to be removed 
            }
            // SCDEV-4291 Modified [Starts] 
            else if (text == 'QuoteLineId') {
              QuoteLineId = parser.getText();
            }
            // SCDEV-4291 Modified [Ends] 
            else if (text == 'ownerId') {
              ownerId = parser.getText();
            } else if (text == 'participantQuantity') {
              participantQuantity = parser.getDoubleValue();
            } else if (text == 'productOption') {
              productOption = parser.getText();
            } else if (text == 'prorateMultiplier') {
              prorateMultiplier = parser.getDoubleValue();
            } else if (text == 'renewalPrice') {
              renewalPrice = parser.getDoubleValue();
            } else if (text == 'renewalQuantity') {
              renewalQuantity = parser.getDoubleValue();
            } else if (text == 'requiredById') {
              requiredById = parser.getText();
            } else if (text == 'requiredByProduct') {
              requiredByProduct = parser.getText();
            } else if (text == 'currencyIsoCode') {
              currencyIsoCode = parser.getText();
            } else {
              System.debug(
                LoggingLevel.WARN,
                'Subscriptions_Y consuming unrecognized property: ' + text
              );
              consumeObject(parser);
            }
          }
        }
      }
    }
  }
  */
  public class Order {
    public List<OrderItems> orderItems { get; set; }

    public Order(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'orderItems') {
              orderItems = arrayOfOrderItems(parser);
            } else {
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

  public Header header { get; set; }
  public Body body { get; set; }

  public INT175_OrderItemV3(JSONParser parser) {
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
              'INT175_OrderItemV3  consuming unrecognized property: ' + text
            );
            consumeObject(parser);
          }
        }
      }
    }
  }
  /*
  public class Subscriptions_Z {
    public String subscriptionId { get; set; }
    public Double subscriptionNumber { get; set; }
    public String subscriptionPricing { get; set; }
    public String subscriptionType { get; set; }
    public String consultType { get; set; }
    public String contractNumber { get; set; }
    public String feeType { get; set; }
    public Boolean isAnchor { get; set; }
    public Boolean isBundled { get; set; }
    public String optionType { get; set; }
    public String orderProductId { get; set; }
    // SCDEV-4291 Modified [Starts] 
    public String originalQuoteLineId { get; set; } // to be removed 
    public String QuoteLineId { get; set; }
     // SCDEV-4291 Modified [Ends] 
    public String ownerId { get; set; }
    public Double participantQuantity { get; set; }
    public String productOption { get; set; }
    public Double prorateMultiplier { get; set; }
    public Double renewalQuantity { get; set; }
    public String requiredById { get; set; }
    public String requiredByProduct { get; set; }
    public String currencyIsoCode { get; set; }

    public Subscriptions_Z(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'subscriptionId') {
              subscriptionId = parser.getText();
            } else if (text == 'subscriptionNumber') {
              subscriptionNumber = parser.getDoubleValue();
            } else if (text == 'subscriptionPricing') {
              subscriptionPricing = parser.getText();
            } else if (text == 'subscriptionType') {
              subscriptionType = parser.getText();
            } else if (text == 'consultType') {
              consultType = parser.getText();
            } else if (text == 'contractNumber') {
              contractNumber = parser.getText();
            } else if (text == 'feeType') {
              feeType = parser.getText();
            } else if (text == 'isAnchor') {
              isAnchor = parser.getBooleanValue();
            } else if (text == 'isBundled') {
              isBundled = parser.getBooleanValue();
            } else if (text == 'optionType') {
              optionType = parser.getText();
            } else if (text == 'orderProductId') {
              orderProductId = parser.getText();
            } else if (text == 'originalQuoteLineId') {
              originalQuoteLineId = parser.getText(); // to be removed 
            }
            // SCDEV-4291 Modified [Starts] 
            else if (text == 'QuoteLineId') {
              QuoteLineId = parser.getText();
            }
            // SCDEV-4291 Modified [Ends] 
            else if (text == 'ownerId') {
              ownerId = parser.getText();
            } else if (text == 'participantQuantity') {
              participantQuantity = parser.getDoubleValue();
            } else if (text == 'productOption') {
              productOption = parser.getText();
            } else if (text == 'prorateMultiplier') {
              prorateMultiplier = parser.getDoubleValue();
            } else if (text == 'renewalQuantity') {
              renewalQuantity = parser.getDoubleValue();
            } else if (text == 'requiredById') {
              requiredById = parser.getText();
            } else if (text == 'requiredByProduct') {
              requiredByProduct = parser.getText();
            } else if (text == 'currencyIsoCode') {
              currencyIsoCode = parser.getText();
            } else {
              System.debug(
                LoggingLevel.WARN,
                'Subscriptions_Z consuming unrecognized property: ' + text
              );
              consumeObject(parser);
            }
          }
        }
      }
    }
  }

  public class Assets_Z {
    public String assetId { get; set; }
    public String assetName { get; set; }
    public Double assetNumber { get; set; }
    public Double assetQuantity { get; set; }
    public String assetStatus { get; set; }
    public Double consultFee { get; set; }
    public String consultType { get; set; }
    public String feeType { get; set; }
    public Boolean hasLifecycleManagement { get; set; }
    public Boolean isBundled { get; set; }
    public String latestQuoteLineId { get; set; }
    public String optionType { get; set; }
    public String ownerId { get; set; }
    public String productOption { get; set; }
    public String purchaseDate { get; set; }
    public String requiredBySubscription { get; set; }
    public String currencyIsoCode { get; set; }
    //"LCRMVisitFeeCode": "GMCF",
    //"LCRMVisitFeeDesc": "GM - Consult Fee",
    public String visitFeeCode { get; set; }
    public String visitFeeDesc { get; set; }

    public Assets_Z(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'assetId') {
              assetId = parser.getText();
            } else if (text == 'assetName') {
              assetName = parser.getText();
            } else if (text == 'visitFeeCode') {
              visitFeeCode = parser.getText();
            } else if (text == 'visitFeeDesc') {
              visitFeeDesc = parser.getText();
            } else if (text == 'assetNumber') {
              assetNumber = parser.getDoubleValue();
            } else if (text == 'assetQuantity') {
              assetQuantity = parser.getDoubleValue();
            } else if (text == 'assetStatus') {
              assetStatus = parser.getText();
            } else if (text == 'consultFee') {
              consultFee = parser.getDoubleValue();
            } else if (text == 'consultType') {
              consultType = parser.getText();
            } else if (text == 'feeType') {
              feeType = parser.getText();
            } else if (text == 'hasLifecycleManagement') {
              hasLifecycleManagement = parser.getBooleanValue();
            } else if (text == 'isBundled') {
              isBundled = parser.getBooleanValue();
            } else if (text == 'latestQuoteLineId') {
              latestQuoteLineId = parser.getText();
            } else if (text == 'optionType') {
              optionType = parser.getText();
            } else if (text == 'ownerId') {
              ownerId = parser.getText();
            } else if (text == 'productOption') {
              productOption = parser.getText();
            } else if (text == 'purchaseDate') {
              purchaseDate = parser.getText();
            } else if (text == 'requiredBySubscription') {
              requiredBySubscription = parser.getText();
            } else if (text == 'currencyIsoCode') {
              currencyIsoCode = parser.getText();
            } else {
              System.debug(
                LoggingLevel.WARN,
                'Assets_Z consuming unrecognized property: ' + text
              );
              consumeObject(parser);
            }
          }
        }
      }
    }
  }*/

  public class quoteLine {
    public string productVersion { get; set; }
    public boolean doesSaleHvAdolescents { get; set; }
    public quoteLine(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'productVersion') {
              productVersion = parser.getText();
            } else if (text == 'doesSaleHvAdolescents') {
              doesSaleHvAdolescents = parser.getBooleanValue();
            } else {
              System.debug(
                LoggingLevel.WARN,
                'quoteLine consuming unrecognized property: ' + text
              );
              consumeObject(parser);
            }
          }
        }
      }
    }
  }

  public class OrderItems {
    public String orderItemGUID { get; set; }
    public String orderItemId { get; set; }
    public String orderItemNumber { get; set; }
    public String servicingPlatform { get; set; }
    public String productCode { get; set; }
    public String productName { get; set; }
    public String productFamily { get; set; }
    public String productId { get; set; }
    public String productSubscriptionType { get; set; }
    public Double availableQuantity { get; set; }
    public String contractAction { get; set; }
    public Double defaultSubscriptionTerm { get; set; }
    public Date endDate { get; set; }
    public Boolean hasHoldOrder { get; set; }
    public Boolean isActivated { get; set; }
    public Double listPrice { get; set; }
    public Double orderedQuantity { get; set; }
    public Double prorateMultiplier { get; set; }
    public Double quantity { get; set; }
    public Date serviceDate { get; set; }
    public String status { get; set; }
    public Double totalPrice { get; set; }
    public Double unitPrice { get; set; }
    public String currencyIsoCode { get; set; }
    public List<Addresses> addresses { get; set; }
    public List<Contacts> contacts { get; set; }
    public List<Assets> assets { get; set; }
    public List<Subscriptions> subscriptions { get; set; }
    public Double membershipFee { get; set; }
    public quoteLine quoteLine { get; set; }
    public String requiredBy { get; set; }

    //manual

    public String parentOrderGUID { get; set; }
    public String parentOrderId { get; set; }
    public String parentOrderItemGUID { get; set; }
    public String parentOrderItemId { get; set; }
    public String parentOpportunityGUID { get; set; }
    public String parentOpportunityId { get; set; }

    public OrderItems(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'orderItemId') {
              orderItemId = parser.getText();
            } else if (text == 'parentOrderGUID') {
              parentOrderGUID = parser.getText();
            } else if (text == 'parentOrderId') {
              parentOrderId = parser.getText();
            } else if (text == 'parentOrderItemGUID') {
              parentOrderItemGUID = parser.getText();
            } else if (text == 'parentOrderItemId') {
              parentOrderItemId = parser.getText();
            } else if (text == 'parentOpportunityGUID') {
              parentOpportunityGUID = parser.getText();
            } else if (text == 'parentOpportunityId') {
              parentOpportunityId = parser.getText();
            } else if (text == 'orderItemGUID') {
              orderItemGUID = parser.getText();
            } else if (text == 'membershipFee') {
              membershipFee = parser.getDoubleValue();
            } else if (text == 'orderItemNumber') {
              orderItemNumber = parser.getText();
            } else if (text == 'servicingPlatform') {
              servicingPlatform = parser.getText();
            } else if (text == 'productCode') {
              productCode = parser.getText();
            } else if (text == 'productName') {
              productName = parser.getText();
            } else if (text == 'productFamily') {
              productFamily = parser.getText();
            } else if (text == 'productId') {
              productId = parser.getText();
            } else if (text == 'productSubscriptionType') {
              productSubscriptionType = parser.getText();
            } else if (text == 'availableQuantity') {
              availableQuantity = parser.getDoubleValue();
            } else if (text == 'contractAction') {
              contractAction = parser.getText();
            } else if (text == 'defaultSubscriptionTerm') {
              defaultSubscriptionTerm = parser.getDoubleValue();
            } else if (text == 'endDate') {
              endDate = parser.getDateValue();
            } else if (text == 'hasHoldOrder') {
              hasHoldOrder = parser.getBooleanValue();
            } else if (text == 'isActivated') {
              isActivated = parser.getBooleanValue();
            } else if (text == 'listPrice') {
              listPrice = parser.getDoubleValue();
            } else if (text == 'orderedQuantity') {
              orderedQuantity = parser.getDoubleValue();
            } else if (text == 'prorateMultiplier') {
              prorateMultiplier = parser.getDoubleValue();
            } else if (text == 'quantity') {
              quantity = parser.getDoubleValue();
            } else if (text == 'serviceDate') {
              serviceDate = parser.getDateValue();
            } else if (text == 'status') {
              status = parser.getText();
            } else if (text == 'totalPrice') {
              totalPrice = parser.getDoubleValue();
            } else if (text == 'unitPrice') {
              unitPrice = parser.getDoubleValue();
            } else if (text == 'currencyIsoCode') {
              currencyIsoCode = parser.getText();
            } else if (text == 'addresses') {
              addresses = arrayOfAddresses(parser);
            } else if (text == 'contacts') {
              contacts = arrayOfContacts(parser);
            } else if (text == 'assets') {
              assets = arrayOfAssets(parser);
            } else if (text == 'subscriptions') {
              subscriptions = arrayOfSubscriptions(parser);
            } else if (text == 'quoteLine') {
              quoteLine = new quoteLine(parser);
            } else if (text == 'requiredBy') {
              requiredBy = parser.getText();
            } else {
              System.debug(
                LoggingLevel.WARN,
                'OrderItems consuming unrecognized property: ' + text
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

    public Contacts(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'contactGUID') {
              contactGUID = parser.getText();
            } else if (text == 'contactId') {
              contactId = parser.getText();
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

  public class Subscriptions {
    public String subscriptionId { get; set; }
    public Double subscriptionNumber { get; set; }
    public String subscriptionPricing { get; set; }
    public String subscriptionType { get; set; }
    public String consultType { get; set; }
    public String contractNumber { get; set; }
    public String feeType { get; set; }
    public Boolean isAnchor { get; set; }
    public Boolean isBundled { get; set; }
    public String bundleType { get; set; }
    public String orderProductId { get; set; }
    /* SCDEV-4291 Modified [Starts] */
    public String originalQuoteLineId { get; set; } /* to be removed */
    public String QuoteLineId { get; set; }
    /* SCDEV-4291 Modified [Ends] */
    public String ownerId { get; set; }
    public Double participantQuantity { get; set; }
    public Double prorateMultiplier { get; set; }
    public Double renewalQuantity { get; set; }
    public String currencyIsoCode { get; set; }

    // manual

    public String optionType { get; set; }
    public String productOption { get; set; }
    public String requiredById { get; set; }
    public String requiredByProduct { get; set; }
    public String packageProductCode { get; set; }
    public Decimal renewalPrice { get; set; }
    public Decimal additionalDiscountAmount { get; set; }
    public String revisedSubscription { get; set; }
    public Date terminatedDate { get; set; }
    public Double subscriptionQuantity { get; set; }
    public Date subscriptionStartDate { get; set; }

    // new fields for Assets

    public String lcrmVisitFeeCode { get; set; }
    public String lcrmVisitFeeDesc { get; set; }
    public double consultFee { get; set; }
    public String assetName { get; set; }
    public String assetId { get; set; }
    public Double assetQuantity { get; set; }
    public String requiredBySubscription { get; set; }
    public String vendorPartner { get; set; }
    public String orderItemId { get; set; }

    public Subscriptions(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'subscriptionId') {
              subscriptionId = parser.getText();
              assetId = parser.getText();
            } else if (text == 'revisedSubscription') {
              revisedSubscription = parser.getText();
            } else if (text == 'vendorPartner') {
              vendorPartner = parser.getText();
            } else if (text == 'subscriptionStartDate') {
              subscriptionStartDate = parser.getDateValue();
            } else if (text == 'subscriptionQuantity') {
              subscriptionQuantity = parser.getDecimalValue();
              assetQuantity = parser.getDoubleValue();
            } else if (text == 'terminatedDate') {
              terminatedDate = parser.getDateValue();
            } else if (text == 'additionalDiscountAmount') {
              additionalDiscountAmount = parser.getDecimalValue();
            } else if (text == 'productOption') {
              productOption = parser.getText();
            } else if (text == 'renewalPrice') {
              renewalPrice = parser.getDecimalValue();
            } else if (text == 'bundleType') {
              bundleType = parser.getText();
            } else if (text == 'packageProductCode') {
              packageProductCode = parser.getText();
            } else if (text == 'requiredById') {
              requiredById = parser.getText();
              requiredBySubscription = parser.getText();
            } else if (text == 'optionType') {
              optionType = parser.getText();
            } else if (text == 'requiredByProduct') {
              requiredByProduct = parser.getText();
            } else if (text == 'subscriptionNumber') {
              subscriptionNumber = parser.getDoubleValue();
            } else if (text == 'subscriptionPricing') {
              subscriptionPricing = parser.getText();
            } else if (text == 'subscriptionType') {
              subscriptionType = parser.getText();
            } else if (text == 'consultType') {
              consultType = parser.getText();
            } else if (text == 'contractNumber') {
              contractNumber = parser.getText();
            } else if (text == 'feeType') {
              feeType = parser.getText();
            } else if (text == 'isAnchor') {
              isAnchor = parser.getBooleanValue();
            } else if (text == 'isBundled') {
              isBundled = parser.getBooleanValue();
            } else if (text == 'orderProductId') {
              orderProductId = parser.getText();
            } else if (text == 'originalQuoteLineId') {
              originalQuoteLineId = parser.getText(); /* to be removed */
            }
            /* SCDEV-4291 Modified [Starts] */
            else if (text == 'QuoteLineId') {
              QuoteLineId = parser.getText();
            }
            /* SCDEV-4291 Modified [Ends] */
            else if (text == 'ownerId') {
              ownerId = parser.getText();
            } //SCDEV-4858 Changes - Participant Quantity parameter change
             else if (text == 'quoteLineParticipantQuantity') {
              participantQuantity = parser.getDoubleValue();
            } else if (text == 'prorateMultiplier') {
              prorateMultiplier = parser.getDoubleValue();
            } else if (text == 'renewalQuantity') {
              renewalQuantity = parser.getDoubleValue();
            } else if (text == 'currencyIsoCode') {
              currencyIsoCode = parser.getText();
            } else if (text == 'LCRMVisitFeeCode') {
              lcrmVisitFeeCode = parser.getText();
            } else if (text == 'LCRMVisitFeeDesc') {
              lcrmVisitFeeDesc = parser.getText();
            } else if (text == 'consultFee') {
              consultFee = parser.getDoubleValue();
            } else if (text == 'requiredByProduct') {
              //added this for creating Assets
              system.debug('requiredByProduct:: ' + parser.getText());
              requiredBySubscription = parser.getText();
            } else {
              System.debug(
                LoggingLevel.WARN,
                'Subscriptions consuming unrecognized property: ' + text
              );
              consumeObject(parser);
            }
          }
        }
      }
    }
  }

  public class Assets {
    public String assetId { get; set; }
    public String assetName { get; set; }
    public Double assetNumber { get; set; }
    public Double assetQuantity { get; set; }
    public String assetStatus { get; set; }
    public Double consultFee { get; set; }
    public String consultType { get; set; }
    public Boolean hasLifecycleManagement { get; set; }
    public Boolean isBundled { get; set; }
    public String latestQuoteLineId { get; set; }
    public String optionType { get; set; }
    public String ownerId { get; set; }
    public String productOption { get; set; }
    public Date purchaseDate { get; set; }
    public String requiredBySubscription { get; set; }
    public String currencyIsoCode { get; set; }
    public String orderItemId { get; set; }
    // manual additions
    public String feeType { get; set; }
    public String visitFeeCode { get; set; }
    public String visitFeeDesc { get; set; }
    public Double additionalDiscountAmount { get; set; }

    public Assets(JSONParser parser) {
      while (parser.nextToken() != System.JSONToken.END_OBJECT) {
        if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
          String text = parser.getText();
          if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
            if (text == 'assetId') {
              assetId = parser.getText();
            } else if (text == 'feeType') {
              feeType = parser.getText();
            } else if (text == 'LCRMVisitFeeCode') {
              visitFeeCode = parser.getText();
            } else if (text == 'LCRMVisitFeeDesc') {
              visitFeeDesc = parser.getText();
            } else if (text == 'assetName') {
              assetName = parser.getText();
            } else if (text == 'additionalDiscountAmount') {
              additionalDiscountAmount = parser.getDoubleValue();
            } else if (text == 'assetNumber') {
              assetNumber = parser.getDoubleValue();
            } else if (text == 'assetQuantity') {
              assetQuantity = parser.getDoubleValue();
            } else if (text == 'assetStatus') {
              assetStatus = parser.getText();
            } else if (text == 'consultFee') {
              consultFee = parser.getDoubleValue();
            } else if (text == 'consultType') {
              consultType = parser.getText();
            } else if (text == 'hasLifecycleManagement') {
              hasLifecycleManagement = parser.getBooleanValue();
            } else if (text == 'isBundled') {
              isBundled = parser.getBooleanValue();
            } else if (text == 'latestQuoteLineId') {
              latestQuoteLineId = parser.getText();
            } else if (text == 'optionType') {
              optionType = parser.getText();
            } else if (text == 'ownerId') {
              ownerId = parser.getText();
            } else if (text == 'productOption') {
              productOption = parser.getText();
            } else if (text == 'purchaseDate') {
              purchaseDate = parser.getDateValue();
            } else if (text == 'requiredBySubscription') {
              requiredBySubscription = parser.getText();
            } else if (text == 'currencyIsoCode') {
              currencyIsoCode = parser.getText();
            } else {
              System.debug(
                LoggingLevel.WARN,
                'Assets consuming unrecognized property: ' + text
              );
              consumeObject(parser);
            }
          }
        }
      }
    }
  }

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

  public static INT175_OrderItemV3 parse(String json) {
    System.JSONParser parser = System.JSON.createParser(json);
    return new INT175_OrderItemV3(parser);
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
  /*
  @testVisible
  private static List<Subscriptions_Z> arrayOfSubscriptions_Z(
    System.JSONParser p
  ) {
    List<Subscriptions_Z> res = new List<Subscriptions_Z>();
    if (p.getCurrentToken() == null)
      p.nextToken();
    while (p.nextToken() != System.JSONToken.END_ARRAY) {
      res.add(new Subscriptions_Z(p));
    }
    return res;
  }
  */
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
  /*
  @testVisible
  private static List<Subscriptions_Y> arrayOfSubscriptions_Y(
    System.JSONParser p
  ) {
    List<Subscriptions_Y> res = new List<Subscriptions_Y>();
    if (p.getCurrentToken() == null)
      p.nextToken();
    while (p.nextToken() != System.JSONToken.END_ARRAY) {
      res.add(new Subscriptions_Y(p));
    }
    return res;
  }
 */
  @testVisible
  private static List<Subscriptions> arrayOfSubscriptions(System.JSONParser p) {
    List<Subscriptions> res = new List<Subscriptions>();
    if (p.getCurrentToken() == null)
      p.nextToken();
    while (p.nextToken() != System.JSONToken.END_ARRAY) {
      res.add(new Subscriptions(p));
    }
    return res;
  }
  /*
  @testvisible
  private static List<Assets_Z> arrayOfAssets_Z(System.JSONParser p) {
    List<Assets_Z> res = new List<Assets_Z>();
    if (p.getCurrentToken() == null)
      p.nextToken();
    while (p.nextToken() != System.JSONToken.END_ARRAY) {
      res.add(new Assets_Z(p));
    }
    return res;
  }
  */
  @testVisible
  private static List<Assets> arrayOfAssets(System.JSONParser p) {
    List<Assets> res = new List<Assets>();
    if (p.getCurrentToken() == null)
      p.nextToken();
    while (p.nextToken() != System.JSONToken.END_ARRAY) {
      res.add(new Assets(p));
    }
    return res;
  }

  private static List<OrderItems> arrayOfOrderItems(System.JSONParser p) {
    List<OrderItems> res = new List<OrderItems>();
    if (p.getCurrentToken() == null)
      p.nextToken();
    while (p.nextToken() != System.JSONToken.END_ARRAY) {
      res.add(new OrderItems(p));
    }
    return res;
  }
}