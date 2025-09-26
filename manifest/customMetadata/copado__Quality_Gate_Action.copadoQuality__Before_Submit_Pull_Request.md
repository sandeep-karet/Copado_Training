<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Before Submit Pull Request</label>
    <protected>false</protected>
    <values>
        <field>copado__Action__c</field>
        <value xsi:type="xsd:string">Submit</value>
    </values>
    <values>
        <field>copado__Details__c</field>
        <value xsi:type="xsd:string">If it fails, then &lt;strong&gt;block users from:&lt;/strong&gt;&lt;br&gt;• Using the &lt;strong&gt;Submit&lt;/strong&gt; button.&lt;br&gt;• Using the user story’s &lt;strong&gt;&quot;Ready to Promote&quot;&lt;/strong&gt; checkbox.</value>
    </values>
    <values>
        <field>copado__Environment_Info_Message__c</field>
        <value xsi:type="xsd:string">Copado will create as many quality gates as needed based on your selection. They will share the same configuration, but you will be able to edit each of them individually.</value>
    </values>
    <values>
        <field>copado__Execution_Error_Message__c</field>
        <value xsi:type="xsd:string">This user story cannot be promoted yet because there is a pull request approval required before submit.</value>
    </values>
    <values>
        <field>copado__Execution_Sequence_Icon__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>copado__Info_Message__c</field>
        <value xsi:type="xsd:string">Prevents user stories from being submitted unless a feature branch pull request has been approved. The pull request must be created manually after all commits are completed.</value>
    </values>
    <values>
        <field>copado__Is_Default__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>copado__Select_Environment_Message__c</field>
        <value xsi:type="xsd:string">Select the environments where changes will be implemented (e.g. Development and Hotfix environments)</value>
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
