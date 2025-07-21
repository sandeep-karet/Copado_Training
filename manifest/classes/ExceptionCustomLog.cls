public class ExceptionCustomLog {
  public static Map<String, List<logWrapper>> exceptionsFound { get; set; }
  public static final String oiProcessor = 'orderItemV3';

  public static void captureCustomException(
    String MUID,
    String Module,
    String Method,
    String Processor,
    String Process,
    String SourceId,
    String errMsg,
    String errDetail
  ) {
    if (exceptionsFound == null) {
      exceptionsFound = new Map<String, List<logWrapper>>();
    }
    logWrapper lw = new logWrapper();
    lw.MUID = MUID;
    lw.MODULE = Module;
    lw.METHOD = Method;
    lw.SOURCEID = SourceId;
    lw.PROCESSOR = Processor;
    lw.PROCESS = Process;
    lw.EXPMSG = errMsg;
    lw.STACKTRACE = errDetail;

    if (exceptionsFound.containsKey(MUID)) {
      exceptionsFound.get(MUID).add(lw);
    } else {
      exceptionsFound.put(MUID, new List<logWrapper>{ lw });
    }
  }
  
  public static void captureCustomExceptionV4(
    String RecordId,
    String Module,
    String Method,
    String Processor,
    String Process,
    String SourceId,
    String errMsg,
    String errDetail
  ) {
    if (exceptionsFound == null) {
      exceptionsFound = new Map<String, List<logWrapper>>();
    }
    logWrapper lw = new logWrapper();
    lw.RECORDID = RecordId;
    lw.MODULE = Module;
    lw.METHOD = Method;
    lw.SOURCEID = SourceId;
    lw.PROCESSOR = Processor;
    lw.PROCESS = Process;
    lw.EXPMSG = errMsg;
    lw.STACKTRACE = errDetail;

    if (exceptionsFound.containsKey(RecordId)) {
      exceptionsFound.get(RecordId).add(lw);
    } else {
      exceptionsFound.put(RecordId, new List<logWrapper>{ lw });
    }
  }
    
  public static void captureException(
    String MUID,
    String Module,
    String Method,
    String Processor,
    String Process,
    String SourceId,
    Exception ex
  ) {
    if (exceptionsFound == null) {
      exceptionsFound = new Map<String, List<logWrapper>>();
    }
    logWrapper lw = new logWrapper();
    lw.MUID = MUID;
    lw.SOURCEID = SourceId;
    lw.MODULE = Module;
    lw.METHOD = Method;
    lw.PROCESSOR = Processor;
    lw.PROCESS = Process;
    lw.EXPMSG = ex.getTypeName() + ' : ' + ex.getMessage();
    lw.STACKTRACE = ex.getStackTraceString();

    if (exceptionsFound.containsKey(MUID)) {
      exceptionsFound.get(MUID).add(lw);
    } else {
      exceptionsFound.put(MUID, new List<logWrapper>{ lw });
    }
  }

  public static void saveResultsToG2LItemLog() {
    try {
      if (exceptionsFound != null && exceptionsFound.size() > 0) {
        List<G2LItemLog__c> lstLogs = new List<G2LItemLog__c>();
        List<G2LCRM_Item__c> lstItems = [
          SELECT Id, Name, MUID__c, Processor__c, Body__c
          FROM G2LCRM_Item__c
          WHERE MUID__c = :exceptionsFound.keySet() OR Id = :exceptionsFound.KeySet()
        ];
        for (G2LCRM_Item__c g2Item : lstItems) {
          for (String key : exceptionsFound.keySet()) {
            String expMSG = '';
            List<logWrapper> logs = exceptionsFound.get(key);
            for (Integer i = (logs.size() - 1); i >= 0; i--) {
              logWrapper log = logs[i];
              expMSG =
                log.EXPMSG +
                ' (' +
                log.PROCESS +
                ')\n ' +
                log.STACKTRACE +
                ' \n \n ';
              if (log.MODULE == '' || log.METHOD == '') {
              } else {
                if (
                  (g2Item.MUID__c == key || g2Item.Id == key) &&
                  g2Item.Processor__c == log.PROCESSOR &&
                  log.PROCESSOR == oiProcessor &&
                  log.SOURCEID != null &&
                  g2Item.Body__c.contains(log.SOURCEID)
                ) {
                  lstLogs.add(
                    new G2LItemLog__c(
                      MUID__c = g2Item.MUID__c,
                      ErrorType__c = 'ERROR',
                      Module__c = log.MODULE,
                      Method__c = log.METHOD,
                      Parsing_Results__c = expMSG,
                      DebugData__c = log.PROCESS,
                      G2LCRM_Item__c = g2Item.Id
                    )
                  );
                  logs.remove(i);
                  //exceptionsFound.get(key).remove(i);
                } else if (
                  (g2Item.MUID__c == key || g2Item.Id == key)&&
                  g2Item.Processor__c == log.PROCESSOR &&
                  log.PROCESSOR == oiProcessor &&
                  log.SOURCEID == null
                ) {
                  lstLogs.add(
                    new G2LItemLog__c(
                      MUID__c = g2Item.MUID__c,
                      ErrorType__c = 'ERROR',
                      Module__c = log.MODULE,
                      Method__c = log.METHOD,
                      Parsing_Results__c = expMSG,
                      DebugData__c = log.PROCESS,
                      G2LCRM_Item__c = g2Item.Id
                    )
                  );
                  logs.remove(i);
                  //exceptionsFound.get(key).remove(i);
                } else if (
                  (g2Item.MUID__c == key || g2Item.Id == key) &&
                  g2Item.Processor__c == log.PROCESSOR &&
                  log.PROCESSOR != oiProcessor
                ) {
                  lstLogs.add(
                    new G2LItemLog__c(
                      MUID__c = g2Item.MUID__c,
                      ErrorType__c = 'ERROR',
                      Module__c = log.MODULE,
                      Method__c = log.METHOD,
                      Parsing_Results__c = expMSG,
                      DebugData__c = log.PROCESS,
                      G2LCRM_Item__c = g2Item.Id
                    )
                  );
                  logs.remove(i);
                  //exceptionsFound.get(key).remove(i);
                } else if ((g2Item.MUID__c == key || g2Item.Id == key) && log.PROCESSOR == '') {
                  //lstLogs.add(new G2LItemLog__c(MUID__c = key, ErrorType__c = 'ERROR', Module__c = log.MODULE, Method__c = log.METHOD, Parsing_Results__c = expMSG, G2LCRM_Item__c = g2Item.Id));
                  //logs.remove(i);
                  //exceptionsFound.get(key).remove(i);
                }
              }
            }
            if (logs != null && logs.size() > 0) {
            } else {
              exceptionsFound.remove(key);
            }
          }
        }
        if (exceptionsFound != null && exceptionsFound.size() > 0) {
          for (G2LCRM_Item__c g2Item : lstItems) {
            for (String key : exceptionsFound.keySet()) {
              List<logWrapper> logs = exceptionsFound.get(key);
              for (logWrapper log : logs) {
                String expMSG = log.EXPMSG + '\n ' + log.STACKTRACE + ' \n \n ';

                if (
                  log.MODULE != '' &&
                  log.METHOD != '' &&
                  g2Item.MUID__c == key
                ) {
                  lstLogs.add(
                    new G2LItemLog__c(
                      MUID__c = g2Item.MUID__c,
                      ErrorType__c = 'ERROR',
                      Module__c = log.MODULE,
                      Method__c = log.METHOD,
                      Parsing_Results__c = expMSG,
                      DebugData__c = log.PROCESS,
                      G2LCRM_Item__c = g2Item.Id
                    )
                  );
                }
              }
            }
          }
        }
        Database.insert(lstLogs);
      }
    } catch (Exception ex) {
      system.debug('Error at G2LItemLog__c record save: ' + ex.getMessage());
    }
  }

  public class logWrapper {
    public String MUID { get; set; }
    public String RECORDID { get; set; }
    public String SOURCEID { get; set; }
    public String MODULE { get; set; }
    public String METHOD { get; set; }
    public String PROCESSOR { get; set; }
    public String PROCESS { get; set; }
    public String EXPMSG { get; set; }
    public String STACKTRACE { get; set; }
  }
}