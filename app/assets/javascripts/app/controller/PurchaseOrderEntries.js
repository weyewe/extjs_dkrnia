Ext.define('AM.controller.PurchaseOrderEntries', {
  extend: 'Ext.app.Controller',

  stores: ['PurchaseOrderEntries', 'PurchaseOrders'],
  models: ['PurchaseOrderEntry'],

  views: [
    'inventory.purchaseorderentry.List',
    'inventory.purchaseorderentry.Form',
		'inventory.purchaseorder.List'
  ],

  refs: [
		{
			ref: 'list',
			selector: 'purchaseorderentrylist'
		},
		{
			ref : 'parentList',
			selector : 'purchaseorderlist'
		}
	],

  init: function() {
    this.control({
      'purchaseorderentrylist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange 
      },
      'purchaseorderentryform button[action=save]': {
        click: this.updateObject
      },
      'purchaseorderentrylist button[action=addObject]': {
        click: this.addObject
      },
      'purchaseorderentrylist button[action=editObject]': {
        click: this.editObject
      },
      'purchaseorderentrylist button[action=deleteObject]': {
        click: this.deleteObject
      },

			// monitor parent(purchase_order) update
			'purchaseorderlist' : {
				'updated' : this.reloadStore,
				'confirmed' : this.reloadStore,
				'deleted' : this.cleanList
			}
		
    });
  },

	reloadStore : function(record){
		var list = this.getList();
		var store = this.getPurchaseOrderEntriesStore();
		
		store.load({
			params : {
				purchase_order_id : record.get('id')
			}
		});
		
		list.setObjectTitle(record);
	},
	
	cleanList : function(){
		var list = this.getList();
		var store = this.getPurchaseOrderEntriesStore();
		
		list.setTitle('');
		store.remove(); 
	},
 

  addObject: function() {
		
		// I want to get the currently selected item 
		var record = this.getParentList().getSelectedObject();
		if(!record){
			return; 
		}
		 
    var view = Ext.widget('purchaseorderentryform');
		view.setParentData( record );
    view.show(); 
  },

  editObject: function() {
		var parentRecord = this.getParentList().getSelectedObject();
    var record = this.getList().getSelectedObject();
    var view = Ext.widget('purchaseorderentryform');

    view.down('form').loadRecord(record);
		view.setParentData( parentRecord );
  },

  updateObject: function(button) {
    var win = button.up('window');
    var form = win.down('form');

		var parentRecord = this.getParentList().getSelectedObject();
    var store = this.getPurchaseOrderEntriesStore();
    var record = form.getRecord();
    var values = form.getValues();

		
		if( record ){
			record.set( values );
			 
			form.setLoading(true);
			record.save({
				params : {
					purchase_order_id : parentRecord.get('id')
				},
				success : function(record){
					console.log("successfully loaded the shite in stock migration");
					form.setLoading(false);
					//  since the grid is backed by store, if store changes, it will be updated
					// form.fireEvent('item_quantity_changed');
					store.load({
						params: {
							purchase_order_id : parentRecord.get('id')
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
			var newObject = new AM.model.PurchaseOrderEntry( values ) ;
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				params : {
					purchase_order_id : parentRecord.get('id')
				},
				success: function(record){
					//  since the grid is backed by store, if store changes, it will be updated
					store.load({
						params: {
							purchase_order_id : parentRecord.get('id')
						}
					});
					// form.fireEvent('item_quantity_changed');
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
      var store = this.getPurchaseOrderEntriesStore();
      store.remove(record);
      store.sync();
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
