<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>LVGO__Update_Campaign_Name</fullName>
        <field>LVGO__Campaign_Name__c</field>
        <formula>Name</formula>
        <name>Update Campaign Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>LVGO__Update Campaign Name Field</fullName>
        <actions>
            <name>LVGO__Update_Campaign_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(Name != null,($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
