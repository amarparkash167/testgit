/* eslint-disable no-alert */
/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from "lightning/platformResourceLoader";
//import getDeliverables from '@salesforce/apex/DailyStandupLWCController.getDeliverables';
import getUsers from '@salesforce/apex/DailyStandupLWCController.getUsers'; 
import submitRecords from '@salesforce/apex/TaskManagementController.submitRecords_Tasks';
import getTasks from '@salesforce/apex/TaskManagementController.getTasks';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import Status_FIELD from '@salesforce/schema/Task__c.Status__c';
//import Deliverable_RecordTypeID from '@salesforce/label/c.Deliverable_Record_Type';


//Loading Confetti
import CONFETTI from "@salesforce/resourceUrl/confetti";
export default class EditTasksAgainstDeliverable extends LightningElement {
    @track richtext;
    @track chatterpost = true;
    @track deliverables;
    @track users;
    @track optionsarr;
    @track showcomp;
    @api showchatter;
    @track initialSelection = [];
    @track delvalue;
    @track DeliverableName;  
    @track DeliverableRecordId; 
    @track editedcol = [];
    @api title;
    @api deliverablerecTypeId;
    @track finalarray = [];
    @track isLoading = false;
    @track comperror;
    @track showspinner;
    @track taskstatuses;
    //@track delrectypeId = Deliverable_RecordTypeID;
    @track showchildcomp = false; //assigning WELCOME_MESSAGE value to "message" property

    parsedresources;


@wire(getPicklistValues, { recordTypeId:'$deliverablerecTypeId', fieldApiName: Status_FIELD })
statusValues;


    myconfetti;
    defaultOptions = JSON.stringify(
       // [ { "label" : "Deliverable", "apiName" : "deliverable", "type" : "lookup", "options" : "" }
        [{"label" : "", "apiName" : "Id", "type" : "hidden", "options" : "" }, 
        { "label" : "Sub Task Name", "apiName" : "task", "type" : "text", "options" :"" },
        { "label" : "Status", "apiName" : "status", "type" : "combobox", "options" : ""} ,
        { "label" : "Start Date", "apiName" : "startDate", "type" : "date", "options" : ""},
        { "label" : "Due Date", "apiName" : "dueDate", "type" : "date", "options" : "" },
        { "label" : "Est. Admin (Low)", "apiName" : "estAdminLow", "type" : "text", "options" : ""  },
        { "label" : "Est. Admin (High)", "apiName" : "estAdminHigh", "type" : "text", "options" : "" },
   //     { "label" : "Hours", "apiName" : "hours", "type" : "text", "options" : "" },
        { "label" : "Description", "apiName" : "description", "type" : "textarea", "options" : "" },
        { "label" : "Assigned To", "apiName" : "user", "type" : "combobox", "options" : "" } 
        ]);


    /*@wire(getDeliverables)
    wiredContacts({ error, data }) {
        if (data) {
            this.deliverables = data;
        } else if (error) {
            console.log('error'+JSON.stringify(error));
        }
    }*/

//


    @wire(getUsers)
    
    wiredUsers({ error, data }) {

     //   console.log('get Users => ' + JSON.stringify(data));
        if (data) {
            this.users = data;
        //    this.taskstatuses = this.statusValues.data.values;

       //     this.template.querySelector('div.hideSubmitButton').classList.remove('slds-hide');  

       console.log('wired users')
            
            this.optionsarr = JSON.stringify(
           /*     [ { "label" : "Deliverable", "apiName" : "deliverable", "type" : "lookup", "options" : "" this.statusValues.data.values}, 
                { "label" : "Task", "apiName" : "task", "type" : "text", "options" :"" },
                { "label" : "Est. Admin (Low)", "apiName" : "estAdminLow", "type" : "text", "options" : "" },
                { "label" : "Hours", "apiName" : "hours", "type" : "text", "options" : "" },
                { "label" : "Start Date", "apiName" : "startDate", "type" : "date", "options" : ""},
                { "label" : "Status", "apiName" : "status", "type" : "combobox", "options" : "this.statusValues.data.values"} ,
                { "label" : "Due Date", "apiName" : "dueDate", "type" : "Date", "options" : ""},
                { "label" : "Description", "apiName" : "description", "type" : "textarea", "options" : ""},
                { "label" : "User", "apiName" : "user", "type" : "combobox", "options" : this.users} 
                ]);*/


               // [ { "label" : "Deliverable", "apiName" : "deliverable", "type" : "lookup", "options" : "" }, 
               [{"label" : "", "apiName" : "Id", "type" : "hidden", "options" : ""},
                { "label" : "Sub Task Name", "apiName" : "task", "type" : "text", "options" : "", "value" : ""},
                { "label" : "Status", "apiName" : "status", "type" : "combobox", } ,
                { "label" : "Start Date", "apiName" : "startDate", "type" : "date", "options" : ""},
                { "label" : "Due Date", "apiName" : "dueDate", "type" : "date", "options" : ""},
                { "label" : "Est. Admin (Low)", "apiName" : "estAdminLow", "type" : "text", "options" : ""},
                { "label" : "Est. Admin (High)", "apiName" : "estAdminHigh", "type" : "text", "options" : ""},
         //       { "label" : "Hours", "apiName" : "hours", "type" : "text", "options" : "" },
                { "label" : "Description", "apiName" : "description", "type" : "textarea", "options" : ""},
                { "label" : "Assigned To", "apiName" : "user", "type" : "combobox", "options" : this.users} 
                ]);             

                this.initialSelection = this.delvalue;
        
                

                      

            this.showcomp = true;
        } else if (error) {
            console.log('error'+JSON.stringify(error));
        }

        // Load confetti library
       Promise.all([
        //loadScript(this, CONFETTI + "/confetti.js"),
        loadScript(this, CONFETTI),
      ])
        .then(() => {
          //this.setUpCanvas();
        })
        // eslint-disable-next-line no-shadow
        .catch(error => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error",
              message: error.message,
              variant: error
            })
          );
        });
    }

   
    // Setting up Confetti - Showing Custom Confetti
    setUpCanvas() {
        var confettiCanvas = this.template.querySelector("canvas.confettiCanvas");
        // eslint-disable-next-line no-undef
        this.myconfetti = confetti.create(confettiCanvas, { resize: true });
        this.myconfetti({
            zIndex: 10000
        });
    }
    //Firwork Confetti Action
    fireworks() {
        var end = Date.now() + 15 * 1000;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        // eslint-disable-next-line consistent-return
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        // eslint-disable-next-line consistent-return
        let interval = setInterval(function() {
            if (Date.now() > end) {
                return clearInterval(interval);
            }
            // eslint-disable-next-line no-undef
            confetti({
            startVelocity: 30,
            spread: 360,
            ticks: 60,
            colors: ['#104fc1', '#62b52c', '#ffffff'],
            origin: {
                x: Math.random(),
                // since they fall down, start a bit higher than random
                y: Math.random() - 0.2
            }
            });
        }, 200);
    }
    
    //School Confetti Action
    schoolpride(){
        var end = Date.now() + (15 * 100);
        // CloudJunction Logo Colors
        var colors = ['#104fc1', '#62b52c', '#ffffff'];
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        // eslint-disable-next-line consistent-return
        let interval = setInterval(function() {
            if (Date.now() < end) {
                return clearInterval(interval);
            }
            // eslint-disable-next-line no-undef
            confetti({
                particleCount: 3,
                angle: 60,
                spread: 55,
                origin: {
                    x: 0
                },
                colors: ['#104fc1', '#62b52c', '#ffffff'],
            });
            // eslint-disable-next-line no-undef
            confetti({
                particleCount: 3,
                angle: 120,
                spread: 55,
                origin: {
                    x: 1
                },
                colors: ['#104fc1', '#62b52c', '#ffffff'],
            });
        }, 200);
        
    }

    handleChange(e) {
        this.richtext = e.detail.value;
    }

    handleCheckboxChange() {
        // Query the DOM
        const checked = Array.from(
            this.template.querySelectorAll('lightning-input')
        )
            // Filter down to checked items
            .filter(element => element.checked)
            // Map checked items to their labels
            .map(element => element.label);
            this.chatterpost = checked.join(', ');
            console.log('chatter =>' + this.chatterpost);

            if(this.chatterpost !== ''){
                this.showchatter = true;
                this.chatterpost = true;
            } else {
                this.showchatter = false;
                this.chatterpost = false;
            }
    }


    handlercancelLookup(event){

     //   this.template.querySelector('c-multi-edit-table-global').clearRownonLookupRemoval();
     this.DeliverableRecordId = undefined;
        this.template.querySelector('c-multi-edit-table-global').clearRows();


    }

    

    submit() {

        if(this.DeliverableRecordId == undefined ){
          
           const err = new ShowToastEvent({
                title: 'Value Missing:',
                message: 'Please select Deliverable to create or modify tasks.',
                variant: 'error',
                mode:'pester' 

            });
            this.dispatchEvent(err);


            console.log('in submit If =>'  + this.DeliverableRecordId)
            

        }

        else{

            console.log('in submit else =>'  + this.DeliverableRecordId)
 
          this.showspinner = true;


        let tables = Array.from( this.template.querySelectorAll("c-multi-edit-table-global") );
        console.log('TABLES => ' + JSON.stringify(tables))
        let allRecords = tables.map(table => table.retrieveRecords());
        //this.finalarray.push(allRecords);
        console.log('allRecords => ' + JSON.stringify(allRecords) )
        submitRecords({ records : allRecords , chatterText : this.richtext, ischatter : this.chatterpost,deliverableId:this.DeliverableRecordId})
            .then(() => {
                //alert('Success!');
                this.message = 'Tasks have been modified or created.';
                this.showspinner = false;
                this.fireworks(); //Confetti Action

                /*If you want to show success screen
        //        this.showcomp = false;
       //         this.showsuccess = true;
       //         this.template.querySelector('div.hideSubmitButton').classList.add('slds-hide');
  */

       this.dispatchEvent(new ShowToastEvent({
        title: 'Success!',
        message: 'Tasks have been modified or created.',
        variant: 'success'
    }));

            })
            .catch((error) => {

                this.comperror = error;
                this.showspinner = false;
             //   throw DailyStandupLWCController.createCustomException('Custom Exception');

                console.log('error'+JSON.stringify(error));
                console.log('error2'+JSON.stringify(this.comperror.body.message));

                const evt = new ShowToastEvent({
                    title: 'Error Occurred:',
                    message: this.comperror.body.message,
                    variant: 'error',
                    mode:'dismissable' 

                });
                this.dispatchEvent(evt);

            })
    }

}




      


onDeliverableSelection(event){  
    this.DeliverableName = event.detail.selectedValue;  
    this.DeliverableRecordId = event.detail.selectedRecordId; 
    this.taskstatuses = this.statusValues.data.values;
 
  //  this.template.querySelector('div.hideSubmitButton').classList.remove('slds-hide');
   // this.template.querySelector('c-multi-edit-table-global').addRow();

    getTasks({ DeliverableId: this.DeliverableRecordId })
    .then((result) => {

    if(result != null){
        this.template.querySelector('div.multiEditTable').classList.remove('slds-hide');
        this.template.querySelector('div.hideSubmitButton').classList.remove('slds-hide');


    console.log('get Tasks => ' + JSON.stringify(result));
    this.updateRows(result);


    //this.rows = []; //clear the existing rows
    //// Loop on RESULTS and set VALUE for each colum and Assign it to ROWS array (this will create rows in UI with populated values)
    //c/inputTableCell  this.updateRows(result);
    }

    else{
        this.template.querySelector('c-multi-edit-table-global').clearRows();

        this.template.querySelector('c-multi-edit-table-global').clearRownonLookupRemoval();
//        this.template.querySelector('c-multi-edit-table-global').clearRownonLookupRemoval();
        this.template.querySelector('div.multiEditTable').classList.remove('slds-hide');
        this.template.querySelector('div.hideSubmitButton').classList.remove('slds-hide');




        const evt = new ShowToastEvent({
            title: 'No Tasks Found.',
            message: 'Start creating your first start under this deliverable.',
            variant: 'info',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);


    }


    })
    
    .catch((error) => {
    console.log('error'+JSON.stringify(error));
    });
    
}

updateRows(result){				
    //result.forEach(function (entry) {
    // Clear all Rows
    this.template.querySelector('c-multi-edit-table-global').clearRows();
 
    for(let entry of result){		
      //      let task = JSON.stringify({"icon":"standard:task","id": entry.Task__r.Id,"sObjectType":"Tasks","subtitle":entry.Task__r.ProjectName__c,"title":entry.Task__r.Name});
      //      let task = JSON.stringify({"icon":"standard:task","id": entry.Id,"sObjectType":"Tasks","subtitle":entry.ProjectName__c,"title":entry.Name});

            // console.log(task);
            // console.log('entry::'+JSON.stringify(entry))
             console.log('optionsarr::'+JSON.stringify(JSON.parse(this.optionsarr)));
            // JSON.parse(this.optionsarr)
            // this.optionsarr['value'] = '123'


        var obj = JSON.parse(this.optionsarr);
        for (let co of obj){


            if(co.apiName == 'Id'){


                co["value"] = entry.Id;
            //    console.log('ID API::'+ JSON.stringify(co));
 
            }

           else if(co.apiName == 'task'){

                co["value"] = entry.Name;

            }


          else  if(co.apiName == 'status'){

                co["value"] = entry.Status__c;
                co["options"] = this.statusValues.data.values;

            }

            
           else if(co.apiName == 'startDate'){

                co["value"] = entry.Start_Date__c;

            }

         else   if(co.apiName == 'dueDate'){

                co["value"] = entry.Due_Date__c;

            }

          else  if(co.apiName == 'estAdminLow'){

                co["value"] = entry.Estimated_Hours_Admin__c;

            }

         else   if(co.apiName == 'estAdminHigh'){

                co["value"] = entry.Estimated_Admin_Hours_High__c;

            }

          else  if(co.apiName == 'description'){

                co["value"] = entry.Description__c;

            }

         else   if(co.apiName == 'user'){

                co["value"] = entry.Resource__c;

            }

        }

        console.log('New Column::'+ JSON.stringify(obj));


        this.template.querySelector('c-multi-edit-table-global').addRowbyData(JSON.stringify(obj));
/*
        let editColumns =
        //    [{ "label" : "Deliverable", "apiName" : "deliverable", "type" : "lookup", "options" : "", "value" : task},
             [{"label" : "", "apiName" : "Id", "type" : "hidden", "options" : "", "value" : entry.Id},
             { "label" : "Task Name", "apiName" : "task", "type" : "text", "options" : "", "value" : entry.Name},
             { "label" : "Status", "apiName" : "status", "type" : "combobox", "options" : this.statusValues.data.values, "value" : entry.Status__c} ,
            { "label" : "Start Date", "apiName" : "startDate", "type" : "date", "options" : "", "value" : entry.Start_Date__c}, 
            { "label" : "Due Date", "apiName" : "dueDate", "type" : "date", "options" : "", "value" : entry.Due_Date__c}, 
            { "label" : "Est. Admin (Low)", "apiName" : "estAdminLow", "type" : "text", "options" : "","value" : entry.Estimated_Hours_Admin__c },
            { "label" : "Est. Admin (High)", "apiName" : "estAdminHigh", "type" : "text", "options" : "","value": entry.Estimated_Admin_Hours_High__c},
      //      { "label" : "Hours", "apiName" : "hours", "type" : "decimal", "options" : "" , "value" : entry.Estimated_Hours__c},
            { "label" : "Description", "apiName" : "description", "type" : "textarea", "options" : "" , "value" : entry.Description__c},
            { "label" : "Assigned To", "apiName" : "user", "type" : "combobox", "options" : this.users, "value" : entry.Resource__c}, 
            ];       

            //13-May-2020

            console.log('Adding new column');   
            // eslint-disable-next-line no-console
            console.log('New Column1::'+ JSON.stringify(editColumns));

            this.template.querySelector('c-multi-edit-table-global').addRowbyData(JSON.stringify(editColumns));*/
    }
}


}