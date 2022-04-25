public class Dreampass_AccessChallenge_ctrl 
{
    @AuraEnabled
    public static User lookupUser(string rfID)
    {
        List<User> objUsers = new List<User>([SELECT Name, Email, CompanyName, Phone, IsActive, AboutMe, FullPhotoURL FROM User Where Id =: rfID LIMIT 1]);
        if (objUsers.size() > 0)
        {
            //PhotoURL
            //https://cgilmore-220414-692-demo--c.documentforce.com/sfc/servlet.shepherd/version/download/CONTENTVERSION_ID
            objUsers[0].AboutMe = objUsers[0].FullPhotoUrl;
            //Replace with active logic
            objUsers[0].IsActive = true;
            
            return objUsers[0];
        }
        return null;
    }
    
    @AuraEnabled
    public static Account lookupDreamband(string rfID, string locationId)
    {
        List<Account> objAccounts = new List<Account>([SELECT Name, PersonEmail, CompanyName__c, PhotoURL__c, DreampassAccess__c FROM Account Where DreambandID__c =: rfID LIMIT 1]);
        if (objAccounts.size() > 0)
        {
            if (String.isNotBlank(locationId))
            {
                logAccess(objAccounts[0], locationId);
            }
            return objAccounts[0];
        }
        return null;
    }
    
    @AuraEnabled
    public static Account lookupDreampass(string qrcode, string locationId)
    {
        try
        {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(qrcode);
            string hvId = (string)responseMap.get('v');
            
            List<vaxhv__Health_Verification__c> objHVs = new List<vaxhv__Health_Verification__c>([SELECT ID, vaxhv__PersonAccount__c FROM vaxhv__Health_Verification__c WHERE id=: hvId LIMIT 1]);
            if (objHVs.size() > 0)
            {
                List<Account> objAccounts = new List<Account>([SELECT Name, PersonEmail, CompanyName__c, PhotoURL__c, DreampassAccess__c FROM Account Where Id =: objHVs[0].vaxhv__PersonAccount__c LIMIT 1]);
                if (objAccounts.size() > 0)
                {
                    return objAccounts[0];
                }
            }
        }
        catch(Exception ex)
        {
            return null;
        }
        return null;
    }
    
    public static void logAccess(Account objAccount, string locationId)
    {
        try
        {
            DreampassAccessLog__c newLog = new DreampassAccessLog__c();
            newLog.Account__c = objAccount.Id;
            newLog.Location__c = locationId;
            newLog.Status__c = objAccount.DreampassAccess__c ? 'Granted' : 'Denied';
            insert newLog;
        }
        catch(Exception ex)
        {
            system.debug('Error writing access log: ' + ex.getMessage());
        }
    }
}