<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Event_Owner_when_End_Date_has_passed</fullName>
        <description>Email Event Owner when End Date has passed</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Past_Event_in_Set_Status_Alert</template>
    </alerts>
    <rules>
        <fullName>Past Event in Set Status Alert</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Event.Meeting_Status__c</field>
            <operation>notEqual</operation>
            <value>Ran,Cancelled</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Email_Event_Owner_when_End_Date_has_passed</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Event.EndDateTime</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
