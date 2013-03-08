Ext.define('AM.controller.StockMigrations', {
  extend: 'Ext.app.Controller',

  stores: ['StockMigrations', 'Items'],
  models: ['StockMigration'],

  views: [
    'inventory.stockmigration.List',
    'inventory.stockmigration.Form',
		'inventory.itemdatabase.List'
  ],

  refs: [
		{
			ref: 'list',
			selector: 'stockmigrationlist'
		},
		{
			ref : 'itemList',
			selector : 'itemdatabaselist'
		}
	],

  init: function() {
    this.control({
      'stockmigrationlist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange// ,
        // 				afterrender : this.loadObjectList,
      },
      'stockmigrationform button[action=save]': {
        click: this.updateObject
      },
      'stockmigrationlist button[action=addObject]': {
        click: this.addObject
      },
      'stockmigrationlist button[action=editObject]': {
        click: this.editObject
      },
      'stockmigrationlist button[action=deleteObject]': {
        click: this.deleteObject
      } 
		
    });
  },
 
// the store will only be loaded if the item is clicked
	// loadObjectList : function(me){
	// 	me.getStore().load();
	// },

  addObject: function() {
		
		// I want to get the currently selected item 
		var record = this.getItemList().getSelectedObject();
		if(!record){
			return; 
		}
		 
    var view = Ext.widget('stockmigrationform');
		
		view.setParentData( record );
		 
		
		
		
    view.show(); 
  },

  editObject: function() {
		var parentRecord = this.getItemList().getSelectedObject();
    var record = this.getList().getSelectedObject();
    var view = Ext.widget('stockmigrationform');

    view.down('form').loadRecord(record);
		view.setParentData( parentRecord );
  },

  updateObject: function(button) {
    var win = button.up('window');
    var form = win.down('form');

		var parentRecord = this.getItemList().getSelectedObject();
    var store = this.getStockMigrationsStore();
    var record = form.getRecord();
    var values = form.getValues();

		
		if( record ){
			record.set( values );
			 
			form.setLoading(true);
			record.save({
				success : function(record){
					console.log("successfully loaded the shite in stock migration");
					form.setLoading(false);
					//  since the grid is backed by store, if store changes, it will be updated
					
					store.load({
						params: {
							item_id : parentRecord.get('id')
						}
					});
					win.close();
				},
				failure : function(record,op ){
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
				}
			});
				
			 
		}else{
			//  no record at all  => gonna create the new one 
			var me  = this; 
			var newObject = new AM.model.StockMigration( values ) ;
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				success: function(record){
					//  since the grid is backed by store, if store changes, it will be updated
					store.load({
						params: {
							item_id : parentRecord.get('id')
						}
					});
					form.setLoading(false);
					win.close();
					
				},
				failure: function( record, op){
					form.setLoading(false);
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
      var store = this.getStockMigrationsStore();
      store.remove(record);
      store.sync();
// to do refresh programmatically
		this.getList().query('pagingtoolbar')[0].doRefresh();
    }

  },

  selectionChange: function(selectionModel, selections) {
    var grid = this.getList();

		// var record = this.getList().getSelectedObject();

    if (selections.length > 0) {
      grid.enableRecordButtons();
    } else {
      grid.disableRecordButtons();
    }
 
  }

});
