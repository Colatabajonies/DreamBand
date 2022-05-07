({
    click1 : function(component, event, helper) 
    {
        component.set('v.output1', true);
        component.set('v.output2', false);
        component.set('v.output3', false);
        //Advance Flow
        var navigate = component.get("v.navigateFlow");
        if (navigate)
        {
            navigate("NEXT");
        }
    },
    click2 : function(component, event, helper) 
    {
        component.set('v.output2', true);
        component.set('v.output1', false);
        component.set('v.output3', false);
        //Advance Flow
        var navigate = component.get("v.navigateFlow");
        if (navigate)
        {
            navigate("NEXT");
        }
    },
    click3 : function(component, event, helper) 
    {
        component.set('v.output3', true);
        component.set('v.output2', false);
        component.set('v.output1', false);
        //Advance Flow
        var navigate = component.get("v.navigateFlow");
        if (navigate)
        {
            navigate("NEXT");
        }
    }
})