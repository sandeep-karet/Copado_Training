<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Before Deployment Pull Request</label>
    <protected>false</protected>
    <values>
        <field>copado__Action__c</field>
        <value xsi:type="xsd:string">Deployment</value>
    </values>
    <values>
        <field>copado__Details__c</field>
        <value xsi:type="xsd:string">If it fails, then &lt;strong&gt;block Deployment.&lt;/strong&gt;</value>
    </values>
    <values>
        <field>copado__Environment_Info_Message__c</field>
        <value xsi:type="xsd:string">Copado will create as many quality gates as needed based on your selection. They will share the same configuration, but you will be able to edit each of them individually.</value>
    </values>
    <values>
        <field>copado__Execution_Error_Message__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>copado__Execution_Sequence_Icon__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>copado__Info_Message__c</field>
        <value xsi:type="xsd:string">Use this to ensure that the promotion branch pull request has been approved before launching the deployment. The pull request will be created automatically before the deployment starts.</value>
    </values>
    <values>
        <field>copado__Is_Default__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>copado__Select_Environment_Message__c</field>
        <value xsi:type="xsd:string">Select the destination environments of the promotions (e.g. Integration and testing environments)</value>
    </values>
    <values>
        <field>copado__Sequence__c</field>
        <value xsi:type="xsd:string">Before</value>
    </values>
    <values>
        <field>copado__Test_Tool__c</field>
        <value xsi:type="xsd:string">copadoQuality__PullRequest</value>
    </values>
    <values>
        <field>copado__Tool_Sequence_Status__c</field>
        <value xsi:type="xsd:string">Block</value>
    </values>
</CustomMetadata>
