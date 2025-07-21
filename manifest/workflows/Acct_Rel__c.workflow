<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Benefit_Sponsor_Account_Name</fullName>
        <description>Update Benefit Sponsor Account Name</description>
        <field>Benefit_Sponsor_Name__c</field>
        <formula>Benefit_Sponsor__r.Name</formula>
        <name>Update Benefit Sponsor Account Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Service_Account_Name</fullName>
        <description>Upate Service Account Name</description>
        <field>Svc_Acct_Name__c</field>
        <formula>Svc_Acct__r.Name</formula>
        <name>Update Service Account Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Update Service Account and Benefit Sponsor Name</fullName>
        <actions>
            <name>Update_Benefit_Sponsor_Account_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Service_Account_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Since formula fields are not allowed in Lookup search, created a text field which is updated by a workflow rule.</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
