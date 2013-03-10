Ext.define('AM.controller.PurchaseOrders', {
  extend: 'Ext.app.Controller',

  stores: ['PurchaseOrders'],
  models: ['PurchaseOrder'],

  views: [
    'inventory.purchaseorder.List',
    'inventory.purchaseorder.Form',
		'inventory.purchaseorderentry.List'
  ],

  refs: [
		{
			ref: 'list',
			selector: 'purchaseorderlist'
		},
		{
			ref : 'purchaseOrderEntryList',
			selector : 'purchaseorderentrylist'
		}
	],

  init: function() {
    this.control({
      'purchaseorderlist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange,
				afterrender : this.loadObjectList,
      },
      'purchaseorderform button[action=save]': {
        click: this.updateObject
      },
      'purchaseorderlist button[action=addObject]': {
        click: this.addObject
      },
      'purchaseorderlist button[action=editObject]': {
        click: this.editObject
      },
      'purchaseorderlist button[action=deleteObject]': {
        click: this.deleteObject
      }
    });
  },
 

	loadObjectList : function(me){
		me.getStore().load();
	},

  addObject: function() {
    var view = Ext.widget('purchaseorderform');
    view.show();
  },

  editObject: function() {
    var record = this.getList().getSelectedObject();
    var view = Ext.widget('purchaseorderform');

    view.down('form').loadRecord(record);
  },

  updateObject: function(button) {
    var win = button.up('window');
    var form = win.down('form');

    var store = this.getPurchaseOrdersStore();
		var list = this.getList();
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
					list.fireEvent('updated', record.get("id"));
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
			var newObject = new AM.model.PurchaseOrder( values ) ;
			
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
					list.fireEvent('updated');
					
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
		var list  = this.getList();

    if (record) {
      var store = this.getPurchaseOrdersStore();
      store.remove(record);
      store.sync();
// to do refresh programmatically
			list.fireEvent('deleted');	
			this.getList().query('pagingtoolbar')[0].doRefresh();
    }

  },

  selectionChange: function(selectionModel, selections) {
    var grid = this.getList();
		var record = this.getList().getSelectedObject();
		
		if(!record){
			return; 
		}
		var purchaseOrderEntryGrid = this.getPurchaseOrderEntryList();
		purchaseOrderEntryGrid.setTitle("Purchase Order: " + record.get('code'));
		purchaseOrderEntryGrid.getStore().load({
			params : {
				purchase_order_id : record.get('id')
			},
			callback : function(records, options, success){
				
				var totalObject  = records.length;
				if( totalObject ===  0 ){
					purchaseOrderEntryGrid.enableRecordButtons(); 
				}else{
					purchaseOrderEntryGrid.enableRecordButtons(); 
				}
			}
		});
		

    if (selections.length > 0) {
      grid.enableRecordButtons();
    } else {
      grid.disableRecordButtons();
    }
  } 
	

});
