<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>LVGO__Case_ready_to_nurture</fullName>
        <ccEmails>sfintegration@livongo.com</ccEmails>
        <description>Case ready for JIRA</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__Salesforce_Case_to_Jira_Story</template>
    </alerts>
    <alerts>
        <fullName>LVGO__Notify_Case_Owner_for_New_Reference_Request_Case</fullName>
        <description>Notify Case Owner for New Reference Request Case</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__Reference_Request_Assignment</template>
    </alerts>
    <alerts>
        <fullName>LVGO__Send_Livongo_Presale_Email_Confirmation</fullName>
        <description>Send Livongo Presale Email Confirmation</description>
        <protected>false</protected>
        <recipients>
            <field>LVGO__SuppliedEmail__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__Livongo_Presale_Auto_Reply</template>
    </alerts>
    <alerts>
        <fullName>LVGO__Send_Livongo_Wins_Email_Confirmation</fullName>
        <description>Send Livongo Wins Email Confirmation</description>
        <protected>false</protected>
        <recipients>
            <field>LVGO__SuppliedEmail__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__Livongo_Wins_Auto_Reply</template>
    </alerts>
    <fieldUpdates>
        <fullName>LVGO__Assign_Reference_Requests_to_Lisa_Thomas</fullName>
        <field>OwnerId</field>
        <lookupValue>Reference_Request_Case_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Assign Reference Requests to Lisa Thomas</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>LVGO__Assign Reference Requests</fullName>
        <actions>
            <name>LVGO__Assign_Reference_Requests_to_Lisa_Thomas</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(RecordType.Name == &quot;Reference Request&quot;,($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Livongo Presale Auto Reply</fullName>
        <actions>
            <name>LVGO__Send_Livongo_Presale_Email_Confirmation</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(RecordType.Name == &quot;Livongo Presale&quot;,($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Livongo Wins Auto Reply</fullName>
        <actions>
            <name>LVGO__Send_Livongo_Wins_Email_Confirmation</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(RecordType.Name == &quot;Livongo Wins&quot;,($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__New Reference Request Auto Response</fullName>
        <actions>
            <name>LVGO__Notify_Case_Owner_for_New_Reference_Request_Case</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(RecordType.Name == &quot;Reference Request&quot;,($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
