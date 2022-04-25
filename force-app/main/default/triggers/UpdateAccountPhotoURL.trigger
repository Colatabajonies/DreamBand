trigger UpdateAccountPhotoURL on ContentVersion (after insert) 
{
    List<Account> objAccounts = new List<Account>();
    for (ContentVersion cv : Trigger.New)
    {
        if (cv.Document_Type__c.tolowercase() == 'image' && cv.FirstPublishLocationId != null && ((string)cv.FirstPublishLocationId).startswith('001'))
        {
            //Get the account and update it
            List<Account> objAccounts2 = new List<Account>([SELECT Id, PhotoURL__c from Account WHERE ID =: cv.FirstPublishLocationId]);
            if (objAccounts2.size() > 0 )
            {
                objAccounts2[0].PhotoURL__c = '/sfc/servlet.shepherd/version/download/' + cv.Id;
                objAccounts.add(objAccounts2[0]);
            }
        }
    }
    if (objAccounts.size() > 0)
    {
        UPDATE objAccounts;
    }
}