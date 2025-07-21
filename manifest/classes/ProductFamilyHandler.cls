/*************************************************************************     
* @description This class is used for the product family object
* @param NA
* @Author InfoSys Developer
**************************************************************************/
public with sharing class ProductFamilyHandler{
    
    Public static final String SERVICES = System.Label.Services;
    Public static final String HARDWARE = System.Label.Hardware;
    Public static final String SOFTWARE = System.Label.Software;
    Public static final String LICENSEPLATFORM = System.Label.License_Platform;
    Public static final String EXPERTMEDICAL = System.Label.Expert_Medical_Services;
    Public static final String CHRONICCARE = System.Label.Chronic_Care_Services;
    Public static final String VIRTUALCARE = System.Label.Virtual_Care_Services;
    
    Public static final String[] VIRTUALCARELIST = New String[] {System.Label.General_Medical,System.Label.Behavioral_Health,System.Label.Virtual_Primary_Care,
        System.Label.Nutrition,System.Label.Sexual_Health,System.Label.Musculoskelatal,System.Label.Tobacco_Cessation,System.Label.Global_Care,
        System.Label.Dermatology};
        
        Public static final String[] CHRONICCARELIST = New String[] {System.Label.Livongo_Hypertension,System.Label.Livongo_CKD_Aware,System.Label.Livongo_Heart_Failure,
            System.Label.Livongo_Weight_Management,System.Label.Livongo_Chronic_Kidney_Disease,System.Label.Livongo_Diabetes_Prevention,
            System.Label.Diabetes,System.Label.Heart_Failure,System.Label.Livongo,System.Label.Livongo_Solution_Bundle,
            System.Label.Livongo_Behavioral_Health,System.Label.Hypertension,System.Label.Prediabetes,System.Label.Livongo_Prediabetes,
            System.Label.Livongo_Diabetes};
                
                Public static final String[] LICENSEPLATFORMS = New String[] {System.Label.Provider,System.Label.License_Platform};                                       

    
    
                    /*************************************************************************
                     * @description This method checks the Trigger event and executes the respective Method
                     * @Author InfoSys Developer
                    **************************************************************************/
                    Public static void executeTrigger(){
                        if(Trigger.isInsert){
                            ProductFamilyHandler.createProductfamilies(Trigger.New);                                                        
                        }
                        if(Trigger.isDelete){
                            ProductFamilyHandler.deleteProductfamilies(Trigger.New);                                                        
                        }                        
                    }
    
    /*************************************************************************
     * @description This method used to create the product family records
     * @param agrLineitems is a list of Agreement line items
     * @Author InfoSys Developer
	**************************************************************************/
    @SuppressWarnings('PMD.AvoidDebugStatements, PMD.CyclomaticComplexity, PMD.NcssMethodCount')    
    Public static Void createProductfamilies(List<Apttus__AgreementLineItem__c> agrLineitems){
        //this method only has 64 NCSS lines
        Map<Id,List<Apttus__AgreementLineItem__c>> agrMap = New Map<Id,List<Apttus__AgreementLineItem__c>>();
        List<Apttus__AgreementLineItem__c> agrLinelist = new List<Apttus__AgreementLineItem__c>();
        for(Apttus__AgreementLineItem__c agrLine : agrLineitems){
            if(!agrMap.containsKey(agrLine.Apttus__AgreementId__c)){
                agrMap.put( agrLine.Apttus__AgreementId__c,new List<Apttus__AgreementLineItem__c>{agrLine});                
            }
            else{
                agrLinelist = agrMap.get(agrLine.Apttus__AgreementId__c);
                agrLinelist.add(agrLine);
                agrMap.put(agrLine.Apttus__AgreementId__c,agrLinelist);
            }
        }
        
        //Getting respective Product Families
        List<Product_Family__c> prdFamilies = [Select Id, Agreement__c, Product_Family_Name__c from Product_Family__c
                                               where Agreement__c IN: agrMap.keySet()];
        //Getting respective Products//
        List<Product2> prodList = [Select Id, Family from Product2 where Id IN (select Apttus__ProductId__c from 
                                                                                Apttus__AgreementLineItem__c where 
                                                                                Id IN: agrLineitems)];
        
        List<Product_Family__c> newPrdlist = new List<Product_Family__c>();
        List<String> prdList = New List<String>();//Storing the existing Product Family names// 
        for(Id agrmt : agrMap.keySet()){         
            prdList.clear(); //Clearing the List to reset the values for each Agreement to avoid recursion//
            For(Product_Family__c prdt : prdFamilies){
                if(prdt.Agreement__c == agrmt){   
                    prdList.add(prdt.Product_Family_Name__c);                    
                }                                    
            }

            String prd;
            for(Apttus__AgreementLineItem__c agl : agrMap.get(agrmt)){
                for(Product2 prod : prodList){
                    if(prod.Id == agl.Apttus__ProductId__c){ //Storing the Family field from Product//
                        prd = prod.Family;  
                    }
                }

                if((LICENSEPLATFORMS.contains(prd))&&(!prdList.contains(LICENSEPLATFORM))){
                    prdList.add(LICENSEPLATFORM);
                    Product_Family__c prdFamily = new Product_Family__c();
                    prdFamily.Agreement__c = agl.Apttus__AgreementId__c;
                    prdFamily.Product_Family_Name__c = LICENSEPLATFORM;
                    newPrdlist.add(prdFamily);
                }
                else if((CHRONICCARELIST.contains(prd))&&(!prdList.contains(CHRONICCARE))){
                    prdList.add(CHRONICCARE);
                    Product_Family__c prdFamily = new Product_Family__c();
                    prdFamily.Agreement__c = agl.Apttus__AgreementId__c;
                    prdFamily.Product_Family_Name__c = CHRONICCARE;
                    newPrdlist.add(prdFamily);
                }
                else if((VIRTUALCARELIST.contains(prd))&&(!prdList.contains(VIRTUALCARE))){
                    prdList.add(VIRTUALCARE);
                    Product_Family__c prdFamily = new Product_Family__c();
                    prdFamily.Agreement__c = agl.Apttus__AgreementId__c;
                    prdFamily.Product_Family_Name__c = VIRTUALCARE;
                    newPrdlist.add(prdFamily);
                }
                else if((prd == SERVICES)&&(!prdList.contains(SERVICES))){
                    prdList.add(SERVICES);
                    Product_Family__c prdFamily = new Product_Family__c();
                    prdFamily.Agreement__c = agl.Apttus__AgreementId__c;
                    prdFamily.Product_Family_Name__c = SERVICES;
                    newPrdlist.add(prdFamily);
                }
                else if((prd == HARDWARE)&&(!prdList.contains(HARDWARE))){
                    prdList.add(HARDWARE);
                    Product_Family__c prdFamily = new Product_Family__c();
                    prdFamily.Agreement__c = agl.Apttus__AgreementId__c;
                    prdFamily.Product_Family_Name__c = HARDWARE;
                    newPrdlist.add(prdFamily);
                }
                else if((prd == SOFTWARE)&&(!prdList.contains(SOFTWARE))){
                    prdList.add(SOFTWARE);
                    Product_Family__c prdFamily = new Product_Family__c();
                    prdFamily.Agreement__c = agl.Apttus__AgreementId__c;
                    prdFamily.Product_Family_Name__c = SOFTWARE;
                    newPrdlist.add(prdFamily);
                }
                else if((prd == EXPERTMEDICAL)&&(!prdList.contains(EXPERTMEDICAL))){
                    prdList.add(EXPERTMEDICAL);
                    Product_Family__c prdFamily = new Product_Family__c();
                    prdFamily.Agreement__c = agl.Apttus__AgreementId__c;
                    prdFamily.Product_Family_Name__c = EXPERTMEDICAL;
                    newPrdlist.add(prdFamily);
                }
            }
        }
        try{
            if(!newPrdlist.isEmpty()){
                insert newPrdlist; 
            }
        }catch(DmlException e){
            System.debug(LoggingLevel.ERROR, e.getMessage()); 
        }
    }
/*************************************************************************     
* @description This method is used to remove the Product family records
* @param agrLineitems is a list of Agreement line items
* @Author InfoSys Developer
**************************************************************************/
    @SuppressWarnings('PMD.AvoidDebugStatements, PMD.NcssMethodCount')
    Public static Void deleteProductfamilies(List<Apttus__AgreementLineItem__c> agrLineitems){
        //this method only has 62 NCSS lines
        Map<Id,List<Apttus__AgreementLineItem__c>> agrMap = New Map<Id,List<Apttus__AgreementLineItem__c>>();
        List<Apttus__AgreementLineItem__c> agrLinelist = new List<Apttus__AgreementLineItem__c>();
        for(Apttus__AgreementLineItem__c agrLine : agrLineitems){
            if(!agrMap.containsKey(agrLine.Apttus__AgreementId__c)){
                agrMap.put(agrLine.Apttus__AgreementId__c,new List<Apttus__AgreementLineItem__c>{agrLine});                
            }
            else{
                agrLinelist = agrMap.get(agrLine.Apttus__AgreementId__c);
                agrLinelist.add(agrLine);
                agrMap.put(agrLine.Apttus__AgreementId__c,agrLinelist);
            }
        }
        
        List<Product_Family__c> prdFamilies = [Select Id, Agreement__c, Product_Family_Name__c from Product_Family__c
                                               where Agreement__c IN: agrMap.keySet()];
        
        Map<Id,List<Product_Family__c>> agrPrdMap = New Map<Id,List<Product_Family__c>>();
        List<Product_Family__c> prdFamilylist = new List<Product_Family__c>();
        for(Product_Family__c prdFamily : prdFamilies){
            if(!agrPrdMap.containsKey(prdFamily.Agreement__c)){
                agrPrdMap.put(prdFamily.Agreement__c,new List<Product_Family__c>{prdFamily});                
            }
            else{
                prdFamilylist = agrPrdMap.get(prdFamily.Agreement__c);
                prdFamilylist.add(prdFamily);
                agrPrdMap.put(prdFamily.Agreement__c,prdFamilylist);
            }
        }        
        
        //Getting respective Products//
        List<Product2> prodList = [Select Id, Family from Product2 where Id IN (select Apttus__ProductId__c from 
                                                                                Apttus__AgreementLineItem__c where 
                                                                                Id IN: agrLineitems)];
        List<String> newPrdlist = new List<String>();
        List<Product_Family__c> prdList = New List<Product_Family__c>();//Storing the existing Product Family names// 
        for(Id agrmt : agrMap.keySet()){          
            String prd;
            newPrdlist.clear();
            for(Apttus__AgreementLineItem__c agl : agrMap.get(agrmt)){
                for(Product2 prod : prodList){
                    if(prod.Id == agl.Apttus__ProductId__c){ //Storing the Family field from Product//
                        prd = prod.Family;  
                    }
                }
                if(LICENSEPLATFORMS.contains(prd)){
                    newPrdlist.add(LICENSEPLATFORM);
                }
                else if(CHRONICCARELIST.contains(prd)){
                    newPrdlist.add(CHRONICCARE);
                }
                else if(VIRTUALCARELIST.contains(prd)){
                    newPrdlist.add(VIRTUALCARE);
                }
                else if(prd == SERVICES){
                    newPrdlist.add(SERVICES);
                }
                else if(prd == HARDWARE){
                    newPrdlist.add(HARDWARE);
                }
                else if(prd == SOFTWARE){
                    newPrdlist.add(SOFTWARE);
                }
                else if(prd == EXPERTMEDICAL){
                    newPrdlist.add(EXPERTMEDICAL);
                }
            }            
            For(Product_Family__c prdt : agrPrdMap.get(agrmt)){
                if(!newPrdlist.contains(prdt.Product_Family_Name__c)){
                    prdList.add(prdt);                                        
                }                    
            }
            
        }
        try{
            if(!prdList.isEmpty()){
                delete prdList; 
            }
        }catch(DmlException e){
            System.debug(LoggingLevel.ERROR, e.getMessage());
        }
      
    }
}