public class Eds2MwProcs {
  public static Boolean CreateTasTasks(Set<String> group_guids, Id case_id) {
    System.Debug('Groups guids[' + group_guids.size() + ']: ' + group_guids);
    RecordType flow_rt = [
      SELECT id, developername
      FROM recordtype
      WHERE sobjecttype = 'Task' AND developername = 'Flow'
    ];
    List<Case> target_case = [SELECT id FROM Case WHERE id = :case_id];
    List<Task> existing_tasks = [
      SELECT id, subject, WhatId, group_guid__c
      FROM Task
      WHERE group_guid__c IN :group_guids
    ];
    System.Debug('Existing tasks: ' + existing_tasks.size());
    Map<String, Task> existing_task_map = new Map<String, Task>();

    Map<String, Mbr_Group__c> mapped_groups = new Map<String, Mbr_Group__c>();
    List<Mbr_Group__c> scoped_groups = [
      SELECT id, name__c, guid__c, hlp_benefit_sponsors__c, hlp_payers__c
      FROM mbr_group__c
      WHERE guid__c IN :group_guids
    ];
    System.debug('Member groups found: ' + scoped_groups.size());
    for (mbr_group__c tmpMg : scoped_groups) {
      mapped_groups.put(tmpMg.guid__c, tmpMg);
    }
    // Map existing tasks so we do not overwrite previous work that has not completed
    for (Task temp_task : existing_tasks) {
      // Look at existing group and flag for bad data BEFORE it leaves us.
      Mbr_Group__c temp_mg = mapped_groups.get(temp_task.Group_GUID__c);
      if (temp_mg.hlp_Benefit_Sponsors__c > 1 || temp_mg.hlp_Payers__c > 1) {
        temp_task.Flow_Response__c = 422;
        temp_task.Description = 'This group has multiple Payers/Benefit Sponsors and cannot be processed through FLOW.';
      } else
        temp_task.Flow_Response__c = 0; // Reset response so it can be resubmitted.

      temp_task.Status = 'Open';
      existing_task_map.put(temp_task.Group_guid__c, temp_task);
    }

    // In theory it should not be possible to submit the same guid twice in same context.
    // But just in case we will use a set to prevent duplicates.

    // Add new guids to pre-existing list
    Map<String, Task> outgoing_guids = new Map<String, Task>();
    for (String temp_guid : group_guids) {
      if (!existing_task_map.containsKey(temp_guid)) {
        Task new_task = new Task(
          WhatId = case_id,
          subject = mapped_groups.get(temp_guid).Name__c,
          group_guid__c = temp_guid,
          RecordTypeId = flow_rt.Id,
          Flow_Response__c = 0
        );

        // Look at existing group and flag for bad data BEFORE it leaves us.
        Mbr_Group__c temp_mg = mapped_groups.get(temp_guid);
        if (temp_mg.hlp_Benefit_Sponsors__c > 1 || temp_mg.hlp_Payers__c > 1) {
          new_task.Flow_Response__c = 422;
          new_task.Description = 'This group has multiple Payers/Benefit Sponsors and cannot be processed through FLOW.';
        }
        outgoing_guids.put(temp_guid, new_task);
      }
    }

    // Remap existing tasks to new case
    for (Task temp_task : existing_task_map.values()) {
      temp_task.WhatId = case_id;
    }
    if (existing_tasks.size() > 0) {
      Database.update(existing_task_map.values());
    }
    if (outgoing_guids.size() > 0) {
      Database.insert(outgoing_guids.values());
    }

    if (existing_tasks.size() == 0 && outgoing_guids.size() == 0)
      return false;
    else
      return true;
  }
}