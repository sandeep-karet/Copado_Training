<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Uncheck_isBouncedEmail</fullName>
        <description>If the field is set to true and the email address gets updated in salesforce then the field should be unchecked.</description>
        <field>IsBouncedEmail__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck isBouncedEmail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Office_Location_City</fullName>
        <field>MailingCity</field>
        <formula>Location__r.Billing_City__c</formula>
        <name>Update Office Location City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Office_Location_Country</fullName>
        <field>MailingCountry</field>
        <formula>Location__r.Billing_Country__c</formula>
        <name>Update Office Location Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Office_Location_State</fullName>
        <field>MailingState</field>
        <formula>Location__r.Billing_State__c</formula>
        <name>Update Office Location State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Office_Location_Street</fullName>
        <field>MailingStreet</field>
        <formula>Location__r.Billing_Address__c</formula>
        <name>Update Office Location Street</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Office_Location_ZIp</fullName>
        <field>MailingPostalCode</field>
        <formula>Location__r.Billing_Postal_Code__c</formula>
        <name>Update Office Location ZIp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>IsBouncedEmail Uncheck - Contact</fullName>
        <actions>
            <name>Uncheck_isBouncedEmail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If the field is set to true and the email address gets updated in salesforce then the field should be unchecked.</description>
        <formula>ISCHANGED(Email)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Use Location Address</fullName>
        <actions>
            <name>Update_Office_Location_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Office_Location_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Office_Location_State</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Office_Location_Street</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Office_Location_ZIp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>(ISNEW() &amp;&amp; Location__c  != null) || (ISCHANGED(Location__c) &amp;&amp; Location__c  != null) || ( Location__c != null &amp;&amp; (MailingStreet !=  Location__r.Billing_Address__c ||  MailingCity !=  Location__r.Billing_City__c  ||  MailingCountry != Location__r.Billing_Country__c  ||  MailingPostalCode !=  Location__r.Billing_Postal_Code__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
