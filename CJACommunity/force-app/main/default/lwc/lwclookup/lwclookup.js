import { LightningElement, track, wire, api } from "lwc";  
 import findRecords from "@salesforce/apex/TaskManagementController.findRecords";  
 export default class LwcLookup extends LightningElement {  
  @track recordsList;  
  @track searchKey = "";  
  @api selectedValue;  
  @api selectedRecordId;  
  @api objectApiName;  
  @api iconName;  
  @api lookupLabel;  
  @track message;  
    
  onLeave(event) {  
   setTimeout(() => {  
    this.searchKey = "";  
    this.recordsList = null;  
   }, 300);  
  }  
    
  onRecordSelection(event) {  
   this.selectedRecordId = event.target.dataset.key;  
   this.selectedValue = event.target.dataset.name;  
   this.searchKey = "";
   const passEventr = new CustomEvent('initialselection', {  
    detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }  
   });  
   this.dispatchEvent(passEventr);    


   this.onSeletedRecordUpdate();  
  }  
   
  handleKeyChange(event) {  
   const searchKey = event.target.value;  
   this.searchKey = searchKey;  
   this.getLookupResult();  
  }  
   
  removeRecordOnLookup(event) {  
   
    var txt;
  var r = confirm("Removing this deliverable will clear all rows. Are you sure you want to Continue?");
  if (r == true) {
    txt = "Removing this deliverable will clear all rows. Are you sure you want to Continue?";
    this.searchKey = "";  
    this.selectedValue = null;  
    this.selectedRecordId = null;  
    this.recordsList = null;  
    console.log('record Removed')
    const recordremove = new CustomEvent('recordremove', {  
     detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }  
    });  
    this.dispatchEvent(recordremove);  
   // this.onSeletedRecordUpdate(); 
  } 
  else {

    txt = "You pressed Cancel!";
 
  }
   /*
    this.searchKey = "";  
   this.selectedValue = null;  
   this.selectedRecordId = null;  
   this.recordsList = null;  
   console.log('record Removed')
   const recordremove = new CustomEvent('recordremove', {  
    detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }  
   });  
   this.dispatchEvent(recordremove);  
  // this.onSeletedRecordUpdate();*/  
 }  

 getLookupResult() {  
    findRecords({ searchKey: this.searchKey, objectName : this.objectApiName })  
     .then((result) => {  
      if (result.length===0) {  
        this.recordsList = [];  
        this.message = "No Records Found";  
       } else {  
        this.recordsList = result;  
        this.message = "";  
       }  
       this.error = undefined;  
     })  
     .catch((error) => {  
      this.error = error;  
      this.recordsList = undefined;  
     });  
   }  
    
   onSeletedRecordUpdate(){  
    const passEventr = new CustomEvent('recordselection', {  
      detail: { selectedRecordId: this.selectedRecordId, selectedValue: this.selectedValue }  
     });  
     this.dispatchEvent(passEventr);  

   }  
  }