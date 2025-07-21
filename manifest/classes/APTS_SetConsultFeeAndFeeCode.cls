/*************************************************************************     
* @description This class is used to rollup Consult Fees from 'Visit Fee' Products to related ParentProduct
* @param Newly created AgreementLineItems coming from Create Agrement Flow
* @Author InfoSys Developer
**************************************************************************/
public without sharing class APTS_SetConsultFeeAndFeeCode {
    
    /**
* @description This is and Invocable method called by 'Create Agreement' flow to rollup Consult Fees from Child Agreement Line items to Parent Agreement line item
* @param newlyaddedlineitems are newly created AgreementLineItems coming from 'Create Agreement' Flow
* @Author InfoSys Developer
**/
    @InvocableMethod (label = 'Update ConsultFees and FeeCode')
    public static void setconsultfeefeecode(List<List<Apttus__AgreementLineItem__c>> newlyaddedlineitems)
    {
        //NewlyCreated AgreementLineitems
        List<Apttus__AgreementLineItem__c> newlyCreatedlineitems=new List<Apttus__AgreementLineItem__c>();
        //NonParent AgreementLineitems not having any related parent lineitem
        List<Apttus__AgreementLineItem__c> childAgglineitems=new List<Apttus__AgreementLineItem__c>();
        //Final list for updating newly created agreement line items
        List<Apttus__AgreementLineItem__c> updatelist=new List<Apttus__AgreementLineItem__c>();
        //Agreement Id of newly created Agreement
        String agid;
        //String for storing feecode
        String feeCodestring;
        for(List<Apttus__AgreementLineItem__c> crrecs:newlyaddedlineitems)
        {
            for(Apttus__AgreementLineItem__c cr:crrecs)
            {
                newlyCreatedlineitems.add(cr);
            }
        }
        for(Apttus__AgreementLineItem__c cr:newlyCreatedlineitems)
        {
            
            agid=cr.Apttus__AgreementId__c;
        }
        for(Apttus__AgreementLineItem__c chagglineitems:[Select Id,APTS_Consult_Fee__c,APTS_Fee_Code__c,APTS_Required_By__c,APTS_Quote_Line__c from Apttus__AgreementLineItem__c where Apttus__AgreementId__c=:agid and APTS_Required_By__c!=null])
        {
           childAgglineitems.add(chagglineitems);
        }
        
        List<Apttus__AgreementLineItem__c> nonParentAggLineItems=[Select Id,APTS_Consult_Fee__c,APTS_Fee_Code__c,APTS_Required_By__c from Apttus__AgreementLineItem__c where Apttus__AgreementId__c=:agid and APTS_Required_By__c!=null];
        for(Apttus__AgreementLineItem__c pagli:newlyCreatedlineitems)
        {
            feeCodestring='abc';
            Apttus__AgreementLineItem__c paraggrec=new Apttus__AgreementLineItem__c();
            paraggrec.Id=pagli.Id;
            for(Apttus__AgreementLineItem__c cagli:nonParentAggLineItems)
            {
                if(cagli.APTS_Required_By__c==pagli.APTS_Quote_Line__c)
                {
                    if(!(feeCodestring.contains('FeeCode1')))
                    {
                        paraggrec.APTS_Fee_Code_1__c=cagli.APTS_Fee_Code__c;
                        feeCodestring='FeeCode1';
                        paraggrec.APTS_Consult_Fees_1__c=cagli.APTS_Consult_Fee__c; 
                        continue;
                        
                    }
                    if(!(feeCodestring.contains('FeeCode2')))
                    {
                        paraggrec.APTS_Fee_Code_2__c=cagli.APTS_Fee_Code__c;
                        feeCodestring+='FeeCode2';
                        paraggrec.APTS_Consult_Fees_2__c=cagli.APTS_Consult_Fee__c;
                        continue;
                    }
                    if(!(feeCodestring.contains('FeeCode3')))
                    {
                        paraggrec.APTS_Fee_Code_3__c=cagli.APTS_Fee_Code__c;
                        feeCodestring+='FeeCode3';
                        paraggrec.APTS_Consult_Fees_3__c=cagli.APTS_Consult_Fee__c;
                        continue;
                    }
                    
                }
                
            }
            updatelist.add(paraggrec);
           }
        APTS_SetConsultFeeAndFeeCode.updaterecords(updatelist);
        
    }
    /**
	* @description Updating AgreementLineItems
	* @param updatereclist agreementlineitem records
	* @Author InfoSys Developer
	**/
    @SuppressWarnings('PMD.AvoidDebugStatements')
    public static void updaterecords(List<Apttus__AgreementLineItem__c> updatereclist)
    {
        try
        {
            update updatereclist;
        }
        catch(exception e)
        {
            system.debug(LoggingLevel.ERROR,e.getMessage());
        }    
    }
}