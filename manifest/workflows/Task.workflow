<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Task_Type</fullName>
        <field>Type_Custom__c</field>
        <formula>TEXT(Type)</formula>
        <name>Update Task Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Update Task Type</fullName>
        <actions>
            <name>Update_Task_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Task.RecordTypeId</field>
            <operation>equals</operation>
            <value>Task</value>
        </criteriaItems>
        <description>Worklow rule updates the custom type field to copy the value from standard type field. This is used for Account Activity report.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
