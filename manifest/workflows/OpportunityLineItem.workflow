<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Consult_Included</fullName>
        <field>GenMed_Consult_Included_Flag__c</field>
        <literalValue>1</literalValue>
        <name>Consult Included</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>HY_Product_Combinations</fullName>
        <description>Update flag to match product. Used for HY Consult Included product selling restrictions.</description>
        <field>OK_to_Sell_with_HY_ConsultIncluded__c</field>
        <literalValue>1</literalValue>
        <name>HY Product Combinations</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>HY_Product_Included</fullName>
        <description>Update the HY Product Included flag on the Opportunity Product Line Item to TRUE if the HY product is selected.  Used for restricting product combinations.</description>
        <field>HY_Product_Included_Flag__c</field>
        <literalValue>1</literalValue>
        <name>HY Product Included</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Product_Combinations</fullName>
        <field>OK_to_sell_with_GenMed_Consults_Included__c</field>
        <literalValue>1</literalValue>
        <name>Product Combinations</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>GenMed Consult Included</fullName>
        <actions>
            <name>Consult_Included</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>Product2.GenMed_Consult_Included_Flag__c</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>HY Consult Included</fullName>
        <actions>
            <name>HY_Product_Included</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Runs when the HY Consults Included product is added to the Opportunity Product Line Item. Update flag to match product. Used for product selling restrictions.</description>
        <formula>Product2.HY_Product_Included_Flag__c</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>HYProduct Combinations</fullName>
        <actions>
            <name>HY_Product_Combinations</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Update flag to match product. Used for HY Consult Included product selling restrictions.</description>
        <formula>Product2.OK_to_Sell_with_HY_ConsultIncluded__c</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Product Combinations</fullName>
        <actions>
            <name>Product_Combinations</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>Product2.OK_to_sell_with_GenMed_Consults_Included__c</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
