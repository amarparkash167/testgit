/* eslint-disable @lwc/lwc/no-async-operation */
import { track,wire,LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from "lightning/platformResourceLoader";

// Import Picklist Values
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import SKILL_TYPE from '@salesforce/schema/Asset.Product_Role__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ASSET_OBJECT from '@salesforce/schema/Asset';

import getProductInfo from '@salesforce/apex/Timesheet_LWC.getProductInfo';

//import submitRecords from '@salesforce/apex/MultiEditTableController.submitRecords';
import saveRecords from '@salesforce/apex/Timesheet_LWC.submitRecords';
import TimesheetStatus from '@salesforce/apex/Timesheet_LWC.getTEStatus';
// Importing Custom Labels
import SucccessLabel from '@salesforce/label/c.SuccessMessage';
import ErrorLabel from '@salesforce/label/c.ErrorMessage';
import ValidationLabel from '@salesforce/label/c.ValidateMessage';
//Loading Confetti
import CONFETTI from "@salesforce/resourceUrl/confetti";




export default class timesheetlwc extends LightningElement {
    myconfetti;
    @track status;
    //@track 
    //optionsarr;
    @track showcomp = false;
    @track message;
    @track showspinner = true;
    @track showsuccess = false;
    @track value = '--Select--';
    @track title='Timesheet - Lightning Web Component';
    @track optionsarr;
    @track notifyViaAlerts = false;
    @track errors = [];
    @track action ='save';
    @track pickListvalues;

    
 /*  @wire(getObjectInfo, { objectApiName: ASSET_OBJECT })
    AssetInfo;

    @wire(getPicklistValues, {

        recordTypeId: '$AssetInfo.data.defaultRecordTypeId',
        fieldApiName : SKILL_TYPE
    })
        wiredPickListValue({ data, error }){
            if(data){
                console.log( 'Picklist values are ', data.values);
                this.pickListvalues = data.values;
                this.error = undefined;
            }
            if(error){
                console.log(' Error while fetching Picklist values  ${error}');
                this.error = error;
                this.pickListvalues = undefined;
            }
        }
*/

get options() {
    return [
        { label: 'Admin', value: 'Admin' },
        { label: 'Consultant', value: 'Consultant' },
        { label: 'Architect', value: 'Architect' },
       
    ];    
    }

   @wire(TimesheetStatus)
   wiredTypes({ error, data }) {
       if (data) {
           // eslint-disable-next-line no-console
           console.log('Data::'+ JSON.stringify(data));
           // eslint-disable-next-line no-console
           console.log('Data Returned');
           console.log('Picklist Values::' + this.options);
           this.status = JSON.stringify(data);

           
           getProductInfo()
           .then(result => {
               
               console.log('Method has called');
               // Clear the user enter values
               //this.accRecord = {};
               if(result){
   
               console.log('result ===> '+JSON.stringify(result));
               
               this.pickListvalues = JSON.stringify(result);
   
               console.log('List of Product Role::' + this.pickListvalues);
               //console.log('hidden account :: ' + this.accRecord.HiddenAccount__r.Name);

              

               }
               else{
   
                   console.log('Result is null' + result);
               }
           })
           .catch(error => {
               //this.error = error.message;
               console.log('Error in Getting Product Role ===>' + JSON.stringify(error));
           });
   
   


           this.optionsarr = JSON.stringify(

            [{ "label" : "Tasks", "apiName" : "tasks", "type" : "lookup", "options" : ""},
            { "label" : "Billable", "apiName" : "billable", "type" : "checkbox", "options" : ""}, 
            { "label" : "Hours", "apiName" : "hours", "type" : "decimal", "options" : "" },
            { "label" : "Comments", "apiName" : "description", "type" : "textarea", "options" : "" }, 
            { "label" : "Status", "apiName" : "type", "type" : "combobox", "options" : JSON.parse(this.status)},           
            { "label" : "Skill Type", "apiName" : "skilltype", "type" : "combobox", "options" : this.options},           
              
        ]);



           this.showcomp = true;
           this.showspinner = false;
       } else if (error) {
           // eslint-disable-next-line no-console
           console.log('error'+JSON.stringify(error));
       } // Wire End

       // Load confetti library
       Promise.all([
        //loadScript(this, CONFETTI + "/confetti.js"),
        loadScript(this, CONFETTI),
      ])
        .then(() => {
          this.setUpCanvas();
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
        var end = Date.now() + (15 * 1000);
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

    // Setting action to submit and calling timesheet submission function
    submit(){
        this.action = 'submit';
        this.save();
    }
    // Saving Timesheet Entries
    save() {
        this.errors = [];
        let tables = Array.from( this.template.querySelectorAll("c-multi-edit-table-timesheet") );
        let allRecords = tables.map(table => table.retrieveRecords());
        let timesheetdate = this.template.querySelector("c-multi-edit-table-timesheet").getdateval();
        // eslint-disable-next-line no-console
        console.log('Time Date::' + timesheetdate);

        console.log(JSON.stringify(allRecords));

        this.checkForErrors(timesheetdate);
        if (this.errors.length === 0) {
            
            saveRecords({ records: allRecords, TEDate : timesheetdate, action: this.action })
            .then((result) => {
                if(result){
                    // eslint-disable-next-line no-console
                    console.log('Result='+ JSON.stringify(result));
                } else {
                    this.notifyUser('Success',SucccessLabel, 'success');
                    this.message = SucccessLabel;
                    this.showcomp = false;
                    this.showspinner = false;
                    this.showsuccess = true;
                    //Confetti Action
                    this.fireworks();
                    //this.schoolpride();
                }
            })
            .catch((error) => {
                this.errors = error;
                this.message = 'Something went wrong...';
                this.notifyUser(this.message,ErrorLabel, 'error');
                // eslint-disable-next-line no-console
                console.log('Error::'+JSON.stringify(error));
            })
        } else {
            this.notifyUser('Something went wrong!', JSON.stringify(this.errors[0].message), 'error');
        }
    }


    checkForErrors(data) {
        if (typeof data == "undefined" || data == null) {
            this.errors = [{ message: ValidationLabel }];
        } else {
            this.errors = [];
        }
    }

    notifyUser(title, message, variant) {
        if (this.notifyViaAlerts){
            // Notify via alert
            // eslint-disable-next-line no-alert
            alert(`${title}\n${message}`);
        } else {
            // Notify via toast
            const toastEvent = new ShowToastEvent({ title, message, variant });
            this.dispatchEvent(toastEvent);
        }
    }

}