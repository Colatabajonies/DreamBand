({
    lookupRFID : function(component, event, helper) 
    {
        this.setLocation(component, event, helper);
        var action = component.get('c.lookupDreamband'); 
        action.setParams({
            "rfID" : component.get("v.scanval"),
            "locationId" : component.get("v.locationId")
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS' && a.getReturnValue() != null) {
                var theAccount = a.getReturnValue();
                component.set('v.objAccount', theAccount);
                component.set('v.access', theAccount.DreampassAccess__c);
                component.set("v.Spinner", false);
            }
            else if (state == 'SUCCESS' && a.getReturnValue() == null)
            {
                component.set('v.objAccount', null);
                component.set('v.access', false);
                component.set("v.Spinner", false);
            }
                else
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "type": "error",
                        "message":  "Error Looking up RFID"
                    });
                    toastEvent.fire();
                    component.set('v.objAccount', null);
                    component.set('v.access', false);
                    component.set("v.Spinner", false);
                }
        });
        $A.enqueueAction(action);
    },
    
    lookupQRCode : function(component, event, helper) 
    {
        var invalid = false;
        try 
        {
            var hvid = JSON.parse(component.get("v.scanval")).v;
            if (hvid == null || hvid == '')
            {
                invalid = true;
            }
        } catch (e) 
        {
            invalid = true;
        }
        
        if (invalid)
        {
            component.set('v.objAccount', null);
            component.set('v.access', false);
            component.set("v.Spinner", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error",
                "type": "error",
                "message":  "Invalid QR code"
            });
            toastEvent.fire();
            
            return;
        }
        
        //Else call apex
        this.setLocation(component, event, helper);
        var action = component.get('c.lookupDreampass'); 
        action.setParams({
            "qrcode" : component.get("v.scanval"),
            "locationId" : component.get("v.locationId") 
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS' && a.getReturnValue() != null) {
                var theAccount = a.getReturnValue();
                component.set('v.objAccount', theAccount);
                component.set('v.access', theAccount.DreampassAccess__c);
                component.set("v.Spinner", false);
            }
            else if (state == 'SUCCESS' && a.getReturnValue() == null)
            {
                component.set('v.objAccount', null);
                component.set('v.access', false);
                component.set("v.Spinner", false);
            }
                else
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "type": "error",
                        "message":  "Error Looking up QR code"
                    });
                    toastEvent.fire();
                    component.set('v.objAccount', null);
                    component.set('v.access', false);
                    component.set("v.Spinner", false);
                }
        });
        $A.enqueueAction(action);
    },
    
    setLocation : function(component, event, helper)
    {
        const autoCompleteComponent = component.find("log-location");
        if(autoCompleteComponent){
            //get selected option from auto complete component's selectedOption attribute
            const selectedOption = autoCompleteComponent.get("v.selectedOption");
            component.set("v.locationId", selectedOption);
        }
        
    },
})