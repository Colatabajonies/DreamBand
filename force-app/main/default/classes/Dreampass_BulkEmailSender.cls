public class Dreampass_BulkEmailSender 
{
    @InvocableMethod(label='Dreampass - Send Bulk Email' description='Sends an email template to a list of contacts')
    public static List<Boolean> sendEmail(List<bulkEmailRequest> requests) 
    {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        try
        {
            for (bulkEmailRequest request : requests) 
            {
                List<Contact> objContacts = new List<Contact>([SELECT ID, Email, AccountId FROM CONTACT WHERE Id in: request.contactIds]);
                for(Contact objC : objContacts)
                {
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setTargetObjectId(objC.Id); 
                    message.orgwideemailaddressid = request.orgWideAddressId;
                    message.setSaveAsActivity(false);
                    message.setTreatTargetObjectAsRecipient(true);
                    message.setTemplateID(request.emailTemplateId);
                    message.setWhatId(objC.AccountId);
                    emails.add(message);
                }
            }
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
        }catch(Exception e){
            system.debug('Error in sending email - ' + e.getMessage() + 'at Line number ' + e.getLineNumber());
            return new list<boolean>{false};
                }
        
        return new list<boolean>{true};
     }
    
    
    public class bulkEmailRequest 
    {
        @InvocableVariable(label='Org Wide Address ID' required=true)
        public string orgWideAddressId;
        
        @InvocableVariable(label='Email Template Id' required=true)
        public string emailTemplateId;
          
        @InvocableVariable(label='ContactId' required=true)
        public List<String> contactIds;
        
        
    }
}