<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Active_Status</fullName>
        <description>Set Status to Active</description>
        <field>Status</field>
        <literalValue>Activated</literalValue>
        <name>Active Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CPQU__CPQ_Contract_Status_Activated</fullName>
        <field>Status</field>
        <literalValue>Activated</literalValue>
        <name>CPQU - Contract - Status = Activated</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CPQU__Renewal_Forecast_True</fullName>
        <field>SBQQ__RenewalForecast__c</field>
        <literalValue>1</literalValue>
        <name>CPQU - Renewal Forecast True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CPQU__Renewal_Quoted_True</fullName>
        <field>SBQQ__RenewalQuoted__c</field>
        <literalValue>1</literalValue>
        <name>CPQU - Renewal Quoted True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CPQ_Renewal_Forecast_True</fullName>
        <field>SBQQ__RenewalForecast__c</field>
        <literalValue>1</literalValue>
        <name>CPQ - Renewal Forecast = True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Preserve_Bundle_Structure_True</fullName>
        <field>SBQQ__PreserveBundleStructureUponRenewals__c</field>
        <literalValue>1</literalValue>
        <name>Set Preserve Bundle Structure = True</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Activate on new</fullName>
        <actions>
            <name>Active_Status</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Activates the Contract when created</description>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CPQ - Contract - Activate - Create Renewal Opp</fullName>
        <actions>
            <name>CPQ_Renewal_Forecast_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contract.Status</field>
            <operation>equals</operation>
            <value>Activated</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CPQ - Contract - Create - Set Preserve Bundle Structure %3D True</fullName>
        <actions>
            <name>Set_Preserve_Bundle_Structure_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>CPQU__CPQU - Activated Contract %3D Renewal Quoted%2FForcast</fullName>
        <actions>
            <name>CPQU__Renewal_Forecast_True</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>CPQU__Renewal_Quoted_True</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Deprecated - 2018-10-26
Replaced by timed Process Builders - CPQU - Contract (On Create) - Auto Renewals and CPQU - Contract (On Update) - Auto Renewals</description>
        <formula>TEXT(Status) == &quot;Activated&quot; &amp;&amp;  $Setup.CPQU__Settings__c.CPQU__Auto_Generate_Renewal_Opportunity_Quote__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CPQU__CPQU - Contract - New Contract %3D Activated</fullName>
        <active>false</active>
        <description>Deprecated.
Replaced by timed Process Builders - CPQU - Contract (On Create) - Auto Renewals</description>
        <formula>False</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>On Renewal Date%2FContract End Date - Set Renewal Forecast %3D True</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Contract.EndDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>CPQ_Renewal_Forecast_True</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Contract.EndDate</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
