<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>LVGO__A_CIM_has_been_assigned</fullName>
        <description>A CIM has been assigned</description>
        <protected>false</protected>
        <recipients>
            <field>LVGO__CIM__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>LVGO__Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__Automated_SFDC_Notification_CSM_Assigned</template>
    </alerts>
    <alerts>
        <fullName>LVGO__An_opportunity_has_been_closed</fullName>
        <ccEmails>contractops@livongo.com</ccEmails>
        <description>An opportunity has been closed New/Cross/Expansion</description>
        <protected>false</protected>
        <recipients>
            <recipient>prince.kumar@teladochealth.com.lcrm</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>LVGO__CIM__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>LVGO__CSM__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>LVGO__Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__Automated_SFDC_Notification_Client_Onboarding</template>
    </alerts>
    <alerts>
        <fullName>LVGO__An_opportunity_has_been_closed_Renewal</fullName>
        <ccEmails>contractops@livongo.com</ccEmails>
        <description>An opportunity has been closed - Renewal</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <recipient>prince.kumar@teladochealth.com.lcrm</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__Automated_SFDC_Notification_Client_Renewal</template>
    </alerts>
    <alerts>
        <fullName>LVGO__Notification_for_CIM_Needed_on_this_Opportunity</fullName>
        <description>Notification for CIM Needed on this Opportunity</description>
        <protected>false</protected>
        <recipients>
            <recipient>brittany.pasay@teladochealth.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>lmahlebashian@teladochealth.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__RequestCIM_Task_Notification</template>
    </alerts>
    <alerts>
        <fullName>LVGO__Notify_Legal_when_Contract_Path_Change_Opportunity_is_Closed</fullName>
        <ccEmails>contractops@livongo.com</ccEmails>
        <description>Notify Legal when Contract Path Change Opportunity is Closed</description>
        <protected>false</protected>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__Automated_SFDC_Notification_Client_Onboarding</template>
    </alerts>
    <alerts>
        <fullName>LVGO__Notify_Legal_when_contract_linked_to_Renewal_Cross_sell_Expansion_opportunity</fullName>
        <ccEmails>contractops@livongo.com</ccEmails>
        <description>Notify Legal when contract linked to Renewal/Cross-sell/Expansion opportunity</description>
        <protected>false</protected>
        <senderAddress>salesforcesupport-crm@teladochealth.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>LVGO__Automated_Email_Notifications/LVGO__Notify_Legal_when_contract_linked_to_Renewal_Cross_sell_Expansion</template>
    </alerts>
    <alerts>
        <fullName>LVGO__Request_Close_Opportunity_EA</fullName>
        <ccEmails>contractops@livongo.com</ccEmails>
        <description>Request Close Opportunity EA</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>LVGO__All/LVGO__Request_Close_Opportunity</template>
    </alerts>
    <fieldUpdates>
        <fullName>LVGO__Calculated_Forecasted_Amount_Update</fullName>
        <description>Calculate forecasted amount based on NET ARR and Percentage on Forecast Manager call.</description>
        <field>LVGO__Calculated_Forecasted_Amount__c</field>
        <formula>if( ISPICKVAL(LVGO__Forecast_Manager_Call__c, &apos;Forecast - Closed&apos;),LVGO__Net_ARR__c,
IF(ISPICKVAL(LVGO__Forecast_Manager_Call__c, &apos;Forecast - Call&apos;) , LVGO__Net_ARR__c * 0.95 ,
IF(ISPICKVAL(LVGO__Forecast_Manager_Call__c, &apos;Forecast - Upside&apos;) , LVGO__Net_ARR__c * 0.75 ,
IF(AND(ISPICKVAL(LVGO__Forecast_Manager_Call__c, &apos;Not In Forecast&apos;),CONTAINS(LVGO__Opp_Owner_Role__c, &apos;Commercial&apos;)) , LVGO__Net_ARR__c * 0.07,0))))</formula>
        <name>Calculated Forecasted Amount Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__Forecast_Closed</fullName>
        <field>LVGO__Forecast_Manager_Call__c</field>
        <literalValue>Forecast - Closed</literalValue>
        <name>Forecast - Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__Request_CIM_When_Opp_Closed</fullName>
        <field>LVGO__Request_CIM__c</field>
        <literalValue>1</literalValue>
        <name>Request CIM When Opp Closed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>LVGO__Check Request CIM When Opportunity Closes</fullName>
        <actions>
            <name>LVGO__Request_CIM_When_Opp_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>When an Opportunity moves to &quot;Closed&quot;, automatically check the &quot;Request CIM&quot; box.  This will trigger the workflow rules associated with that checkbox.</description>
        <formula>AND(OR(ISPICKVAL(LVGO__StageName__c,&quot;Contracting&quot;),ISPICKVAL(LVGO__StageName__c,&quot;Closed Won&quot;)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Email notification for CIM Assignment</fullName>
        <actions>
            <name>LVGO__A_CIM_has_been_assigned</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(ISCHANGED( LVGO__CIM__c ) ,($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Notify Legal when contract linked to Renewal%2FCross-sell%2FExpansion opportunity</fullName>
        <actions>
            <name>LVGO__Notify_Legal_when_contract_linked_to_Renewal_Cross_sell_Expansion_opportunity</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify Legal when contract is linked to Renewal/Cross-sell/Expansion opportunity</description>
        <formula>AND(LVGO__Contract__c != null,OR(ISPICKVAL(LVGO__Type__c,&quot;New Business&quot;),ISPICKVAL(LVGO__Type__c,&quot;Expansion&quot;),ISPICKVAL(LVGO__Type__c,&quot;Cross-sell (New product)&quot;)),($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Opportunity is won - Contract Path Change</fullName>
        <actions>
            <name>LVGO__Notify_Legal_when_Contract_Path_Change_Opportunity_is_Closed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(ISPICKVAL(LVGO__StageName__c,&quot;Closed Won&quot;),ISPICKVAL(LVGO__Type__c,&quot;Contract Path Change&quot;) ,($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Opportunity is won -- New%2FCross%2FExpansion</fullName>
        <actions>
            <name>LVGO__An_opportunity_has_been_closed</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>LVGO__Forecast_Closed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Opportunity is won -- New/Cross/Expansion/HuntingLicense</description>
        <formula>AND(                      ISPICKVAL(LVGO__StageName__c,&quot;Closed Won&quot;),                     OR(                     ISPICKVAL(LVGO__Type__c,&quot;New Business&quot;),                     ISPICKVAL(LVGO__Type__c,&quot;Expansion&quot;),                     ISPICKVAL(LVGO__Type__c,&quot;Cross-sell (New product)&quot;),                     ISPICKVAL(LVGO__Type__c,&quot;Hunting License&quot;)                     ),                     ($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c)                     )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Opportunity is won -- Renewal</fullName>
        <actions>
            <name>LVGO__An_opportunity_has_been_closed_Renewal</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(ISPICKVAL(LVGO__StageName__c,&quot;Closed Won&quot;),ISPICKVAL(LVGO__Type__c,&quot;Renewal&quot;),$Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Update Calculated Forecasted Amount on Oppty</fullName>
        <actions>
            <name>LVGO__Calculated_Forecasted_Amount_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update the calculated forecasted amount on opportunity based on calculation on NetARR and Forecast Manager Call percentage.</description>
        <formula>AND(OR(ISCHANGED(LVGO__Forecast_Manager_Call__c),ISNEW(),ISCHANGED(LVGO__Net_ARR__c)),($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
