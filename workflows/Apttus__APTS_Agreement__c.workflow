<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>APTS_Activation_Notification</fullName>
        <description>APTS Activation Notification Email to Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Apttus__Requestor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Apttus__ApttusEmailTemplates/ApttusContractActivationNotice</template>
    </alerts>
    <alerts>
        <fullName>APTS_Approval_Rejected_Notification</fullName>
        <description>APTS - Approval - Rejected Notification</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <type>creator</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Apttus__ApttusEmailTemplates/Apttus_Approval_Rejected_Notification</template>
    </alerts>
    <alerts>
        <fullName>APTS_Cancelleation_Notice_Email_to_Owner</fullName>
        <description>APTS Cancelleation Notice Email to Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>APTS_ContractManager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Apttus__ApttusEmailTemplates/ApttusContractCancellationNotice</template>
    </alerts>
    <alerts>
        <fullName>APTS_Send_Agreement_Approved_Notice</fullName>
        <description>APTS Send Agreement Approved Notice</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Apttus__ApttusEmailTemplates/Apttus_Approval_Approved_Notification</template>
    </alerts>
    <alerts>
        <fullName>APTS_Termination_Notice_Email_to_Owner</fullName>
        <description>APTS Termination Notice Email to Owner</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Apttus__ApttusEmailTemplates/ApttusContractTerminationNotice</template>
    </alerts>
    <alerts>
        <fullName>Contract_request_submission_notification</fullName>
        <description>Contract request submission notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Apttus__ApttusEmailTemplates/Apttus__Agreement_Review_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notification_that_an_agreement_was_fully_signed</fullName>
        <ccEmails>infosys.sfdc.teamDC.Team@teladochealth.com</ccEmails>
        <description>Notification that an agreement was fully signed</description>
        <protected>false</protected>
        <recipients>
            <field>APTS_ContractManager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Apttus__ApttusEmailTemplates/APTS_Fully_Executed_Notice_to_Contracts_Team</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_Contracts_Team_that_an_agreement_is_ready_for_Internal_signature</fullName>
        <description>Notification to Contracts Team that an agreement is ready for Internal signature</description>
        <protected>false</protected>
        <recipients>
            <field>APTS_ContractManager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Apttus__ApttusEmailTemplates/APTS_Agreement_Ready_for_Internal_Signature_Notice_to_Contracts_Team</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_Requestor_that_an_agreement_is_ready_for_Other_Party_signature</fullName>
        <description>Notification to Requestor that an agreement is ready for Other Party signature</description>
        <protected>false</protected>
        <recipients>
            <field>Apttus__Requestor__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Apttus__ApttusEmailTemplates/APTS_Agreement_Ready_for_Other_Party_Signature_Notice_to_Requestor</template>
    </alerts>
    <fieldUpdates>
        <fullName>Apttus__SearchFieldUpdate</fullName>
        <description>Update the account search field with Account Name</description>
        <field>Apttus__Account_Search_Field__c</field>
        <formula>Apttus__Account__r.Name  &amp;  Apttus__FF_Agreement_Number__c</formula>
        <name>Search Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Apttus__SetAgreementNumber</fullName>
        <description>Set agreement number from the auto generated contract number</description>
        <field>Apttus__Agreement_Number__c</field>
        <formula>Apttus__Contract_Number__c</formula>
        <name>Set Agreement Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Apttus__SetClonetriggertofalse</fullName>
        <description>Set Clone trigger to false</description>
        <field>Apttus__Workflow_Trigger_Created_From_Clone__c</field>
        <literalValue>0</literalValue>
        <name>Set Clone trigger to false</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Apttus__Reset Clone Trigger</fullName>
        <actions>
            <name>Apttus__SetClonetriggertofalse</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Apttus__APTS_Agreement__c.Apttus__Workflow_Trigger_Created_From_Clone__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Reset Clone Trigger</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Apttus__Search Field Update</fullName>
        <actions>
            <name>Apttus__SearchFieldUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populate an external Id search field with account name, so that side bar support can work with Account name search</description>
        <formula>or(not (isnull(Apttus__Account__r.Name)) ,not (isnull(Apttus__FF_Agreement_Number__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Apttus__Set Agreement Number</fullName>
        <actions>
            <name>Apttus__SetAgreementNumber</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Apttus__APTS_Agreement__c.Apttus__Agreement_Number__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Set agreement number for new agreements. The agreement number is auto generated.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
