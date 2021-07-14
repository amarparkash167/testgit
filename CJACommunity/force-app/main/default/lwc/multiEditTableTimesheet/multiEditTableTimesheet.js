import { LightningElement, track, api } from 'lwc';

export default class MultiEditTableTimesheet extends LightningElement {
    @api columnList;
    @api addrowsitems;
    @api title;
    @api types;
    @api skilltype;
    columns;
    parsedTypes;
    parsedSkillType;
    @track datevalue;
    today = new Date();
    @track currentdate = this.today.getFullYear()+'-'+(this.today.getMonth()+1)+'-'+this.today.getDate();
    @track rows = [];
    



    //@track rows = [];
    connectedCallback() {

        console.log('Connected Call Back');

        let cleanedColumnList = this.columnList[0] === '\\' ? this.columnList.substring(1) : this.columnList;
        //cleanedColumnList = '{ "label" : "Task", "apiName" : "task", "type" : "combobox", "options" : this.taskLists} , '+cleanedColumnList;
        this.columns = JSON.parse(cleanedColumnList);
        //this.addRowLi(this.addrowsitems);
        this.rows.push({ uuid: this.createUUID(), columns : this.columns });
        //console.log(JSON.stringify(this.rows));
        this.parsedTypes = JSON.parse(this.types);
        this.parsedSkillType = this.skilltype;

        //console.log('Parsed Skill Type::' + parsedSkillType);
    }

    createUUID() {
        var dt = new Date().getTime();
        var uuid = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            var r = (dt + Math.random()*16)%16 | 0;
            dt = Math.floor(dt/16);
            return (c === 'x' ? r :(r&0x3|0x8)).toString(16);
        });
        return uuid;
    }

    handleDateChange(event){
        this.datevalue = event.target.value;
    }

    @api
    getdateval(){
        return this.datevalue;
    }

    @api
    retrieveRecords() {
        let rows = Array.from( this.template.querySelectorAll("tr.inputRows") );
        let records = rows.map(row => {
            let cells = Array.from( row.querySelectorAll("c-input-table-cell") );
            return cells.reduce( (record, cell) => {
                let inputVal = cell.inputValue();
                record[inputVal.field] = inputVal.value;
                return record;
            }, {})
        })

        return records;
    }

    removeRow(event) {
        this.rows.splice(event.target.value, 1);
    }
    
    addRow() {
        this.rows.push({ uuid: this.createUUID(), columns : this.columns });
    }

    cloneRow(event) {

        let allrecords = this.retrieveRecords();
        let clonedrecord = allrecords[event.target.value];
        // eslint-disable-next-line no-console
        console.log('Item Id ::'+ allrecords[event.target.value]);
        // eslint-disable-next-line no-console
        console.log('Cloned values::'+ JSON.stringify(allrecords[event.target.value]));
        // eslint-disable-next-line no-console
        console.log('Task ID ::' + clonedrecord.tasks);

        let clone_columns =
            [{ "label" : "Tasks", "apiName" : "tasks", "type" : "lookup", "options" : "", "value" : clonedrecord.tasks},
            { "label" : "Billable", "apiName" : "billable", "type" : "checkbox", "options" : "", "value" : clonedrecord.billable}, 
            { "label" : "Hours", "apiName" : "hours", "type" : "decimal", "options" : "" , "value" : clonedrecord.hours},
            { "label" : "Comments", "apiName" : "description", "type" : "textarea", "options" : "" , "value" : clonedrecord.internalcomments},
            { "label" : "Status", "apiName" : "type", "type" : "combobox", "options" : this.parsedTypes, "value" : clonedrecord.type},          
            { "label" : "Skill Type", "apiName" : "skillType", "type" : "combobox", "options" : this.parsedSkillType, "value" : clonedrecord.skillType},          
                
        ];

            
            // eslint-disable-next-line no-console
            console.log('New Column::'+ JSON.stringify(clone_columns));
        this.rows.push({ uuid: this.createUUID(), columns : clone_columns });
    }

    addRowLi(items) {
        // eslint-disable-next-line no-console
        console.log('items'+items);
        
        let lrows = JSON.parse(items);

        for(let i=0;i<lrows.length;i++){
            // eslint-disable-next-line no-console
            console.log('value'+ lrows[i].label);

            this.rows.push({ uuid: this.createUUID(), task: lrows[i].label, taskId: lrows[i].value });
        }
    }
}