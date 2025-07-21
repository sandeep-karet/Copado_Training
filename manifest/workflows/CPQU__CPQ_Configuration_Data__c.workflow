<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CPQU__CPQU_Import_Date_Default_Value</fullName>
        <field>CPQU__CSV_Import_Date__c</field>
        <formula>TODAY()</formula>
        <name>CPQU - Import Date - Default Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CPQU__CPQU_Status_Default_Value</fullName>
        <field>CPQU__Status__c</field>
        <literalValue>Imported</literalValue>
        <name>CPQU - Status - Default Value</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CPQU__CPQU - Default Values</fullName>
        <actions>
            <name>CPQU__CPQU_Import_Date_Default_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CPQU__CPQU_Status_Default_Value</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>CPQU__CPQ_Configuration_Data__c.CPQU__Status__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
