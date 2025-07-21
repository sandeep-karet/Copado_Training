/**
* Company : PwC.
* @description : L2O_Constants will contain all the Constants used in Apex
* *******************************************************************************************************************************************
* History : 
* @date 11/04/2022
* @author Lakshitha Salian
*/

public class L2O_Constants {
    
    //Opportunity Types
    public static final String RENEWAL_OPPTY_TYPE = 'Re-Sign Business';
    public static final String OPPTY_TYPE_NEWBUSINESS = 'New Business';
    public static final String OPPTY_TYPE_RESIGNBUSINESS = 'Re-Sign Business';
    public static final String OPPTY_TYPE_EXISTINGBUSINESS = 'Existing Business';
    
    //Opportunity Stages
    public static final String OPPTY_STAGE_PROPOSAL = 'Proposal';
    public static final String OPPTY_STAGE_PROSPECT = 'Prospect';
    public static final String OPPTY_STAGE_DISCOVERY = 'Discovery';
    public static final String OPPTY_STAGE_CLOSED_OWN = 'Closed Won';
    public static final String OPPTY_STAGE_CLOSED_LOST = 'Closed Lost';
    public static final String OPPTY_STAGE_CONTRACTING = 'Contracting';
    public static final String OPPTY_STAGE_REVIEW_NEGOTIATION = 'Review/Negotiation';
    
    //Opportunity Sub Types
    //public static final String SUBTYPE_EXPANSION = 'Expansion';
    public static final String SUBTYPE_CHANGEORDER = 'Change Order';
    public static final String RENEWAL_OPPTY_SUB_TYPE_PILOT = 'Pilot';
    public static final String RENEWAL_OPPTY_SUB_TYPE_RENEWAL = 'Renewal';
    public static final String CONTRACT_AMENDMENT_SUBTYPE = 'Recontracting';
    public static final String RENEWAL_OPPTY_SUB_TYPE_PILOT_EXT = 'Pilot Extension';
    
    //Opportuntiy Benefit Consultant Involved in Deal
    public static final String BENEFIT_CONSULTANT_NO_INVOLVEMENT = 'No Involvement';
    
    //Opportunity Contact Role
    public static final String OPPCON_ROLE_BROKER = 'Broker';
    public static final String OPPCON_ROLE_GENERAL_AGENCY = 'General Agency';
    public static final String OPPCON_ROLE_BENEFIT_CONSULTANT = 'Benefit Consultant';
    
    //Quote Status
    public static final String QUOTE_STATUS_DRAFT = 'Draft';
    public static final String QUOTE_STATUS_DENIED = 'Denied';
    public static final String QUOTE_STATUS_APPROVED = 'Approved';
    public static final String QUOTE_STATUS_ACCEPTED = 'Accepted';
    public static final String QUOTE_STATUS_REJECTED = 'Rejected';
    public static final String QUOTE_STATUS_IN_REVIEW = 'In Review';
    public static final String QUOTE_STATUS_PRESENTED = 'Presented';
    
    //Quote Types
    public static final String QUOTE_TYPE_QUOTE = 'Quote';
    public static final String QUOTE_TYPE_RENEWAL = 'Renewal';
    public static final String QUOTE_TYPE_AMENDMENT = 'Amendment';
    
    //Approval Stages
    public static final String APPROVAL_STATUS_APPROVED = 'Approved';
    public static final String APPROVAL_STATUS_REJECTED = 'Rejected';
    
    //Opportunity naming conventions
    public static final String RIP_REPLACE_OPPTY_PREFIX_NAME = 'Rip And Replace- contract';

    //opportunity bussiness type
    public static final String BUSSINESS_TYPE_HHS = 'HHS';
    public static final String BUSSINESS_TYPE_USGH = 'USGH';
    public static final String BUSSINESS_TYPE_LIV = 'LIV';
    public static final String BUSSINESS_TYPE_TDH = 'TDH';
    public static final String BUSSINESS_TYPE_CROSSELL = 'Cross Sell';
    
    //opportunity bussiness region
    public static final String BUSSINESS_REGION_USA = 'USA';
    public static final String BUSSINESS_REGION_CANADA = 'Canada';
    
    //Order status
    public static final String ORDER_STATUS_DRAFT = 'Draft';
    public static final String ORDER_STATUS_ACTIVATED = 'Activated';
    
    //Contract Signed Email Addresses Name
    public static final String CONTRACT_SIGNED_EMAIL_ADDRESSES_USA_HHS = 'L2O_USA_HHS';
    public static final String CONTRACT_SIGNED_EMAIL_ADDRESSES_USA_USGH = 'L2O_USA_USGH';
    public static final String CONTRACT_SIGNED_EMAIL_ADDRESSES_INTL_CANADA = 'L2O_INTL_CANADA';
    public static final String CONTRACT_SIGNED_EMAIL_ADDRESSES_INTL_NOT_CANADA = 'L2O_INTL_Not_CANADA';
    
    //User Profiles
    public static final String PROFILE_SALES = 'Sales';
    public static final String PROFILE_CLIENT_SUCCESS = 'Client Success';
    public static final String PROFILE_SYSTEM_ADMINISTRATOR = 'System Administrator';
    
    //Objects
    public static final String OBJECT_ORDER = 'Order';
    
    //Names
    public static final String NAME_CONTRACT_AMENDMENT = ' - Contract - Amendment - ';
    public static final String NAME_CONTRACT = ' - Contract ';
    public static final String NAME_AMENDMENT = ' - Amendment - ';
    //Price Books
    public static final String PRICEBOOK_INTL = 'INTL Pricebook';
}