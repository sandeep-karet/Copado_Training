<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Change_Status_to_Expired</fullName>
        <field>Product_Family_Status__c</field>
        <literalValue>Expired</literalValue>
        <name>Change Status to Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Extend_Product_End_Date</fullName>
        <field>Product_Family_End_Date__c</field>
        <formula>ADDMONTHS( Product_Family_End_Date__c ,   (Product_Renewal_Term_Months__c ))</formula>
        <name>Extend Product End Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status</fullName>
        <field>Product_Family_Status__c</field>
        <literalValue>Expired</literalValue>
        <name>Update Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Extend Product End Date</fullName>
        <active>false</active>
        <formula>ISPICKVAL(Product_Auto_Renew__c, &apos;Yes&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Extend_Product_End_Date</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Product_Family__c.Extend_Date__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Product Family Status Update</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Product_Family__c.Product_Auto_Renew__c</field>
            <operation>equals</operation>
            <value>No</value>
        </criteriaItems>
        <criteriaItems>
            <field>Product_Family__c.Product_Family_Perpetual__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Status</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Product_Family__c.Product_Family_End_Date__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
