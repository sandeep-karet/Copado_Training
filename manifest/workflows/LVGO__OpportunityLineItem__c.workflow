<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>LVGO__Copy_Gross_EVA</fullName>
        <field>LVGO__Gross_Program_TCV_Copy__c</field>
        <formula>LVGO__Gross_Program_TCV__c</formula>
        <name>Copy Gross EVA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__Copy_Gross_Program_ARR</fullName>
        <field>LVGO__Gross_Program_ARR_Copy__c</field>
        <formula>LVGO__Gross_Program_ARR__c</formula>
        <name>Copy Gross Program ARR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__Copy_Net_Program_ARR</fullName>
        <field>LVGO__Program_ARR_Copy__c</field>
        <formula>LVGO__Program_ARR__c</formula>
        <name>Copy Net Program ARR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__PO_WholePerson</fullName>
        <field>LVGO__PO_WholePerson__c</field>
        <formula>1</formula>
        <name>PO#_WholePerson</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__Sales_Price_equals_Sales_Comm_Price</fullName>
        <field>LVGO__Sales_Commissionable_Price__c</field>
        <formula>LVGO__UnitPrice__c</formula>
        <name>Sales Price equals Sales Comm Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__Set_Integrate_Program_field_to_TRUE</fullName>
        <description>Sets the Integrate Program field on the Opportunity Program to TRUE when an Opportunity Program is created.</description>
        <field>LVGO__IntegrateProgram__c</field>
        <literalValue>1</literalValue>
        <name>Set Integrate Program field to TRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LVGO__Set_the_Opportunity_Product_Name</fullName>
        <field>LVGO__OpportunityProductName__c</field>
        <formula>LVGO__Product2__r.Name</formula>
        <name>Set the Opportunity Product Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>LVGO__Opportunity Owner Role IsChanged</fullName>
        <actions>
            <name>LVGO__Copy_Gross_EVA</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>LVGO__Copy_Gross_Program_ARR</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>LVGO__Copy_Net_Program_ARR</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>AND(ISCHANGED(LVGO__Opportunity_Owner_Role__c),$Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Populate Sales Commisionable Price on Creation</fullName>
        <actions>
            <name>LVGO__Sales_Price_equals_Sales_Comm_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Sales Commissionable Price will be updated to match Sales Price until the Opportunity is Closed Won.</description>
        <formula>AND($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c,                     NOT(ISPICKVAL(LVGO__Opportunity__r.LVGO__StageName__c,&quot;Closed Won&quot;)),                     NOT(ISPICKVAL(LVGO__Opportunity__r.LVGO__StageName__c,&quot;Closed Lost&quot;)),                     NOT(ISPICKVAL(LVGO__Opportunity__r.LVGO__StageName__c,&quot;Closed No Decision&quot;))                 )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Sales Price updates Sales Comm Price until closed</fullName>
        <actions>
            <name>LVGO__Sales_Price_equals_Sales_Comm_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Sales Commissionable Price will be updated to match Sales Price until the Opportunity is Closed Won.</description>
        <formula>AND($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c,                     NOT(ISPICKVAL(LVGO__Opportunity__r.LVGO__StageName__c,&quot;Closed Won&quot;)),                     NOT(ISPICKVAL(LVGO__Opportunity__r.LVGO__StageName__c,&quot;Closed Lost&quot;)),                     NOT(ISPICKVAL(LVGO__Opportunity__r.LVGO__StageName__c,&quot;Closed No Decision&quot;))                 )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Set Integrate Program Field on Opportunity Product</fullName>
        <actions>
            <name>LVGO__Set_Integrate_Program_field_to_TRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Sets the Integrate Program field on the Opportunity Program to TRUE.</description>
        <formula>AND($Setup.LVGO__LVGO_Automation_Switch__c.LVGO__Workflows__c,LVGO__IntegrateProgram__c = FALSE)</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>LVGO__Set the Product Name</fullName>
        <actions>
            <name>LVGO__Set_the_Opportunity_Product_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>LVGO__OpportunityLineItem__c.LVGO__ProductCode__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Sets the product name on the Opportunity Product</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
