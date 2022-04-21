({
    onInit : function(component, event, helper) 
    {
        component.set("v.Spinner", false);
	},
    
	handleRFID : function(component, event, helper) 
    {
        component.set("v.Spinner", true);
        component.set('v.access', false);
        component.set('v.objAccount', null);
        var rfid = event.getParam("payload");
        //alert('PAYLOAD RECEIVED:' + rfid);
        component.set('v.rFID', rfid);
        helper.lookupRFID(component, event, helper);
	}
})