({
    doinit: function (component, event, helper)
    {
        window.addEventListener('keydown', (event) => {
           //alert(event.key);
            
            //alert(component.get('v.inputText'));
            //if (component.get('v.inputText').length >= component.get('v.rfidLength'))
            if (event.key == 'CapsLock')
            {
            	return;
        	}
            else if(event.key == 'Enter')
            {
            	helper.fireReadEvent(component, event, helper);
            	component.set('v.inputText', '');
            	return;
            }
            var oldString = component.get('v.inputText');
            component.set('v.inputText', oldString + event.key);
            //alert(component.get('v.inputText'));
    	});
	},
})