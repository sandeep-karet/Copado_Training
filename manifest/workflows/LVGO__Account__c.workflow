<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>LVGO__Account_Status_has_changed_to_Former_Client</fullName>
        <ccEmails>clientsuccessleadership@livongo.com</ccEmails>
        <description>Account Status has changed to Former Client</description>
        <protected>false</protected>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__Account_Status_is_Former_Client</template>
    </alerts>
    <alerts>
        <fullName>LVGO__Enrollment_Marketing_Lead_Assignemnt</fullName>
        <description>Enrollment Marketing Lead Assignemnt</description>
        <protected>false</protected>
        <recipients>
            <field>LVGO__EML__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__All/LVGO__Enrollment_Marketing_Lead_Assigned_to_You</template>
    </alerts>
    <fieldUpdates>
        <fullName>LVGO__Multi_program</fullName>
        <field>LVGO__Single_or_Multi_Program2__c</field>
        <literalValue>Multi Program</literalValue>
        <name>Multi program</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__Request_CSM_60_Days</fullName>
        <field>LVGO__RequestCSM__c</field>
        <literalValue>1</literalValue>
        <name>Request CSM_60 Days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__Single_program</fullName>
        <field>LVGO__Single_or_Multi_Program2__c</field>
        <literalValue>Single Program</literalValue>
        <name>Single program</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__Status_changed_to_Prosp_Exp_Int</fullName>
        <field>LVGO__Account_Type__c</field>
        <literalValue>Prospecting - Expressed Interest</literalValue>
        <name>Status changed to Prosp-Exp Int</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__Turn_Status_to_Engaging</fullName>
        <field>LVGO__Account_Type__c</field>
        <literalValue>Engaging</literalValue>
        <name>Turn Status to Engaging</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__Update_Prior_Account_Status</fullName>
        <description>JENGA-1279</description>
        <field>LVGO__Prior_Account_Status__c</field>
        <formula>TEXT(PRIORVALUE(LVGO__Account_Type__c))</formula>
        <name>Update Prior Account Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__Whole_Person_Populate</fullName>
        <field>LVGO__Single_or_Multi_Program2__c</field>
        <literalValue>Whole Person</literalValue>
        <name>Whole Person Populate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>LVGO__Account Status Engaging</fullName>
        <actions>
            <name>LVGO__Turn_Status_to_Engaging</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>An account with an open opportunity should be in the Account Status &apos;Engaging.&apos;</description>
        <formula>AND(                     AND(                         NOT(ISPICKVAL(LVGO__Account_Type__c,&quot;Engaging&quot;)),                         NOT(ISPICKVAL(LVGO__Account_Type__c,&quot;Client&quot;)),                         NOT(ISPICKVAL(LVGO__Account_Type__c,&quot;Disqualified&quot;)),                         NOT(ISPICKVAL(LVGO__Account_Type__c,&quot;Active Partner&quot;))                     ),                     LVGO__Closed_Won_Opportunity_Count__c == 0,                     LVGO__Open_Opportunity_Count__c != 0,                     $Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c                 )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Enrollment Marketing Lead Assigned to You</fullName>
        <actions>
            <name>LVGO__Enrollment_Marketing_Lead_Assignemnt</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>AND($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c,LVGO__EML__c != null)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Lost Opp Account status Expressed Interest</fullName>
        <actions>
            <name>LVGO__Status_changed_to_Prosp_Exp_Int</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If a prospect has a closed no decision/lost opp, and no open opp, the status should be Prospecting - Expressed Interest</description>
        <formula>AND($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c,ISPICKVAL(LVGO__Account_Type__c,&quot;Engaging&quot;),ISPICKVAL(LVGO__Account_Type__c,&quot;Prospecting&quot;),LVGO__Open_Opportunity_Count__c=0,LVGO__Closed_Won_Opportunity_Count__c=0,OR(LVGO__Total_Closed_No_Decision_Opps__c!=0,LVGO__Total_Closed_Lost_Opps__c!=0))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Multi Program populate</fullName>
        <actions>
            <name>LVGO__Multi_program</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c,LVGO__Program_Count3__c&gt;=2,1&gt;LVGO__PO_WholePerson__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Request CSM_60 Days</fullName>
        <active>false</active>
        <formula>AND($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c,LVGO__Earliest_Active_Initial_Launch_Date__c!=null,RecordType.Name=&quot;Client Account&quot;,LVGO__RequestCSM__c=false,LVGO__CSM__c=null,NOT(ISPICKVAL(LVGO__Account_Type__c,&quot;Former Client&quot;)),NOT(ISPICKVAL(LVGO__Account_Type__c,&quot;Disqualified&quot;)),NOT(ISPICKVAL(LVGO__Account_Type__c,&quot;Study&quot;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>LVGO__Request_CSM_60_Days</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>LVGO__Account__c.LVGO__Earliest_Active_Initial_Launch_Date__c</offsetFromField>
            <timeLength>60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>LVGO__Single program populate</fullName>
        <actions>
            <name>LVGO__Single_program</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c,LVGO__Program_Count3__c=1,1&gt;LVGO__PO_WholePerson__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Update Prior Account Status</fullName>
        <actions>
            <name>LVGO__Update_Prior_Account_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>JENGA-1279</description>
        <formula>AND(ISCHANGED(LVGO__Account_Type__c), NOT(ISPICKVAL(LVGO__Account_Type__c, &apos;&apos;)), NOT(ISBLANK(PRIORVALUE(LVGO__Account_Type__c))),$Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>LVGO__Resource_Request_CSM_Needed_on_this_Account</fullName>
        <assignedTo>prince.kumar@teladochealth.com.lcrm</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>3</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Resource Request: CSM Needed on this Account</subject>
    </tasks>
    <tasks>
        <fullName>LVGO__Resource_Request_CSM_Needed_on_this_Account10</fullName>
        <assignedTo>prince.kumar@teladochealth.com.lcrm</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>3</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Resource Request: CSM Needed on this Account</subject>
    </tasks>
    <tasks>
        <fullName>LVGO__Resource_Request_CSM_Needed_on_this_Account2</fullName>
        <assignedTo>prince.kumar@teladochealth.com.lcrm</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>3</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Resource Request: CSM Needed on this Account</subject>
    </tasks>
    <tasks>
        <fullName>LVGO__Resource_Request_CSM_Needed_on_this_Account4</fullName>
        <assignedTo>prince.kumar@teladochealth.com.lcrm</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>3</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Resource Request: CSM Needed on this Account</subject>
    </tasks>
    <tasks>
        <fullName>LVGO__Resource_Request_CSM_Needed_on_this_Account5</fullName>
        <assignedTo>prince.kumar@teladochealth.com.lcrm</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>3</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Resource Request: CSM Needed on this Account</subject>
    </tasks>
    <tasks>
        <fullName>LVGO__Resource_Request_CSM_Needed_on_this_Account9</fullName>
        <assignedTo>prince.kumar@teladochealth.com.lcrm</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>3</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Resource Request: CSM Needed on this Account</subject>
    </tasks>
    <tasks>
        <fullName>LVGO__Resource_Request_CSM_Needed_on_this_Account_1</fullName>
        <assignedTo>prince.kumar@teladochealth.com.lcrm</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>3</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Resource Request: CSM Needed on this Account</subject>
    </tasks>
    <tasks>
        <fullName>LVGO__Resource_Request_CSM_Needed_on_this_Account_2</fullName>
        <assignedTo>prince.kumar@teladochealth.com.lcrm</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>3</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Open</status>
        <subject>Resource Request: CSM Needed on this Account</subject>
    </tasks>
</Workflow>
