public class DreampassEmailHelper 
{
    @InvocableMethod(label='Send DreamPass Email' description='Sends an Email with the Dreampass Attachment')
    public static List<Boolean> sendEmail(List<dpEmailRequest> requests) 
    {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        try
        {
            for (dpEmailRequest request : requests) 
            {
                vaxhv__Health_Verification__c objHV = [SELECT ID, vaxhv__EmailToReceiveNotifications__c, safetycloud__AccessStartTime__c, safetycloud__AccessEndTime__c, vaxhv__FirstName__c, vaxhv__LastName__c, vaxhv__PersonAccount__c   FROM vaxhv__Health_Verification__c  WHERE ID=: request.HVID];
                Contact objc = [SELECT ID FROM CONTACT WHERE AccountID=: objHV.vaxhv__PersonAccount__c ];
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(objc.Id); 
                message.setSenderDisplayName('Safety Cloud Team'); 
                message.setReplyTo('no-reply@company.com');
                message.setUseSignature(false); 
                message.setBccSender(false); 
                message.setSaveAsActivity(false); 
                EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName =: request.emailTemplateDEVName];
                message.setTemplateID(emailTemplate.Id); 
                message.setWhatId(request.HVID); //This is important for the merge fields in template to work
                message.toAddresses = new String[] { objHV.vaxhv__EmailToReceiveNotifications__c};
                
                List<ContentVersion> contVersions = new List<ContentVersion>([SELECT VersionData FROM ContentVersion WHERE FirstPublishLocationId =: objHV.Id AND Title =: 'Dreampass']);
                if (contVersions.size() > 0)
                {
                    List<Messaging.EmailFileAttachment> atts = new List<Messaging.EmailFileAttachment>();
                    Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
                    Blob passFile = contVersions[0].VersionData;
                    att.setBody(passFile);
                    att.setFileName('dreampass.pkpass');
                    att.setInline(false);
                    atts.add(att);
                    message.setFileAttachments(atts);
                }
                emails.add(message);
            }
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emails);
        }catch(Exception e){
            system.debug('Error in sending email - ' + e.getMessage() + 'at Line number ' + e.getLineNumber());
            return new list<boolean>{false};
                }
        
        return new list<boolean>{true};
            }
    
    
    public class dpEmailRequest 
    {
        @InvocableVariable(label='Email Template Developer Name' required=true)
        public string emailTemplateDEVName;
          
        @InvocableVariable(label='Health Verification ID' required=true)
        public string HVID;
        
    }
}