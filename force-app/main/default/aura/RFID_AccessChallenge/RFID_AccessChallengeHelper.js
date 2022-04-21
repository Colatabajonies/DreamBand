({
	lookupRFID : function(component, event, helper) 
    {
		var action = component.get('c.lookupAccount'); 
        action.setParams({
            "rfID" : component.get("v.rFID") 
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
        });
        $A.enqueueAction(action);
	}
})