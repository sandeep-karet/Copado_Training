<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>LVGO__Notify_Users_on_Survey_Status</fullName>
        <description>Notify Users on Survey Status</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>LVGO__Enrollment_Marketing_Lead__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__Enrollment_Communications_Survey_Status_Updated</template>
    </alerts>
    <rules>
        <fullName>LVGO__Notify Owner and EML when survey status is changed</fullName>
        <actions>
            <name>LVGO__Notify_Users_on_Survey_Status</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND(ISCHANGED(LVGO__Survey_Status__c),($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
