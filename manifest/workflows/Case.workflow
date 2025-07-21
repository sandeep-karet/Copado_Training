<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_email_notification_when_case_owner_reassign</fullName>
        <description>Send email notification when case owner reassign</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Case_Reassign_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_QA_Start_Date</fullName>
        <field>QA_Start_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set QA Start Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Send Notification for Case</fullName>
        <actions>
            <name>Send_email_notification_when_case_owner_reassign</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>ISCHANGED(OwnerId) &amp;&amp; OwnerId ==  CreatedById</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set QA Start Date</fullName>
        <actions>
            <name>Set_QA_Start_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>QA Review</value>
        </criteriaItems>
        <criteriaItems>
            <field>Case.QA_Start_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Set QA Start Date when the case status is set to QA Review</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
