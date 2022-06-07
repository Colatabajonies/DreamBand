public class Dreampass_FlowGetCollectionFromIDList 
{
    @InvocableMethod(label='Get Contact Collection From List of Contact Ids')
    public static List<List<Contact>> getAccount(List<List<String>> requests) 
    {
        List<Contact> objContacts = new List<Contact>();
        for (List<String> request : requests)
        {
            try
            {
                objContacts = new List<Contact>([SELECT ID, AccountId FROM Contact WHERE Id In: request]);
                return new List<List<Contact>>{objContacts};
            }
            catch(Exception ex)
            {
                system.debug('Not Valid Dreampass');
            }
        }
        return null;
    }
}