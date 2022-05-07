public class Dreampass_CovidTestVerified 
{
    @InvocableMethod(label='See if Account is Covid Negative Verified')
    public static List<Boolean> getCovidTestVerified(List<String> accoundIds) 
    {
        List<Boolean> results = new List<Boolean>();
        for (String accountId : accoundIds)
        {
            results.add(Dreampass_Helper.AccountHasVerifiedNegCovidTest(accountId));
        }
        return results;
    }
}