import { LightningElement, track, api } from 'lwc';

export default class MultiEditTable extends LightningElement {
    @api columnList;
    @api title
    columns;
    @api types;
    parsedResources;
    //@track rows = [{ uuid: this.createUUID() }];
    @track rows = [];
    @track isLoading  = false; 
    @api taskstatuses;
    
    connectedCallback() {
        console.log('Column list ==> ' + this.columnList);

        //let cleanedColumnList = this.columnList[0] === '\\' ? this.columnList.substring(1) : this.columnList;
        //this.columns = JSON.parse(cleanedColumnList);
        this.columns = JSON.parse(this.columnList);


        for(let co of this.columns){

            if(co.apiName == "status"){

                console.log('tasks statuses in connected callback => ' + this.taskstatuses)
                co["options"] = this.taskstatuses;

            }
     
        }

        this.rows.push({ uuid: this.createUUID(), columns: this.columns});
        console.log('Columns for each val ===> ' + JSON.stringify(this.columns));
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

    @api
    retrieveRecords() {
        let rows = Array.from( this.template.querySelectorAll("tr.inputRows") );
        let records = rows.map(row => {
            let cells = Array.from( row.querySelectorAll("c-input-table-cell-global") );
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

        for(let co of this.columns ){

            co["value"] = undefined;
         //   co["Id"] = undefined;

             if(co.apiName == "status"){

                console.log('tasks statuses => ' + this.taskstatuses)
                co["options"] = this.taskstatuses;

            }

        }
        this.rows.push({ uuid: this.createUUID(), columns : this.columns });
    }

    @api addRowbyData(column){
        console.log('edited columns from parent => ' + column )
        this.rows.push({ uuid: this.createUUID(), columns : JSON.parse(column) });
    }

    @api clearRows(){
        this.rows = [];
    }

    @api clearRownonLookupRemoval(){
     
        this.rows = [];
        this.rows.push({ uuid: this.createUUID(), columns : this.columns });

    }

//copied from multi edit table lwc


    cloneRow(event) {

        let allrecords = this.retrieveRecords();
        let clonedrecord = allrecords[event.target.value];
        // eslint-disable-next-line no-console
        console.log('Item Id ::'+ allrecords[event.target.value]);
        // eslint-disable-next-line no-console
        console.log('Cloned values::'+ JSON.stringify(allrecords[event.target.value]));
        console.log('tasks status => ' + JSON.stringify(this.taskstatuses))
        // eslint-disable-next-line no-console
        //console.log('Task ID ::' + clonedrecord.tasks);

        let clone_columns = this.columns;
        
        for(let co of clone_columns ){

            if(co.apiName != 'Id'){
            co['value']=clonedrecord[co.apiName];
            }

            if(co.apiName == "status"){

                console.log('tasks statuses => ' + this.taskstatuses)
            //    co['options']=this.taskstatuses;
                co["options"] = this.taskstatuses;

            }

            
        }

        // let clone_columns =
        //     [{ "label" : "Tasks", "apiName" : "tasks", "type" : "lookup", "options" : "", "value" : clonedrecord.tasks},
        //     { "label" : "Billable", "apiName" : "billable", "type" : "checkbox", "options" : "", "value" : clonedrecord.billable}, 
        //     { "label" : "Hours", "apiName" : "hours", "type" : "decimal", "options" : "" , "value" : clonedrecord.hours},
        //     { "label" : "Comments", "apiName" : "description", "type" : "textarea", "options" : "" , "value" : clonedrecord.internalcomments},
        //     { "label" : "Status", "apiName" : "type", "type" : "combobox", "options" : this.parsedTypes, "value" : clonedrecord.type},          
        //     { "label" : "Skill Type", "apiName" : "skillType", "type" : "combobox", "options" : this.parsedSkillType, "value" : clonedrecord.skillType},          
                
        // ];
 
            // eslint-disable-next-line no-console
        console.log('New Column::'+ JSON.stringify(clone_columns));
        this.rows.push({ uuid: this.createUUID(), columns : clone_columns });
    }



    

}