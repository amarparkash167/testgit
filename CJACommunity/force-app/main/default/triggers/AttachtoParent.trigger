//
// Author : M Hamza Siddiqui
// Created Date : 9/14/2018
// Description : Apex Trigger to move Attachment from Task to Parent Object Record (on the basis of WHATID i.e. RelatedTo)
//
// Initializing Trigger when any new attachment get inserted in SF
trigger AttachtoParent on Attachment (after insert) {
    List<Attachment> Attachments = new list<Attachment>();
    // Looping thorugh the attachments
    for (Attachment a : trigger.new){
    	Attachments.add(a);
    }
   
    if(Attachments !=null && Attachments.size() > 0 ){
    	AttachtoParent_Handler att = new AttachtoParent_Handler(Attachments);
    }

}