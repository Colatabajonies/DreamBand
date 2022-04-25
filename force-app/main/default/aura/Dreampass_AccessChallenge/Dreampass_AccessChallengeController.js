({
    onInit : function(component, event, helper) 
    {
        component.set("v.Spinner", false);
        component.set('v.device', $A.get("$Browser.formFactor"));
        
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
        component.set('v.objAccount', null);
        var rfid = event.getParam("payload");
        //alert('PAYLOAD RECEIVED:' + rfid);
        component.set('v.scanval', rfid);
        helper.lookupRFID(component, event, helper);
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