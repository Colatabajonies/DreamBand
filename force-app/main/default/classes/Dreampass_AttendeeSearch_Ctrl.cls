public class Dreampass_AttendeeSearch_Ctrl 
{
    @InvocableMethod(label='Get Campaign Member Collection From List of Contact Ids')
    public static List<List<CampaignMember>> getCMs(List<getcmrequest> requests) 
    {
        List<CampaignMember> objCMs = new List<CampaignMember>();
        for (getcmrequest request : requests)
        {
            if (request.contactIds == null || request.contactIds.size() == 0)
            {
                return null;
            }
            try
            {
                objCMs = new List<CampaignMember>([SELECT ID, ContactId, CampaignId FROM CampaignMember WHERE ContactId In: request.contactIds AND CampaignId =: request.campaignId]);
                return new List<List<CampaignMember>>{objCMs};
            }
            catch(Exception ex)
            {
                system.debug('Not Valid Dreampass');
            }
        }
        return null;
    }
    
    public class getcmrequest
    {
        @InvocableVariable(label='Campaign Id' required=true)
        public string campaignId;
          
        @InvocableVariable(label='Contact Ids')
        public List<string> contactIds;
    }
    
    @AuraEnabled
    public static list<Account> getAccountList()
    {
        List<Account> accList= [Select Id, Name, PersonEmail, Dreampass_CompanyName__c From Account Order By CreatedDate];
        if(accList != null && accList.size()>0){
            return accList;
        }
        else{return null;}
    }
    
    @AuraEnabled
    public static list<Contact> getNonCampaignMembers(string campaignId)
    {
        //First get Campaign Members
        List<CampaignMember> objCMs = new List<CampaignMember>([SELECT Id, ContactId FROM CampaignMember WHERE CampaignId =: campaignId]);
        List<id> contactIds = new List<id>();
        for (CampaignMember objCM : objCMs)
        {
            contactIds.add(objCM.ContactId);
        }
        List<Contact> cList= [Select Id, Name, Email, Dreampass_AttendeeType__c, CreatedDate  From Contact where Id NOT in: contactIds Order By CreatedDate DESC];
        if(cList != null && cList.size()>0){
            return cList;
        }
        else{return null;}
    }
    
    @AuraEnabled
    public static list<Contact> getCampaignMembers(string campaignId)
    {
        //First get Campaign Members
        List<CampaignMember> objCMs = new List<CampaignMember>([SELECT Id, ContactId FROM CampaignMember WHERE CampaignId =: campaignId]);
        List<id> contactIds = new List<id>();
        for (CampaignMember objCM : objCMs)
        {
            contactIds.add(objCM.ContactId);
        }
        List<Contact> cList= [Select Id, Name, Email, Dreampass_AttendeeType__c, CreatedDate From Contact where Id in: contactIds Order By CreatedDate DESC];
        if(cList != null && cList.size()>0){
            return cList;
        }
        else{return null;}
    }
}