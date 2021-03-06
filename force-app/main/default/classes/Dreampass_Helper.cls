public class Dreampass_Helper 
{    
    @AuraEnabled
    public static Dreampass getDreampassFromQR(string qrcode)
    {
        Dreampass objDreampass = new Dreampass();
        objDreampass.isValid = false;
        try
        {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(qrcode);
            string hvId = (string)responseMap.get('v');
            
            List<vaxhv__Health_Verification__c> objHVs = new List<vaxhv__Health_Verification__c>([SELECT ID, vaxhv__PersonAccount__c FROM vaxhv__Health_Verification__c WHERE id=: hvId LIMIT 1]);
            if (objHVs.size() > 0)
            {
                List<Account> objAccounts = new List<Account>([SELECT Name, PersonEmail, Phone, Type, Dreampass_PhotoURL__c, Dreampass_CompanyName__c, Dreampass_Revoked__c, Dreampass_Checkin_Time__c, Dreampass_OnsitePCRTestDate__c FROM Account Where Id =: objHVs[0].vaxhv__PersonAccount__c LIMIT 1]);
                if (objAccounts.size() > 0)
                {
                    objDreampass.objAccount = objAccounts[0];
                    SetDreampassValidity(objDreampass);
                    return objDreampass;
                }
            }
        }
        catch(Exception ex)
        {
            return null;
        }
        return null;
    }
    
    @AuraEnabled
    public static Dreampass getDreampassFromDreambandId(string rfID)
    {
        Dreampass objDreampass = new Dreampass();
        objDreampass.isValid = false;
        List<Account> objAccounts = new List<Account>([SELECT Name, PersonEmail, Phone, Type, Dreampass_PhotoURL__c, Dreampass_CompanyName__c, Dreampass_Revoked__c, Dreampass_Checkin_Time__c, Dreampass_OnsitePCRTestDate__c  FROM Account Where Dreampass_DreambandID__c =: rfID LIMIT 1]);
        if (objAccounts.size() > 0)
        {
            objDreampass.objAccount = objAccounts[0];
            SetDreampassValidity(objDreampass);
            return objDreampass;
        }
        return null;
    }
    
    @AuraEnabled
    public static Dreampass getDreampassFromAccountId(string accountId)
    {
        Dreampass objDreampass = new Dreampass();
        objDreampass.isValid = false;
        List<Account> objAccounts = new List<Account>([SELECT Name, PersonEmail, Phone, Type, Dreampass_PhotoURL__c, Dreampass_CompanyName__c, Dreampass_Revoked__c, Dreampass_Checkin_Time__c, Dreampass_OnsitePCRTestDate__c  FROM Account Where id =: accountId LIMIT 1]);
        if (objAccounts.size() > 0)
        {
            objDreampass.objAccount = objAccounts[0];
            SetDreampassValidity(objDreampass);
            return objDreampass;
        }
        return null;
    }
    
    public static void logAccessChallenge(Account objAccount, string locationId, boolean isValid)
    {
        try
        {
            DreampassAccessLog__c newLog = new DreampassAccessLog__c();
            newLog.Account__c = objAccount.Id;
            newLog.Location__c = String.isblank(locationId) ? null : locationId;
            newLog.Status__c = isValid ? 'Granted' : 'Denied';
            insert newLog;
        }
        catch(Exception ex)
        {
            system.debug('Error writing access log: ' + ex.getMessage());
        }
    }
    
    public static void SetDreampassValidity(Dreampass objDreampass)
    {
        integer timewindow = 24;
        
        Account objAccount = objDreampass.objAccount;
        objDreampass.inValidReason = '';
        objDreampass.isValid = false;
        objDreampass.expiration = null;
        
        /*<members>Account.Dreampass_Revoked__c</members>
        <members>Account.Dreampass_Checkin_Time__c</members>
        <members>Account.Dreampass_OnsitePCRTestDate__c</members> */
        
        //first see if the dreampass has been revoked or if they haven't checked in yet.
        if (objAccount.Dreampass_Revoked__c)
        {
            objDreampass.inValidReason = 'Dreampass Revoked';
            objDreampass.isValid = false;
            return;
        }
        if (objAccount.Dreampass_Checkin_Time__c == null)
        {
            objDreampass.inValidReason = 'Attendee has not checked in';
            objDreampass.isValid = false;
            return;
        }
        
        //Next determine the Account type
        //If VIP... its valid
        if (objAccount.Type == 'VIP')
        {
            objDreampass.isValid = true;
            return;
        }
        
        //Next validate vax for Guests
        if (objAccount.Type == 'Guest' && !AccountHasVerifiedVax(objAccount.Id))
        {
            objDreampass.inValidReason = 'Guest has not provided proof of vaccination';
            objDreampass.isValid = false;
            return;
        }
        
        //Next verify they have a verified negative initial covid test
        if (!AccountHasVerifiedNegCovidTest(objAccount.Id))
        {
            objDreampass.inValidReason = 'Attendee does not have a negative covid test on file';
            objDreampass.isValid = false;
            return;
        }
        
        vaxhv__Health_Verification__c onsiteTest = getOnsitePCRTest(objAccount.Id);
        //Verify that it hasnt been more than timewindow hrs since checkin without PCR being administered
        if (onsiteTest == null)
        {
            objDreampass.inValidReason = '(Active until: ' + objAccount.Dreampass_Checkin_Time__c.AddHours(timewindow).format('E h:mm a') + '. No PCR.)';
            objDreampass.expiration = objAccount.Dreampass_Checkin_Time__c.AddHours(timewindow);
            if (Datetime.now() > objAccount.Dreampass_Checkin_Time__c.AddHours(timewindow))
            {
                objDreampass.inValidReason = 'Missing onsite PCR test after check in';
                objDreampass.isValid = false;
                return;
            }
        }
        
        //Finally verify that if they have taken their onsite PCR, verify the information
        if (onsiteTest != null && onsiteTest.vaxhv__HealthVerificationStatus__c != 'Verified')
        {
            objDreampass.inValidReason = '(Active until: ' + onsiteTest.safetycloud__TestDateTime__c.AddHours(timewindow).format('E h:mm a') + '. Pending PCR result.)';
            objDreampass.expiration = onsiteTest.safetycloud__TestDateTime__c.AddHours(timewindow);
            //If it was rejected...
            if (onsiteTest.vaxhv__HealthVerificationStatus__c == 'Rejected')
            {
                objDreampass.inValidReason = 'Onsite PCR test rejected';
                objDreampass.isValid = false;
                objDreampass.expiration = null;
                return;
            }
            //Else if we haven't received results in time
            else if (Datetime.now() > onsiteTest.safetycloud__TestDateTime__c.AddHours(timewindow))
            {
                objDreampass.inValidReason = 'Onsite PCR test results missing';
                objDreampass.isValid = false;
                return;                
            }
        }
        
        //if all these pass, the Dreampass is valid
        objDreampass.isValid = true;
    }
    
    public static void updateDreampassExpirations(boolean resync)
    {
        List<DreampassExpiration__c> objExpirations = new List<DreampassExpiration__c>([SELECT ID, Account__c, Dreampass_Active__c, Dreampass_Expiration__c, LastProcessed__c  FROM DreampassExpiration__c ORDER BY LastProcessed__c ASC]);
        List<Id> accountIDs = new List<Id>();
        for(DreampassExpiration__c objExpiration : objExpirations)
        {
            accountIDs.add(objExpiration.Account__c);
        }
        
        if (resync)
        {
            objExpirations = new List<DreampassExpiration__c>();
            List<Account> objAs = new List<Account>([SELECT ID FROM ACCOUNT WHERE ID NOT in: accountIDs]);
            for (Account objA : objAs)
            {
                DreampassExpiration__c objExpiration = new DreampassExpiration__c();
                objExpiration.Account__c = objA.Id;
                objExpirations.add(objExpiration);
            }
            if (objExpirations.size() > 0)
            {
                INSERT objExpirations;
            }
            return;
        }
        
        integer counter = 0;
        List<Account> allAccounts = new List<Account>([SELECT ID, Dreampass_Revoked__c, Dreampass_Checkin_Time__c, Type  FROM ACCOUNT]);
        List<DreampassExpiration__c> expirationstoUpdate = new List<DreampassExpiration__c>();
        
        for(DreampassExpiration__c objExpiration : objExpirations)
        {
            if (counter >= 40)
            {
                break;
            }

            Account objA = FindAccountbyId(allAccounts, objExpiration.Account__c);
            if (objA == null)
            {
                continue;
            }
            
            Dreampass objDreampass = new Dreampass();
            objDreampass.objAccount = objA;
            SetDreampassValidity(objDreampass);
            
            objExpiration.Dreampass_Active__c = objDreampass.isValid;
            objExpiration.Dreampass_Expiration__c = objDreampass.expiration;
            objExpiration.LastProcessed__c = Datetime.Now();
            expirationstoUpdate.add(objExpiration);
            
            counter+=1;
        }
        
        if (expirationstoUpdate.size() > 0)
        {
            UPDATE expirationstoUpdate;
        }

    }
    
    private static Account FindAccountbyId(List<Account> objAs, string accountId)
    {
        for (Account objA : objAs)
        {
            //Match on person Account
            if (objA.Id == accountId)
            {
                return objA;
            }
        }
        return null;
    }
    
    public static boolean AccountHasVerifiedVax(id accountId)
    {
        Integer verifiedvaxCount = [SELECT count() FROM vaxhv__Health_Verification__c WHERE vaxhv__PersonAccount__c = :accountId AND vaxhv__HealthVerificationMethod__c =: 'Proof of vaccination' AND vaxhv__HealthVerificationStatus__c =: 'Verified'];
        if (verifiedvaxCount > 0)
        {
            return true;
        }
        return false;
    }
    
    public static boolean AccountHasVerifiedNegCovidTest(id accountId)
    {
        Integer verifiedtestCount = [SELECT count() FROM vaxhv__Health_Verification__c WHERE vaxhv__PersonAccount__c = :accountId AND vaxhv__HealthVerificationMethod__c =: 'Negative COVID-19 test' AND vaxhv__HealthVerificationStatus__c =: 'Verified'];
        if (verifiedtestCount > 0)
        {
            return true;
        }
        return false;
    }
    
    public static boolean AccountHasVerifiedNegOnsitePCRTest(id accountId)
    {
        string occuranceId = 'onsitepcr';
        Integer verifiedtestCount = [SELECT count() FROM vaxhv__Health_Verification__c WHERE safetycloud__OccurrenceId__c =: occuranceId AND vaxhv__PersonAccount__c = :accountId AND vaxhv__HealthVerificationMethod__c =: 'Negative COVID-19 test' AND vaxhv__HealthVerificationStatus__c =: 'Verified'];
        if (verifiedtestCount > 0)
        {
            return true;
        }
        return false;
    }
    
    public static vaxhv__Health_Verification__c getOnsitePCRTest(id accountId)
    {
        string occuranceId = 'onsitepcr';
        List<vaxhv__Health_Verification__c> objHvs = New List<vaxhv__Health_Verification__c>([SELECT Id, vaxhv__HealthVerificationDocumentDate__c, vaxhv__HealthVerificationStatus__c, safetycloud__TestDateTime__c FROM vaxhv__Health_Verification__c WHERE safetycloud__OccurrenceId__c =: occuranceId AND vaxhv__PersonAccount__c = :accountId AND vaxhv__HealthVerificationMethod__c =: 'Negative COVID-19 test']);
        if (objHvs.size() > 0)
        {
            return objHVs[0];
        }
        return null;
    }
    
    public Class Dreampass
    {
        @AuraEnabled
        public Account objAccount;
        @AuraEnabled
        public Boolean isValid;
        @AuraEnabled
        public String inValidReason;
        @AuraEnabled
        public datetime expiration;
    }
}