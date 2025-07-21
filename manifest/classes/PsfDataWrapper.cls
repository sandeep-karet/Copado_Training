public class PsfDataWrapper {
    public String subProdCode {get; set;}
    public String AssetProdCode {get; set;}
    public String opportunityGUID {get; set;}
    public SBQQ__Subscription__c sub {get; set;}
    public Plan_Specific_Fees__c psf {get; set;}        
    public psfDataWrapper(String opportunityGUID,String subProdCode, String AssetProdCode, SBQQ__Subscription__c sub, Plan_Specific_Fees__c psf) {
        this.opportunityGUID = opportunityGUID;
        this.subProdCode = subProdCode;
        this.AssetProdCode = AssetProdCode;
        this.sub = sub;
        this.psf = psf;
    }
}