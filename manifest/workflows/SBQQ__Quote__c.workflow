<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>CPQU__CPQ_Quote_Approved</fullName>
        <description>CPQ - Quote - Approved</description>
        <protected>false</protected>
        <recipients>
            <field>SBQQ__SalesRep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQU__CPQ_Email_Templates/CPQU__CPQ_Quote_Approved</template>
    </alerts>
    <alerts>
        <fullName>CPQU__CPQ_Quote_Rejected</fullName>
        <description>CPQ - Quote - Rejected</description>
        <protected>false</protected>
        <recipients>
            <field>SBQQ__SalesRep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQU__CPQ_Email_Templates/CPQU__CPQ_Quote_Rejected</template>
    </alerts>
    <alerts>
        <fullName>CPQ_Quote_Approved_Email_Alert_Notification</fullName>
        <ccEmails>contracts@teladoc.com</ccEmails>
        <description>CPQ - Quote Approved - Email Alert Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>cgreeff-berens@teladochealth.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jkneip@teladochealth.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>simperato@teladochealth.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ_Templates/Quote_Approved_V43</template>
    </alerts>
    <alerts>
        <fullName>CPQ_Quote_Approved_Email_Alert_to_Sales_Rep</fullName>
        <description>CPQ - Quote Approved - Email Alert to Sales Rep</description>
        <protected>false</protected>
        <recipients>
            <field>SBQQ__SalesRep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ_Templates/Quote_Approved_V43</template>
    </alerts>
    <alerts>
        <fullName>CPQ_Quote_Rejected_Email_Alert_to_Sales_Rep</fullName>
        <ccEmails>contracts@teladoc.com</ccEmails>
        <description>CPQ - Quote Rejected - Email Alert to Sales Rep</description>
        <protected>false</protected>
        <recipients>
            <field>Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>cgreeff-berens@teladochealth.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jkneip@teladochealth.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>kmcneil@teladochealth.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>simperato@teladochealth.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>SBQQ__SalesRep__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CPQ_Templates/Quote_Reject_V43</template>
    </alerts>
    <alerts>
        <fullName>Quote_Approval_Required_Email_Alert</fullName>
        <description>Quote - Approval Required - Email Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>jmckenzie@teladochealth.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>joanne.wiens1@teladochealth.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/CPQ_Quote_Approval_Required</template>
    </alerts>
    <fieldUpdates>
        <fullName>CPQU__CPQ_Quote_Status_Approved</fullName>
        <field>SBQQ__Status__c</field>
        <literalValue>Approved</literalValue>
        <name>CPQ - Quote - Status = Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CPQU__CPQ_Quote_Status_Draft</fullName>
        <field>SBQQ__Status__c</field>
        <literalValue>Draft</literalValue>
        <name>CPQ - Quote - Status = Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CPQU__CPQ_Quote_Status_In_Review</fullName>
        <field>SBQQ__Status__c</field>
        <literalValue>In Review</literalValue>
        <name>CPQ - Quote - Status = In Review</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CPQU__CPQ_Quote_Status_Rejected</fullName>
        <field>SBQQ__Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>CPQ - Quote - Status = Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CPQU__Watermark_false</fullName>
        <field>SBQQ__WatermarkShown__c</field>
        <literalValue>0</literalValue>
        <name>CPQU - Watermark = false</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CPQU__Watermark_true</fullName>
        <field>SBQQ__WatermarkShown__c</field>
        <literalValue>1</literalValue>
        <name>CPQU - Watermark = true</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CPQ_Quote_Record_Type_Provider</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Provider</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CPQ - Quote - Record Type = Provider</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CPQ_Quote_Status_Draft</fullName>
        <field>SBQQ__Status__c</field>
        <literalValue>Draft</literalValue>
        <name>CPQ - Quote - Status = Draft</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CPQ_Update_Quote_Status_Approved</fullName>
        <field>SBQQ__Status__c</field>
        <literalValue>Approved</literalValue>
        <name>CPQ - Update Quote Status = Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CPQ_Update_Quote_Status_Rejected</fullName>
        <field>SBQQ__Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>CPQ - Update Quote Status = Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Inject_text</fullName>
        <field>Approvals_for_templates__c</field>
        <formula>Approvals__c</formula>
        <name>Inject text</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Manager_Email_Update</fullName>
        <field>Manager_Email__c</field>
        <formula>Owner:User.Manager.Email</formula>
        <name>Manager Email Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Quote_Set_Record_Type_Master</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Teladoc</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Quote - Set Record Type = Master</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Quote_Set_Record_Type_Needs_Approval</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Needs_Approval</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Quote - Set Record Type = Needs Approval</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Quote_Set_Record_Type_Read_Only</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Read_Only</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Quote - Set Record Type = Read Only</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Quote_Set_Show_Watermark_True</fullName>
        <field>SBQQ__WatermarkShown__c</field>
        <literalValue>1</literalValue>
        <name>Quote - Set Watermark Shown = True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Quote_Set_Sub_Term</fullName>
        <field>SBQQ__SubscriptionTerm__c</field>
        <formula>SBQQ__Opportunity2__r.Proposal_Contract_Term_years__c * 12</formula>
        <name>Quote - Set Sub Term</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Quote_Set_Watermark_Shown_False</fullName>
        <field>SBQQ__WatermarkShown__c</field>
        <literalValue>0</literalValue>
        <name>Quote - Set Watermark Shown = False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Start_Date_to_Revenue_Effective_Date</fullName>
        <field>SBQQ__StartDate__c</field>
        <formula>SBQQ__Opportunity2__r.CloseDate</formula>
        <name>Quote - Set Revenue Effective Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CPQ - Quote - Create - Set Revenue Effective Date and Sub Term</fullName>
        <actions>
            <name>Quote_Set_Sub_Term</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Start_Date_to_Revenue_Effective_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CPQ - Quote - Modified - Set Status %3D Draft</fullName>
        <actions>
            <name>CPQ_Quote_Status_Draft</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>OR(ISCHANGED(SBQQ__NetAmount__c),  ISCHANGED(SBQQ__StartDate__c),  ISCHANGED (SBQQ__EndDate__c),  ISCHANGED (Number_of_Lives__c),  ISCHANGED (Sales_Channels__c),  ISCHANGED (CPQ_Pricebook_Formula__c)  ) = TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CPQ - Quote - Needs Approval</fullName>
        <actions>
            <name>Quote_Set_Record_Type_Needs_Approval</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Quote_Set_Show_Watermark_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>NOT(ISBLANK(Approvals__c)) &amp;&amp;  TEXT(SBQQ__Opportunity2__r.StageName) != &apos;Closed Won&apos; &amp;&amp;  SBQQ__Opportunity2__r.RecordType.Name  &lt;&gt; &apos;Provider - Platform&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CPQ - Quote - No Approval Needed</fullName>
        <actions>
            <name>Quote_Set_Record_Type_Master</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Quote_Set_Watermark_Shown_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>ISBLANK(Approvals__c) &amp;&amp;  TEXT(SBQQ__Opportunity2__r.StageName) != &apos;Closed Won&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CPQ - Quote - Provider Pricebook %3D Provider Record Type</fullName>
        <actions>
            <name>CPQ_Quote_Record_Type_Provider</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>SBQQ__Quote__c.Sales_Channels__c</field>
            <operation>equals</operation>
            <value>Hospital and Health Systems</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CPQU__CPQU - Draft Quote %3D Watermark</fullName>
        <actions>
            <name>CPQU__Watermark_true</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>TEXT(SBQQ__Status__c) == &quot;Draft&quot; &amp;&amp;  $Setup.CPQU__Settings__c.CPQU__Show_Watermark_on_Draft_Quotes__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CPQU__CPQU - Non-Draft Quote %3D No Watermark</fullName>
        <actions>
            <name>CPQU__Watermark_false</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>TEXT(SBQQ__Status__c) &lt;&gt; &quot;Draft&quot; &amp;&amp; $Setup.CPQU__Settings__c.CPQU__Show_Watermark_on_Draft_Quotes__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Inject the approvals text</fullName>
        <actions>
            <name>Inject_text</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>SBQQ__Quote__c.Approvals__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Inject the approvals texts without BR&lt;&gt; code</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
