({
    doinit: function (component, event, helper)
    {
        window.addEventListener('keydown', (event) => {
            //alert(event.key);
            
            //alert(component.get('v.inputText'));
            //if (component.get('v.inputText').length >= component.get('v.rfidLength'))
            
            //first see if we need to submit
            if(event.key == 'Enter')
            {
            if (component.get('v.inputText') != '')
            {
            helper.fireReadEvent(component, event, helper);
        }
                                component.set('v.inputText', '');
        return;
    }
    else if (event.key == 'CapsLock' || event.key == 'Shift' || event.key.length > 1)
    {
    return;
}
 
 var oldString = component.get('v.inputText');
component.set('v.inputText', oldString + event.key);
//alert(component.get('v.inputText'));
});
},
    
    clearRFID : function(component, event)
{
    component.set('v.inputText', '');
},
    
})