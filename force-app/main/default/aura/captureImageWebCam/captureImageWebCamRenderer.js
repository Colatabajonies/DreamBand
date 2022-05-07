({
	unrender : function(component, helper) 
    {
        try
        {
            document.getElementById('video').srcObject.getTracks()[0].stop();
	        document.getElementById('video').srcObject.getTracks()[0].enabled = false;
        }
        catch(error)
        {
            console.error(error);
        }
        
        this.superUnrender();
         
    },
})