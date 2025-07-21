<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>LVGO__Claim_based_billing_notification</fullName>
        <description>Claim based billing notification</description>
        <protected>false</protected>
        <recipients>
            <field>LVGO__CIM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__All/LVGO__Claim_Based_Billing_Notification</template>
    </alerts>
    <alerts>
        <fullName>LVGO__Client_Must_Approved_Assets_has_changed</fullName>
        <description>Client_Must_Approved_Assets_has_changed</description>
        <protected>false</protected>
        <recipients>
            <field>LVGO__CSM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__Client_Must_Approved_Assets_has_changed</template>
    </alerts>
    <alerts>
        <fullName>LVGO__Consecutive_Inactive_Months_to_Lapse_is_changed</fullName>
        <description>Consecutive_Inactive_Months_to_Lapse_is_changed</description>
        <protected>false</protected>
        <recipients>
            <field>LVGO__Client_Overview_CSM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__Consecutive_Inactive_Months_to_Lapse_is_changed</template>
    </alerts>
    <alerts>
        <fullName>LVGO__Contract_Term_Date_14_Days</fullName>
        <description>Contract_Term_Date_14_Days</description>
        <protected>false</protected>
        <recipients>
            <field>LVGO__CSM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__Contract_Term_Date_14_Days</template>
    </alerts>
    <alerts>
        <fullName>LVGO__Contract_Termination_Date_has_changed</fullName>
        <description>Contract_Termination_Date_has_changed</description>
        <protected>false</protected>
        <recipients>
            <field>LVGO__CSM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__Contract_Termination_Date_has_changed</template>
    </alerts>
    <alerts>
        <fullName>LVGO__Detailed_Invoice_has_changed</fullName>
        <description>Detailed_Invoice_has_changed</description>
        <protected>false</protected>
        <recipients>
            <field>LVGO__CSM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__Detailed_Invoice_has_changed</template>
    </alerts>
    <alerts>
        <fullName>LVGO__Is_There_Laspe_Criteria_has_Changed</fullName>
        <description>Is_There_Laspe_Criteria_has_Changed</description>
        <protected>false</protected>
        <recipients>
            <field>LVGO__Client_Overview_CSM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__Is_There_Laspe_Criteria_has_Changed</template>
    </alerts>
    <alerts>
        <fullName>LVGO__Lapse_Criteria_has_Changed</fullName>
        <description>Lapse_Criteria_has_Changed</description>
        <protected>false</protected>
        <recipients>
            <field>LVGO__Client_Overview_CSM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__Lapse_Criteria_has_Changed</template>
    </alerts>
    <alerts>
        <fullName>LVGO__Notify_Legal_Cannot_Activate_Contract_No_Lapse_Criteria</fullName>
        <ccEmails>contractops@livongo.com</ccEmails>
        <description>Notify Legal - Cannot Activate Contract - No Lapse Criteria</description>
        <protected>false</protected>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__All/LVGO__Cannot_Activate_Contract_No_Lapse_Criteria</template>
    </alerts>
    <alerts>
        <fullName>LVGO__Notify_Legal_with_required_fields_missing_on_contract</fullName>
        <ccEmails>contractops@livongo.com</ccEmails>
        <description>Notify Legal with required fields missing on contract</description>
        <protected>false</protected>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__All/LVGO__Notify_Legal_with_Required_Fields_Required</template>
    </alerts>
    <alerts>
        <fullName>LVGO__Notify_when_Client_Overview_status_is_changed_to_Expired_or_Terminated</fullName>
        <ccEmails>clientsuccessleadership@livongo.com</ccEmails>
        <description>Notify when Client Overview status is changed to Expired or Terminated</description>
        <protected>false</protected>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__ClientOverview_is_Expired_or_Terminated</template>
    </alerts>
    <alerts>
        <fullName>LVGO__Participants_Term_Mininum_Months_has_changed</fullName>
        <description>Participants_Term_Mininum_Months_has_changed</description>
        <protected>false</protected>
        <recipients>
            <field>LVGO__Client_Overview_CSM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__Participants_Term_Mininum_Months_has_changed</template>
    </alerts>
    <alerts>
        <fullName>LVGO__Program_End_Date_has_Changed</fullName>
        <description>Program_End_Date_has_Changed</description>
        <protected>false</protected>
        <recipients>
            <field>LVGO__Client_Overview_CSM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__Program_End_Date_has_changed</template>
    </alerts>
    <alerts>
        <fullName>LVGO__Program_Overview_Date_14_Days</fullName>
        <description>Program_Overview_Date_14_Days</description>
        <protected>false</protected>
        <recipients>
            <field>LVGO__Client_Overview_CSM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__Program_Overview_Date_14_Days</template>
    </alerts>
    <alerts>
        <fullName>LVGO__Program_Status_has_Changed</fullName>
        <description>Program_Status_has_Changed</description>
        <protected>false</protected>
        <recipients>
            <field>LVGO__Client_Overview_CSM__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__Program_Status_has_changed</template>
    </alerts>
    <fieldUpdates>
        <fullName>LVGO__Complete_Per_Legal_Date_Time</fullName>
        <field>LVGO__Date_Completed_By_Legal__c</field>
        <formula>NOW()</formula>
        <name>Complete Per Legal Date-Time</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__Program_Implementation_Status</fullName>
        <field>LVGO__Program_Implementation_status__c</field>
        <literalValue>Terminated</literalValue>
        <name>Program Implementation  Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__Registration_Status</fullName>
        <field>LVGO__Registration_Status__c</field>
        <literalValue>Closed</literalValue>
        <name>Registration Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__UpdateProgramImplementationStatus</fullName>
        <description>Update Prog Implementation Status to &quot;Launch+90&quot;</description>
        <field>LVGO__Program_Implementation_status__c</field>
        <literalValue>Launched +90</literalValue>
        <name>UpdateProgramImplementationStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__UpdateRegStatus</fullName>
        <description>udpate the reg status to Open</description>
        <field>LVGO__Registration_Status__c</field>
        <literalValue>Open</literalValue>
        <name>UpdateRegStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__Update_Contract_Status_Activated</fullName>
        <description>Updates the Status on Contract to &quot;Activated&quot;</description>
        <field>LVGO__Status__c</field>
        <literalValue>Activate</literalValue>
        <name>Update Contract Status - Activated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__Update_Contract_Status_Terminated</fullName>
        <description>Updates the Contract status to &quot;Expired&quot;</description>
        <field>LVGO__Status__c</field>
        <literalValue>Expired</literalValue>
        <name>Update Contract Status - Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__Update_Program_Agreement_default_name</fullName>
        <description>Set&apos;s contract name field to Account name</description>
        <field>Name</field>
        <formula>LVGO__Account__r.Name</formula>
        <name>Update Program Agreement default name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__Update_Program_Overview_Name</fullName>
        <description>Default the name for a Program Overview record</description>
        <field>Name</field>
        <formula>LEFT(LVGO__Account__r.Name &amp; &quot; - &quot; &amp;  TEXT(LVGO__Program_Name__c)  &amp; &quot; - &quot; &amp; LVGO__Client_Overview__r.LVGO__Contract_Path__r.Name, 80)</formula>
        <name>Update Program Overview Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__Update_TargetedRecruitableField_on_PO</fullName>
        <field>LVGO__Targeted_Recruitable_Data__c</field>
        <literalValue>1</literalValue>
        <name>Update TargetedRecruitableField on PO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>LVGO__Claim based billing notification</fullName>
        <actions>
            <name>LVGO__Claim_based_billing_notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>$Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c &amp;&amp; RecordType.Name =&apos;Program Overview&apos; &amp;&amp; (ISNEW() || ISCHANGED( LVGO__Claims_Configuration__c )) &amp;&amp; NOT(ISBLANK(LVGO__Claims_Configuration__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Contract_Term_Date_14_Days</fullName>
        <active>true</active>
        <formula>$Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c &amp;&amp; RecordType.Name =&apos;Client Overview&apos; &amp;&amp; LVGO__Contract_Termination_Date__c=null &amp;&amp; ISPICKVAL(LVGO__Status__c,&apos;Terminated&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>LVGO__Contract_Term_Date_14_Days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>LVGO__Contract__c.LVGO__Contract_Termination_Date__c</offsetFromField>
            <timeLength>-14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>LVGO__Date Stamp Complete per Legal</fullName>
        <actions>
            <name>LVGO__Complete_Per_Legal_Date_Time</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(LVGO__Complete_Per_Legal__c == TRUE,$Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Default Program Overview Name</fullName>
        <actions>
            <name>LVGO__Update_Program_Overview_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When a Program Overview record is manually created and the &quot;Name&quot; field is blank, give it a default name</description>
        <formula>$Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c &amp;&amp; CASESAFEID(RecordType.Id) =  $Label.LVGO__Program_Schedule_Record_Type  &amp;&amp; OR(ISCHANGED( LVGO__Program_Name__c ), ISBLANK(Name))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Notify when Client Overview is Expired or Terminated</fullName>
        <actions>
            <name>LVGO__Notify_when_Client_Overview_status_is_changed_to_Expired_or_Terminated</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify CS Leadership when Client Overview status changes to Expired or Terminated.</description>
        <formula>AND($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c,RecordType.Name=&quot;Client Overview&quot;,               ISCHANGED(LVGO__Status__c),              OR(ISPICKVAL(LVGO__Status__c, &quot;Expired&quot;) ,ISPICKVAL(LVGO__Status__c, &quot;Terminated&quot;))           )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Program_Overview_Date_14_Days</fullName>
        <active>true</active>
        <formula>$Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c &amp;&amp; RecordType.Name =&apos;Program Overview&apos; &amp;&amp; LVGO__Program_End_Date__c!=null &amp;&amp; NOT(ISPICKVAL(LVGO__Program_Implementation_status__c,&apos;Terminated&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>LVGO__Program_Overview_Date_14_Days</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>LVGO__Contract__c.LVGO__Program_End_Date__c</offsetFromField>
            <timeLength>-14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>LVGO__Set default Program Agreement Name</fullName>
        <actions>
            <name>LVGO__Update_Program_Agreement_default_name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set&apos;s the default contract name field of a Program Agreement to the name of the account it&apos;s related too.</description>
        <formula>AND($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c,RecordType.Name == &apos;Program Agreement&apos;)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Update Client Overview Status - Activate</fullName>
        <active>false</active>
        <description>Updates the status of a Client Overview to &quot;Activated&quot; on the Contract Effective Date.</description>
        <formula>AND($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c,RecordType.Name = &quot;Client Overview&quot;, ISPICKVAL(LVGO__Status__c,&quot;Draft&quot;), NOT(ISBLANK(LVGO__Contract_Effective_Date__c)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>LVGO__Update_Contract_Status_Activated</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>LVGO__Contract__c.LVGO__Contract_Effective_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>LVGO__Update Client Overview Status - Expired</fullName>
        <active>true</active>
        <description>Updates the status of a Client Overview to &quot;Expired&quot; on the Contract Terminated Date.</description>
        <formula>AND($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c,RecordType.Name = &quot;Client Overview&quot;, ISPICKVAL(LVGO__Status__c, &quot;Active&quot;), NOT(ISBLANK(LVGO__Contract_Termination_Date__c)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>LVGO__Notify_when_Client_Overview_status_is_changed_to_Expired_or_Terminated</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>LVGO__Contract__c.LVGO__Contract_Termination_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>LVGO__Update PO Fields when Status is Terminated</fullName>
        <actions>
            <name>LVGO__Program_Implementation_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>LVGO__Registration_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Program Implementation Status” to be updated to “Terminated” and “Registration Status” as “Closed” , when the Program Status  is Terminated</description>
        <formula>AND($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c,RecordType.Name = &quot;Program Overview&quot;, ISPICKVAL(LVGO__Status__c, &quot;Terminated&quot;), NOT(ISBLANK(LVGO__Program_End_Date__c)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Update TargetedRecruitableData field when PO is created</fullName>
        <actions>
            <name>LVGO__Update_TargetedRecruitableField_on_PO</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(RecordType.Name == &quot;Program Overview&quot;,$Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
