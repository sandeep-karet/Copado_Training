trigger RHX_copado_Static_Code_Analysis_Result on copado__Static_Code_Analysis_Result__c
    (after delete, after insert, after undelete, after update, before delete) {
  	 Type rollClass = System.Type.forName('rh2', 'ParentUtil');
	 if(rollClass != null) {
		rh2.ParentUtil pu = (rh2.ParentUtil) rollClass.newInstance();
		if (trigger.isAfter) {
			pu.performTriggerRollups(trigger.oldMap, trigger.newMap, new String[]{'copado__Static_Code_Analysis_Result__c'}, null);
    	}
    }
}