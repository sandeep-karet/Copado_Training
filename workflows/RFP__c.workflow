<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_RFP_Owner_Change</fullName>
        <description>Notify RFP Owner Change</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>RFP_Email_Template/RFPRequest_Notification</template>
    </alerts>
    <alerts>
        <fullName>RFPRequest_Notification</fullName>
        <ccEmails>RFPrequests@teladoc.com</ccEmails>
        <description>RFPRequest Notification</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>RFP_Email_Template/RFPRequest_Notification</template>
    </alerts>
    <alerts>
        <fullName>RFPRequest_Notification_Submitted</fullName>
        <description>RFPRequest Notification Submitted</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>RFP_Requester__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>RFP_Email_Template/RFP_Submitted</template>
    </alerts>
    <alerts>
        <fullName>SalesRep_Notification</fullName>
        <description>SalesRep Notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>RFP_Email_Template/SalesRep_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Record_Type</fullName>
        <description>Update Record Type</description>
        <field>RecordTypeId</field>
        <lookupValue>Edit</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Requested_Date</fullName>
        <description>Update Requested Date</description>
        <field>Request_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Requested Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
