<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Notify_RFP_Owner_Change</fullName>
        <description>Notify RFP Owner Change</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
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
            <field>Opportunity_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>RFP_Email_Template/RFP_Submitted</template>
    </alerts>
    <alerts>
        <fullName>SalesRep_Notification</fullName>
        <description>SalesRep Notification</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>RFP_Email_Template/SalesRep_Notification</template>
    </alerts>
    <fieldUpdates>
        <fullName>Assign_Sales_Represantative</fullName>
        <description>Assign created Id to the Sales Representative</description>
        <field>Opportunity_Owner__c</field>
        <name>Assign Sales Represantative</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Response_Status_Update</fullName>
        <description>Update Response Status to &apos;InProgress&apos;</description>
        <field>Response_Status__c</field>
        <literalValue>In Progress</literalValue>
        <name>Response Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
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
        <field>Request_Date__c</field>
        <formula>TODAY()</formula>
        <name>Update Requested Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Edit RFP Status Change when not assigned to the Queue</fullName>
        <actions>
            <name>Notify_RFP_Owner_Change</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Response_Status_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Change the Response Status to In Progress and send a Notification email</description>
        <formula>ISCHANGED(OwnerId) &amp;&amp; Owner:Queue.DeveloperName &lt;&gt; &quot;RFP_Requests_Queue&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Edit RFP Status changed to Submitted</fullName>
        <actions>
            <name>RFPRequest_Notification_Submitted</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>ISCHANGED(Response_Status__c) &amp;&amp; TEXT(Response_Status__c) = &apos;Submitted&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>New RFP Workflow</fullName>
        <actions>
            <name>RFPRequest_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>SalesRep_Notification</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Record_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Requested_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Change the Recordtype to Edit, Assign the sales represntative when the RFP record is created</description>
        <failedMigrationToolVersion>252.14.10</failedMigrationToolVersion>
        <formula>true</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
