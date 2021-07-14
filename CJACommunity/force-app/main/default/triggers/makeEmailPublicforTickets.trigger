/**
* 
* Description: This Class makes email public for Ticket object only.
* Author : M Tiham Siddiqui - CloudJunction
* Date : 21-01-2021
* 
**/

trigger makeEmailPublicforTickets on EmailMessage (before insert) {
    
    for(EmailMessage em:trigger.new){
        if(string.valueOf(em.RelatedToId).startsWith('a2J')){
            em.IsExternallyVisible = true;
        }
    }
    
}