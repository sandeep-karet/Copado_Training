global class SfmcLogoSch implements Schedulable {
  global void execute(SchedulableContext SC) {
    SFMC_LogoUploadBatch sfbatch = new SFMC_LogoUploadBatch();
    database.executebatch(sfbatch, 1);
  }
}