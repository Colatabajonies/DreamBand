({
    onInit : function(component, event, helper) 
    {
        component.set("v.Spinner", false);
        var device = $A.get("$Browser.formFactor");
        component.set('v.device', device);
        
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('&'); //Split by & so that you get the key value pairs separately in a list
        var match = false;
        for (var i = 0; i < sURLVariables.length; i++) {
            var sParameterName = sURLVariables[i].split('='); //to split the key from the value.
            if (sParameterName[0] === 'cam') 
            { //lets say you are looking for param name - firstName
                sParameterName[1] === undefined ? '' : sParameterName[1];
                if (sParameterName[1] != '')
                {
                    match = true;
                }
            }
        }
        
        if (device == 'DESKTOP' || match)
        {
            component.set('v.camera', true);
        }
        
        //Add postmessage listener for QR Code Scanner
        if (window && window.addEventListener != null)
        {
            window.addEventListener('message', $A.getCallback(function(postMessageEvent)
                                                              {
                                                                  if (postMessageEvent.data.name == 'qrcodescan')
                                                                  {
                                                                      //alert(postMessageEvent.data.payload);
                                                                      component.set("v.Spinner", true);
                                                                      component.set('v.access', false);
                                                                      component.set('v.reason', '');
                                                                      component.set('v.objAccount', null);
                                                                      component.set('v.scanval', postMessageEvent.data.payload);
                                                                      helper.lookupQRCode(component, event, helper);
                                                                  }
                                                              }))
        }
    },
    
    handleRFID : function(component, event, helper) 
    {
        component.set("v.Spinner", true);
        component.set('v.access', false);
        component.set('v.reason', '');
        component.set('v.objAccount', null);
        var rfid = event.getParam("payload");
        //alert('PAYLOAD RECEIVED:' + rfid);
        component.set('v.scanval', rfid);
        //see if we could have received an QR code
        if (rfid.startsWith('{') && rfid.endsWith('}'))
        {
            //Call QR Code method
            helper.lookupQRCode(component, event, helper);            
        }
        else
        {
            helper.lookupRFID(component, event, helper);
        }
    },
    
    onfocus : function(component, event, helper) 
    {
        component.set('v.focuslost', false);
    },
    
    onfocusout : function(component, event, helper) 
    {
        component.set('v.focuslost', true);
    },
    
    clearrfid : function(component, event, helper) 
    {
        var childCmp = component.find("rfidReader");
        // call the aura:method in the child component
        childCmp.clearRFID();
    }
})