({
    onInit : function(component, event, helper) 
    {
        //Add postmessage listener for QR Code Scanner
        if (window && window.addEventListener != null)
        {
            window.addEventListener('message', $A.getCallback(function(postMessageEvent)
                                                              {
                                                                  if (component.get("v.camera") && postMessageEvent.data.name == 'qrcodescan')
                                                                  {
                                                                      //alert(postMessageEvent.data.payload);
                                                                      component.set('v.scanval', postMessageEvent.data.payload);
                                                                      
                                                                      //Advance Flow
                                                                      var navigate = component.get("v.navigateFlow");
                                                                      if (navigate)
                                                                      {
                                                                          navigate("NEXT");
                                                                      }
                                                                  }
                                                              }))
        }
    },
    
    handleRFID : function(component, event, helper) 
    {
        if (component.get("v.rfid"))
        {
            var rfid = event.getParam("payload");
            //alert('PAYLOAD RECEIVED:' + rfid);
            component.set('v.scanval', rfid);
            //Advance Flow
            var navigate = component.get("v.navigateFlow");
            if (navigate)
            {
                navigate("NEXT");
            }
        }
    },
})