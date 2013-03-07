Ext.define('AM.controller.Employees', {
  extend: 'Ext.app.Controller',

  stores: ['Employees'],
  models: ['Employee'],

  views: [
    'management.employee.List',
    'management.employee.Form'
  ],

  	refs: [
		{
			ref: 'list',
			selector: 'employeelist'
		} 
	],

  init: function() {
    this.control({
      'employeelist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				show : this.loadObjectList
      },
      'employeeform button[action=save]': {
        click: this.updateObject
      },
      'employeelist button[action=addObject]': {
        click: this.addObject
      },
      'employeelist button[action=editObject]': {
        click: this.editObject
      },
      'employeelist button[action=deleteObject]': {
        click: this.deleteObject
      } 
		
    });
  },
 

	loadObjectList : function(){
		console.log("Gonna load Object List");
	},

  addObject: function() {
		console.log("Gonna Add Object");
    var view = Ext.widget('employeeform');
    view.show();
  },

  editObject: function() {
		console.log("event listener editObject");
    var record = this.getList().getSelectedObject();
		if( record ) {
			console.log("The name is " + record.get("name"));
		}
    var view = Ext.widget('employeeform');
		if( view ) {
			console.log("The view is not nil");
		}
    view.down('form').loadRecord(record);
// view.show();
  },

  updateObject: function(button) {
		console.log("Gonna Call update user");
    var win = button.up('window');
    var form = win.down('form');

    var store = this.getEmployeesStore();
    var record = form.getRecord();
    var values = form.getValues();

		
		if( record ){
			console.log("Update action");
			record.set( values );
			 
			form.setLoading(true);
			record.save({
				success : function(record){
					form.setLoading(false);
					console.log("UPDATE is successful");
					//  since the grid is backed by store, if store changes, it will be updated
					store.load();
					win.close();
				},
				failure : function(record,op ){
					form.setLoading(false);
					console.log("UPDATE is a failure");
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
				}
			});
				
			 
		}else{
			//  no record at all  => gonna create the new one 
			console.log("NO USER. GONNA CREATE");
			var me  = this; 
			var newObject = new AM.model.Employee( values ) ;
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				success: function(record){
					console.log("This is successful");
					//  since the grid is backed by store, if store changes, it will be updated
					store.load();
					form.setLoading(false);
					win.close();
					
				},
				failure: function( record, op){
					form.setLoading(false);
					console.log("This is a failure");
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
				}
			});
		} 
  },

  deleteObject: function() {
    var record = this.getList().getSelectedObject();

    if (record) {
      var store = this.getEmployeesStore();
      store.remove(record);
      store.sync();
// to do refresh programmatically
		this.getList().query('pagingtoolbar')[0].doRefresh();
    }

  },

  selectionChange: function(selectionModel, selections) {
    var grid = this.getList();

    if (selections.length > 0) {
      grid.enableRecordButtons();
    } else {
      grid.disableRecordButtons();
    }
  }

});
