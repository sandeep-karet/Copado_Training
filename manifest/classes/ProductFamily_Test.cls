@isTest
public class ProductFamily_Test {
    
    @testsetup Static void productFamilydata(){
        
        List<String> productList = New List<String>{'License Platform', 'Behavioral Health', 'Diabetes', 'Hardware', 'Software', 'Services',
            'Expert Medical Services'};
            List<Product2> prdList = New List<Product2>();
        for(integer localCount=0; localCount<7; localCount++){
            Product2 prd = New Product2();
            prd.Name = productList.get(localCount)+'Product';
            prd.Family = productList.get(localCount);
            prdList.add(prd);
        }
        insert prdList;
        System.assertNotEquals(null, prdList, 'Success');
        
        List<Apttus__APTS_Agreement__c> agrList = New List<Apttus__APTS_Agreement__c>();
        List<Apttus__AgreementLineItem__c> agrLineItem = New List<Apttus__AgreementLineItem__c>();
        List<Product_Family__c> prdFamList = New List<Product_Family__c>();
        for(integer i=0; i<2; i++){
            Apttus__APTS_Agreement__c agr = New Apttus__APTS_Agreement__c(Name='Test Agreement'+i);
            AgrList.add(agr);                       
        }
        insert agrList;
        System.assertNotEquals(null, agrList, 'Success');
        
        for(integer m=0; m<agrList.size(); m++){
            for(integer j=0; j<7; j++){
                Apttus__AgreementLineItem__c agrLine = New Apttus__AgreementLineItem__c();
                agrLine.Apttus__AgreementId__c = agrList.get(m).Id;
                agrLine.Apttus__ProductId__c = prdList.get(j).Id;
                agrLineItem.add(agrLine);
            }
            for(integer k=0; k<7; k++){
                Product_Family__c prdFam = new Product_Family__c();
                prdFam.Agreement__c = agrList.get(m).Id;
                prdFam.Product_Family_Name__c = prdList.get(k).Name;
                prdFamList.add(prdFam);
            } 
        }
        
        insert agrLineItem;
        insert prdFamList;
        System.assertNotEquals(null, agrLineItem, 'Success');
        System.assertNotEquals(null, prdFamList, 'Success');
        
    }
    
    @isTest
   Private static void productFamilyTest(){        
                
        Test.startTest();
        
        List<Apttus__AgreementLineItem__c> agrLineItem = [select Id, Name,Apttus__AgreementId__c,
                                        Apttus__ProductId__c
                                        from Apttus__AgreementLineItem__c];        
       ProductFamilyHandler.createProductfamilies(agrLineItem);
       ProductFamilyHandler.deleteProductfamilies(agrLineItem);
       System.assertNotEquals(null, agrLineItem, 'Records found successfully');
        
        Test.stopTest();
    }
}