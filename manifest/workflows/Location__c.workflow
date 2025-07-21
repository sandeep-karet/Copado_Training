<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Location_HQ_Name</fullName>
        <field>Location_HQ_Name__c</field>
        <formula>Location_HQ__r.Name</formula>
        <name>Update Location HQ Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Update Location HQ Name Field</fullName>
        <actions>
            <name>Update_Location_HQ_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update a readOnly filed for location object</description>
        <formula>Location_HQ__c  &lt;&gt; null</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
