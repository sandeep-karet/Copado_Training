<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Inject_OneTime_NetTotal</fullName>
        <field>OneTime_NetTotal__c</field>
        <name>Inject OneTime NetTotal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Inject_Reoccurring_NetTotal</fullName>
        <description>Inject Reoccurring Net Total</description>
        <field>Reoccurring_NetTotal__c</field>
        <formula>SBQQ__NetTotal__c</formula>
        <name>Inject Reoccurring NetTotal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Inject_Subscription_Type</fullName>
        <field>Subscription_Type__c</field>
        <formula>TEXT(SBQQ__Product__r.SBQQ__SubscriptionType__c)</formula>
        <name>Inject Subscription Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Inject_product_family</fullName>
        <field>Product_Family_No_formula__c</field>
        <formula>TEXT(SBQQ__Product__r.Family)</formula>
        <name>Inject product family</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Insert_CPQ_Pricebook_no_formula</fullName>
        <description>update the CPQ PriceBook No formula field.. This field gets used in Monthly Price field on Quoteline</description>
        <field>CPQ_Pricebook_No_formula__c</field>
        <formula>SBQQ__Quote__r.CPQ_Pricebook_Formula__c</formula>
        <name>Insert CPQ Pricebook no formula</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Product_Code</fullName>
        <field>Product_Code_No_formula__c</field>
        <formula>SBQQ__Product__r.ProductCode</formula>
        <name>Product Code</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>inject_number</fullName>
        <field>SBQQ__Number__c</field>
        <formula>SBQQ__Quote__r.SBQQ__LineItemCount__c +1</formula>
        <name>inject number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Inject OneTime NetTotal</fullName>
        <actions>
            <name>Inject_OneTime_NetTotal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>SBQQ__QuoteLine__c.SBQQ__Number__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>SBQQ__QuoteLine__c.Subscription_Type__c</field>
            <operation>equals</operation>
            <value>One-time</value>
        </criteriaItems>
        <description>Inject OneTime netTotal</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Inject Reoccurring NetTotal</fullName>
        <actions>
            <name>Inject_Reoccurring_NetTotal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>SBQQ__QuoteLine__c.SBQQ__Number__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>SBQQ__QuoteLine__c.Subscription_Type__c</field>
            <operation>equals</operation>
            <value>Renewable</value>
        </criteriaItems>
        <description>Inject Reoccurring NetTotal</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Inject number for amendments</fullName>
        <actions>
            <name>inject_number</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>SBQQ__Quote__c.SBQQ__Type__c</field>
            <operation>equals</operation>
            <value>Amendment</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Inject product code and Subscription Type</fullName>
        <actions>
            <name>Inject_Subscription_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Inject_product_family</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Insert_CPQ_Pricebook_no_formula</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Product_Code</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>SBQQ__QuoteLine__c.SBQQ__Number__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
