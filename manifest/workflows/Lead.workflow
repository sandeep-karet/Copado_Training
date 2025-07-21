<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_Lead_Owner_after_lead_status_is_changed_to_SAL_and_not_converted_after_7_d</fullName>
        <description>Alert Lead Owner after lead status is changed to MQL and not converted after 5 days.</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Leads_5_days_Alert_to_Lead_Owner_after_lead_status_changed_to_MQL</template>
    </alerts>
    <alerts>
        <fullName>Alert_Lead_Owner_when_lead_is_Rejected</fullName>
        <description>Alert Lead Owner when lead is Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>unfiled$public/Leads_Rejected_by_Sales_Notification</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_on_Physician_Lead_to_Clinical_email_addresses</fullName>
        <ccEmails>docresume@teladoc.com, recruit@teladoc.com</ccEmails>
        <description>Email Alert on Physician Lead to Clinical email addresses</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Leads_New_Physician_Lead_alert_to_Clinical</template>
    </alerts>
    <alerts>
        <fullName>Lead_Assignment_Notification_to_New_Owner</fullName>
        <description>Lead Assignment Notification to New Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/LeadsNewassignmentnotificationSAMPLE</template>
    </alerts>
    <fieldUpdates>
        <fullName>Date_Sales_Accepted_Field_Update_on_Lead</fullName>
        <field>Date_Sales_Accepted__c</field>
        <formula>Now()</formula>
        <name>Date Sales Accepted Field Update on Lead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Sales_Qualified_FieldUpdate_on_Lead</fullName>
        <field>Date_Sales_Qualified__c</field>
        <formula>NOW()</formula>
        <name>Date Sales Qualified FieldUpdate on Lead</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Uncheck_isBouncedEmail</fullName>
        <field>IsBouncedEmail__c</field>
        <literalValue>0</literalValue>
        <name>Uncheck isBouncedEmail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_AQL_date_field</fullName>
        <field>AQL_Date__c</field>
        <formula>NOW()</formula>
        <name>Update AQL date field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Lead_Owner_to_AQL_Queue</fullName>
        <description>Update Lead Owner to AQL Queue</description>
        <field>OwnerId</field>
        <lookupValue>Inquiry_Lead_Queue</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Lead Owner to AQL Queue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Sync_to_Marketo_Nurture_True</fullName>
        <field>Synch_to_Marketo_Nurture__c</field>
        <literalValue>1</literalValue>
        <name>Update Sync to Marketo Nurture True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>IsBouncedEmail Uncheck - Lead</fullName>
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
        <fullName>Lead Alert - Physician%2C to Clinical Team</fullName>
        <actions>
            <name>Email_Alert_on_Physician_Lead_to_Clinical_email_addresses</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Account_Type__c</field>
            <operation>equals</operation>
            <value>Physician</value>
        </criteriaItems>
        <description>Sends email alert to docresume@teladoc.com, recruit@teladoc.com</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Lead Assignment Notification to New Owner</fullName>
        <actions>
            <name>Lead_Assignment_Notification_to_New_Owner</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(ISCHANGED(OwnerId),NOT(ISPICKVAL(Status,&apos;AQL&apos;)),NOT(ISPICKVAL(Status,&apos;INQ&apos;)),NOT(ISPICKVAL(Lead_Source_Detail__c,&apos;Onvia&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Marketo Synch Owner to AQL Queue</fullName>
        <actions>
            <name>Update_Lead_Owner_to_AQL_Queue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Change the Lead owner to AQL Queue if the Lead owner is Marketo Sync profile user. Using workflow instead of Lead Assignment rule to avoid the default assignments.</description>
        <formula>Owner:User.Profile.Name = &apos;Marketo Sync&apos;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Sync to Marketo Nuture to True</fullName>
        <actions>
            <name>Update_Sync_to_Marketo_Nurture_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.CreatedById</field>
            <operation>equals</operation>
            <value>Marketo</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Synch_to_Marketo_Nurture__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Updates the Lead Field &quot;Sync to Marketo Nuture&quot; to &quot;True&quot; upon creation of a lead by Marketo.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
