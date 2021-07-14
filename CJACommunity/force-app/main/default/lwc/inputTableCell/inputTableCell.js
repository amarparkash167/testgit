import { LightningElement, api, track} from 'lwc';
import apexSearch from '@salesforce/apex/LookupController.search';

export default class InputTableCell extends LightningElement {
    @api record;
    @api options; 
    @api inputfield;
    @api inputval;
    @api type;
    @api field;
    @api ivalue;
    @track ifield;
    @track Skillfield;
    @track label;
    @track uuid;
    @track showcombo = false;
    @track skillcombo = false;
    @track showtextarea = false;
    @track showcheckedbox = false;
    @track showinputbox = false;
    @track showlookup = false;
    @track combooptions;
    @track value;
    @track skillValue;
    @track lookupvalue;
    @track checked='required';
    // FOR LOOKUP
    // Use alerts instead of toast to notify user
    @api notifyViaAlerts = false;
    @track errors = [];
    @track isMultiEntry = false;
    @track initialSelection = [];

    

    connectedCallback() {
        console.log('connected call back');
        this.setup();
    }

    setup(){
        console.log('Setup called');
        //this.value = this.record[this.field];
        this.combooptions = this.options;
        this.label = this.field;
        this.ifield = this.field;
        this.value = this.ivalue;

        // eslint-disable-next-line no-console
        console.log('Type ::'+ this.type +'&& Value ::'+ this.value);
        if(this.type=='checkbox' && this.value=='true'){
            this.checked = 'checked';
            //this.template.getElementsByClassName('slds-checkbox')[0].getElementsByTagName('input')[0].setAttribute("checked", "true");
        }

        // eslint-disable-next-line no-console
        console.log('Value : ' + this.value);

        if(this.type=='lookup' && this.value !=null){
            this.initialSelection.push(JSON.parse(this.value));
        }


        //this.uuid = this.record.uuid;
        //this.value = this.inputval;
        /*console.log('Record::'+ JSON.stringify(this.record));
        console.log('Record ID::'+ JSON.stringify(this.record.uuid));
        console.log('Field::'+ JSON.stringify(this.field));
        console.log('Type '+ this.type);
        console.log('Options '+ JSON.stringify(this.options));*/

        // Lookup Populate on Clone !
        // if(this.value != null){
        //     console.log(this.value);
        //     let value_data;
        //     if(this.value.constructor === Array){
        //         value_data = this.value;
        //     } else {
        //         value_data = JSON.parse(this.value);
        //     }

            
        //     //this.initialSelection.push(
        //         //{id: value_data.id, sObjectType: value_data.sObjectType, icon: value_data.icon, title: value_data.title, subtitle:value_data.subtitle}
        //        // );

             
        // }

        if(this.type =="combobox"){
            this.showcombo = true;
            this.showtextarea = false;
            this.showinputbox = false;
            this.showlookup =  false;
            this.showcheckedbox = false;
            //this.skillcombo = true;
        } else if(this.type == "textarea"){
            this.showtextarea = true;
            this.showcombo = false;
            this.showinputbox = false;
            this.showlookup =  false;
        } else if(this.type == "lookup"){
            this.showtextarea = false;
            this.showcombo = false;
            this.showinputbox = false;
            this.showlookup =  true;
            this.showcheckedbox = false;
        } else if(this.type == "checkbox"  && this.value=='true'){
            this.showtextarea = false;
            this.showcombo = false;
            this.showinputbox = false;
            this.showlookup =  false;
            this.showcheckedbox = true;
        } else {
            this.showcheckedbox = false;
            this.showinputbox = true;
            this.showtextarea = false;
            this.showcombo = false;
            this.showlookup =  false;
        }
      
    }

    handleInputChange(event) {
        console.log('Handle input change called');

        if(this.type == 'checkbox'){
            // Query the DOM
            const checked = Array.from(
                this.template.querySelectorAll('lightning-input')
            )
                // Filter down to checked items
                .filter(element => element.checked)
                // Map checked items to their value (i.e. checked)
                .map(element => element.checked);
                this.value =  checked.join(', ');
        } else {
            this.value = event.target.value; 
        }
    }

    handleOptionsChange(event) {
        console.log('Handle options change called = ' + event.target.value);
        //console.log('Handle options change event = ' + JSON.stringify(event));
        this.value = event.target.value;
        this.picklistselect(event.target.value,event.target.name);

        console.log('Handle SKill type Options' + event.target.label);
        
        
        //this.picklistselect(event.target.value,event.target.name,event.target.attributes.getNamedItem('data-recordid').value);
    }

    @api id;
    picklistselect(recid,object,uid) {
        console.log('Picklist select called');
        const event = new CustomEvent('picklistselect', {
            // detail contains only primitives
            detail : [{"id": recid , "type": object}]
        });
        // Fire the event from c-tile
        this.dispatchEvent(event);
    }

    @api
    inputValue() {
        console.log('Input value called');
        return { value : this.value, field: this.field };
    }

    // FOR LOOKUP

    handleLookupTypeChange(event) {
        this.initialSelection = [];
        this.errors = [];
        this.isMultiEntry = event.target.checked;
    }

    handleSearch(event) {
        apexSearch(event.detail)
            .then(results => {
                this.template.querySelector('c-lookup').setSearchResults(results);
            })
            .catch(error => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleSelectionChange(event) {
        this.errors = [];
        console.log('Their Method:: '+ JSON.stringify(this.template.querySelector('c-lookup').getSelection()[0]));
        //this.value = event.target.value; 
        // If value is not null, assigning complete array as value for lookup in JSON format
        if(this.template.querySelector('c-lookup').getSelection() != null)
        this.value = JSON.stringify(this.template.querySelector('c-lookup').getSelection()[0]);
    }

    handleSubmit() {
        this.checkForErrors();
        if (this.errors.length === 0) {
            this.notifyUser('Success', 'The form was submitted.', 'success');
        }
    }

    checkForErrors() {
        const selection = this.template.querySelector('c-lookup').getSelection();
        if (selection.length === 0) {
            this.errors = [
                { message: 'You must make a selection before submitting!' },
                { message: 'Please make a selection and try again.' }
            ];
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