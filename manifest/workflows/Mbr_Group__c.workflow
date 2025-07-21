<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Teladoc_Select_Email_Alert</fullName>
        <ccEmails>providerrelations@teladoc.com.TEST</ccEmails>
        <description>Teladoc Select Email Alert</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/Teladoc_Select_activation_notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Active_Date</fullName>
        <field>Active_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Active Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Update Active Date</fullName>
        <actions>
            <name>Update_Active_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR( AND(ISNEW(),ISPICKVAL(Status__c, &quot;ACTIVE&quot;) ), AND(ISCHANGED(Status__c),ISPICKVAL(Status__c, &quot;ACTIVE&quot;)) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
