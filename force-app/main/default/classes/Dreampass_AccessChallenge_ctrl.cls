public class Dreampass_AccessChallenge_ctrl 
{
    @AuraEnabled
    public static Dreampass_Helper.Dreampass getDreampassFromDreambandId(string rfID, string locationId)
    {
        Dreampass_Helper.Dreampass objDp = Dreampass_Helper.getDreampassFromDreambandId(rfID);
        if (objDp == null)
        {
            return null;
        }
        Dreampass_Helper.logAccessChallenge(objDp.objAccount, locationId, objDp.isValid);
        return objDp;
    }
    
    @AuraEnabled
    public static Dreampass_Helper.Dreampass getDreampassFromQR(string qrcode, string locationId)
    {
        Dreampass_Helper.Dreampass objDp = Dreampass_Helper.getDreampassFromQR(qrcode);
        //system.debug('Dreampass returned:' + objDP);
        if (objDp == null)
        {
            return null;
        }
        Dreampass_Helper.logAccessChallenge(objDp.objAccount, locationId, objDp.isValid);
        return objDp;
    }
}