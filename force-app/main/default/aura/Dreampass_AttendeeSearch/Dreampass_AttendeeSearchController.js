({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Name', fieldName:'Name',sortable:true,type:'text'},
            {label: 'Email', fieldName:'PersonEmail',sortable:true,type:'text'},
            {label: 'Company', fieldName:'Dreampass_CompanyName__c',sortable:true,type:'text'}
        ]);
        helper.getAccounts(component, helper);
    },
    rowSelected: function (cmp, event, helper) 
    {
        var selectedRows = event.getParam('selectedRows');
        if (selectedRows != null && selectedRows.length > 0)
        {
            //alert('SelectedID : ' +selectedRows[0].Id);
            cmp.set('v.selectedAccountID', selectedRows[0].Id);
        }
        else
        {
            cmp.set('v.selectedAccountID', '');
        }
    },
    
    createNewAttendee: function(cmp, event, helper)
    {
        cmp.set('v.createNewAttendee', true);
        //Try and advance the flow
        var navigate = cmp.get("v.navigateFlow");
        if (navigate)
        {
            navigate("NEXT");
        }
    },
    
    updateSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },
    searchTable: function (cmp, event, helper) {
        var allRecords = cmp.get("v.allData");
        var searchFilter = event.getSource().get("v.value").toUpperCase();
        var tempArray =[];
        var i;
        for(i=0; i<allRecords.length; i++){
            if(searchFilter != '' && ((allRecords[i].Name && allRecords[i].Name.toUpperCase().indexOf(searchFilter) != -1) || 
               (allRecords[i].PersonEmail && allRecords[i].PersonEmail.toUpperCase().indexOf(searchFilter) != -1))){
                tempArray.push(allRecords[i]);
            }
        }
        cmp.set("v.recordList",tempArray);
    }
    
})