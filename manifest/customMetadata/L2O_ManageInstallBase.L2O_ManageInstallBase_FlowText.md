<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>L2O_Manage Install Base Flow Text</label>
    <protected>false</protected>
    <values>
        <field>L2O_AllContractsHeader__c</field>
        <value xsi:type="xsd:string">&lt;p&gt;&lt;b style=&quot;font-size: 15px;&quot;&gt;Please select the Contract that would like to Amend&lt;/b&gt;&lt;/p&gt;  &lt;br&gt;</value>
    </values>
    <values>
        <field>L2O_AmendAssetsOnly__c</field>
        <value xsi:type="xsd:string">&lt;b style=&quot;color: rgb(92, 45, 145); font-size: 15px;&quot;&gt;Hardware or Non-Recurring Services&lt;/b&gt;&lt;br&gt;&lt;br&gt;
&lt;p style=&quot;margin-left:5%;&quot;&gt;&lt;i&gt;Choose this option if you would like to make changes to hardware or non-recurring services purchased by this Account, this will update the Assets related to this Account. 
 &lt;br&gt; &lt;br&gt;
An Existing Business Opportunity will be created automatically. &lt;/i&gt;&lt;/p&gt;</value>
    </values>
    <values>
        <field>L2O_AmendBothOption__c</field>
        <value xsi:type="xsd:string">&lt;b style=&quot;color: rgb(92, 45, 145); font-size: 15px;&quot;&gt;Recurring Services&lt;/b&gt;&lt;br&gt;&lt;br&gt;
&lt;p style=&quot;margin-left:5%;&quot;&gt;&lt;i&gt;Choose this option if you would like to make changes to Recurring Services (including Device Leases) which will update the Subscriptions related to this Account. &lt;br&gt; &lt;br&gt;
An Existing Business Opportunity will be created automatically.
&lt;/i&gt;&lt;/p&gt;</value>
    </values>
    <values>
        <field>L2O_AmendOptionHeader__c</field>
        <value xsi:type="xsd:string">&lt;p&gt;&lt;b style=&quot;font-size: 15px;&quot;&gt;What type of products are you making changes to:&lt;/b&gt;&lt;/p&gt;  &lt;br&gt;</value>
    </values>
    <values>
        <field>L2O_AmendSubTypeHeader__c</field>
        <value xsi:type="xsd:string">&lt;p&gt;&lt;b style=&quot;font-size: 15px;&quot;&gt;Please select a Subtype for the Opportunity:&lt;/b&gt;&lt;/p&gt;  &lt;br&gt;</value>
    </values>
    <values>
        <field>L2O_ChangeOrderOption__c</field>
        <value xsi:type="xsd:string">&lt;b style=&quot;color: rgb(92, 45, 145); font-size: 15px;&quot;&gt;Change Order&lt;/b&gt;&lt;br&gt;

&lt;p style=&quot;margin-left:5%;&quot;&gt;&lt;i&gt;Allows any of the following Contract Actions (approvals may be required):
&lt;br&gt;&lt;br&gt;
&lt;ul style=&quot;margin-left:9%;&quot;&gt;
&lt;li&gt;&lt;b&gt;Upsell:&lt;/b&gt; Add-on new products from the same Product Portfolio as previously purchased products or services.&lt;/li&gt;
&lt;li&gt;&lt;b&gt;Cross-Sell:&lt;/b&gt; Add-on new products from a different Product Portfolio as previously purchased products or services.&lt;/li&gt;
&lt;li&gt;&lt;b&gt;Price Change:&lt;/b&gt; Change the price of a purchased product or recurring service. Requires reducing the current quantity of the product or service to zero (0) and re-adding same product or service with a new price.&lt;/li&gt;
&lt;li&gt;&lt;b&gt;Add-On Membership:&lt;/b&gt; Increase membership within an existing service. Requires adding the same product in the configurator with the net new delta membership.&lt;/li&gt;
&lt;li&gt;&lt;b&gt;Delayed Launch:&lt;/b&gt; Modify the start date of one or multiple products. Requires reducing the current quantity of the product or service to zero (0) and adding the same product with an updated start date.&lt;/li&gt;
&lt;li&gt;&lt;b&gt;Cancel:&lt;/b&gt; Remove all of the purchased products or services. Requires reducing the current quantity of the product or service to zero (0) (i.e. Did Not Launch).&lt;/li&gt;
&lt;li&gt;&lt;b&gt;Product Swap:&lt;/b&gt; Exchange a purchased product or recurring service for a different product or service (i.e. Upgrade, Downgrade). Requires reducing the current quantity of the product or service to zero (0) and adding another product product or service with an equal quantity.&lt;/li&gt;
&lt;li&gt;&lt;b&gt;Reschedule (HHS): &lt;/b&gt; Change the Delivery Date and/or Shipping Address for purchased products.&lt;/li&gt;
&lt;li&gt;&lt;b&gt;Quantity Increase (HHS):&lt;/b&gt; Increase the quantity of a purchased product or service.&lt;/li&gt;
&lt;li&gt;&lt;b&gt;Quantity Decrease (HHS):&lt;/b&gt; Decrease the quantity of a purchased product or service.&lt;/li&gt;
 
&lt;/ul&gt;

&lt;/i&gt;&lt;/p&gt;</value>
    </values>
    <values>
        <field>L2O_ContractListNote2__c</field>
        <value xsi:type="xsd:string">&lt;b&gt;Update Contact on Account &gt; Select a Contact for the Opportunity &lt;/b&gt;&lt;br&gt;&lt;br&gt;</value>
    </values>
    <values>
        <field>L2O_ContractListNote__c</field>
        <value xsi:type="xsd:string">&lt;br&gt;&lt;br&gt;&lt;p style=&quot;font-size: 15px;&quot;&gt;&lt;i&gt;NOTE: If you select a Contract from the above list, the Quote will contain all of it&apos;s Subscriptions (recurring services) and any hardware or non-recurring services that those Subscriptions are bundled with.&lt;br&gt;

If you only want to make changes to hardware and non-recurring services, please go back and select the &lt;b&gt;&quot;Hardware or Non-Recurring Services&quot;&lt;/b&gt; option as the type of product you are making change to.&lt;/i&gt; &lt;br&gt;&lt;/p&gt; &lt;br&gt;</value>
    </values>
    <values>
        <field>L2O_ContractPathChangeOption__c</field>
        <value xsi:type="xsd:string">&lt;b style=&quot;color: rgb(92, 45, 145); font-size: 15px;&quot;&gt; Contract Path Change&lt;/b&gt;&lt;br&gt;

&lt;p style=&quot;margin-left:5%;&quot;&gt;&lt;i&gt;Use this option for all amendment actions relating to a Contract Path Change (i.e. Price Increase, Upgrade, Upsell, Add-On Membership).
&lt;/i&gt;&lt;/p&gt;</value>
    </values>
    <values>
        <field>L2O_CpqAccountAmendURL__c</field>
        <value xsi:type="xsd:string">https://teladochealthglobalcrm--sbqq.vf.force.com/apex/AssetSelectorAmend?id=</value>
    </values>
    <values>
        <field>L2O_CpqContractAmendURL__c</field>
        <value xsi:type="xsd:string">https://teladochealthglobalcrm--sbqq.vf.force.com/apex/AmendContract?id=</value>
    </values>
    <values>
        <field>L2O_ExpansionOption__c</field>
        <value xsi:type="xsd:string">&lt;b style=&quot;color: rgb(92, 45, 145); font-size: 15px;&quot;&gt;Expansion&lt;/b&gt;&lt;br&gt;

&lt;p style=&quot;margin-left:7%;&quot;&gt;&lt;i&gt;Allows any of the following Contract Actions:
&lt;br&gt;&lt;br&gt;
&lt;ul style=&quot;margin-left:14%;&quot;&gt;
&lt;li&gt;&lt;b&gt;Upsell:&lt;/b&gt; Add-on new products from the same Product Portfolio as previously purchased products or services.&lt;/li&gt;
&lt;li&gt;&lt;b&gt;Cross-Sell:&lt;/b&gt; Add-on new products from a different Product Portfolio as previously purchased products or services.&lt;/li&gt;
&lt;li&gt;&lt;b&gt;Quantity Increase (HHS):&lt;/b&gt; Increase the quantity of a purchased product or service.&lt;/li&gt;
&lt;/ul&gt;

&lt;/i&gt;&lt;/p&gt;</value>
    </values>
    <values>
        <field>L2O_RecontractingOption__c</field>
        <value xsi:type="xsd:string">&lt;b style=&quot;color: rgb(92, 45, 145); font-size: 15px;&quot;&gt;Recontracting&lt;/b&gt;&lt;br&gt;

&lt;p style=&quot;margin-left:5%;&quot;&gt;&lt;i&gt;Allows the full cancelation of an existing Contract to be replaced by a new Contract. This option will create a cancellation opportunity for the original Contract and new opportunity for the replacement Contract.
&lt;/i&gt;&lt;/p&gt;</value>
    </values>
</CustomMetadata>
