<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>L2O_Email_Alert_When_Quote_is_Denied</fullName>
        <description>L2O_Email_Alert_When_Quote_is_Denied</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/L2O_Rejection_Template</template>
    </alerts>
    <alerts>
        <fullName>L2O_Email_Alert_when_quote_is_approved</fullName>
        <description>L2O_Email Alert when quote is approved</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/L2O_Approval_Template</template>
    </alerts>
</Workflow>
