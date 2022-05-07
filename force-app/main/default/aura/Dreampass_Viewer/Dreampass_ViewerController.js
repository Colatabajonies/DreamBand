({
	onInit : function(component, event, helper) 
    {
		var action = component.get('c.getDreampassFromAccountId'); 
        action.setParams({
            "accountId" : component.get("v.recordId"),
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS' && a.getReturnValue() != null) {
                var objDreampass = a.getReturnValue();
                component.set('v.objAccount', objDreampass.objAccount);
                component.set('v.access', objDreampass.isValid);
                component.set('v.reason', objDreampass.inValidReason);
                
            }
            else if (state == 'SUCCESS' && a.getReturnValue() == null)
            {
                component.set('v.objAccount', null);
                component.set('v.access', false);
                component.set('v.reason', '');
                
            }
                else
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "type": "error",
                        "message":  "Error Retrieving Dreampass"
                    });
                    toastEvent.fire();
                    component.set('v.objAccount', null);
                    component.set('v.access', false);
                    component.set('v.reason', '');
                    
                }
        });
        $A.enqueueAction(action);
	}
})