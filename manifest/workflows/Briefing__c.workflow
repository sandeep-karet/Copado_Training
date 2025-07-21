<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_confirmation_to_requestoer_for_briefing</fullName>
        <description>Email confirmation to requestoer for briefing</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Experience_Center/Email_confirmation_to_requester</template>
    </alerts>
    <alerts>
        <fullName>Email_to_event_meeting_team_for_briefing</fullName>
        <ccEmails>ExperienceCenter@teladochealth.com</ccEmails>
        <description>Email to event meeting team for briefing</description>
        <protected>false</protected>
        <senderType>CurrentUser</senderType>
        <template>Experience_Center/Email_to_Event_Team</template>
    </alerts>
</Workflow>
