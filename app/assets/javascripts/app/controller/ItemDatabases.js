Ext.define('AM.controller.ItemDatabases', {
  extend: 'Ext.app.Controller',

  stores: ['Items'],
  models: ['Item'],

  views: [
    'inventory.itemdatabase.List',
    'inventory.itemdatabase.Form',
		'inventory.stockmigration.List',
  ],

  refs: [
		{
			ref: 'list',
			selector: 'itemdatabaselist'
		},
		{
			ref : 'stockMigrationList',
			selector : 'stockmigrationlist'
		}
	],

  init: function() {
    this.control({
      'itemdatabaselist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				afterrender : this.loadObjectList,
      },
      'itemdatabaseform button[action=save]': {
        click: this.updateObject
      },
      'itemdatabaselist button[action=addObject]': {
        click: this.addObject
      },
      'itemdatabaselist button[action=editObject]': {
        click: this.editObject
      },
      'itemdatabaselist button[action=deleteObject]': {
        click: this.deleteObject
      },
			'stockmigrationform form' : {
				'item_quantity_changed' : function(){
					this.getItemsStore().load();
				}
			}
			
		
    });
  },
 

	loadObjectList : function(me){
		me.getStore().load();
	},

  addObject: function() {
    var view = Ext.widget('itemdatabaseform');
    view.show();
  },

  editObject: function() {
    var record = this.getList().getSelectedObject();
		if(!record){return;}
    var view = Ext.widget('itemdatabaseform');

    view.down('form').loadRecord(record);
  },

  updateObject: function(button) {
    var win = button.up('window');
    var form = win.down('form');

    var store = this.getItemsStore();
    var record = form.getRecord();
    var values = form.getValues();

		
		if( record ){
			record.set( values );
			 
			form.setLoading(true);
			record.save({
				success : function(record){
					form.setLoading(false);
					//  since the grid is backed by store, if store changes, it will be updated
					store.load();
					win.close();
				},
				failure : function(record,op ){
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					this.reject();
				}
			});
				
			 
		}else{
			//  no record at all  => gonna create the new one 
			var me  = this; 
			var newObject = new AM.model.Item( values ) ;
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				success: function(record){
					//  since the grid is backed by store, if store changes, it will be updated
					store.load();
					form.setLoading(false);
					win.close();
					
				},
				failure: function( record, op){
					form.setLoading(false);
					var message  = op.request.scope.reader.jsonData["message"];
					var errors = message['errors'];
					form.getForm().markInvalid(errors);
					this.reject();
				}
			});
		} 
  },

  deleteObject: function() {
    var record = this.getList().getSelectedObject();

    if (record) {
      var store = this.getItemsStore();
      store.remove(record);
      store.sync();
// to do refresh programmatically
		this.getList().query('pagingtoolbar')[0].doRefresh();
    }

  },

  selectionChange: function(selectionModel, selections) {
    var grid = this.getList();
		var record = this.getList().getSelectedObject();
		
		if(!record){
			return; 
		}
		var stockMigrationGrid = this.getStockMigrationList();
		stockMigrationGrid.setTitle("StockMigration: " + record.get('name'));
		stockMigrationGrid.getStore().load({
			params : {
				item_id : record.get('id')
			},
			callback : function(records, options, success){
				var totalObject  = records.length;
				if( totalObject ===  0 ){
					stockMigrationGrid.enableAddButton(); 
				}else{
					stockMigrationGrid.disableAddButton(); 
				}
			}
		});

    if (selections.length > 0) {
      grid.enableRecordButtons();
    } else {
      grid.disableRecordButtons();
    }

		// load the stock migration
		// load the stock adjustment 
  }

});
