({
	init : function (component, event, helper) 
    {
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        // In that component, start your flow. Reference the flow's API Name.
        flow.startFlow("Davos_Registration_Flow");
    },
    
    handleStatusChange : function (component, event, helper)
    {
        if (event.getParam("locationName") == 'Scan_QR_Code' || event.getParam("locationName") == "Complete")
        {
            component.set('v.showStartOverButton', false);
        }
        else
        {
            component.set('v.showStartOverButton', true);
        }
    },
    
    startover : function (component, event, helper)
    {
        window.location.reload();
    },
})