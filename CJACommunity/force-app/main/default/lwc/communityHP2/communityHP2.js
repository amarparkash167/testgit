import { LightningElement,track } from 'lwc';

export default class CommunityHP2 extends LightningElement {

@track modal = false;
openModal(event){

this.modal = true


}

closemodal(event){

this.modal = false

}


}
