global without sharing class GoogleChatWebhook {
    global static boolean skipCallout {get; set;}
    
    global class GoogleChatData {
        @InvocableVariable
        public String webhookUrl;
        @InvocableVariable
        public Id recordId;
        @InvocableVariable
        public String alertMessage;
        @InvocableVariable
        public String alertDetails;
    }
    // @InvocableVariable
    //public String ticketNumber;
    //@InvocableVariable
    // public String ticketSubject;
    // @InvocableVariable
    // public String ticketEmail;
    // @InvocableVariable
    // public String ticketContactName;
    
    
    @InvocableMethod
    public static void sendChat(List<GoogleChatData> chatData) {
        for (Integer i=0;i<chatData.size();i++) {
            sendOutputMessageToRoom(chatData.get(i).webhookUrl,
                                    chatData.get(i).recordId, 
                                    chatData.get(i).alertMessage,
                                    chatData.get(i).alertDetails);
        }
    }
    
    @future(callout=true)
    public static void sendOutputMessageToRoom(String webhookUrl,
                                               Id recordId,
                                               String alertMessage,
                                               String alertDetails ) 
    {
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(webhookUrl);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        String url = System.Url.getSalesforceBaseUrl().toExternalForm();
        String ticketUrl = url + '/lightning/r/Issue__c/' + recordId + '/view'; // Using the new URL format!
        
        // Send formatted card message
        
        //String message = '{"text": "*New Ticket Alert*\r\n';
        /*
* //String message = '{"cards":..<abbreviated>...}]}';
String message = '{"text": "New Ticket Alert\r\n';
message += 'Ticket #: '+ticketNumber+'\r\n';
message += 'URL: '+ticketUrl+'\r\n';
message += 'Subject: '+ticketSubject+'\r\n';
message += 'From Email: '+ticketEmail+'\r\n';
message += 'Contact Name: '+ticketContactName+'\r\n';
message += '"}';

*/
        String message = '{"text":"'+ alertMessage + '\r\n';
        message += alertDetails +'\r\n';
        message += '"}';
        
        req.setBody(message);
        system.debug( 'This is a new alert: ' + message); 
        
        Http http = new Http();
        if(skipCallout == true) {
            system.debug('skipping webservice callout');
        } else {
        	HttpResponse res = http.send(req);    
        }
        
    }
}