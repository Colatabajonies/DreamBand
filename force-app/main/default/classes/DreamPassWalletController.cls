public class DreamPassWalletController 
{
    @InvocableMethod(label='Generate Dreampass Apple Pass Attachment')
    public static List<String> generateDreampass(List<dpGenerateRequest> requests) 
    {
        List<string> results = new List<string>();
        try
        {
            for (dpGenerateRequest request : requests) 
            {
                vaxhv__Health_Verification__c objHV = [SELECT ID, vaxhv__EmailToReceiveNotifications__c, safetycloud__AccessStartTime__c, safetycloud__AccessEndTime__c, vaxhv__FirstName__c, vaxhv__LastName__c, vaxhv__PersonAccount__c   FROM vaxhv__Health_Verification__c  WHERE ID=: request.HVID];
                Contact objc = [SELECT ID FROM CONTACT WHERE AccountID=: objHV.vaxhv__PersonAccount__c ];
                string qr = '{"v":"' + objHV.id + '","vs":"' + objHV.safetycloud__AccessStartTime__c + '","ve":"' + objHV.safetycloud__AccessEndTime__c + '"}';
                Blob passFile = DreamPassWalletController.getDreamPassBlob(request.WalletSetting, objHV.vaxhv__FirstName__c + ' ' + objHV.vaxhv__LastName__c, objHV.Id, qr);
                //Attach this to the file
                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
                conVer.PathOnClient = 'dreampass.pkpass'; // The files name, extension is very important here which will help the file in preview.
                conVer.Title = 'Dreampass'; // Display name of the files
                conVer.VersionData = passFile; // converting your binary string to Blog
                //conVer.External_Approved__c = true;
                conVer.FirstPublishLocationId = request.HVID;
                insert conVer;    //Insert ContentVersion
                //results.add(conVer.Id);
                system.debug('Inserted ConVersion');
                // First get the content document Id from ContentVersion
                Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                //Create ContentDocumentLink
                ContentDocumentLink cDe = [SELECT ID, Visibility FROM ContentDocumentLink WHERE LinkedEntityId=: request.HVID AND ContentDocumentId =: conDoc LIMIT 1];
                cDe.Visibility = 'AllUsers';
                results.add(cDe.Id);
                UPDATE cDe;
            }
        }
        catch(Exception e)
        {
            system.debug('Error generating dreampass - ' + e.getMessage() + 'at Line number ' + e.getLineNumber());
            return null;
        }
        return results;
    }
    
    public class dpGenerateRequest 
    {        
        @InvocableVariable(label='The Apple Wallet Setting Name' required=true)
        public string WalletSetting;
        
        @InvocableVariable(label='Health Verification ID' required=true)
        public string HVID;
        
    }
    
    public static Blob getDreamPassBlob(string passtype, String Name, string sn, String qr)
    {
        //system.debug('Generating Dreampass Blob');
        AppleWalletGenerator gen = new AppleWalletGenerator();
        String pass;
        Blob passData;
        //system.debug('Getting Settings');
        gen.getWalletSettings(passtype);
        //system.debug('Getting JSON');
        pass = createDreampassJSON(gen.ws, Name, sn, qr);
        //system.debug('Generating Resource Blob');
        gen.getResourceBlob();
        //system.debug('Generating Passkey file');
        passData = gen.getpkpassFile(pass,gen.resourceBlob);
        
        return passData;
    }
    
    @AuraEnabled
    public static String getStringEncodedDreampassbyHVID(string passtype, string HVId)
    {
        vaxhv__Health_Verification__c objHV = [SELECT ID, vaxhv__EmailToReceiveNotifications__c, safetycloud__AccessStartTime__c, safetycloud__AccessEndTime__c, vaxhv__FirstName__c, vaxhv__LastName__c, vaxhv__PersonAccount__c   FROM vaxhv__Health_Verification__c  WHERE ID=: HVId];
        Contact objc = [SELECT ID FROM CONTACT WHERE AccountID=: objHV.vaxhv__PersonAccount__c ];
        string qr = '{"v":"' + objHV.id + '","vs":"' + objHV.safetycloud__AccessStartTime__c + '","ve":"' + objHV.safetycloud__AccessEndTime__c + '"}';
        
        return EncodingUtil.base64Encode(getDreamPassBlob(passtype,objHV.vaxhv__FirstName__c + ' ' + objHV.vaxhv__LastName__c, objHV.Id, qr));
    }
    
    public static String createDreampassJSON(Wallet_Setting__C ws, string attendeeName, string sn, string qr)
    {
        ApplePassBookDictionary pass = new ApplePassBookDictionary();
        pass.formatVersion = 1;
        pass.organizationName = ws.Organization_Name__c; 
        pass.description = ws.Pass_Description__c;
        pass.passTypeIdentifier = ws.Pass_Identifier__c; 
        pass.serialNumber = ws.Name + '-' + sn;
        pass.teamIdentifier = ws.Team_Identifier__c;
        pass.webServiceURL = 'https://example.com/passes/'; //tbd
        pass.authenticationToken = 'vxwxd7J8AlNNFPS8k0a0FfUFtq0ewzFdc'; //tbd
        //pass.relevantDate = '2023-01-31T14:25-08:00';
        pass.relevantDate = ws.eventStart__c.format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
        
        List<ApplePassBookDictionary.locationKey> locations = new List<ApplePassBookDictionary.locationKey>();
        ApplePassBookDictionary.locationKey location = new ApplePassBookDictionary.locationKey();
        location.longitude = -122.3748889;
        location.latitude = 37.6189722;
        locations.add(location);
        
        location = new ApplePassBookDictionary.locationKey();
        location.longitude = -122.03118;
        location.latitude = 7.33182;
        locations.add(location);
        
        pass.locations = locations;
        
        List<ApplePassBookDictionary.barcodeKey> barcodes = new List<ApplePassBookDictionary.barcodeKey>();
        ApplePassBookDictionary.barcodeKey barcode = new ApplePassBookDictionary.barcodeKey();
        barcode.message = qr;
        barcode.format = 'PKBarcodeFormatQR';
        barcode.messageEncoding = 'iso-8859-1';
        barcodes.add(barcode);
        pass.barcodes = barcodes;
        
        pass.foregroundColor = 'rgb(255, 255, 255)';
        pass.backgroundColor = 'rgb(60, 65, 76)';
        
        List<ApplePassBookDictionary.fieldDictKey> primaryFields = new List<ApplePassBookDictionary.fieldDictKey>();
        ApplePassBookDictionary.fieldDictKey  field = new ApplePassBookDictionary.fieldDictKey();
        field.key = 'event';
        field.label = 'Event';
        field.value = ws.EventName__c;
        primaryFields.add(field);
        
        List<ApplePassBookDictionary.fieldDictKey> secondaryFields = new List<ApplePassBookDictionary.fieldDictKey>();
        field = new ApplePassBookDictionary.fieldDictKey();
        field.key = 'loc';
        field.label = 'Location';
        field.value = ws.Location__c;
        secondaryFields.add(field);
        field = new ApplePassBookDictionary.fieldDictKey();
        field.key = 'date';
        field.label = 'Date';
        field.value = ws.eventStart__c.format('MMM') + ' ' + ws.eventStart__c.format('d') + ', ' + ws.eventStart__c.format('yyyy');
        secondaryFields.add(field);
        
        List<ApplePassBookDictionary.fieldDictKey> auxiliaryFields = new List<ApplePassBookDictionary.fieldDictKey>();
        field = new ApplePassBookDictionary.fieldDictKey();
        field.key = 'attendee';
        field.label = 'Attendee';
        field.value = attendeeName;
        auxiliaryFields.add(field);
        
        pass.eventTicket = new ApplePassBookDictionary.passStructureKey();
        pass.eventTicket.primaryFields = primaryFields;
        pass.eventTicket.secondaryFields = secondaryFields;
        pass.eventTicket.auxiliaryFields = auxiliaryFields;
        
        return JSON.serialize(pass,true);
    }
    
}