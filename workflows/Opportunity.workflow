<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Opportunity_Unlock_Email_Alert</fullName>
        <description>Opportunity Unlock Email Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>Early_Implementation_Users</recipient>
            <type>group</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>L2O_Opportunity_Templates/Opportunity_Unlock_Email_Template</template>
    </alerts>
</Workflow>
