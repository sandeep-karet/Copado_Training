<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>CommitMetadataActionPrecedence</label>
    <protected>false</protected>
    <values>
        <field>copado__Extension__c</field>
        <value xsi:type="xsd:string">cmcSf__Salesforce_DX</value>
    </values>
    <values>
        <field>copado__Key__c</field>
        <value xsi:type="xsd:string">ActionPrecedenceConfig</value>
    </values>
    <values>
        <field>copado__Value__c</field>
        <value xsi:type="xsd:string">[{&quot;o&quot;:&quot;Delete&quot;,&quot;n&quot;:[&quot;RetrieveOnly&quot;]},{&quot;o&quot;:&quot;Add&quot;,&quot;n&quot;:[&quot;RetrieveOnly&quot;,&quot;SelectiveCommit&quot;]},{&quot;o&quot;:&quot;Full&quot;,&quot;n&quot;:[&quot;RetrieveOnly&quot;,&quot;SelectiveCommit&quot;,&quot;Add&quot;]},{&quot;o&quot;:&quot;SelectiveCommit&quot;,&quot;n&quot;:[&quot;RetrieveOnly&quot;]}]</value>
    </values>
</CustomMetadata>
