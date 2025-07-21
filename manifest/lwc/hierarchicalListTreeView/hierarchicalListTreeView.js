import { LightningElement, api, wire, track } from 'lwc';
import {refreshApex} from '@salesforce/apex';
import getHierarchicalData from '@salesforce/apex/hierarchicalListTreeViewController.getHierarchicalData';

export default class hierarchicalListTreeView extends LightningElement {
    @api recordId;
    @api listViewName='Quote_Lines_View';
    @track isLoading = true;
    @track error;
    @track qteLines;
    roles = {};
    @track dataTypes;
    @track objsInfo;
    noData=false;
    @track dataToRefresh;
    @track wiredMeta;
    @track selfParentFieldName;
    @track selfRelationshipName;
    @track objectName;
    newColumns;   

    @wire(getHierarchicalData,{sourceId:'$recordId',listViewName:'$listViewName'})
    wiredHierarchicalData(result){
       
        this.dataToRefresh = result;
        var HViewData = this.dataToRefresh.data;        
        var error = this.dataToRefresh.error;
        
        if(HViewData){
            var data = HViewData.lstHViewData;
            let relName = HViewData.SelfRelationshipName;
            this.objectName = HViewData.ObjectName;
            if(data){

                if(typeof data[0] === "undefined"){
                    this.noData=true;
                    this.isLoading = false;
                }else{
                    let dataColumnList = data[0].lstFieldValues;
                    
                    this.newColumns = [];
                    for ( var i = 0; i < dataColumnList.length; i++ ) {
                        let vData = dataColumnList[i];
                        
                        if(vData.dName != 'Id' && vData.dName!=HViewData.SelfParentFieldName){
                            let newEntry;
                            if(vData.dName == 'Name'){
                                newEntry = {
                                    type: 'url',
                                    fieldName: 'Id',
                                    label: vData.dLabel,
                                    initialWidth: 150,
                                    typeAttributes: {
                                        label: { fieldName: 'Name' },
                                        target: '_blank'
                                    }
                                }
                            }else{
                                newEntry = {
                                    type: 'text',
                                    fieldName: vData.dName,
                                    label:vData.dLabel
                                }
                            }
                            if ( this.newColumns ) {

                                this.newColumns = [ ...this.newColumns, newEntry ];
                    
                            } else {
                    
                                this.newColumns = [ newEntry ];
                    
                            }
                        }

                    }
                    var finaldata=[];
                    for ( var j = 0; j < data.length; j++ ) {
                        let vData = data[j];                   
                        if(vData.isParent == true){
                            let recorddata={};
                            for ( var i = 0; i < vData.lstFieldValues.length; i++ ) {
                                let vfData = vData.lstFieldValues[i];
                                if(vfData.dName == 'Id'){
                                    recorddata[vfData.dName] = '/'+vfData.dValue;
                                }else{
                                    recorddata[vfData.dName] = vfData.dValue;
                                }
                            }
                            recorddata['_children']=[];
                            this.roles[vData.recordId] = recorddata;
                            
                        }else{
                            let recorddata={};
                            for ( var i = 0; i < vData.lstFieldValues.length; i++ ) {
                                let vfData = vData.lstFieldValues[i];
                                if(vfData.dName == 'Id'){
                                    recorddata[vfData.dName] = '/'+vfData.dValue;
                                }else{
                                    recorddata[vfData.dName] = vfData.dValue;
                                }
                            }
                            this.roles[vData.recordId]=recorddata;
                        }
                    }

                    for ( var i = 0; i < data.length; i++ ) {
                        let vData = data[i];
                        if(vData.parentId.trim() == ""){}else{
                            if(typeof vData.parentId === "undefined"){}else{
                                if(typeof this.roles[vData.parentId] === "undefnied"){}else{ 
                                        if(this.roles[vData.parentId]){
                                            this.roles[vData.parentId]._children.push(this.roles[vData.recordId]); 
                                        }
                                }
                            }
                        }
                        
                    }
                    
                    for ( var i = 0; i < data.length; i++ ) {
                        let vData = data[i];
                        if(typeof vData.parentId === "undefined" || vData.parentId == null || vData.parentId == ''){
                            finaldata.push(this.roles[vData.recordId]);
                        }else{}
                    }
                    if(data.length >0){
                        this.noData=false;
                    }else{
                        this.noData=true;
                    }
                    this.qteLines = finaldata;
                    this.isLoading = false;
                }
            }else{
                this.noData=true;
            }
        }else {
            this.noData=true;
        }
        if(error){
            this.error = error;
            this.isLoading = false;
        }
    }

    refreshData(){        
        refreshApex(this.dataToRefresh).then(() => {
            var HViewData = this.dataToRefresh.data;        
            var error = this.dataToRefresh.error;
            
            if(HViewData){
                var data = HViewData.lstHViewData;
                let relName = HViewData.SelfRelationshipName;
                this.objectName = HViewData.ObjectName;
                if(data){
                    var finaldata=[];
                    for ( var j = 0; j < data.length; j++ ) {
                        let vData = data[j];                 
                        if(vData.isParent == true){
                            let recorddata={};
                            for ( var i = 0; i < vData.lstFieldValues.length; i++ ) {
                                let vfData = vData.lstFieldValues[i];
                                if(vfData.dName == 'Id'){
                                    recorddata[vfData.dName] = '/'+vfData.dValue;
                                }else{
                                    recorddata[vfData.dName] = vfData.dValue;
                                }
                            }
                            recorddata['_children']=[];
                            this.roles[vData.recordId] = recorddata;
                            
                        }else{
                            let recorddata={};
                            for ( var i = 0; i < vData.lstFieldValues.length; i++ ) {
                                let vfData = vData.lstFieldValues[i];
                                if(vfData.dName == 'Id'){
                                    recorddata[vfData.dName] = '/'+vfData.dValue;
                                }else{
                                    recorddata[vfData.dName] = vfData.dValue;
                                }
                            }
                            this.roles[vData.recordId]=recorddata;
                        }
                    }

                    for ( var i = 0; i < data.length; i++ ) {
                        let vData = data[i];
                        if(typeof vData.parentId === "undefined"){}else{
                            if(this.roles[vData.parentId]){
                                this.roles[vData.parentId]._children.push(this.roles[vData.recordId]); 
                            }
                        }
                        
                    }
                    
                    for ( var i = 0; i < data.length; i++ ) {
                        let vData = data[i];
                        if(typeof vData.parentId === "undefined" || vData.parentId == null || vData.parentId == ''){
                            finaldata.push(this.roles[vData.recordId]);
                        }else{}
                    }
                    if(data.length >0){
                        this.noData=false;
                    }else{
                        this.noData=true;
                    }
                    this.qteLines = finaldata;
                    this.isLoading = false;
                }else{
                    this.noData=true;
                }
            }
        }).catch(error => {
            this.error = error;
            this.isLoading = false;
        });       
   }  
   
    qlsExpandAll( e ) {
        const grid =  this.template.querySelector( 'lightning-tree-grid' );
        grid.expandAll();
    }
    qlsCollapseAll( e ) {

        const grid =  this.template.querySelector( 'lightning-tree-grid' );
        grid.collapseAll();
      
    }


}