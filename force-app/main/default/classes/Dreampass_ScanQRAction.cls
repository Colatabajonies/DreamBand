public class Dreampass_ScanQRAction 
{
    @InvocableMethod(label='Get Attendee From Dreampass QR Code')
    public static List<Account> sendEmail(List<String> requests) 
    {
        List<ID> hvIDs = new List<ID>();
        List<ID> accountIDs = new List<ID>();
        for (String request : requests)
        {
            if (string.isBlank(request))
            {
                continue;
            }
            try
            {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(request);
                string hvId = (string)responseMap.get('v');
                hvIDs.add(hvId);
                //system.debug('Adding HvID:' + hvId);
            }
            catch(Exception ex)
            {
                system.debug('Not Valid Dreampass');
            }
        }
        List<vaxhv__Health_Verification__c> objHVs = new List<vaxhv__Health_Verification__c>([SELECT ID, vaxhv__PersonAccount__c FROM vaxhv__Health_Verification__c WHERE id IN: hvIDs]);
        if (objHVs.size() > 0)
        {
            //system.debug('Hvs Found');
            for (vaxhv__Health_Verification__c hv : objHVs)
            {
                accountIds.add(hv.vaxhv__PersonAccount__c);
            }
            List<Account> objAccounts = new List<Account>([SELECT Name, PersonEmail, PersonBirthDate, Phone, CompanyName__c, PhotoURL__c, DreampassAccess__c FROM Account Where Id IN: accountIds]);
            if (objAccounts.size() > 0)
            {
                return objAccounts;
            }
        }
        
        return null;
    }
}