public class Dreampass_LabHelper 
{
    @InvocableMethod(label='Process Imported Lab Data')
    public static List<processLabResult> processLabResults()
    {
        List<processLabResult> results = new List<processLabResult>();
        processLabResult result = new processLabResult();
        result.numLabs = 0;
        result.numHVCreate = 0;
        result.numHVUpdate = 0;
        result.numPositives = 0;
        
        List<LabData__c> objLabs = new List<LabData__c>([SELECT EMail__c, Last_name__c, Birth_date__c, Sampling_date__c, Sampling_time__c, Test_result__c, Test_Antigen_PCR__c  FROM LabData__c WHERE Test_Antigen_PCR__c =: 'PCR' AND isProcessed__c = false]);
        List<Account> objAccounts = new List<Account>([SELECT ID, FirstName, LastName, PersonEmail, PersonBirthdate, Dreampass_OnsitePCRTestDate__c, Dreampass_CompanyName__c FROM Account]);
        List<vaxhv__Health_Verification__c> objHVs = new List<vaxhv__Health_Verification__c>([SELECT Id, vaxhv__PersonAccount__c, vaxhv__HealthVerificationStatus__c, vaxhv__TestResult__c, safetycloud__TestDateTime__c  FROM vaxhv__Health_Verification__c WHERE safetycloud__OccurrenceId__c  =: 'onsitepcr']);
        
        //Loop through this list
        for (LabData__c objLab : objLabs)
        {
            //First try to find an account match
            Account objA = findAMatch(objAccounts, objLab);
            if (objA != null)
            {
                //Now see if there is an associated Health Verification
                vaxhv__Health_Verification__c objHV = findHMatch(objHVs, objA);
                string HVstatus = '';
                if (string.isblank(objLab.Test_result__c))
                {
                    objLab.Test_result__c = '';
                }
                switch on objLab.Test_result__c.toLowerCase() {
                    when 'negative' {		// when block 1
                        HVstatus = 'Verified';
                    }	
                    when 'positive' {		// when block 2
                        HVstatus = 'Rejected';
                        result.numPositives+=1;
                    }
                    when 'pending' {		// when block 3
                        HVstatus = 'New';
                    }
                    when else {		  // default block, optional
                        HVstatus = 'New';
                    }
                }
                
                if (objHV == null)
                {
                    //we need to create a new HV
                    objHV = new vaxhv__Health_Verification__c();
                    objHV.safetycloud__OccurrenceId__c = 'onsitepcr';
                    objHV.safetycloud__TestDateTime__c = Datetime.newInstance(objLab.Sampling_date__c, objLab.Sampling_time__c);
                    objHV.vaxhv__EmailToReceiveNotifications__c = objA.PersonEmail;
                    objHV.vaxhv__EventDate__c = Date.today();
                    objHV.vaxhv__ExternalId__c = 'onsitepcrtest-' + objA.Id;
                    objHV.vaxhv__FirstName__c = objA.FirstName;
                    objHV.vaxhv__HasNotificationConsent__c = true;
                    objHV.vaxhv__HasReadTerms__c = true;
                    objHV.vaxhv__HealthVerificationDocumentDate__c = Date.today();
                    objHV.vaxhv__HealthVerificationMethod__c = 'Negative COVID-19 test';
                    objHV.vaxhv__HealthVerificationStatus__c = HVstatus;
                    objHV.vaxhv__Language__c = 'en_US';
                    objHV.vaxhv__LastName__c = objA.LastName;
                    objHV.vaxhv__PersonAccount__c = objA.Id;
                    objHV.Company__c = objA.Dreampass_CompanyName__c;
                    objHVs.add(objHV);
                    result.numHVCreate+=1;
                }
                else if (objHV.vaxhv__HealthVerificationStatus__c == 'New')
                {
                    objHV.vaxhv__HealthVerificationStatus__c = HVstatus;
                    objHV.safetycloud__TestDateTime__c = Datetime.newInstance(objLab.Sampling_date__c, objLab.Sampling_time__c);
                    result.numHVUpdate+=1;
                }
                objA.Dreampass_OnsitePCRTestDate__c = objHV.safetycloud__TestDateTime__c;
            }
            //Update lab to be processed
            objLab.isProcessed__c = true;
            result.numLabs+=1;
        }
        
        UPSERT objHVS;
        UPDATE objAccounts;
        UPDATE objLabs;
        
        results.add(result);
        return results;
    }
    
    private static Account findAMatch(List<Account> objAs, LabData__c lab)
    {
        for (Account objA : objAs)
        {
            //Match on email + birthdate
            if (String.isNotBlank(lab.Email__c) && String.isNotBlank(objA.PersonEmail) && lab.Birth_date__c != null && objA.PersonBirthdate != null 
                && lab.EMail__c.toLowerCase() == objA.PersonEmail.toLowerCase() && lab.Birth_date__c == objA.PersonBirthdate)
            {
                return objA;
            }
        }
        return null;
    }
    
    private static vaxhv__Health_Verification__c findHMatch(List<vaxhv__Health_Verification__c> objHVs, Account objA)
    {
        for (vaxhv__Health_Verification__c objHV : objHVs)
        {
            //Match on person Account
            if (objA.Id == objHV.vaxhv__PersonAccount__c)
            {
                return objHV;
            }
        }
        return null;
    }
    
    public class processLabResult
    {
        @InvocableVariable(label='Labs Processed')
        public integer numLabs;
        
        @InvocableVariable(label='Positive Results Processed')
        public integer numPositives;
        
        @InvocableVariable(label='Health Verifications Create')
        public integer numHVCreate;
          
        @InvocableVariable(label='Health Verifications Updated')
        public integer numHVUpdate;
        
        
    }
}