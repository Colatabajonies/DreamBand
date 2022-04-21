public class RFID_AccessChallenge_ctrl 
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
    public static Account lookupAccount(string rfID)
    {
        List<Account> objAccounts = new List<Account>([SELECT Name, PersonEmail, CompanyName__c, PhotoURL__c, DreampassAccess__c FROM Account Where DreambandID__c =: rfID LIMIT 1]);
        if (objAccounts.size() > 0)
        {
            //PhotoURL
            //https://cgilmore-220414-692-demo--c.documentforce.com/sfc/servlet.shepherd/version/download/CONTENTVERSION_ID
            
            //Replace with active logic
            //objAccounts[0].DreampassAccess__c = true;
            
            return objAccounts[0];
        }
        return null;
    }
}