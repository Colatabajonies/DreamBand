public class Dreampass_VaxVerifyAction 
{
    @InvocableMethod(label='See if Account is Vaccine Verified')
    public static List<Boolean> getVaccineVerified(List<String> accoundIds) 
    {
        List<Boolean> results = new List<Boolean>();
        for (String accountId : accoundIds)
        {
            results.add(Dreampass_Helper.AccountHasVerifiedVax(accountId));
        }
        return results;
    }
}