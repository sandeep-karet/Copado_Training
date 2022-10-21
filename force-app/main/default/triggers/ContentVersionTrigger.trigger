trigger ContentVersionTrigger on ContentVersion (before update) {

      public static final String DEFAULT_CONTENT_NOTE_TITLE = System.Label.Default_Content_Note_Type;
      public static final String DEFAULT_CONTENT_NOTE_ERROR_MSG = System.Label.Content_Note_Error_Message;
    
   	 for(ContentVersion conVer:Trigger.new){
         if(conVer.title !=DEFAULT_CONTENT_NOTE_TITLE && trigger.oldmap.get(conVer.Id).title==DEFAULT_CONTENT_NOTE_TITLE){
             conVer.addError(DEFAULT_CONTENT_NOTE_ERROR_MSG);
         }
    	}       
}