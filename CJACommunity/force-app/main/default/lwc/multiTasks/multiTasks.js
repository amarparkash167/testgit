/* eslint-disable no-alert */
/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from "lightning/platformResourceLoader";
//import getDeliverables from '@salesforce/apex/DailyStandupLWCController.getDeliverables';
import getUsers from '@salesforce/apex/DailyStandupLWCController.getUsers'; 
import submitRecords from '@salesforce/apex/DailyStandupLWCController.submitRecords';
//Loading Confetti
import CONFETTI from "@salesforce/resourceUrl/confetti";

export default class MultiTasks extends LightningElement {
    @track richtext;
    @track chatterpost = true;
    @track deliverables;
    @track users;
    @track optionsarr;
    @track showcomp;
    @track showchatter = true;
    myconfetti;
    defaultOptions = JSON.stringify(
        [ { "label" : "Deliverable", "apiName" : "deliverable", "type" : "lookup", "options" : "" }, 
        { "label" : "Task", "apiName" : "task", "type" : "text", "options" :"" },
        { "label" : "Hours", "apiName" : "hours", "type" : "text", "options" : "" },
        { "label" : "Start Date", "apiName" : "startDate", "type" : "date", "options" : ""},
        { "label" : "Due Date", "apiName" : "dueDate", "type" : "date", "options" : ""},
        { "label" : "Description", "apiName" : "description", "type" : "text", "options" : ""},
        { "label" : "User", "apiName" : "user", "type" : "combobox", "options" : ""} 
        ]);

    /*@wire(getDeliverables)
    wiredContacts({ error, data }) {
        if (data) {
            this.deliverables = data;
        } else if (error) {
            console.log('error'+JSON.stringify(error));
        }
    }*/

    @wire(getUsers)
    wiredUsers({ error, data }) {
        console.log(JSON.stringify(data));
        if (data) {
            this.users = data;
            this.optionsarr = JSON.stringify(
                [ { "label" : "Deliverable", "apiName" : "deliverable", "type" : "lookup", "options" : "" }, 
                { "label" : "Task", "apiName" : "task", "type" : "text", "options" :"" },
                { "label" : "Hours", "apiName" : "hours", "type" : "text", "options" : "" },
                { "label" : "Start Date", "apiName" : "startDate", "type" : "date", "options" : ""},
                { "label" : "Due Date", "apiName" : "dueDate", "type" : "Date", "options" : ""},
                { "label" : "Description", "apiName" : "description", "type" : "textarea", "options" : ""},
                { "label" : "User", "apiName" : "user", "type" : "combobox", "options" : this.users} 
                ]);
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
            console.log(this.chatterpost);

            if(this.chatterpost !== ''){
                this.showchatter = true;
                this.chatterpost = true;
            } else {
                this.showchatter = false;
                this.chatterpost = false;
            }
    }

    submit() {
        let tables = Array.from( this.template.querySelectorAll("c-multi-edit-table-global") );
        let allRecords = tables.map(table => table.retrieveRecords());
        submitRecords({ records: allRecords , chatterText : this.richtext, ischatter : this.chatterpost})
            .then(() => {
                //alert('Success!');
                this.message = 'Tasks have been created';
                this.showcomp = false;
                this.showspinner = false;
                this.showsuccess = true;
                //Confetti Action
                    this.fireworks();
            })
            .catch(() => {
                alert('Something went wrong...');
            })
    }
}