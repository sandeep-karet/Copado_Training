<?xml version="1.0" encoding="UTF-8"?>
<CustomApplication xmlns="http://soap.sforce.com/2006/04/metadata">
    <formFactors>Large</formFactors>
    <isNavAutoTempTabsDisabled>false</isNavAutoTempTabsDisabled>
    <isNavPersonalizationDisabled>false</isNavPersonalizationDisabled>
    <isNavTabPersistenceDisabled>false</isNavTabPersistenceDisabled>
    <isOmniPinnedViewEnabled>false</isOmniPinnedViewEnabled>
    <label>Salesforce CMS</label>
    <navType>Console</navType>
    <profileActionOverrides>
        <actionName>View</actionName>
        <content>Opportunity_read_only</content>
        <formFactor>Large</formFactor>
        <pageOrSobjectType>Opportunity</pageOrSobjectType>
        <recordType>Opportunity.Read_Only</recordType>
        <type>Flexipage</type>
        <profile>Read Only</profile>
    </profileActionOverrides>
    <tabs>standard-CmsAuthorHome</tabs>
    <tabs>standard-CmsChannel</tabs>
    <tabs>standard-CmsWorkspaces</tabs>
    <tabs>standard-CmsExperiences</tabs>
    <tabs>Quotas__c</tabs>
    <tabs>Briefing__c</tabs>
    <uiType>Lightning</uiType>
    <workspaceConfig>
        <mappings>
            <tab>Briefing__c</tab>
        </mappings>
        <mappings>
            <tab>Quotas__c</tab>
        </mappings>
        <mappings>
            <tab>standard-CmsAuthorHome</tab>
        </mappings>
        <mappings>
            <tab>standard-CmsChannel</tab>
        </mappings>
        <mappings>
            <tab>standard-CmsExperiences</tab>
        </mappings>
        <mappings>
            <tab>standard-CmsWorkspaces</tab>
        </mappings>
    </workspaceConfig>
</CustomApplication>
