<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Opportunity Parser</label>
    <protected>false</protected>
    <values>
        <field>Account_Fields__c</field>
        <value xsi:type="xsd:string">Id,Name,Type,Account_Type__c,Website,Phone,OwnerId,Guid__c,BillingStreet,BillingCity,BillingStateCode,BillingPostalCode,BillingCountryCode,Total_US_Employees_Benefits_Enrolled__c,Members__c,Sales_Ranking__c, CIM__c, Rev_Synergy__c,Livongo_Account_Record_Type__c,Account_Health_Score__c</value>
    </values>
    <values>
        <field>Contact_Fields__c</field>
        <value xsi:type="xsd:string">Id, FirstName, Middlename, LastName, Email, Phone, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry</value>
    </values>
    <values>
        <field>Opportunity_Fields__c</field>
        <value xsi:type="xsd:string">AccountId , Id, Name, StageName, OwnerId, Contracted_Date__c, CloseDate, Next_Steps__c, Opp_Guid__c, Initial_of_Lives__c, Decision_Date__c, Pricebook2Id, Ann_Rec_Rev__c,Primary_Carrier_LOB__c,Monthly_Recurring_Revenue__c,LeadSource,Probability,Reason_for_Loss__c,Type,Sub_Channel__c,ForecastCategoryName,Primary_Carrier_Account__c, Benefit_Consultant_Involved_in_Deal__c, CIM__c, Forecast_Manager_Call__c, Request_CIM__c, Primary_Carrier__c, Num_of_Broker_Rel__c, Sub_Type__c,Box_Contract_URL__c,Parent_Opportunity__c,Parent_Opportunity__r.Sub_Type__c,Parent_Opportunity__r.AccountId,CIM_Assignment_Completed__c,Msg_Bus_Manual_Trigger__c,ContractOps_Notes__c,ContractOps_Owner__c,ContractOps_Stage__c,ContractOps_Status__c,CPQ_Pricebook__c, Contract_Path__c,Sub_Type_Detail__c,GCRM_Contract_Path__c,GCRM_Contracting_Account__c,Line_of_Business_CP__c</value>
    </values>
    <values>
        <field>Opportunity_Line_Item_Fields__c</field>
        <value xsi:type="xsd:string">Id, Membership_fee__c, SBQQ__QuoteLine__r.Parent_Product_Code__c, ProductCode, Name, Anchor__c, SBQQ__QuoteLine__r.Participant_Quantity__c, Quantity,UnitPrice,SBQQ__QuoteLine__r.SBQQ__EffectiveSubscriptionTerm__c, TotalPrice, Net_ARR__c, SBQQ__QuoteLine__r.Admin_Fee__c, SBQQ__QuoteLine__r.At_Risk_PPPM__c, SBQQ__QuoteLine__r.Up_Front_Fee__c,SBQQ__QuoteLine__r.Disable_Teletherapy__c,SBQQ__QuoteLine__r.Disable_Coaching__c,SBQQ__QuoteLine__r.GrandParent_Product_Code__c,Product_Rollup__c</value>
    </values>
    <values>
        <field>Parser_Name__c</field>
        <value xsi:type="xsd:string">Opportunity_Parser</value>
    </values>
</CustomMetadata>
