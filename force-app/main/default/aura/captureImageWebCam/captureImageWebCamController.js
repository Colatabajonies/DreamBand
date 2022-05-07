({
    doInit : function(component, event, helper) 
    {
        if (component.get('v.videoLoaded'))
        {
            //Dont load the cam twice
            return;
        }
        
        component.set('v.videoLoaded', true);
        var width = 400; // scale the photo width to this
        var height = 0; // computed based on the input stream

     	var streaming = false;
        var video = null;
        var canvas = null;
        var photo = null;
        var startbutton = null;
        
        video = document.getElementById('video');
        
        canvas = document.getElementById('canvas');
        photo = document.getElementById('photo');
        startbutton = document.getElementById('startbutton');
        var clearbutton = document.getElementById('clearbutton');
        navigator.mediaDevices.getUserMedia({video: true, audio: false})
        .then(function(stream) {
            video.srcObject = stream;
            video.play();
        })
        .catch(function(err) {
            console.log("An error occurred: " + err);
        });
        
        video.addEventListener('canplay', function(ev){
            if (!streaming) {
                height = video.videoHeight / (video.videoWidth/width);
                
                // Firefox currently has a bug where the height can't be read from
                // the video, so make assumptions if this happens.
                
                if (isNaN(height)) {
                    height = width / (4/3);
                }
                
                //video.setAttribute('width', width);
                //video.setAttribute('height', height);
                //canvas.setAttribute('width', width);
                //canvas.height = 240;
                streaming = true;
            }
        }, false);
    },
    
    takephoto:function(component, event, helper) 
    {
        component.set('v.saveDisabled', false);
        var width = 400; // scale the photo width to this
        var height = 300; 
        var photo = document.getElementById('photo');
        var canvas = document.getElementById('canvas');
        var context = canvas.getContext('2d');
        if (width && height) {
            canvas.width = width;
            canvas.height = height;
            context.drawImage(video, 0, 0, width, height);
            var data = canvas.toDataURL('image/png');
            photo.setAttribute('src', data);
        } else {
            //ClearPhoto
        }
    },
    
    clearphoto:function(component, event, helper) 
    {
        component.set('v.saveDisabled', true);
        var photo = document.getElementById('photo');
        var canvas = document.getElementById('canvas');
        var context = canvas.getContext('2d');
        context.fillStyle = "#AAA";
        context.fillRect(0, 0, canvas.width, canvas.height);
        
        var data = canvas.toDataURL('image/png');
        photo.setAttribute('src', data);
    },
    
    savePhoto: function(component, event, helper) {
        component.set('v.Spinner', true);
        
        var image = document.getElementById("photo");
        var action = component.get('c.saveImageFile'); 
       	action.setParams({
            "imageUrl" : photo.getAttribute('src'),
            "recordId" : component.get('v.recordId')
        });
        action.setCallback(this, function(a)
        {
            component.set('v.spinner', false);
            //continue
            
            
            var navigate = component.get("v.navigateFlow");
            if (navigate)
            {
                var availableActions = component.get('v.availableActions');
                for (var i = 0; i < availableActions.length; i++) {
                    if (availableActions[i] == "NEXT") {
                        navigate("NEXT");
                    } else if (availableActions[i] == "FINISH") {
                        navigate("FINISH");
                    }
                }
            }
        });
        $A.enqueueAction(action);
	},
})