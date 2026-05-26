{
    "recordTypeMap": {},
    "RecordSetBundles": [
        {
            "Records": [
                {
                    "attributes": {
                        "type": "copado__JobTemplate__c",
                        "url": "/services/data/v65.0/sobjects/copado__JobTemplate__c/a0xJ6000000TP1OIAW"
                    },
                    "copado__ApiName__c": "Classic_to_Source_Format_Migration_2",
                    "copado__Type__c": "Standard",
                    "copado__Version__c": 2,
                    "Id": "a0xJ6000000TP1OIAW",
                    "LastReferencedDate": "2025-06-30T06:06:48.000+0000",
                    "LastViewedDate": "2025-06-30T06:06:48.000+0000",
                    "Name": "Classic to Source Format Migration"
                },
                {
                    "attributes": {
                        "type": "copado__JobTemplate__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobTemplate__c/a0xJ6000000TOrqIAG"
                    },
                    "copado__ApiName__c": "MFP_to_SFP_Snapshot_migration_1",
                    "copado__Backend_Bypass__c": false,
                    "copado__Type__c": "Standard",
                    "copado__Version__c": 1,
                    "copado__VolumeOptions__c": "[\r\n{\r\n\"name\": \"volumeSize\",\r\n\"value\": \"10\"\r\n},\r\n{\r\n\"name\": \"volumeTTL\",\r\n\"value\": \"100\"\r\n},\r\n{\r\n\"name\": \"preserveVolumeAfterExecution\",\r\n\"value\": \"true\"\r\n},\r\n{\r\n\"name\": \"volumeEnabled\",\r\n\"value\": \"true\"\r\n}\r\n]",
                    "Id": "a0xJ6000000TOrqIAG",
                    "LastReferencedDate": "2025-06-30T18:07:17.000+0000",
                    "LastViewedDate": "2025-06-30T18:07:17.000+0000",
                    "Name": "MFP to SFP Snapshot migration"
                },
                {
                    "attributes": {
                        "type": "copado__JobTemplate__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobTemplate__c/a0xJ6000000TPTqIAO"
                    },
                    "copado__ApiName__c": "SFP_Migration_WIP_1",
                    "copado__Type__c": "Standard",
                    "copado__Version__c": 1,
                    "Id": "a0xJ6000000TPTqIAO",
                    "LastReferencedDate": "2025-06-24T15:01:57.000+0000",
                    "LastViewedDate": "2025-06-24T15:01:57.000+0000",
                    "Name": "SFP Migration WIP"
                }
            ],
            "ObjectType": "copado__JobTemplate__c"
        },
        {
            "Records": [
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0wJ6000000bt2XIAQ"
                    },
                    "copado__ApiName__c": "Classic_to_Source_Format_Migration_2_Deactivate_Classic_Pipeline_and_Block_commits__1",
                    "copado__ConfigJson__c": "{\"flowName\":\"cmcSf.Deactivate_Pipeline_and_Block_Commits\",\"parameters\":[{\"name\":\"pipelineId\",\"value\":\"{$Pipeline.Id}\"}]}",
                    "copado__CustomType__c": "Salesforce Flow",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TP1OIAW",
                    "copado__Order__c": 1,
                    "copado__Type__c": "Flow",
                    "Id": "a0wJ6000000bt2XIAQ",
                    "Name": "Deactivate Classic Pipeline and Block commits."
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0wJ6000000bt2bIAA"
                    },
                    "copado__ApiName__c": "Classic_to_Source_Format_Migration_2_Git_Initialization_2",
                    "copado__ConfigJson__c": "{\"flowName\":\"cmcSf.Migration_Source_Format_Git_Initialisation\",\"parameters\":[{\"name\":\"gitRepositoryId\",\"value\":\"{$Context.JobExecution__r.DataJson.gitRepositoryId}\"},{\"name\":\"branch\",\"value\":\"{$Pipeline.copado__Main_Branch__c}\"},{\"name\":\"gitRepositoryURI\",\"value\":\"{$Context.JobExecution__r.DataJson.uri}\"}]}",
                    "copado__CustomType__c": "Salesforce Flow",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TP1OIAW",
                    "copado__Order__c": 2,
                    "copado__Type__c": "Flow",
                    "Id": "a0wJ6000000bt2bIAA",
                    "Name": "Git Initialization"
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                      "url": "/services/data/v65.0/sobjects/copado__JobStep__c/a0wS8000002CGe9IAG"
                    },
                    "copado__ApiName__c": "Classic_to_Source_Format_Migration_2_Update_Gitignore_and_Forceignore_3",
                    "copado__Backend_Bypass__c": false,
                    "copado__ConfigJson__c": "{\"instructions\":\"Update gitignore and forceignore\",\"parameters\":[{\"name\":\"assigneeId\",\"value\":\"005RR000002rJGHYA2\"},{\"name\":\"assigneeName\",\"value\":\"Sakshi Vijay\"},{\"name\":\"performAtSource\",\"value\":\"false\"},{\"name\":\"performAtDestination\",\"value\":\"false\"},{\"name\":\"skippedForBackPromotion\",\"value\":\"false\"},{\"name\":\"skippedStages\",\"value\":\"[]\"},{\"name\":\"skippedEnvironments\",\"value\":\"[]\"}]}",
                    "copado__CustomType__c": "Manual Task",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TP1OIAW",
                    "copado__Order__c": 3,
                    "copado__Type__c": "Manual",
                    "Id": "a0wS8000002CGe9IAG",
                    "Name": "Update Gitignore and Forceignore"
                    },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0wJ6000000bt2cIAA"
                    },
                    "copado__ApiName__c": "Classic_to_Source_Format_Migration_2_Update_Exclude_From_AutoResolve_3",
                    "copado__Backend_Bypass__c": false,
                    "copado__ConfigJson__c": "{\"functionName\":\"Update_Exclude_From_AutoResolve\",\"parameters\":[{\"name\":\"autoResolveMetadatas\",\"value\":\"{$Pipeline.copado__Exclude_From_Auto_Resolve__c}\"},{\"name\":\"branch\",\"value\":\"{$Pipeline.copado__Main_Branch__c}\"},{\"name\":\"git_json\",\"value\":\"{$Context.apex.cmcSf.GetGitJson}\"},{\"name\":\"gitEmail\",\"value\":\"{$User.Email}\"},{\"name\":\"gitName\",\"value\":\"{$User.Name}\"}]}",
                    "copado__CustomType__c": "Function",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TP1OIAW",
                    "copado__Order__c": 4,
                    "copado__Type__c": "Function",
                    "Id": "a0wJ6000000bt2cIAA",
                    "Name": "Update Exclude From AutoResolve"
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0wJ6000000bt2dIAA"
                    },
                    "copado__ApiName__c": "Classic_to_Source_Format_Migration_2_Clone_Classic_and_create_DX_Pipeline_4",
                    "copado__Backend_Bypass__c": false,
                    "copado__ConfigJson__c": "{\"flowName\":\"cmcSf.Clone_Classic_Pipeline_To_Source_Format\",\"parameters\":[{\"name\":\"pipelineId\",\"value\":\"{$Pipeline.Id}\"},{\"name\":\"repositoryId\",\"value\":\"{$Context.JobExecution__r.DataJson.gitRepositoryId}\"},{\"name\":\"jobExecutionId\",\"value\":\"{$Context.JobExecution__r.Id}\"}]}",
                    "copado__CustomType__c": "Salesforce Flow",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TP1OIAW",
                    "copado__Order__c": 5,
                    "copado__Type__c": "Flow",
                    "Id": "a0wJ6000000bt2dIAA",
                    "Name": "Clone Classic and create DX Pipeline"
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v66.0/sobjects/copado__JobStep__c/a0tJ7000000mZwMIAU"
                    },
                    "copado__ApiName__c": "Classic_to_Source_Format_Migration_2_Enable_Vlocity_10",
                    "copado__Backend_Bypass__c": false,
                    "copado__ConfigJson__c": "{\"flowName\":\"cmcSf.Enable_Vlocity\",\"parameters\":[{\"name\":\"pipelineId\",\"value\":\"{$Context.JobExecution__r.DataJson.sfpPipelineId}\"},{\"name\":\"skippedForBackPromotion\",\"value\":\"false\"},{\"name\":\"skippedStages\",\"value\":\"[]\"},{\"name\":\"skippedEnvironments\",\"value\":\"[]\"}]}",
                    "copado__CustomType__c": "Salesforce Flow",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TP1OIAW",
                    "copado__Order__c": 6,
                    "copado__SkipCondition__c": "{$Context.JobExecution__r.DataJson.isVlocityEnabled.matches(false)}",
                    "copado__Type__c": "Flow",
                    "Id": "a0tJ7000000mZwMIAU",
                    "LastReferencedDate": "2026-03-24T09:56:11.000+0000",
                    "LastViewedDate": "2026-03-24T09:56:11.000+0000",
                    "Name": "Enable Vlocity"
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0wJ6000000bt2eIAA"
                    },
                    "copado__ApiName__c": "Classic_to_Source_Format_Migration_2_Create_Git_Snapshot_Record_5",
                    "copado__Backend_Bypass__c": false,
                    "copado__ConfigJson__c": "{\"flowName\":\"cmcSf.Migration_Create_Git_Snapshot\",\"parameters\":[{\"name\":\"mainBranch\",\"value\":\"{$Pipeline.copado__Main_Branch__c}\"},{\"name\":\"repositoryId\",\"value\":\"{$Context.JobExecution__r.DataJson.gitRepositoryId}\"},{\"name\":\"credentialId\",\"value\":\"{$Context.JobExecution__r.DataJson.credentialId}\"},{\"name\":\"pipelineId\",\"value\":\"{$Context.JobExecution__r.DataJson.sfpPipelineId}\"},{\"name\":\"snapshotScope\",\"value\":\"{$Context.Apex.cmcSf.GetSnapshotScopeForMigration}\"},{\"name\":\"jobExecutionId\",\"value\":\"{$Context.JobExecution__r.Id}\"},{\"name\":\"skippedForBackPromotion\",\"value\":\"false\"},{\"name\":\"skippedStages\",\"value\":\"[]\"},{\"name\":\"skippedEnvironments\",\"value\":\"[]\"}]}",
                    "copado__CustomType__c": "Salesforce Flow",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TP1OIAW",
                    "copado__Order__c": 7,
                    "copado__SkipCondition__c": "{$Context.JobExecution__r.DataJson.takeSnapshot.matches(false)}",
                    "copado__Type__c": "Flow",
                    "Id": "a0wJ6000000bt2eIAA",
                    "Name": "Create Git Snapshot Record"
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0wJ6000000bt2fIAA"
                    },
                    "copado__ApiName__c": "Classic_to_Source_Format_Migration_2_Snapshot_6",
                    "copado__Backend_Bypass__c": false,
                    "copado__ConfigJson__c": "{\"flowName\":\"cmcSf.SFP_Migration_Snapshot\",\"parameters\":[{\"name\":\"branch\",\"value\":\"{$Pipeline.copado__Main_Branch__c}\"},{\"name\":\"pipelineId\",\"value\":\"{$Context.JobExecution__r.DataJson.sfpPipelineId}\"},{\"name\":\"sourceOrgId\",\"value\":\"{$Source.Id}\"},{\"name\":\"snapshotInformation\",\"value\":\"{\\\"applyEnvVars\\\":true,\\\"ymlReplacement\\\":true}\"},{\"name\":\"snapshotId\",\"value\":\"{$Context.JobExecution__r.DataJson.gitSnapshotId}\"},{\"name\":\"skippedForBackPromotion\",\"value\":\"false\"},{\"name\":\"skippedStages\",\"value\":\"[]\"},{\"name\":\"skippedEnvironments\",\"value\":\"[]\"}]}",
                    "copado__CustomType__c": "Salesforce Flow",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TP1OIAW",
                    "copado__Order__c": 8,
                    "copado__SkipCondition__c": "{$Context.JobExecution__r.DataJson.takeSnapshot.matches(false)}",
                    "copado__Type__c": "Flow",
                    "Id": "a0wJ6000000bt2fIAA",
                    "Name": "Snapshot"
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0wJ6000000bt2gIAA"
                    },
                    "copado__ApiName__c": "Classic_to_Source_Format_Migration_2_Create_Env_Branches_7",
                    "copado__Backend_Bypass__c": false,
                    "copado__ConfigJson__c": "{\"functionName\":\"Migration_Create_Git_Branches\",\"parameters\":[{\"name\":\"branches\",\"value\":\"{$Context.JobExecution__r.DataJson.branches}\",\"required\":false},{\"name\":\"mainBranch\",\"value\":\"{$Context.JobExecution__r.DataJson.mainBranch}\",\"required\":false},{\"name\":\"gitEmail\",\"value\":\"{$User.Email}\",\"required\":true},{\"name\":\"gitUser\",\"value\":\"{$User.Name}\",\"required\":true},{\"name\":\"git_json\",\"value\":\"{$Context.apex.cmcSf.GetGitJson}\",\"required\":true}]}",
                    "copado__CustomType__c": "Function",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TP1OIAW",
                    "copado__Order__c": 9,
                    "copado__SkipCondition__c": "{$Context.JobExecution__r.DataJson.hasWip.matches(true)}",
                    "copado__Type__c": "Function",
                    "Id": "a0wJ6000000bt2gIAA",
                    "Name": "Create Env Branches"
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0wJ6000000bt2hIAA"
                    },
                    "copado__ApiName__c": "Classic_to_Source_Format_Migration_2_Refresh_Sandboxes_9",
                    "copado__Backend_Bypass__c": false,
                    "copado__ConfigJson__c": "{\"functionName\":\"Refresh_Sandbox\",\"parameters\":[{\"name\":\"destinationSessionid\",\"value\":\"{$Destination.Credential.SessionId}\"},{\"name\":\"destinationEndpoint\",\"value\":\"{$Destination.Credential.Endpoint}\"}]}",
                    "copado__CustomType__c": "Function",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TP1OIAW",
                    "copado__Order__c": 11,
                    "copado__SkipCondition__c": "{$Context.JobExecution__r.DataJson.refreshSandboxes.matches(false)}",
                    "copado__Type__c": "Function",
                    "Id": "a0wJ6000000bt2hIAA",
                    "Name": "Refresh Sandboxes"
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0wJ6000000buaBIAQ"
                    },
                    "copado__ApiName__c": "Classic_to_Source_Format_Migration_2_Handle_Work_in_Progress_8",
                    "copado__Backend_Bypass__c": false,
                    "copado__ConfigJson__c": "{\"flowName\":\"cmcSf.Handle_work_in_progress_migration\",\"parameters\":[{\"name\":\"jobExecutionId\",\"value\":\"{$Context.JobExecution__r.Id}\"}]}",
                    "copado__CustomType__c": "Salesforce Flow",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TP1OIAW",
                    "copado__Order__c": 10,
                    "copado__SkipCondition__c": "{$Context.JobExecution__r.DataJson.hasWip.matches(false)}",
                    "copado__Type__c": "Flow",
                    "Id": "a0wJ6000000buaBIAQ",
                    "Name": "Handle Work in Progress"
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0wJ6000000bsaSIAQ"
                    },
                    "copado__ApiName__c": "MFP_to_SFP_Snapshot_migration_1_Refresh_Metadata_1",
                    "copado__Backend_Bypass__c": false,
                    "copado__ConfigJson__c": "{\"flowName\":\"cmcSf.Refresh_Metadata\",\"parameters\":[{\"name\":\"credentialId\",\"value\":\"{$Job.ExecutionParent.copado__Org__c}\"}]}",
                    "copado__CustomType__c": "Salesforce Flow",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TOrqIAG",
                    "copado__Order__c": 1,
                    "copado__Type__c": "Flow",
                    "Id": "a0wJ6000000bsaSIAQ",
                    "Name": "Refresh Metadata"
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v66.0/sobjects/copado__JobStep__c/a0tJ7000000mZzQIAU"
                    },
                    "copado__ApiName__c": "MFP_to_SFP_Snapshot_migration_1_Vlocity_Snapshot_13",
                    "copado__Backend_Bypass__c": false,
                    "copado__ConfigJson__c": "{\"functionName\":\"vlocity_git_snapshot\",\"parameters\":[{\"name\":\"git_json\",\"value\":\"{$Context.Repository.Credential}\",\"required\":true},{\"name\":\"sourceDirectory\",\"value\":\"vlocity\",\"required\":true},{\"name\":\"selections\",\"value\":\"{$Context.apex.cmcSf.VlocitySnapshotMetadataForMigration}\",\"required\":true},{\"name\":\"sourceSessionId\",\"value\":\"{$Source.Credential.SessionId}\",\"required\":true},{\"name\":\"endpointUrl\",\"value\":\"{$Source.Credential.EndpointURL}\",\"required\":true},{\"name\":\"metadataRefreshResult\",\"value\":\"{$Context.JobExecution__r.DataJson.metadataRefreshResult}\",\"required\":true},{\"name\":\"maxBuffer\",\"value\":\"5242880\"},{\"name\":\"skippedForBackPromotion\",\"value\":\"false\"},{\"name\":\"skippedStages\",\"value\":\"[]\"},{\"name\":\"skippedEnvironments\",\"value\":\"[]\"}]}",
                    "copado__CustomType__c": "Function",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TOrqIAG",
                    "copado__Order__c": 3,
                    "copado__Type__c": "Function",
                    "Id": "a0tJ7000000mZzQIAU",
                    "LastReferencedDate": "2026-03-25T06:59:07.000+0000",
                    "LastViewedDate": "2026-03-25T06:59:07.000+0000",
                    "Name": "Vlocity Snapshot"
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0wJ6000000bsaXIAQ"
                    },
                    "copado__ApiName__c": "MFP_to_SFP_Snapshot_migration_1_Git_Snapshot_2",
                    "copado__Backend_Bypass__c": false,
                    "copado__ConfigJson__c": "{\"functionName\":\"sfdx_git_snapshot\",\"parameters\":[{\"name\":\"git_json\",\"value\":\"{$Context.Repository.Credential}\",\"required\":true},{\"name\":\"gitName\",\"value\":\"{$User.Name}\",\"required\":true},{\"name\":\"gitEmail\",\"value\":\"{$User.Email}\",\"required\":true},{\"name\":\"sourceEndpoint\",\"value\":\"{$Source.Credential.Endpoint}\",\"required\":true},{\"name\":\"sourceSessionId\",\"value\":\"{$Source.Credential.SessionId}\",\"required\":true},{\"name\":\"branch\",\"value\":\"{$Job.ExecutionParent.copado__Branch__c}\",\"required\":true},{\"name\":\"selectedMetadata\",\"value\":\"{$Context.apex.cmcSf.MainSnapshotMetadataForMigrationToSFP}\"},{\"name\":\"snapshotInformation\",\"value\":\"{\\\"applyEnvVars\\\":true,\\\"ymlReplacement\\\":true}\"},{\"name\":\"metadataRefreshResult\",\"value\":\"{$Context.JobExecution__r.DataJson.metadataRefreshResult}\",\"required\":false},{\"name\":\"overriddenApiVersion\",\"value\":\"\"},{\"name\":\"maximumRetryCount\",\"value\":\"1\",\"required\":true},{\"name\":\"commitMessage\",\"value\":\"{$Context.JobExecution__r.DataJson.message}\",\"required\":true},{\"name\":\"processesUsedForRetrieval\",\"value\":\"{$Pipeline.Property.sfdx_git_snapshot_processesUsedForRetrieval}\",\"required\":false},{\"name\":\"environmentVariables\",\"value\":\"{$Source.apex.EnvironmentVariables}\"},{\"name\":\"findAndReplaceFileId\",\"value\":\"{$Context.apex.GlobalFindAndReplaceSourceId}\"},{\"name\":\"metadataChunkInfo\",\"value\":\"{$Pipeline.Property.sfdx_git_snapshot_metadataChunkInfo}\",\"required\":false},{\"name\":\"vlocityFolder\",\"value\":\"vlocity\"}]}",
                    "copado__CustomType__c": "Function",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TOrqIAG",
                    "copado__Order__c": 4,
                    "copado__Type__c": "Function",
                    "Id": "a0wJ6000000bsaXIAQ",
                    "Name": "Git Snapshot"
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0wJ6000000bsacIAA"
                    },
                    "copado__ApiName__c": "MFP_to_SFP_Snapshot_migration_1_Static_Resources_3",
                    "copado__Backend_Bypass__c": false,
                    "copado__ConfigJson__c": "{\"functionName\":\"sfdx_git_snapshot\",\"parameters\":[{\"name\":\"git_json\",\"value\":\"{$Context.Repository.Credential}\",\"required\":true},{\"name\":\"gitName\",\"value\":\"{$User.Name}\",\"required\":true},{\"name\":\"gitEmail\",\"value\":\"{$User.Email}\",\"required\":true},{\"name\":\"sourceEndpoint\",\"value\":\"{$Source.Credential.Endpoint}\",\"required\":true},{\"name\":\"sourceSessionId\",\"value\":\"{$Source.Credential.SessionId}\",\"required\":true},{\"name\":\"branch\",\"value\":\"{$Job.ExecutionParent.copado__Branch__c}\",\"required\":true},{\"name\":\"selectedMetadata\",\"value\":\"{\\\"SFDX\\\":{\\\"included\\\":[\\\"StaticResource\\\"]}}\"},{\"name\":\"snapshotInformation\",\"value\":\"{$Job.ExecutionParent.copado__Other_Information__c}\"},{\"name\":\"metadataRefreshResult\",\"value\":\"{$Context.JobExecution__r.DataJson.metadataRefreshResult}\",\"required\":false},{\"name\":\"overriddenApiVersion\",\"value\":\"\"},{\"name\":\"maximumRetryCount\",\"value\":\"1\",\"required\":true},{\"name\":\"commitMessage\",\"value\":\"{$Context.JobExecution__r.DataJson.message}\",\"required\":true},{\"name\":\"processesUsedForRetrieval\",\"value\":\"{$Pipeline.Property.sfdx_git_snapshot_processesUsedForRetrieval}\",\"required\":false},{\"name\":\"environmentVariables\",\"value\":\"{$Source.apex.EnvironmentVariables}\"},{\"name\":\"findAndReplaceFileId\",\"value\":\"{$Context.apex.GlobalFindAndReplaceSourceId}\"},{\"name\":\"metadataChunkInfo\",\"value\":\"{$Pipeline.Property.sfdx_git_snapshot_metadataChunkInfo}\",\"required\":false},{\"name\":\"vlocityFolder\",\"value\":\"vlocity\"},{\"name\":\"repositoryId\",\"value\":\"{$Job.ExecutionParent.copado__Git_Repository__r.Id}\",\"required\":true},{\"name\":\"skippedForBackPromotion\",\"value\":\"false\"},{\"name\":\"skippedStages\",\"value\":\"[]\"},{\"name\":\"skippedEnvironments\",\"value\":\"[]\"}]}",
                    "copado__CustomType__c": "Function",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TOrqIAG",
                    "copado__Order__c": 5,
                    "copado__SkipCondition__c": "{$Context.JobExecution__r.DataJson.sfdxExcludedTypes.matches(\"*StaticResource*\")}",
                    "copado__Type__c": "Function",
                    "Id": "a0wJ6000000bsacIAA",
                    "Name": "Static Resources"
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0wJ6000000bsaTIAQ"
                    },
                    "copado__ApiName__c": "MFP_to_SFP_Snapshot_migration_1_Reports_4",
                    "copado__Backend_Bypass__c": false,
                    "copado__ConfigJson__c": "{\"functionName\":\"sfdx_git_snapshot\",\"parameters\":[{\"name\":\"git_json\",\"value\":\"{$Context.Repository.Credential}\",\"required\":true},{\"name\":\"gitName\",\"value\":\"{$User.Name}\",\"required\":true},{\"name\":\"gitEmail\",\"value\":\"{$User.Email}\",\"required\":true},{\"name\":\"sourceEndpoint\",\"value\":\"{$Source.Credential.Endpoint}\",\"required\":true},{\"name\":\"sourceSessionId\",\"value\":\"{$Source.Credential.SessionId}\",\"required\":true},{\"name\":\"branch\",\"value\":\"{$Job.ExecutionParent.copado__Branch__c}\",\"required\":true},{\"name\":\"selectedMetadata\",\"value\":\"{\\\"SFDX\\\":{\\\"included\\\":[\\\"Report\\\"]}}\"},{\"name\":\"snapshotInformation\",\"value\":\"{$Job.ExecutionParent.copado__Other_Information__c}\"},{\"name\":\"metadataRefreshResult\",\"value\":\"{$Context.JobExecution__r.DataJson.metadataRefreshResult}\",\"required\":false},{\"name\":\"overriddenApiVersion\",\"value\":\"\"},{\"name\":\"maximumRetryCount\",\"value\":\"1\",\"required\":true},{\"name\":\"commitMessage\",\"value\":\"{$Context.JobExecution__r.DataJson.message}\",\"required\":true},{\"name\":\"processesUsedForRetrieval\",\"value\":\"{$Pipeline.Property.sfdx_git_snapshot_processesUsedForRetrieval}\",\"required\":false},{\"name\":\"environmentVariables\",\"value\":\"{$Source.apex.EnvironmentVariables}\"},{\"name\":\"findAndReplaceFileId\",\"value\":\"{$Context.apex.GlobalFindAndReplaceSourceId}\"},{\"name\":\"metadataChunkInfo\",\"value\":\"{$Pipeline.Property.sfdx_git_snapshot_metadataChunkInfo}\",\"required\":false},{\"name\":\"vlocityFolder\",\"value\":\"vlocity\"},{\"name\":\"repositoryId\",\"value\":\"{$Job.ExecutionParent.copado__Git_Repository__r.Id}\",\"required\":true},{\"name\":\"skippedForBackPromotion\",\"value\":\"false\"},{\"name\":\"skippedStages\",\"value\":\"[]\"},{\"name\":\"skippedEnvironments\",\"value\":\"[]\"}]}",
                    "copado__CustomType__c": "Function",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TOrqIAG",
                    "copado__Order__c": 6,
                    "copado__SkipCondition__c": "{$Context.JobExecution__r.DataJson.sfdxExcludedTypes.matches(\"*Report*\")}",
                    "copado__Type__c": "Function",
                    "Id": "a0wJ6000000bsaTIAQ",
                    "Name": "Reports"
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0wJ6000000bsahIAA"
                    },
                    "copado__ApiName__c": "MFP_to_SFP_Snapshot_migration_1_Dashboards_5",
                    "copado__Backend_Bypass__c": false,
                    "copado__ConfigJson__c": "{\"functionName\":\"sfdx_git_snapshot\",\"parameters\":[{\"name\":\"git_json\",\"value\":\"{$Context.Repository.Credential}\",\"required\":true},{\"name\":\"gitName\",\"value\":\"{$User.Name}\",\"required\":true},{\"name\":\"gitEmail\",\"value\":\"{$User.Email}\",\"required\":true},{\"name\":\"sourceEndpoint\",\"value\":\"{$Source.Credential.Endpoint}\",\"required\":true},{\"name\":\"sourceSessionId\",\"value\":\"{$Source.Credential.SessionId}\",\"required\":true},{\"name\":\"branch\",\"value\":\"{$Job.ExecutionParent.copado__Branch__c}\",\"required\":true},{\"name\":\"selectedMetadata\",\"value\":\"{\\\"SFDX\\\":{\\\"included\\\":[\\\"Dashboard\\\"]}}\"},{\"name\":\"snapshotInformation\",\"value\":\"{$Job.ExecutionParent.copado__Other_Information__c}\"},{\"name\":\"metadataRefreshResult\",\"value\":\"{$Context.JobExecution__r.DataJson.metadataRefreshResult}\",\"required\":false},{\"name\":\"overriddenApiVersion\",\"value\":\"\"},{\"name\":\"maximumRetryCount\",\"value\":\"1\",\"required\":true},{\"name\":\"commitMessage\",\"value\":\"{$Context.JobExecution__r.DataJson.message}\",\"required\":true},{\"name\":\"processesUsedForRetrieval\",\"value\":\"{$Pipeline.Property.sfdx_git_snapshot_processesUsedForRetrieval}\",\"required\":false},{\"name\":\"environmentVariables\",\"value\":\"{$Source.apex.EnvironmentVariables}\"},{\"name\":\"findAndReplaceFileId\",\"value\":\"{$Context.apex.GlobalFindAndReplaceSourceId}\"},{\"name\":\"metadataChunkInfo\",\"value\":\"{$Pipeline.Property.sfdx_git_snapshot_metadataChunkInfo}\",\"required\":false},{\"name\":\"vlocityFolder\",\"value\":\"vlocity\"},{\"name\":\"repositoryId\",\"value\":\"{$Job.ExecutionParent.copado__Git_Repository__r.Id}\",\"required\":true},{\"name\":\"skippedForBackPromotion\",\"value\":\"false\"},{\"name\":\"skippedStages\",\"value\":\"[]\"},{\"name\":\"skippedEnvironments\",\"value\":\"[]\"}]}",
                    "copado__CustomType__c": "Function",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TOrqIAG",
                    "copado__Order__c": 7,
                    "copado__SkipCondition__c": "{$Context.JobExecution__r.DataJson.sfdxExcludedTypes.matches(\"*Dashboard*\")}",
                    "copado__Type__c": "Function",
                    "Id": "a0wJ6000000bsahIAA",
                    "Name": "Dashboards"
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0wJ6000000bsaUIAQ"
                    },
                    "copado__ApiName__c": "MFP_to_SFP_Snapshot_migration_1_ContentAsset_6",
                    "copado__Backend_Bypass__c": false,
                    "copado__ConfigJson__c": "{\"functionName\":\"sfdx_git_snapshot\",\"parameters\":[{\"name\":\"git_json\",\"value\":\"{$Context.Repository.Credential}\",\"required\":true},{\"name\":\"gitName\",\"value\":\"{$User.Name}\",\"required\":true},{\"name\":\"gitEmail\",\"value\":\"{$User.Email}\",\"required\":true},{\"name\":\"sourceEndpoint\",\"value\":\"{$Source.Credential.Endpoint}\",\"required\":true},{\"name\":\"sourceSessionId\",\"value\":\"{$Source.Credential.SessionId}\",\"required\":true},{\"name\":\"branch\",\"value\":\"{$Job.ExecutionParent.copado__Branch__c}\",\"required\":true},{\"name\":\"selectedMetadata\",\"value\":\"{\\\"SFDX\\\":{\\\"included\\\":[\\\"ContentAsset\\\"]}}\"},{\"name\":\"snapshotInformation\",\"value\":\"{$Job.ExecutionParent.copado__Other_Information__c}\"},{\"name\":\"metadataRefreshResult\",\"value\":\"{$Context.JobExecution__r.DataJson.metadataRefreshResult}\",\"required\":false},{\"name\":\"overriddenApiVersion\",\"value\":\"\"},{\"name\":\"maximumRetryCount\",\"value\":\"1\",\"required\":true},{\"name\":\"commitMessage\",\"value\":\"{$Context.JobExecution__r.DataJson.message}\",\"required\":true},{\"name\":\"processesUsedForRetrieval\",\"value\":\"{$Pipeline.Property.sfdx_git_snapshot_processesUsedForRetrieval}\",\"required\":false},{\"name\":\"environmentVariables\",\"value\":\"{$Source.apex.EnvironmentVariables}\"},{\"name\":\"findAndReplaceFileId\",\"value\":\"{$Context.apex.GlobalFindAndReplaceSourceId}\"},{\"name\":\"metadataChunkInfo\",\"value\":\"{$Pipeline.Property.sfdx_git_snapshot_metadataChunkInfo}\",\"required\":false},{\"name\":\"vlocityFolder\",\"value\":\"vlocity\"},{\"name\":\"repositoryId\",\"value\":\"{$Job.ExecutionParent.copado__Git_Repository__r.Id}\",\"required\":true},{\"name\":\"skippedForBackPromotion\",\"value\":\"false\"},{\"name\":\"skippedStages\",\"value\":\"[]\"},{\"name\":\"skippedEnvironments\",\"value\":\"[]\"}]}",
                    "copado__CustomType__c": "Function",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TOrqIAG",
                    "copado__Order__c": 8,
                    "copado__SkipCondition__c": "{$Context.JobExecution__r.DataJson.sfdxExcludedTypes.matches(\"*ContentAsset*\")}",
                    "copado__Type__c": "Function",
                    "Id": "a0wJ6000000bsaUIAQ",
                    "Name": "ContentAsset"
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0wJ6000000bsamIAA"
                    },
                    "copado__ApiName__c": "MFP_to_SFP_Snapshot_migration_1_Document_7",
                    "copado__Backend_Bypass__c": false,
                    "copado__ConfigJson__c": "{\"functionName\":\"sfdx_git_snapshot\",\"parameters\":[{\"name\":\"git_json\",\"value\":\"{$Context.Repository.Credential}\",\"required\":true},{\"name\":\"gitName\",\"value\":\"{$User.Name}\",\"required\":true},{\"name\":\"gitEmail\",\"value\":\"{$User.Email}\",\"required\":true},{\"name\":\"sourceEndpoint\",\"value\":\"{$Source.Credential.Endpoint}\",\"required\":true},{\"name\":\"sourceSessionId\",\"value\":\"{$Source.Credential.SessionId}\",\"required\":true},{\"name\":\"branch\",\"value\":\"{$Job.ExecutionParent.copado__Branch__c}\",\"required\":true},{\"name\":\"selectedMetadata\",\"value\":\"{\\\"SFDX\\\":{\\\"included\\\":[\\\"Document\\\"]}}\"},{\"name\":\"snapshotInformation\",\"value\":\"{$Job.ExecutionParent.copado__Other_Information__c}\"},{\"name\":\"metadataRefreshResult\",\"value\":\"{$Context.JobExecution__r.DataJson.metadataRefreshResult}\",\"required\":false},{\"name\":\"overriddenApiVersion\",\"value\":\"\"},{\"name\":\"maximumRetryCount\",\"value\":\"1\",\"required\":true},{\"name\":\"commitMessage\",\"value\":\"{$Context.JobExecution__r.DataJson.message}\",\"required\":true},{\"name\":\"processesUsedForRetrieval\",\"value\":\"{$Pipeline.Property.sfdx_git_snapshot_processesUsedForRetrieval}\",\"required\":false},{\"name\":\"environmentVariables\",\"value\":\"{$Source.apex.EnvironmentVariables}\"},{\"name\":\"findAndReplaceFileId\",\"value\":\"{$Context.apex.GlobalFindAndReplaceSourceId}\"},{\"name\":\"metadataChunkInfo\",\"value\":\"{$Pipeline.Property.sfdx_git_snapshot_metadataChunkInfo}\",\"required\":false},{\"name\":\"vlocityFolder\",\"value\":\"vlocity\"},{\"name\":\"repositoryId\",\"value\":\"{$Job.ExecutionParent.copado__Git_Repository__r.Id}\",\"required\":true},{\"name\":\"skippedForBackPromotion\",\"value\":\"false\"},{\"name\":\"skippedStages\",\"value\":\"[]\"},{\"name\":\"skippedEnvironments\",\"value\":\"[]\"}]}",
                    "copado__CustomType__c": "Function",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TOrqIAG",
                    "copado__Order__c": 9,
                    "copado__SkipCondition__c": "{$Context.JobExecution__r.DataJson.sfdxExcludedTypes.matches(\"*Document*\")}",
                    "copado__Type__c": "Function",
                    "Id": "a0wJ6000000bsamIAA",
                    "Name": "Document"
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0wJ6000000bsarIAA"
                    },
                    "copado__ApiName__c": "MFP_to_SFP_Snapshot_migration_1_Email_Template_8",
                    "copado__Backend_Bypass__c": false,
                    "copado__ConfigJson__c": "{\"functionName\":\"sfdx_git_snapshot\",\"parameters\":[{\"name\":\"git_json\",\"value\":\"{$Context.Repository.Credential}\",\"required\":true},{\"name\":\"gitName\",\"value\":\"{$User.Name}\",\"required\":true},{\"name\":\"gitEmail\",\"value\":\"{$User.Email}\",\"required\":true},{\"name\":\"sourceEndpoint\",\"value\":\"{$Source.Credential.Endpoint}\",\"required\":true},{\"name\":\"sourceSessionId\",\"value\":\"{$Source.Credential.SessionId}\",\"required\":true},{\"name\":\"branch\",\"value\":\"{$Job.ExecutionParent.copado__Branch__c}\",\"required\":true},{\"name\":\"selectedMetadata\",\"value\":\"{\\\"SFDX\\\":{\\\"included\\\":[\\\"EmailTemplate\\\"]}}\"},{\"name\":\"snapshotInformation\",\"value\":\"{$Job.ExecutionParent.copado__Other_Information__c}\"},{\"name\":\"metadataRefreshResult\",\"value\":\"{$Context.JobExecution__r.DataJson.metadataRefreshResult}\",\"required\":false},{\"name\":\"overriddenApiVersion\",\"value\":\"\"},{\"name\":\"maximumRetryCount\",\"value\":\"1\",\"required\":true},{\"name\":\"commitMessage\",\"value\":\"{$Context.JobExecution__r.DataJson.message}\",\"required\":true},{\"name\":\"processesUsedForRetrieval\",\"value\":\"{$Pipeline.Property.sfdx_git_snapshot_processesUsedForRetrieval}\",\"required\":false},{\"name\":\"environmentVariables\",\"value\":\"{$Source.apex.EnvironmentVariables}\"},{\"name\":\"findAndReplaceFileId\",\"value\":\"{$Context.apex.GlobalFindAndReplaceSourceId}\"},{\"name\":\"metadataChunkInfo\",\"value\":\"{$Pipeline.Property.sfdx_git_snapshot_metadataChunkInfo}\",\"required\":false},{\"name\":\"vlocityFolder\",\"value\":\"vlocity\"},{\"name\":\"repositoryId\",\"value\":\"{$Job.ExecutionParent.copado__Git_Repository__r.Id}\",\"required\":true},{\"name\":\"skippedForBackPromotion\",\"value\":\"false\"},{\"name\":\"skippedStages\",\"value\":\"[]\"},{\"name\":\"skippedEnvironments\",\"value\":\"[]\"}]}",
                    "copado__CustomType__c": "Function",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TOrqIAG",
                    "copado__Order__c": 10,
                    "copado__SkipCondition__c": "{$Context.JobExecution__r.DataJson.sfdxExcludedTypes.matches(\"*EmailTemplate*\")}",
                    "copado__Type__c": "Function",
                    "Id": "a0wJ6000000bsarIAA",
                    "Name": "Email Template"
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0wJ6000000bsanIAA"
                    },
                    "copado__ApiName__c": "MFP_to_SFP_Snapshot_migration_1_Custom_Labels_9",
                    "copado__Backend_Bypass__c": false,
                    "copado__ConfigJson__c": "{\"functionName\":\"sfdx_git_snapshot\",\"parameters\":[{\"name\":\"git_json\",\"value\":\"{$Context.Repository.Credential}\",\"required\":true},{\"name\":\"gitName\",\"value\":\"{$User.Name}\",\"required\":true},{\"name\":\"gitEmail\",\"value\":\"{$User.Email}\",\"required\":true},{\"name\":\"sourceEndpoint\",\"value\":\"{$Source.Credential.Endpoint}\",\"required\":true},{\"name\":\"sourceSessionId\",\"value\":\"{$Source.Credential.SessionId}\",\"required\":true},{\"name\":\"branch\",\"value\":\"{$Job.ExecutionParent.copado__Branch__c}\",\"required\":true},{\"name\":\"selectedMetadata\",\"value\":\"{\\\"SFDX\\\":{\\\"included\\\":[\\\"CustomLabels\\\"]}}\"},{\"name\":\"snapshotInformation\",\"value\":\"{$Job.ExecutionParent.copado__Other_Information__c}\"},{\"name\":\"metadataRefreshResult\",\"value\":\"{$Context.JobExecution__r.DataJson.metadataRefreshResult}\",\"required\":false},{\"name\":\"overriddenApiVersion\",\"value\":\"\"},{\"name\":\"maximumRetryCount\",\"value\":\"1\",\"required\":true},{\"name\":\"commitMessage\",\"value\":\"{$Context.JobExecution__r.DataJson.message}\",\"required\":true},{\"name\":\"processesUsedForRetrieval\",\"value\":\"{$Pipeline.Property.sfdx_git_snapshot_processesUsedForRetrieval}\",\"required\":false},{\"name\":\"environmentVariables\",\"value\":\"{$Source.apex.EnvironmentVariables}\"},{\"name\":\"findAndReplaceFileId\",\"value\":\"{$Context.apex.GlobalFindAndReplaceSourceId}\"},{\"name\":\"metadataChunkInfo\",\"value\":\"{$Pipeline.Property.sfdx_git_snapshot_metadataChunkInfo}\",\"required\":false},{\"name\":\"vlocityFolder\",\"value\":\"vlocity\"},{\"name\":\"repositoryId\",\"value\":\"{$Job.ExecutionParent.copado__Git_Repository__r.Id}\",\"required\":true},{\"name\":\"skippedForBackPromotion\",\"value\":\"false\"},{\"name\":\"skippedStages\",\"value\":\"[]\"},{\"name\":\"skippedEnvironments\",\"value\":\"[]\"}]}",
                    "copado__CustomType__c": "Function",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TOrqIAG",
                    "copado__Order__c": 11,
                    "copado__SkipCondition__c": "{$Context.JobExecution__r.DataJson.sfdxExcludedTypes.matches(\"*CustomLabels*\")}",
                    "copado__Type__c": "Function",
                    "Id": "a0wJ6000000bsanIAA",
                    "Name": "Custom Labels"
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0wJ6000000bsaiIAA"
                    },
                    "copado__ApiName__c": "MFP_to_SFP_Snapshot_migration_1_Custom_Object_10",
                    "copado__Backend_Bypass__c": false,
                    "copado__ConfigJson__c": "{\"functionName\":\"sfdx_git_snapshot\",\"parameters\":[{\"name\":\"git_json\",\"value\":\"{$Context.Repository.Credential}\",\"required\":true},{\"name\":\"gitName\",\"value\":\"{$User.Name}\",\"required\":true},{\"name\":\"gitEmail\",\"value\":\"{$User.Email}\",\"required\":true},{\"name\":\"sourceEndpoint\",\"value\":\"{$Source.Credential.Endpoint}\",\"required\":true},{\"name\":\"sourceSessionId\",\"value\":\"{$Source.Credential.SessionId}\",\"required\":true},{\"name\":\"branch\",\"value\":\"{$Job.ExecutionParent.copado__Branch__c}\",\"required\":true},{\"name\":\"selectedMetadata\",\"value\":\"{\\\"SFDX\\\":{\\\"included\\\":[\\\"CustomObject\\\"]}}\"},{\"name\":\"snapshotInformation\",\"value\":\"{$Job.ExecutionParent.copado__Other_Information__c}\"},{\"name\":\"metadataRefreshResult\",\"value\":\"{$Context.JobExecution__r.DataJson.metadataRefreshResult}\",\"required\":false},{\"name\":\"overriddenApiVersion\",\"value\":\"\"},{\"name\":\"maximumRetryCount\",\"value\":\"1\",\"required\":true},{\"name\":\"commitMessage\",\"value\":\"{$Context.JobExecution__r.DataJson.message}\",\"required\":true},{\"name\":\"processesUsedForRetrieval\",\"value\":\"{$Pipeline.Property.sfdx_git_snapshot_processesUsedForRetrieval}\",\"required\":false},{\"name\":\"environmentVariables\",\"value\":\"{$Source.apex.EnvironmentVariables}\"},{\"name\":\"findAndReplaceFileId\",\"value\":\"{$Context.apex.GlobalFindAndReplaceSourceId}\"},{\"name\":\"metadataChunkInfo\",\"value\":\"{$Pipeline.Property.sfdx_git_snapshot_metadataChunkInfo}\",\"required\":false},{\"name\":\"vlocityFolder\",\"value\":\"vlocity\"},{\"name\":\"repositoryId\",\"value\":\"{$Job.ExecutionParent.copado__Git_Repository__r.Id}\",\"required\":true},{\"name\":\"skippedForBackPromotion\",\"value\":\"false\"},{\"name\":\"skippedStages\",\"value\":\"[]\"},{\"name\":\"skippedEnvironments\",\"value\":\"[]\"}]}",
                    "copado__CustomType__c": "Function",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TOrqIAG",
                    "copado__Order__c": 12,
                    "copado__SkipCondition__c": "{$Context.JobExecution__r.DataJson.sfdxExcludedTypes.matches(\"*CustomObject*\")}",
                    "copado__Type__c": "Function",
                    "Id": "a0wJ6000000bsaiIAA",
                    "Name": "Custom Object"
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0wJ6000000bsawIAA"
                    },
                    "copado__ApiName__c": "MFP_to_SFP_Snapshot_migration_1_Apex_Classes_11",
                    "copado__Backend_Bypass__c": false,
                    "copado__ConfigJson__c": "{\"functionName\":\"sfdx_git_snapshot\",\"parameters\":[{\"name\":\"git_json\",\"value\":\"{$Context.Repository.Credential}\",\"required\":true},{\"name\":\"gitName\",\"value\":\"{$User.Name}\",\"required\":true},{\"name\":\"gitEmail\",\"value\":\"{$User.Email}\",\"required\":true},{\"name\":\"sourceEndpoint\",\"value\":\"{$Source.Credential.Endpoint}\",\"required\":true},{\"name\":\"sourceSessionId\",\"value\":\"{$Source.Credential.SessionId}\",\"required\":true},{\"name\":\"branch\",\"value\":\"{$Job.ExecutionParent.copado__Branch__c}\",\"required\":true},{\"name\":\"selectedMetadata\",\"value\":\"{\\\"SFDX\\\":{\\\"included\\\":[\\\"ApexClass\\\"]}}\"},{\"name\":\"snapshotInformation\",\"value\":\"{$Job.ExecutionParent.copado__Other_Information__c}\"},{\"name\":\"metadataRefreshResult\",\"value\":\"{$Context.JobExecution__r.DataJson.metadataRefreshResult}\",\"required\":false},{\"name\":\"overriddenApiVersion\",\"value\":\"\"},{\"name\":\"maximumRetryCount\",\"value\":\"1\",\"required\":true},{\"name\":\"commitMessage\",\"value\":\"{$Context.JobExecution__r.DataJson.message}\",\"required\":true},{\"name\":\"processesUsedForRetrieval\",\"value\":\"{$Pipeline.Property.sfdx_git_snapshot_processesUsedForRetrieval}\",\"required\":false},{\"name\":\"environmentVariables\",\"value\":\"{$Source.apex.EnvironmentVariables}\"},{\"name\":\"findAndReplaceFileId\",\"value\":\"{$Context.apex.GlobalFindAndReplaceSourceId}\"},{\"name\":\"metadataChunkInfo\",\"value\":\"{$Pipeline.Property.sfdx_git_snapshot_metadataChunkInfo}\",\"required\":false},{\"name\":\"vlocityFolder\",\"value\":\"vlocity\"},{\"name\":\"repositoryId\",\"value\":\"{$Job.ExecutionParent.copado__Git_Repository__r.Id}\",\"required\":true},{\"name\":\"skippedForBackPromotion\",\"value\":\"false\"},{\"name\":\"skippedStages\",\"value\":\"[]\"},{\"name\":\"skippedEnvironments\",\"value\":\"[]\"}]}",
                    "copado__CustomType__c": "Function",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TOrqIAG",
                    "copado__Order__c": 13,
                    "copado__SkipCondition__c": "{$Context.JobExecution__r.DataJson.sfdxExcludedTypes.matches(\"*ApexClass*\")}",
                    "copado__Type__c": "Function",
                    "Id": "a0wJ6000000bsawIAA",
                    "Name": "Apex Classes"
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0wJ6000000bsvkIAA"
                    },
                    "copado__ApiName__c": "MFP_to_SFP_Snapshot_migration_1_Add_Metadata_Content_Id_in_JE_12",
                    "copado__Backend_Bypass__c": false,
                    "copado__ConfigJson__c": "{\"flowName\":\"cmcSf.UpdateMigrationSnapshotJobDataJson\",\"parameters\":[{\"name\":\"jobExecutionId\",\"value\":\"{$Context.JobExecution__r.Id}\"},{\"name\":\"metadataRefreshResult\",\"value\":\"{$Job.PrevStep.Result__r.Result_Data__c}\"}]}",
                    "copado__CustomType__c": "Salesforce Flow",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TOrqIAG",
                    "copado__Order__c": 2,
                    "copado__Type__c": "Flow",
                    "Id": "a0wJ6000000bsvkIAA",
                    "Name": "Add Metadata Content Id in JE"
                },
                {
                    "attributes": {
                        "type": "copado__JobStep__c",
                        "url": "/services/data/v64.0/sobjects/copado__JobStep__c/a0wJ6000000buXqIAI"
                    },
                    "copado__ApiName__c": "SFP_Migration_WIP_1_Create_Branch_1",
                    "copado__ConfigJson__c": "{\"functionName\":\"Migration_Create_Git_Branch\",\"parameters\":[{\"name\":\"childBranch\",\"value\":\"{$Context.JobExecution__r.DataJson.createBranch}\",\"required\":true},{\"name\":\"parentBranch\",\"value\":\"{$Context.JobExecution__r.DataJson.fromBranch}\",\"required\":true},{\"name\":\"gitEmail\",\"value\":\"{$User.Email}\",\"required\":true},{\"name\":\"gitUser\",\"value\":\"{$User.Name}\",\"required\":true},{\"name\":\"git_json\",\"value\":\"{$Context.apex.cmcSf.GetGitJson}\",\"required\":true}]}",
                    "copado__CustomType__c": "Function",
                    "copado__IsSkipped__c": false,
                    "copado__JobTemplate__c": "a0xJ6000000TPTqIAO",
                    "copado__Order__c": 1,
                    "copado__Type__c": "Function",
                    "Id": "a0wJ6000000buXqIAI",
                    "Name": "Create Branch"
                }
            ],
            "ObjectType": "copado__JobStep__c"
        },
        {
            "Records": [
                {
                    "attributes": {
                        "type": "copado__Function__c",
                        "url": "/services/data/v64.0/sobjects/copado__Function__c/a0oJ6000000TYbVIAW"
                    },
                    "copado__API_Name__c": "Update_Exclude_From_AutoResolve",
                    "copado__Backend_Bypass__c": false,
                    "copado__Image_Name__c": "copado-function-core:v1",
                    "copado__Options__c": "[ ]",
                    "copado__Parameters__c": "[ {\n  \"name\" : \"autoResolveMetadatas\",\n  \"defaultValue\" : \"{$Context.copado__Exclude_From_Auto_Resolve__c}\"\n}, {\n  \"name\" : \"branch\",\n  \"defaultValue\" : \"{$Context.copado__Main_Branch__c}\"\n}, {\n  \"name\" : \"git_json\",\n  \"defaultValue\" : \"{$Context.apex.cmcSf.GetGitJson}\"\n}, {\n  \"name\" : \"gitEmail\",\n  \"defaultValue\" : \"{$User.Email}\"\n}, {\n  \"name\" : \"gitName\",\n  \"defaultValue\" : \"{$User.Name}\"\n} ]",
                    "copado__Script__c": "#!/usr/bin/env node\n'use strict';\n\n// IMPORTS\nconst fs = require('fs'),\n    { execSync, spawnSync } = require('child_process'),\n    process = require('process'),\n    { isTest, branch, autoResolveMetadatas, gitEmail, gitName } = process.env;\n\n// CONSTANTS\n\nconst STDIO = {\n        INHERIT: 'inherit'\n    },\n    CHECK_LOG = 'Please check the logs for details',\n    PROJECT_DIRECTORY = 'sfProject',\n    metadataDirectoriesMap = JSON.parse('{\"InstalledPackage\":\"installedPackages\",\"CustomLabels\":\"labels\",\"CustomLabel\":\"labels\",\"StaticResource\":\"staticresources\",\"Scontrol\":\"scontrols\",\"Certificate\":\"certs\",\"LightningMessageChannel\":\"messageChannels\",\"LightningComponentBundle\":\"lwc\",\"AuraDefinitionBundle\":\"aura\",\"ApexComponent\":\"components\",\"ApexPage\":\"pages\",\"Queue\":\"queues\",\"InboundNetworkConnection\":\"inboundNetworkConnections\",\"OutboundNetworkConnection\":\"outboundNetworkConnections\",\"ExternalAuthIdentityProvider\":\"externalAuthIdentityProviders\",\"ExternalCredential\":\"externalCredentials\",\"NamedCredential\":\"namedCredentials\",\"ExternalDataSource\":\"dataSources\",\"ExternalDataSrcDescriptor\":\"dataSources\",\"ExternalServiceRegistration\":\"externalServiceRegistrations\",\"Role\":\"roles\",\"Group\":\"groups\",\"GlobalValueSet\":\"globalValueSets\",\"StandardValueSet\":\"standardValueSets\",\"CustomPermission\":\"customPermissions\",\"CustomObject\":\"objects\",\"CustomField\":\"objects\",\"Index\":\"objects\",\"BusinessProcess\":\"objects\",\"RecordType\":\"objects\",\"CompactLayout\":\"objects\",\"WebLink\":\"objects\",\"ValidationRule\":\"objects\",\"SharingReason\":\"objects\",\"ListView\":\"objects\",\"FieldSet\":\"objects\",\"ReportType\":\"reportTypes\",\"Report\":\"reports\",\"Dashboard\":\"dashboards\",\"AnalyticSnapshot\":\"analyticSnapshots\",\"Layout\":\"layouts\",\"Document\":\"documents\",\"CustomPageWebLink\":\"weblinks\",\"Letterhead\":\"letterhead\",\"EmailTemplate\":\"email\",\"QuickAction\":\"quickActions\",\"UiFormatSpecificationSet\":\"uiFormatSpecificationSets\",\"FlexiPage\":\"flexipages\",\"CustomTab\":\"tabs\",\"CustomApplicationComponent\":\"customApplicationComponents\",\"CustomApplication\":\"applications\",\"CustomMetadata\":\"customMetadata\",\"Flow\":\"flows\",\"FlowDefinition\":\"flowDefinitions\",\"FlowTest\":\"flowtests\",\"ProcessFlowMigration\":\"processflowmigrations\",\"ContentAsset\":\"contentassets\",\"Workflow\":\"workflows\",\"WorkflowFieldUpdate\":\"workflows\",\"WorkflowKnowledgePublish\":\"workflows\",\"WorkflowTask\":\"workflows\",\"WorkflowAlert\":\"workflows\",\"WorkflowSend\":\"workflows\",\"WorkflowOutboundMessage\":\"workflows\",\"WorkflowFlowAutomation\":\"workflows\",\"WorkflowRule\":\"workflows\",\"AssignmentRules\":\"assignmentRules\",\"AssignmentRule\":\"assignmentRules\",\"AutoResponseRules\":\"autoResponseRules\",\"AutoResponseRule\":\"autoResponseRules\",\"EscalationRules\":\"escalationRules\",\"EscalationRule\":\"escalationRules\",\"ApprovalProcess\":\"approvalProcesses\",\"HomePageComponent\":\"homePageComponents\",\"HomePageLayout\":\"homePageLayouts\",\"CustomObjectTranslation\":\"objectTranslations\",\"Translations\":\"translations\",\"GlobalValueSetTranslation\":\"globalValueSetTranslations\",\"StandardValueSetTranslation\":\"standardValueSetTranslations\",\"DataWeaveResource\":\"dw\",\"ApexClass\":\"classes\",\"ApexTrigger\":\"triggers\",\"ApexTestSuite\":\"testSuites\",\"Profile\":\"profiles\",\"PermissionSet\":\"permissionsets\",\"MutingPermissionSet\":\"mutingpermissionsets\",\"PermissionSetGroup\":\"permissionsetgroups\",\"ProfilePasswordPolicy\":\"profilePasswordPolicies\",\"ProfileSessionSetting\":\"profileSessionSettings\",\"MyDomainDiscoverableLogin\":\"myDomainDiscoverableLogins\",\"BlacklistedConsumer\":\"blacklistedConsumers\",\"OauthCustomScope\":\"oauthcustomscopes\",\"OauthTokenExchangeHandler\":\"oauthtokenexchangehandlers\",\"UserProvisioningConfig\":\"userProvisioningConfigs\",\"CustomNotificationType\":\"notificationtypes\",\"ExternalClientApplication\":\"externalClientApps\",\"ExtlClntAppOauthSettings\":\"extlClntAppOauthSettings\",\"ExtlClntAppGlobalOauthSettings\":\"extlClntAppGlobalOauthSets\",\"ExtlClntAppOauthConfigurablePolicies\":\"extlClntAppOauthPolicies\",\"ExtlClntAppConfigurablePolicies\":\"extlClntAppPolicies\",\"ExtlClntAppSamlConfigurablePolicies\":\"extlClntAppSamlConfigurablePolicies\",\"DataCategoryGroup\":\"datacategorygroups\",\"RemoteSiteSetting\":\"remoteSiteSettings\",\"CspTrustedSite\":\"cspTrustedSites\",\"RedirectWhitelistUrl\":\"redirectWhitelistUrls\",\"MatchingRules\":\"matchingRules\",\"MatchingRule\":\"matchingRules\",\"DuplicateRule\":\"duplicateRules\",\"CleanDataService\":\"cleanDataServices\",\"CustomIndex\":\"customindex\",\"AuthProvider\":\"authproviders\",\"EclairGeoData\":\"eclair\",\"WaveAnalyticAssetCollection\":\"wave\",\"AppFrameworkTemplateBundle\":\"appTemplates\",\"IPAddressRange\":\"IPAddressRanges\",\"RecordAlertCategory\":\"recordAlertCategories\",\"ApexEmailNotifications\":\"apexEmailNotifications\",\"ChannelLayout\":\"channelLayouts\",\"CustomSite\":\"sites\",\"BriefcaseDefinition\":\"briefcaseDefinitions\",\"SharingRules\":\"sharingRules\",\"SharingOwnerRule\":\"sharingRules\",\"SharingCriteriaRule\":\"sharingRules\",\"SharingGuestRule\":\"sharingRules\",\"SharingSet\":\"sharingSets\",\"IframeWhiteListUrlSettings\":\"iframeWhiteListUrlSettings\",\"Community\":\"communities\",\"DecisionTable\":\"decisionTables\",\"DecisionTableDatasetLink\":\"decisionTableDatasetLinks\",\"AIApplication\":\"aiApplications\",\"AIApplicationConfig\":\"aiApplicationConfigs\",\"MLPredictionDefinition\":\"mlPredictions\",\"MLRecommendationDefinition\":\"mlRecommendations\",\"MLDataDefinition\":\"mlDataDefinitions\",\"BatchProcessJobDefinition\":\"batchProcessJobDefinitions\",\"BatchCalcJobDefinition\":\"batchCalcJobDefinitions\",\"ExpressionSetMessageToken\":\"expressionSetMessageToken\",\"ExplainabilityMsgTemplate\":\"ExplainabilityMsgTemplates\",\"ExpressionSetObjectAlias\":\"expressionSetObjectAlias\",\"DecisionMatrixDefinition\":\"decisionMatrixDefinition\",\"DecisionMatrixDefinitionVersion\":\"decisionMatrixVersion\",\"ExpressionSetDefinition\":\"expressionSetDefinition\",\"ExpressionSetDefinitionVersion\":\"expressionSetVersion\",\"PlatformEventChannel\":\"platformEventChannels\",\"PlatformEventChannelMember\":\"platformEventChannelMembers\",\"EventRelayConfig\":\"eventRelays\",\"ManagedEventSubscription\":\"managedEventSubscriptions\",\"CallCenter\":\"callCenters\",\"MilestoneType\":\"milestoneTypes\",\"EntitlementProcess\":\"entitlementProcesses\",\"EntitlementTemplate\":\"entitlementTemplates\",\"DocumentType\":\"documentTypes\",\"PublicKeyCertificate\":\"PublicKeyCertificate\",\"PublicKeyCertificateSet\":\"PublicKeyCertificateSet\",\"MessagingChannel\":\"messagingChannels\",\"CanvasMetadata\":\"Canvases\",\"MobileApplicationDetail\":\"MobileApplicationDetails\",\"ConnectedApp\":\"connectedApps\",\"AppMenu\":\"appMenus\",\"NotificationTypeConfig\":\"notificationTypeConfig\",\"DelegateGroup\":\"delegateGroups\",\"BrandingSet\":\"brandingSets\",\"ManagedContentType\":\"managedContentTypes\",\"ExperiencePropertyTypeBundle\":\"experiencePropertyTypeBundles\",\"DigitalExperienceBundle\":\"digitalExperiences\",\"DigitalExperience\":\"digitalExperiences\",\"SiteDotCom\":\"siteDotComSites\",\"ExperienceContainer\":\"experienceContainers\",\"NetworkBranding\":\"networkBranding\",\"FlowCategory\":\"flowCategories\",\"LightningBolt\":\"lightningBolts\",\"LightningExperienceTheme\":\"lightningExperienceThemes\",\"LightningOnboardingConfig\":\"lightningOnboardingConfigs\",\"CustomHelpMenuSection\":\"customHelpMenuSections\",\"Prompt\":\"prompts\",\"SamlSsoConfig\":\"samlssoconfigs\",\"CorsWhitelistOrigin\":\"corsWhitelistOrigins\",\"ActionLinkGroupTemplate\":\"actionLinkGroupTemplates\",\"TransactionSecurityPolicy\":\"transactionSecurityPolicies\",\"ConversationMessageDefinition\":\"conversationMessageDefinitions\",\"SynonymDictionary\":\"synonymDictionaries\",\"PathAssistant\":\"pathAssistants\",\"AnimationRule\":\"animationRules\",\"LeadConvertSettings\":\"LeadConvertSettings\",\"LiveChatSensitiveDataRule\":\"liveChatSensitiveDataRule\",\"PlatformCachePartition\":\"cachePartitions\",\"TopicsForObjects\":\"topicsForObjects\",\"RestrictionRule\":\"restrictionRules\",\"FieldRestrictionRule\":\"fieldRestrictionRules\",\"RecommendationStrategy\":\"recommendationStrategies\",\"OrchestrationContext\":\"iot\",\"Orchestration\":\"iot\",\"EmailServicesFunction\":\"emailservices\",\"PaymentGatewayProvider\":\"paymentGatewayProviders\",\"GatewayProviderPaymentMethodType\":\"gatewayProviderPaymentMethodTypes\",\"ActionLauncherItemDef\":\"ActionLauncherItemDef\",\"RecordActionDeployment\":\"recordActionDeployments\",\"SalesAgreementSettings\":\"salesAgreementSettings\",\"ObjectHierarchyRelationship\":\"ObjectHierarchyRelationship\",\"AcctMgrTargetSettings\":\"acctMgrTargetSettings\",\"AccountForecastSettings\":\"AccountForecastSettings\",\"AdvAcctForecastPeriodGroup\":\"AdvAcctForecastPeriodGroup\",\"AdvAccountForecastSet\":\"AdvAccountForecastSet\",\"AdvAcctForecastDimSource\":\"AdvAcctForecastDimSource\",\"MfgProgramTemplate\":\"MfgProgramTemplate\",\"BusinessProcessTypeDefinition\":\"BusinessProcessTypeDefinitions\",\"ApplicationSubtypeDefinition\":\"ApplicationSubtypeDefinitions\",\"ExplainabilityActionDefinition\":\"ExplainabilityActionDefinitions\",\"ExplainabilityActionVersion\":\"ExplainabilityActionVersions\",\"OmniInteractionConfig\":\"OmniInteractionConfig\",\"OmniInteractionAccessConfig\":\"OmniInteractionAccessConfig\",\"OmniScript\":\"omniScripts\",\"OmniIntegrationProcedure\":\"omniIntegrationProcedures\",\"OmniUiCard\":\"omniUiCard\",\"OmniDataTransform\":\"omniDataTransforms\",\"OmniExtTrackingDef\":\"OmniExtTrackingDefs\",\"OmniExtTrackingEventDef\":\"OmniExtTrackingEventDefs\",\"OmniTrackingGroup\":\"OmniTrackingGroups\",\"OmniTrackingComponentDef\":\"OmniTrackingComponentDef\",\"ChoiceList\":\"ChoiceList\",\"EmbeddedServiceConfig\":\"EmbeddedServiceConfig\",\"EmbeddedServiceBranding\":\"EmbeddedServiceBranding\",\"EmbeddedServiceFlowConfig\":\"EmbeddedServiceFlowConfig\",\"EmbeddedServiceMenuSettings\":\"EmbeddedServiceMenuSettings\",\"CallCoachingMediaProvider\":\"callCoachingMediaProviders\",\"ActionPlanTemplate\":\"actionPlanTemplates\",\"TimelineObjectDefinition\":\"timelineObjectDefinitions\",\"ConvIntelligenceSignalRule\":\"ConvIntelligenceSignalRule\",\"SearchCustomization\":\"searchCustomizations\",\"SearchOrgWideObjectConfig\":\"searchOrgWideConfiguration\",\"PlatformEventSubscriberConfig\":\"PlatformEventSubscriberConfigs\",\"RecordAlertDataSource\":\"recordAlertDataSources\",\"RecAlrtDataSrcExpSetDef\":\"recAlrtDataSrcExpSetDefs\",\"RecordAlertTemplate\":\"recordAlertTemplates\",\"Settings\":\"settings\"}');\n\n// SCRIPT FUNCTIONS\n\nfunction execute() {\n    try {\n        this.setupDirectory(PROJECT_DIRECTORY);\n        this.cloneRepo(branch);\n        this.configureGit();\n        this.updateAutoResolveFile(metadataDirectoriesMap);\n        this.commit();\n    } catch (err) {\n        //Error status = 3, is when we have Custom Error Message, where error is already populated on result and hence we do not need to call it again.\n        if (err?.status === 3) {\n            process.exit(1);\n        }\n        execSync(`${this.getErrorCmd(err?.toString())}`);\n    }\n}\n\nfunction commit() {\n    execSync(\n        `\n        git add '.copado_exclude_autoresolve' || (${this.getErrorCmd(`Error adding git change, ${CHECK_LOG}`)})\n        git commit -m 'Committing copado_exclude_autoresolve' || (${this.getErrorCmd(`Error commiting git change, ${CHECK_LOG}`)})\n        git push origin ${branch} || (${this.getErrorCmd(`Error pushing changes in git, ${CHECK_LOG}`)})`,\n        { stdio: 'inherit' }\n    );\n}\n\nfunction cloneRepo(branchName) {\n    if (!branchName) {\n        throw `Could not find branch name.`;\n    }\n\n    execSync(\n        `\n\t\tcopado -p 'Cloning git repository'\n\t\tcopado-git-get ${branchName} --depth 1 || (${this.getErrorCmd(`Error check out branch ${branchName}, ${CHECK_LOG}`)})`,\n        { stdio: STDIO.INHERIT }\n    );\n}    \n\nfunction updateAutoResolveFile(metadataDirectoriesMap) {\n    try {\n        let content = '';\n        autoResolveMetadatas && autoResolveMetadatas.split(';').forEach(element => {\n            content += `**/${metadataDirectoriesMap[element]}/*.cls\\n`;\n        });\n        execSync(\n            'ls',\n            { stdio: STDIO.INHERIT }\n        );\n        fs.writeFileSync('.copado_exclude_autoresolve', content);\n    } catch (error) {\n        console.log(error);\n        throw error;\n    }\n}\n\nfunction configureGit() {\n    execSync(\n        `\n        git config --global user.email \"${gitEmail}\" || exit 1\n        git config --global user.name \"${gitName}\" || exit 1`,\n        { stdio: 'inherit' }\n    );\n}\n\nfunction escapeSpecialCharacters(text) {\n    return text.replace(/`/g, '\\\\`').replace(/\\$/g, '\\\\$');\n}\n\nfunction getErrorCmd(error) {\n    return `copado -p 'Error' -e ${this.escapeSpecialCharacters(JSON.stringify(error))} ${isTest ? '' : '&& exit 3'}`;\n}\n\nfunction setupDirectory(directory) {\n    fs.mkdirSync(directory);\n    process.chdir(directory);\n}\n\nfunction executeCommand(cmd, disableLogs) {\n    const options = {\n        shell: true,\n        maxBuffer: 5242880\n    };\n    const response = spawnSync(cmd, options);\n    const { output, error } = this.log(response, disableLogs);\n    if (response?.status != 0) {\n        if (response?.status == 3) {\n            if (isTest) {\n                throw output;\n            }\n            process.exit(3);\n        }\n        throw error ? error : `Error executing the command: ${cmd}`;\n    }\n    return output;\n}\n\nfunction log(response, disableLogs) {\n    const output = response?.stdout?.toString().trim();\n    const error = response?.stderr?.toString().trim();\n    if (!disableLogs) {\n        if (output) {\n            console.log(output);\n        }\n        if (error) {\n            console.log(error);\n        }\n    }\n    return { output, error };\n}\n\nmodule.exports.cloneRepo = cloneRepo;\nmodule.exports.escapeSpecialCharacters = escapeSpecialCharacters;\nmodule.exports.getErrorCmd = getErrorCmd;\nmodule.exports.updateAutoResolveFile = updateAutoResolveFile;\nmodule.exports.execute = execute;\nmodule.exports.setupDirectory = setupDirectory;\nmodule.exports.executeCommand = executeCommand;\nmodule.exports.log = log;\nmodule.exports.commit = commit;\nmodule.exports.configureGit = configureGit;\n\n// EXECUTION\n\n!isTest && this.execute();",
                    "copado__Type__c": "Standard",
                    "copado__Worker_Size__c": "S",
                    "Id": "a0oJ6000000TYbVIAW",
                    "LastReferencedDate": "2025-06-27T07:29:28.000+0000",
                    "LastViewedDate": "2025-06-27T07:29:28.000+0000",
                    "Name": "Update Exclude From AutoResolve"
                },
                {
                    "attributes": {
                        "type": "copado__Function__c",
                        "url": "/services/data/v64.0/sobjects/copado__Function__c/a0oJ6000000TYjPIAW"
                    },
                    "copado__ApexClass__c": "cmcSf.RepositoryBranchCreationCallback",
                    "copado__API_Name__c": "Migration_Create_Git_Branches",
                    "copado__Image_Name__c": "copado-multicloud-dx:v5",
                    "copado__Options__c": "[ ]",
                    "copado__Parameters__c": "[ {\n  \"required\" : false,\n  \"name\" : \"branches\",\n  \"defaultValue\" : \"{$Context.JobExecution__r.DataJson.branches}\"\n}, {\n  \"required\" : false,\n  \"name\" : \"mainBranch\",\n  \"defaultValue\" : \"{$Context.JobExecution__r.DataJson.mainBranch}\"\n}, {\n  \"required\" : true,\n  \"name\" : \"gitEmail\",\n  \"defaultValue\" : \"{$User.Email}\"\n}, {\n  \"required\" : true,\n  \"name\" : \"gitUser\",\n  \"defaultValue\" : \"{$User.Name}\"\n}, {\n  \"required\" : true,\n  \"name\" : \"git_json\",\n  \"defaultValue\" : \"{$Context.apex.cmcSf.GetGitJson}\"\n} ]",
                    "copado__Script__c": "#!/usr/bin/env node\n'use strict';\n\nconst child_process = require('child_process'),\n    process = require('process'),\n    fs = require('fs'),\n    { branches, isTest, gitEmail, gitUser, mainBranch } = process.env,\n    APP_DIRECTORY = getPath('/app'),\n    TEMP_DIRECTORY = getPath('/tmp'),\n    TARGET_DIRECTORY = `${APP_DIRECTORY}/repository`,\n    RESULT_INFO = {\n        LEVEL: {\n            INFO: 'INFO',\n            ERROR: 'ERROR',\n            WARN: 'WARN'\n        },\n        CATEGORY: {\n            GIT: 'Git',\n            COPADO_INFO: 'Copado Info',\n            COPADO_SERVICE: 'Copado Service',\n            UNKNOWN_EXCEPTION: 'Unknown Exception',\n            FILE_SYSTEM: 'File System'\n        },\n        ADDITIONAL_INFORMATION: {\n            GIT_CHECKOUT: 'Git Checkout',\n            GIT_PUSH: 'Git Push',\n            UPLOAD_FILES: 'Upload Files',\n            COPADO_GIT_GET: 'Copado Git Service',\n            GIT_CONFIG: 'Git Configuration',\n            SETUP_DIRECTORY: 'Setup Directory',\n            GIT_BRANCH_NAME: 'Git Branch Name'\n        }\n    },\n    STDIO = {\n        INHERIT: 'inherit',\n        PIPE: 'pipe',\n        IGNORE: 'ignore'\n    },\n    COPADO_INFO_PREFIX = 'CopadoFunction INFO',\n    resultViewerJson = [],\n    CUSTOM_ERROR = {\n        COMMAND_EXECUTION_ERROR: 'CommandExecutionError'\n    },\n    RESULT_TABLE_HEADER = {\n        label: 'Create Environment Branch Result',\n        customLabel: 'create_environment_branch_result'\n    },\n    HEADER_ICON = 'standard:note',\n    RESULT_TABLE_COLUMNS = [\n        {\n            label: 'Level',\n            fieldName: 'Level',\n            type: 'text',\n            wrapText: true,\n            customLabel: 'Level',\n            initialWidth: 80\n        },\n        {\n            label: 'Category',\n            fieldName: 'Category',\n            type: 'text',\n            wrapText: true,\n            customLabel: 'Category',\n            initialWidth: 120\n        },\n        {\n            label: 'Additional Information',\n            fieldName: 'AdditionalInformation',\n            type: 'text',\n            wrapText: true,\n            customLabel: 'Additional_Information',\n            initialWidth: 200\n        },\n        {\n            label: 'Message',\n            fieldName: 'Message',\n            type: 'text',\n            wrapText: true,\n            customLabel: 'Message'\n        }\n    ];\n\nlet executionError;\n\nasync function execute() {\n    try {\n        const environmentBranches = JSON.parse(branches);\n        const parentBranch = mainBranch;\n        await this.createWorkingDirectory(TARGET_DIRECTORY);\n        this.logger('START Creating environment branches');\n        for await (let environmentBranch of environmentBranches) {\n            if(parentBranch === environmentBranch) {\n                continue;\n            }\n            await this.validateBranches(environmentBranch, parentBranch);\n            await this.createWorkingDirectory(TARGET_DIRECTORY + '/environmentBranch');\n            await this.fetchGitBranch(parentBranch);\n            this.changeWorkingDirectory(TARGET_DIRECTORY + '/environmentBranch');\n            await this.configureGit(gitUser, gitEmail);\n            await this.createEnvironmentBranch(environmentBranch, parentBranch);\n            await this.pushEnvironmentBranch(environmentBranch);\n        }\n        \n        this.logger('END Creating environment branches');\n    } catch (err) {\n        this.log(`Error: ${err.stack}`);\n        if (!(err instanceof CommandExecutionError)) {\n            this.populateResultViewer(RESULT_INFO.LEVEL.ERROR, RESULT_INFO.CATEGORY.UNKNOWN_EXCEPTION, 'See logs for more info', err.message);\n        }\n        executionError = err.message || err?.toString() || 'Unknown Error occurred';\n    } finally {\n        if (resultViewerJson?.length) {\n            this.uploadResultViewerJson(resultViewerJson, RESULT_TABLE_COLUMNS, RESULT_TABLE_HEADER, HEADER_ICON);\n        }\n        if (executionError) {\n            await this.executeCommand(this.getErrorCommand(executionError));\n            process.exit(1);\n        }\n    }\n}\n\n\nasync function fetchGitBranch(branch) {\n    this.logger(`START Fetching ${branch}`);\n\n    const cmd = `cd ${TARGET_DIRECTORY}\n        copado-git-get ${branch}`;\n\n    await this.executeCommand(cmd, RESULT_INFO.CATEGORY.COPADO_SERVICE, RESULT_INFO.ADDITIONAL_INFORMATION.COPADO_GIT_GET);\n    this.logger(`END Fetching ${branch}`);\n}\n\nfunction getRemoteBranches(parentBranch) {\n    const response = child_process.execSync(`copado-git-get --remote \"${parentBranch}\"`, { encoding: 'utf-8' });\n    return response?.trim().split(', ');\n}\n\nasync function validateBranches(environmentBranch, parentBranch) {\n\n    if (parentBranch === null || environmentBranch === null) {\n        throw new Error('Error creating environment branch: ' + environmentBranch);\n    }\n\n    await this.validateBranchName([parentBranch, environmentBranch]);\n\n\n    const remoteBranches = this.getRemoteBranches(parentBranch);\n    if (!remoteBranches.includes(parentBranch)) {\n        throw new Error(`Error creating environment branch: ${parentBranch} does not exist!`);\n    }\n\n    if (remoteBranches.includes(environmentBranch)) {\n        throw new Error(`Error creating environment branch: ${environmentBranch} already exists!`);\n    }\n}\n\nasync function configureGit(gitEmail, gitUser) {\n    const gitConfig = `\n    git config --local user.email \"${gitEmail}\" || exit 1\n    git config --local user.name \"${gitUser}\" || exit 1\n    git config --global diff.renames false || exit 1\n    git config --global merge.renames false || exit 1\n    git config --global status.renames false || exit 1\n    `;\n    await this.executeCommand(gitConfig, RESULT_INFO.CATEGORY.GIT, RESULT_INFO.ADDITIONAL_INFORMATION.GIT_CONFIG);\n}\n\nasync function validateBranchName(branches) {\n\n    for(const branch of branches) {\n        const checkReferenceFormatCommand = `git check-ref-format --branch \"${branch}\" || exit 1`;\n        await this.executeCommand(checkReferenceFormatCommand, RESULT_INFO.CATEGORY.GIT, RESULT_INFO.ADDITIONAL_INFORMATION.GIT_BRANCH_NAME);\n    }\n}\n\nasync function createWorkingDirectory(dir) {\n    await this.executeCommand(`mkdir -p ${dir}`, RESULT_INFO.CATEGORY.FILE_SYSTEM, RESULT_INFO.ADDITIONAL_INFORMATION.SETUP_DIRECTORY);\n}\n\nasync function createEnvironmentBranch(environmentBranch, parentBranch) {\n    this.log(`Creating branch ${environmentBranch} from ${parentBranch}`);\n    if (parentBranch) {\n        this.asyncCopadoLogMessage(`\"Creating branch ${environmentBranch} from ${parentBranch}\"`);\n        await this.executeCommand(\n            `git checkout -b ${environmentBranch} ${parentBranch}`,\n            RESULT_INFO.CATEGORY.GIT,\n            RESULT_INFO.ADDITIONAL_INFORMATION.GIT_CHECKOUT\n        );\n    } else {\n        throw new Error('No environment branch provided');\n    }\n}\n\nasync function pushEnvironmentBranch(branchName) {\n\n    this.asyncCopadoLogMessage(`Pushing environment branch ${branchName}`);\n    const gitPush = `git push origin ${branchName}`;\n    await this.executeCommand(gitPush, RESULT_INFO.CATEGORY.GIT, RESULT_INFO.ADDITIONAL_INFORMATION.GIT_PUSH);\n}\n\nasync function executeCommand(command, category, additionalInfo, hasJsonResponse, disableLog) {\n    this.logger(`==> ${command}`);\n    return new Promise((resolve, reject) => {\n        let output = '',\n            error = '';\n\n        const childProcess = child_process.spawn(command, [], { shell: true });\n\n        childProcess.stdout.on('data', (data) => {\n           const outputStream = data?.toString();\n\t\t\tif(!disableLog) {\n\t\t\t\tthis.logger(outputStream);\n\t\t\t}\n\t\t\toutput += outputStream;\n        });\n\n        childProcess.stderr.on('data', (data) => {\n            const errorStream = data?.toString();\n\t\t\tthis.logger(errorStream);\n            error += data?.toString();\n        });\n\n        childProcess.on('close', (code) => {\n            if (code !== 0) {\n            \t\n                this.logger(`Code: ${code}`);\n                let errorMessage = '';\n\n                if (hasJsonResponse) {\n                    try {\n                        resolve(JSON.parse(output));\n                    } catch (error) {\n                        errorMessage = error;\n                    }\n                } else {\n                    errorMessage = error;\n                }\n\n                errorMessage = errorMessage ? errorMessage : `Error executing the command ${command}`;\n\n                this.populateResultViewer(RESULT_INFO.LEVEL.ERROR, category, additionalInfo, errorMessage);\n\n                const truncatedError = JSON.stringify(\n                    errorMessage.split('\\n').filter((msg) => !msg.includes(COPADO_INFO_PREFIX)).join(' ')\n                );\n                reject( new CommandExecutionError(truncatedError, category, additionalInfo));\n            }\n\n            resolve(hasJsonResponse ? JSON.parse(output) : output);\n        });\n\n        childProcess.on('error', (error) => {\n            this.populateResultViewer(RESULT_INFO.LEVEL.ERROR, category, additionalInfo, error);\n\n            const truncatedError = JSON.stringify(error.split('\\n').filter((msg) => !msg.includes(COPADO_INFO_PREFIX)).join(' '));\n            reject(new CommandExecutionError(truncatedError, category, additionalInfo));\n        });\n    });\n}\n\nfunction getPath(filePath) {\n    return isTest ? `${__dirname}/__tests__/__mockDir__${filePath}` : filePath;\n}\n\nfunction logger(message) {\n    console.log(message);\n}\n\nfunction log(response, disableLogs) {\n    const outputStream = response?.stdout?.toString().trim();\n    const errorStream = response?.stderr?.toString().trim();\n    if (!disableLogs) {\n        if (outputStream) {\n            console.log(outputStream);\n        }\n        if (errorStream) {\n            console.log(errorStream);\n        }\n    }\n    return { outputStream, errorStream };\n}\n\nfunction changeWorkingDirectory(dir) {\n    process.chdir(dir);\n}\n\nfunction populateResultViewer(level, category, additionalInfo, message) {\n    if (message) {\n        resultViewerJson.push({\n            Level: level,\n            Category: category,\n            AdditionalInformation: additionalInfo,\n            Message: message\n        });\n    }\n}\n\nfunction uploadResultViewerJson(data, columns, header, headerIcon) {\n    const RESULT_VIEWER_JSON_PATH = `${TEMP_DIRECTORY}/ResultViewer.json`;\n\n    const fileContent = { data, columns, header, headerIcon };\n    fs.writeFileSync(RESULT_VIEWER_JSON_PATH, JSON.stringify(fileContent, null, 2));\n    this.uploadFileAtPath(RESULT_VIEWER_JSON_PATH);\n}\n\nfunction uploadFileAtPath(filePath) {\n    new Promise((resolve, reject) => {\n        child_process.exec(`copado --uploadfile ${filePath}`, {}, err => {\n            if (err) {\n                this.populateResultViewer(\n                    RESULT_INFO.LEVEL.ERROR,\n                    RESULT_INFO.CATEGORY.COPADO_SERVICE,\n                    RESULT_INFO.ADDITIONAL_INFORMATION.UPLOAD_FILES,\n                    err\n                );\n                reject(new CommandExecutionError(err, RESULT_INFO.CATEGORY.COPADO_SERVICE, RESULT_INFO.ADDITIONAL_INFORMATION.UPLOAD_FILES));\n            } else {\n                resolve();\n            }\n        });\n    });\n}\nfunction asyncCopadoLogMessage(msg, logLevel) {\n    if (msg) {\n        this.populateResultViewer(logLevel ? logLevel : RESULT_INFO.LEVEL.INFO, RESULT_INFO.CATEGORY.COPADO_INFO, '', msg);\n        new Promise(resolve => {\n            child_process.exec(`copado -p \"${msg}\"`, { stdio: STDIO.INHERIT }, () => {\n                resolve();\n            });\n        });\n    }\n}\n\nfunction getErrorCommand(error) {\n    const suffix = 'Please check the logs for details.';\n    return `{ copado -p 'Error' -e '${error}. ${suffix}'; exit 2; }`;\n}\n\nclass CommandExecutionError extends Error {\n    constructor(message, category, additionalInfo) {\n        super(`${category ? category + ' - ' : ''}${additionalInfo ? additionalInfo + ' : ' : ''}${message}`);\n        this.name = CUSTOM_ERROR.COMMAND_EXECUTION_ERROR;\n    }\n}\n\n\nmodule.exports.executeCommand = executeCommand;\nmodule.exports.createEnvironmentBranch = createEnvironmentBranch;\nmodule.exports.execute = execute;\nmodule.exports.log = log;\nmodule.exports.changeWorkingDirectory = changeWorkingDirectory;\nmodule.exports.pushEnvironmentBranch = pushEnvironmentBranch;\nmodule.exports.uploadFileAtPath = uploadFileAtPath;\nmodule.exports.uploadResultViewerJson = uploadResultViewerJson;\nmodule.exports.populateResultViewer = populateResultViewer;\nmodule.exports.fetchGitBranch = fetchGitBranch;\nmodule.exports.createWorkingDirectory = createWorkingDirectory;\nmodule.exports.configureGit = configureGit;\nmodule.exports.getErrorCommand = getErrorCommand;\nmodule.exports.logger = logger;\nmodule.exports.getRemoteBranches = getRemoteBranches;\nmodule.exports.validateBranches = validateBranches;\nmodule.exports.asyncCopadoLogMessage = asyncCopadoLogMessage;\nmodule.exports.validateBranchName = validateBranchName;\n\n!isTest && this.execute();",
                    "copado__Type__c": "Standard",
                    "copado__Worker_Size__c": "M",
                    "Id": "a0oJ6000000TYjPIAW",
                    "LastReferencedDate": "2025-06-27T07:53:45.000+0000",
                    "LastViewedDate": "2025-06-27T07:53:45.000+0000",
                    "Name": "[Migration] - Create Git Branches"
                },
                {
                    "attributes": {
                        "type": "copado__Function__c",
                        "url": "/services/data/v64.0/sobjects/copado__Function__c/a0oJ6000000TYoZIAW"
                    },
                    "copado__API_Name__c": "Refresh_Sandbox",
                    "copado__Backend_Bypass__c": false,
                    "copado__Image_Name__c": "copado-multicloud-dx:v5",
                    "copado__Options__c": "[ ]",
                    "copado__Parameters__c": "[ {\n  \"name\" : \"destinationSessionid\",\n  \"defaultValue\" : \"{$Context.Credential.SessionId}\"\n}, {\n  \"name\" : \"destinationEndpoint\",\n  \"defaultValue\" : \"{$Context.Credential.Endpoint}\"\n} ]",
                    "copado__Script__c": "#!/usr/bin/env node\n/**\n * Performs execution of apex script using sfdx cli command.\n * @param destinationSessionid\n * @param destinationEndpoint\n * @param script\n * @param destinationEnvVar\n * @param isValidation\n */\n\nconst { mkdirSync, writeFileSync } = require('fs'),\n\t{ exec, spawn, execSync } = require('child_process'),\n\t{ destinationSessionid, destinationEndpoint, isTest, API_VERSION, maxBuffer } = process.env,\n\tdestinationBaseUrl = getBaseUrl(destinationEndpoint),\n\tTEMP_DIRECTORY = getPath('/tmp'),\n\tSFDX_PROJECT_DIRECTORY = `${TEMP_DIRECTORY}/sfdx-project`,\n\tSTDIO = {\n\t\tINHERIT: 'inherit',\n\t\tPIPE: 'pipe',\n\t\tIGNORE: 'ignore'\n\t},\n\tMAX_BUFFER = parseInt(maxBuffer);\nlet sandboxNames = [];\n\n// SCRIPT FUNCTIONS\n\nasync function execute() {\n\ttry {\n       \n        this.createSfdxProject(SFDX_PROJECT_DIRECTORY);\n\t\tawait this.setupSFConfig();\n        const sandboxInfo = await this.querySandbxes();\n        if(!sandboxInfo.status && sandboxInfo?.result?.records?.length) {\n            sandboxNames = sandboxInfo.result.records.map(ele => ele.SandboxName);\n        } else {\n            this.logger(`No Sandboxes`);\n            process.exit(0);\n        }\n       const sandboxProcessesId = await this.refreshSandboxes(sandboxNames, destinationSessionid);\n        await this.pollStatus(sandboxProcessesId);\n\t} catch (error) {\n\t\tawait this.logError(error);\n\t}\n}\n\nfunction createSfdxProject(projectDirectory) {\n\tthis.asyncCopadoLogMessage('Creating SFDX Project');\n\tmkdirSync(projectDirectory, { recursive: true, force: true });\n\tconst projectJSON = {\n\t\tpackageDirectories: [\n\t\t\t{\n\t\t\t\tpath: 'force-app',\n\t\t\t\tdefault: true\n\t\t\t}\n\t\t],\n\t\tname: 'sfdx-project',\n\t\tnamespace: '',\n\t\tsfdcLoginUrl: 'https://login.salesforce.com',\n\t\tsourceApiVersion: API_VERSION\n\t};\n\twriteFileSync(`${projectDirectory}/sfdx-project.json`, JSON.stringify(projectJSON));\n\tprocess.chdir(projectDirectory);\n}\n\n\nasync function refreshSandboxes(sourceNames, targetOrg) {\n    let outputResponse = [];\n    for await (let sourceName of sourceNames) {\n        outputResponse.push(await this.refreshSandbox(sourceName, targetOrg));\n    }\n    \n    const errorMessages = outputResponse.filter(ele => ele.exitCode === 1);\n    if(errorMessages.length) {\n        throw errorMessages[0]?.message;\n    }\n    return outputResponse.map(ele => ele?.result?.Id);\n}\n\nfunction refreshSandbox(sourceName, targetOrg) {\n    this.asyncCopadoLogMessage('Sandbox refresh start!');\n\tconst cmd = `\n\t    sf org refresh sandbox --name ${sourceName} --target-org ${targetOrg} --wait 1 --json\n    `;\n\treturn this.executeCommandAsync(cmd, true);\n}\n\nasync function pollStatus(processIds) {\n    return new Promise((resolve, reject) => {\n        const poll = setInterval(async () => {\n            const response = await queryStatus(processIds);\n            \n            if (!response?.status) {\n                const inProgress = response.result.records.filter(ele => (ele.Status === 'Processing' || ele.Status === 'Pending Activation' || ele.Status === 'Pending' || ele.Status === 'Activating' || ele.Status === 'Locking'));\n                if(inProgress.length) {\n                    this.logger(`Few sandbox refreshes are in progress: `, inProgress);\n                } else {\n                    this.logger(`Sandbox Refresh is completed`);\n                    clearInterval(poll);\n                    resolve(response);\n                }\n            } else if (response?.status) {\n                clearInterval(poll);\n                reject(response?.message || 'Some issue while fetching Sandbox Refresh Status');\n            }\n        }, 60 * 1000);\n    });\n}\n\nasync function queryStatus(processIds) {\n    execSync(`copado -p 'Checking status'`, {stdio: 'inherit'});\n    const query = `SELECT Id,ActivatedDate,Description,EndDate,LicenseType,SandboxInfoId,SandboxName,SandboxOrganization,CreatedDate,Source.SandboxName, Status FROM SandboxProcess WHERE Id IN ('${processIds.join(\"','\")}')`;\n    \n    const cmd = `sf data query --query \"${query}\" --use-tooling-api --target-org ${destinationSessionid} --json`;\n\n    const result = JSON.parse(execSync(cmd).toString());\n    logger(` Tooling API Response ==> ${JSON.stringify(result)}`);\n    return result;\n\n }\n\nasync function querySandbxes() {\n    const query = 'SELECT Id, SandboxName FROM SandboxInfo';\n    const cmd = `sf data query --query \"${query}\" --use-tooling-api --target-org ${destinationSessionid} --json`;\n    const result = await this.executeCommandAsync(cmd, true);\n    logger(`SandboxInfo Response ==> ${JSON.stringify(result)}`);\n    return result;\n}\n\nasync function setupSFConfig() {\n\tthis.asyncCopadoLogMessage('Configuring sf cli');\n\tconst cmd = `\n      sf config set org-instance-url=${destinationBaseUrl}\n    `;\n\tawait this.executeCommandAsync(cmd);\n}\n\nasync function logError(error) {\n\tawait this.executeCommandAsync(this.getErrorCommandString(error.message || error?.toString()));\n\tprocess.exit(1);\n}\n\nfunction getPath(filePath) {\n\treturn isTest ? `${__dirname}/__tests__/__mockDirectory__${filePath}` : filePath;\n}\n\nfunction getBaseUrl(endpoint) {\n\treturn endpoint.substring(0, endpoint.indexOf('/', endpoint.indexOf('/') + 2));\n}\n\nfunction asyncCopadoLogMessage(msg) {\n\tnew Promise(resolve => {\n\t\texec(`copado -p \"${msg}\"`, { stdio: STDIO.INHERIT }, (err, response, stderr) => {\n\t\t\tresolve();\n\t\t});\n\t});\n}\n\nfunction executeCommandAsync(command, hasJsonResponse, disableLog) {\n\treturn new Promise((resolve, reject) => {\n\t\tlet output = '',\n\t\t\terror = '';\n\t\tconst childProcess = spawn(command, [], { shell: true });\n\n\t\tchildProcess.stdout.on('data', data => {\n\t\t\toutput += data?.toString();\n\t\t});\n\n\t\tchildProcess.stderr.on('data', data => {\n\t\t\terror += data?.toString();\n\t\t});\n\n\t\tchildProcess.on('close', code => {\n\t\t\tif (code !== 0) {\n\t\t\t\tlet errorMessage = '';\n\t\t\t\tif (hasJsonResponse) {\n\t\t\t\t\ttry {\n\t\t\t\t\t\tresolve(JSON.parse(output));\n\t\t\t\t\t} catch (error) {\n\t\t\t\t\t\terrorMessage = error;\n\t\t\t\t\t}\n\t\t\t\t} else {\n\t\t\t\t\terrorMessage = error;\n\t\t\t\t}\n\t\t\t\terrorMessage = errorMessage ? errorMessage : `Error executing the command ${command}`;\n\t\t\t\treject(errorMessage);\n\t\t\t}\n\t\t\tif (!disableLog) {\n\t\t\t\tif (code?.toString()) {\n\t\t\t\t\tthis.logger(`code: ${code?.toString()}`);\n\t\t\t\t}\n\t\t\t\tif (output) {\n\t\t\t\t\tthis.logger(`stdout: ${output}`);\n\t\t\t\t}\n\t\t\t\tif (error) {\n\t\t\t\t\tthis.logger(`stderr: ${error}`);\n\t\t\t\t}\n\t\t\t}\n\t\t\tresolve(hasJsonResponse ? JSON.parse(output) : output);\n\t\t});\n\n\t\tchildProcess.on('error', error => {\n\t\t\treject(error);\n\t\t});\n\t});\n}\n\nfunction getOptions() {\n\tconst options = {\n\t\tshell: true,\n\t\tmaxBuffer: MAX_BUFFER\n\t};\n\treturn options;\n}\n\nfunction logger(text) {\n\tconsole.log(text);\n}\n\nfunction log(response, disableLogs) {\n\tconst outputStream = response?.stdout?.toString().trim();\n\tconst errorStream = response?.stderr?.toString().trim();\n\tif (!disableLogs) {\n\t\tif (outputStream) {\n\t\t\tconsole.log(outputStream);\n\t\t}\n\t\tif (errorStream) {\n\t\t\tconsole.log(errorStream);\n\t\t}\n\t}\n\treturn { outputStream, errorStream };\n}\n\nfunction getErrorCommandString(error) {\n\tconst suffix = 'Please check the logs for details.';\n\treturn `copado -p \"Error\" -e \"${error.trim()?.substring(0, 32760)}; ${suffix}\"`;\n}\n\nmodule.exports.execute = execute;\nmodule.exports.setupSFConfig = setupSFConfig;\nmodule.exports.logError = logError;\nmodule.exports.getPath = getPath;\nmodule.exports.createSfdxProject = createSfdxProject;\nmodule.exports.asyncCopadoLogMessage = asyncCopadoLogMessage;\nmodule.exports.refreshSandbox = refreshSandbox;\nmodule.exports.log = log;\nmodule.exports.logger = logger;\nmodule.exports.querySandbxes = querySandbxes;\nmodule.exports.getOptions = getOptions;\nmodule.exports.refreshSandboxes = refreshSandboxes;\nmodule.exports.pollStatus = pollStatus;\nmodule.exports.executeCommandAsync = executeCommandAsync;\nmodule.exports.getErrorCommandString = getErrorCommandString;\n\n// EXECUTION\n\n!isTest && this.execute();",
                    "copado__Type__c": "Standard",
                    "copado__Worker_Size__c": "S",
                    "Id": "a0oJ6000000TYoZIAW",
                    "LastReferencedDate": "2025-06-27T11:17:41.000+0000",
                    "LastViewedDate": "2025-06-27T11:17:41.000+0000",
                    "Name": "Refresh Sandbox"
                },
                {
                    "attributes": {
                        "type": "copado__Function__c",
                        "url": "/services/data/v64.0/sobjects/copado__Function__c/a0oJ6000000Tag7IAC"
                    },
                    "copado__API_Name__c": "Migration_Create_Git_Branch",
                    "copado__Image_Name__c": "copado-multicloud-dx:v5",
                    "copado__Options__c": "[ ]",
                    "copado__Parameters__c": "[ {\n  \"required\" : true,\n  \"name\" : \"childBranch\",\n  \"defaultValue\" : \"{$Context.JobExecution__r.DataJson.createBranch}\"\n}, {\n  \"required\" : true,\n  \"name\" : \"parentBranch\",\n  \"defaultValue\" : \"{$Context.JobExecution__r.DataJson.fromBranch}\"\n}, {\n  \"required\" : true,\n  \"name\" : \"gitEmail\",\n  \"defaultValue\" : \"{$User.Email}\"\n}, {\n  \"required\" : true,\n  \"name\" : \"gitUser\",\n  \"defaultValue\" : \"{$User.Name}\"\n}, {\n  \"required\" : true,\n  \"name\" : \"git_json\",\n  \"defaultValue\" : \"{$Context.apex.cmcSf.GetGitJson}\"\n} ]",
                    "copado__Script__c": "#!/usr/bin/env node\n'use strict';\n\nconst child_process = require('child_process'),\n    process = require('process'),\n    fs = require('fs'),\n    { childBranch, isTest, gitEmail, gitUser, parentBranch } = process.env,\n    APP_DIRECTORY = getPath('/app'),\n    TEMP_DIRECTORY = getPath('/tmp'),\n    TARGET_DIRECTORY = `${APP_DIRECTORY}/repository`,\n    RESULT_INFO = {\n        LEVEL: {\n            INFO: 'INFO',\n            ERROR: 'ERROR',\n            WARN: 'WARN'\n        },\n        CATEGORY: {\n            GIT: 'Git',\n            COPADO_INFO: 'Copado Info',\n            COPADO_SERVICE: 'Copado Service',\n            UNKNOWN_EXCEPTION: 'Unknown Exception',\n            FILE_SYSTEM: 'File System'\n        },\n        ADDITIONAL_INFORMATION: {\n            GIT_CHECKOUT: 'Git Checkout',\n            GIT_PUSH: 'Git Push',\n            UPLOAD_FILES: 'Upload Files',\n            COPADO_GIT_GET: 'Copado Git Service',\n            GIT_CONFIG: 'Git Configuration',\n            SETUP_DIRECTORY: 'Setup Directory',\n            GIT_BRANCH_NAME: 'Git Branch Name'\n        }\n    },\n    STDIO = {\n        INHERIT: 'inherit',\n        PIPE: 'pipe',\n        IGNORE: 'ignore'\n    },\n    COPADO_INFO_PREFIX = 'CopadoFunction INFO',\n    resultViewerJson = [],\n    CUSTOM_ERROR = {\n        COMMAND_EXECUTION_ERROR: 'CommandExecutionError'\n    },\n    RESULT_TABLE_HEADER = {\n        label: 'Create Environment Branch Result',\n        customLabel: 'create_environment_branch_result'\n    },\n    HEADER_ICON = 'standard:note',\n    RESULT_TABLE_COLUMNS = [\n        {\n            label: 'Level',\n            fieldName: 'Level',\n            type: 'text',\n            wrapText: true,\n            customLabel: 'Level',\n            initialWidth: 80\n        },\n        {\n            label: 'Category',\n            fieldName: 'Category',\n            type: 'text',\n            wrapText: true,\n            customLabel: 'Category',\n            initialWidth: 120\n        },\n        {\n            label: 'Additional Information',\n            fieldName: 'AdditionalInformation',\n            type: 'text',\n            wrapText: true,\n            customLabel: 'Additional_Information',\n            initialWidth: 200\n        },\n        {\n            label: 'Message',\n            fieldName: 'Message',\n            type: 'text',\n            wrapText: true,\n            customLabel: 'Message'\n        }\n    ];\n\nlet executionError;\n\nasync function execute() {\n    try {\n        console.log('process.env:::', process.env);\n        console.log('process.env:::', JSON.stringify(process.env));\n        await this.createWorkingDirectory(TARGET_DIRECTORY);\n        this.logger('START Creating environment branches');\n        await this.validateBranches(childBranch, parentBranch);\n        await this.createWorkingDirectory(TARGET_DIRECTORY + '/environmentBranch');\n        await this.fetchGitBranch(parentBranch);\n        this.changeWorkingDirectory(TARGET_DIRECTORY + '/environmentBranch');\n        await this.configureGit(gitUser, gitEmail);\n        await this.createEnvironmentBranch(childBranch, parentBranch);\n        await this.pushEnvironmentBranch(childBranch);\n        \n        this.logger('END Creating environment branches');\n    } catch (err) {\n        this.log(`Error: ${err.stack}`);\n        if (!(err instanceof CommandExecutionError)) {\n            this.populateResultViewer(RESULT_INFO.LEVEL.ERROR, RESULT_INFO.CATEGORY.UNKNOWN_EXCEPTION, 'See logs for more info', err.message);\n        }\n        executionError = err.message || err?.toString() || 'Unknown Error occurred';\n    } finally {\n        if (resultViewerJson?.length) {\n            this.uploadResultViewerJson(resultViewerJson, RESULT_TABLE_COLUMNS, RESULT_TABLE_HEADER, HEADER_ICON);\n        }\n        if (executionError) {\n            await this.executeCommand(this.getErrorCommand(executionError));\n            process.exit(1);\n        }\n    }\n}\n\n\nasync function fetchGitBranch(branch) {\n    this.logger(`START Fetching ${branch}`);\n\n    const cmd = `cd ${TARGET_DIRECTORY}\n        copado-git-get ${branch}`;\n\n    await this.executeCommand(cmd, RESULT_INFO.CATEGORY.COPADO_SERVICE, RESULT_INFO.ADDITIONAL_INFORMATION.COPADO_GIT_GET);\n    this.logger(`END Fetching ${branch}`);\n}\n\nfunction getRemoteBranches(parentBranch) {\n    const response = child_process.execSync(`copado-git-get --remote \"${parentBranch}\"`, { encoding: 'utf-8' });\n    return response?.trim().split(', ');\n}\n\nasync function validateBranches(environmentBranch, parentBranch) {\n\n    if (parentBranch === null || environmentBranch === null) {\n        throw new Error('Error creating environment branch: ' + environmentBranch);\n    }\n\n    await this.validateBranchName([parentBranch, environmentBranch]);\n\n\n    const remoteBranches = this.getRemoteBranches(parentBranch);\n    if (!remoteBranches.includes(parentBranch)) {\n        throw new Error(`Error creating environment branch: ${parentBranch} does not exist!`);\n    }\n\n    if (remoteBranches.includes(environmentBranch)) {\n        throw new Error(`Error creating environment branch: ${environmentBranch} already exists!`);\n    }\n}\n\nasync function configureGit(gitEmail, gitUser) {\n    const gitConfig = `\n    git config --local user.email \"${gitEmail}\" || exit 1\n    git config --local user.name \"${gitUser}\" || exit 1\n    git config --global diff.renames false || exit 1\n    git config --global merge.renames false || exit 1\n    git config --global status.renames false || exit 1\n    `;\n    await this.executeCommand(gitConfig, RESULT_INFO.CATEGORY.GIT, RESULT_INFO.ADDITIONAL_INFORMATION.GIT_CONFIG);\n}\n\nasync function validateBranchName(branches) {\n\n    for(const branch of branches) {\n        const checkReferenceFormatCommand = `git check-ref-format --branch \"${branch}\" || exit 1`;\n        await this.executeCommand(checkReferenceFormatCommand, RESULT_INFO.CATEGORY.GIT, RESULT_INFO.ADDITIONAL_INFORMATION.GIT_BRANCH_NAME);\n    }\n}\n\nasync function createWorkingDirectory(dir) {\n    await this.executeCommand(`mkdir -p ${dir}`, RESULT_INFO.CATEGORY.FILE_SYSTEM, RESULT_INFO.ADDITIONAL_INFORMATION.SETUP_DIRECTORY);\n}\n\nasync function createEnvironmentBranch(environmentBranch, parentBranch) {\n    this.log(`Creating branch ${environmentBranch} from ${parentBranch}`);\n    if (parentBranch) {\n        this.asyncCopadoLogMessage(`\"Creating branch ${environmentBranch} from ${parentBranch}\"`);\n        await this.executeCommand(\n            `git checkout -b ${environmentBranch} ${parentBranch}`,\n            RESULT_INFO.CATEGORY.GIT,\n            RESULT_INFO.ADDITIONAL_INFORMATION.GIT_CHECKOUT\n        );\n    } else {\n        throw new Error('No environment branch provided');\n    }\n}\n\nasync function pushEnvironmentBranch(branchName) {\n\n    this.asyncCopadoLogMessage(`Pushing environment branch ${branchName}`);\n    const gitPush = `git push origin ${branchName}`;\n    await this.executeCommand(gitPush, RESULT_INFO.CATEGORY.GIT, RESULT_INFO.ADDITIONAL_INFORMATION.GIT_PUSH);\n}\n\nasync function executeCommand(command, category, additionalInfo, hasJsonResponse, disableLog) {\n    this.logger(`==> ${command}`);\n    return new Promise((resolve, reject) => {\n        let output = '',\n            error = '';\n\n        const childProcess = child_process.spawn(command, [], { shell: true });\n\n        childProcess.stdout.on('data', (data) => {\n           const outputStream = data?.toString();\n\t\t\tif(!disableLog) {\n\t\t\t\tthis.logger(outputStream);\n\t\t\t}\n\t\t\toutput += outputStream;\n        });\n\n        childProcess.stderr.on('data', (data) => {\n            const errorStream = data?.toString();\n\t\t\tthis.logger(errorStream);\n            error += data?.toString();\n        });\n\n        childProcess.on('close', (code) => {\n            if (code !== 0) {\n            \t\n                this.logger(`Code: ${code}`);\n                let errorMessage = '';\n\n                if (hasJsonResponse) {\n                    try {\n                        resolve(JSON.parse(output));\n                    } catch (error) {\n                        errorMessage = error;\n                    }\n                } else {\n                    errorMessage = error;\n                }\n\n                errorMessage = errorMessage ? errorMessage : `Error executing the command ${command}`;\n\n                this.populateResultViewer(RESULT_INFO.LEVEL.ERROR, category, additionalInfo, errorMessage);\n\n                const truncatedError = JSON.stringify(\n                    errorMessage.split('\\n').filter((msg) => !msg.includes(COPADO_INFO_PREFIX)).join(' ')\n                );\n                reject( new CommandExecutionError(truncatedError, category, additionalInfo));\n            }\n\n            resolve(hasJsonResponse ? JSON.parse(output) : output);\n        });\n\n        childProcess.on('error', (error) => {\n            this.populateResultViewer(RESULT_INFO.LEVEL.ERROR, category, additionalInfo, error);\n\n            const truncatedError = JSON.stringify(error.split('\\n').filter((msg) => !msg.includes(COPADO_INFO_PREFIX)).join(' '));\n            reject(new CommandExecutionError(truncatedError, category, additionalInfo));\n        });\n    });\n}\n\nfunction getPath(filePath) {\n    return isTest ? `${__dirname}/__tests__/__mockDir__${filePath}` : filePath;\n}\n\nfunction logger(message) {\n    console.log(message);\n}\n\nfunction log(response, disableLogs) {\n    const outputStream = response?.stdout?.toString().trim();\n    const errorStream = response?.stderr?.toString().trim();\n    if (!disableLogs) {\n        if (outputStream) {\n            console.log(outputStream);\n        }\n        if (errorStream) {\n            console.log(errorStream);\n        }\n    }\n    return { outputStream, errorStream };\n}\n\nfunction changeWorkingDirectory(dir) {\n    process.chdir(dir);\n}\n\nfunction populateResultViewer(level, category, additionalInfo, message) {\n    if (message) {\n        resultViewerJson.push({\n            Level: level,\n            Category: category,\n            AdditionalInformation: additionalInfo,\n            Message: message\n        });\n    }\n}\n\nfunction uploadResultViewerJson(data, columns, header, headerIcon) {\n    const RESULT_VIEWER_JSON_PATH = `${TEMP_DIRECTORY}/ResultViewer.json`;\n\n    const fileContent = { data, columns, header, headerIcon };\n    fs.writeFileSync(RESULT_VIEWER_JSON_PATH, JSON.stringify(fileContent, null, 2));\n    this.uploadFileAtPath(RESULT_VIEWER_JSON_PATH);\n}\n\nfunction uploadFileAtPath(filePath) {\n    new Promise((resolve, reject) => {\n        child_process.exec(`copado --uploadfile ${filePath}`, {}, err => {\n            if (err) {\n                this.populateResultViewer(\n                    RESULT_INFO.LEVEL.ERROR,\n                    RESULT_INFO.CATEGORY.COPADO_SERVICE,\n                    RESULT_INFO.ADDITIONAL_INFORMATION.UPLOAD_FILES,\n                    err\n                );\n                reject(new CommandExecutionError(err, RESULT_INFO.CATEGORY.COPADO_SERVICE, RESULT_INFO.ADDITIONAL_INFORMATION.UPLOAD_FILES));\n            } else {\n                resolve();\n            }\n        });\n    });\n}\nfunction asyncCopadoLogMessage(msg, logLevel) {\n    if (msg) {\n        this.populateResultViewer(logLevel ? logLevel : RESULT_INFO.LEVEL.INFO, RESULT_INFO.CATEGORY.COPADO_INFO, '', msg);\n        new Promise(resolve => {\n            child_process.exec(`copado -p \"${msg}\"`, { stdio: STDIO.INHERIT }, () => {\n                resolve();\n            });\n        });\n    }\n}\n\nfunction getErrorCommand(error) {\n    const suffix = 'Please check the logs for details.';\n    return `{ copado -p 'Error' -e '${error}. ${suffix}'; exit 2; }`;\n}\n\nclass CommandExecutionError extends Error {\n    constructor(message, category, additionalInfo) {\n        super(`${category ? category + ' - ' : ''}${additionalInfo ? additionalInfo + ' : ' : ''}${message}`);\n        this.name = CUSTOM_ERROR.COMMAND_EXECUTION_ERROR;\n    }\n}\n\n\nmodule.exports.executeCommand = executeCommand;\nmodule.exports.createEnvironmentBranch = createEnvironmentBranch;\nmodule.exports.execute = execute;\nmodule.exports.log = log;\nmodule.exports.changeWorkingDirectory = changeWorkingDirectory;\nmodule.exports.pushEnvironmentBranch = pushEnvironmentBranch;\nmodule.exports.uploadFileAtPath = uploadFileAtPath;\nmodule.exports.uploadResultViewerJson = uploadResultViewerJson;\nmodule.exports.populateResultViewer = populateResultViewer;\nmodule.exports.fetchGitBranch = fetchGitBranch;\nmodule.exports.createWorkingDirectory = createWorkingDirectory;\nmodule.exports.configureGit = configureGit;\nmodule.exports.getErrorCommand = getErrorCommand;\nmodule.exports.logger = logger;\nmodule.exports.getRemoteBranches = getRemoteBranches;\nmodule.exports.validateBranches = validateBranches;\nmodule.exports.asyncCopadoLogMessage = asyncCopadoLogMessage;\nmodule.exports.validateBranchName = validateBranchName;\n\n!isTest && this.execute();",
                    "copado__Type__c": "Standard",
                    "copado__Worker_Size__c": "M",
                    "Id": "a0oJ6000000Tag7IAC",
                    "LastReferencedDate": "2025-06-19T05:53:40.000+0000",
                    "LastViewedDate": "2025-06-19T05:53:40.000+0000",
                    "Name": "[Migration] - Create Git Branch"
                }
            ],
            "ObjectType": "copado__Function__c"
        }
    ],
    "blobsByUID": {}
}