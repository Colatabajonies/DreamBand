public class Dreampass_AttendeeSearch_Ctrl 
{
    @AuraEnabled
    public static list<Account> getAccountList()
    {
        List<Account> accList= [Select Id, Name, PersonEmail, Dreampass_CompanyName__c From Account Order By CreatedDate];
        if(accList != null && accList.size()>0){
            return accList;
        }
        else{return null;}
    }
}