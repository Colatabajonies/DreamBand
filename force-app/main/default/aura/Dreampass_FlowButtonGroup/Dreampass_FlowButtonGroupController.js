({
    click1 : function(component, event, helper) 
    {
        component.set('v.output1', true);
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
        //Advance Flow
        var navigate = component.get("v.navigateFlow");
        if (navigate)
        {
            navigate("NEXT");
        }
    }
})