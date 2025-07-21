global class OpportunityHSUpdateScheduler implements schedulable {
    global void execute(SchedulableContext sc)
    {
        OpportunityHSUpdateBatch b = new OpportunityHSUpdateBatch();
        database.executebatch(b, 200);
    }
}