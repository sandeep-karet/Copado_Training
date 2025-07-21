<?xml version="1.0" encoding="UTF-8"?>
<CustomApplication xmlns="http://soap.sforce.com/2006/04/metadata">
    <brand>
        <headerColor>#0070D2</headerColor>
        <logoVersion>1</logoVersion>
        <shouldOverrideOrgTheme>false</shouldOverrideOrgTheme>
    </brand>
    <description>Build stronger customer relationships, manage renewals, and stay organized.</description>
    <formFactors>Large</formFactors>
    <isNavAutoTempTabsDisabled>false</isNavAutoTempTabsDisabled>
    <isNavPersonalizationDisabled>false</isNavPersonalizationDisabled>
    <isNavTabPersistenceDisabled>false</isNavTabPersistenceDisabled>
    <isOmniPinnedViewEnabled>false</isOmniPinnedViewEnabled>
    <label>Relationship Management</label>
    <navType>Standard</navType>
    <profileActionOverrides>
        <actionName>View</actionName>
        <content>Opportunity_read_only</content>
        <formFactor>Large</formFactor>
        <pageOrSobjectType>Opportunity</pageOrSobjectType>
        <recordType>Opportunity.Read_Only</recordType>
        <type>Flexipage</type>
        <profile>Read Only</profile>
    </profileActionOverrides>
    <tabs>standard-home</tabs>
    <tabs>standard-Account</tabs>
    <tabs>standard-Contact</tabs>
    <tabs>standard-Contract</tabs>
    <tabs>standard-Event</tabs>
    <tabs>standard-CollaborationGroup</tabs>
    <tabs>standard-ContentNote</tabs>
    <tabs>standard-Task</tabs>
    <tabs>Quotas__c</tabs>
    <uiType>Lightning</uiType>
    <utilityBar>Relationship_Management_UtilityBar</utilityBar>
</CustomApplication>
