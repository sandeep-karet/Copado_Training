public without sharing class ObjectInfo {
  private static Map<String, Map<String, String>> mappedObjInfo = new Map<String, Map<String, String>>();
  public static String TypeForField(String objectName, String fieldName) {
    String tmpObjName = objectName.toUpperCase();
    String tmpFldName = fieldName.toUpperCase();
    // Check if we already have a map for this object. If not make one
    fieldsForObject(objectName);
    Map<String, String> tmpMap = mappedObjInfo.get(tmpObjName);
    if (tmpMap.containsKey(tmpFldName))
      return tmpMap.get(tmpFldName);
    else
      return null;
  }

  public static Map<String, String> fieldsForObject(String objectName) {
    String tmpObjName = objectName.toUpperCase();
    // Check if we already have a map for this object. If not make one
    if (!mappedObjInfo.containsKey(tmpObjName)) {
      System.debug(
        LoggingLevel.FINEST,
        'OBJECT MAP NOT FOUND FOR: ' + tmpObjName
      );
      List<DescribeSObjectResult> dsor = Schema.describeSObjects(
        new List<String>{ tmpObjName }
      );
      for (DescribeSObjectResult tmpDsor : dsor) {
        Map<String, String> tmpMap = new Map<String, String>();
        Map<String, SObjectField> mappedSof = tmpDsor.fields.getMap();
        for (SObjectField tmpSof : mappedSof.values()) {
          DescribeFieldResult tmpDfr = tmpSof.getDescribe();
          tmpMap.put(tmpDfr.name.toUpperCase(), tmpDfr.soapType.name());
        }
        mappedObjInfo.put(tmpObjName, tmpMap);
      }
    }

    return mappedObjInfo.get(tmpObjName);
  }
}