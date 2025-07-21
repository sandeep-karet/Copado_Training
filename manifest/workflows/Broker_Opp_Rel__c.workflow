<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Laster_Broker_Opportunity</fullName>
        <field>Recent_Broker_Involved__c</field>
        <formula>Broker_Rel__r.Svc_Acct_Name__c</formula>
        <name>Update Laster Broker Opportunity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>Opp_Broker__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>Lastest Broker Opportunity</fullName>
        <actions>
            <name>Update_Laster_Broker_Opportunity</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Update the lastest Broker Opportunity on the Opportunity Record</description>
        <failedMigrationToolVersion>256.4.3</failedMigrationToolVersion>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
