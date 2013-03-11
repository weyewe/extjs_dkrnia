Ext.define('AM.controller.PurchaseReceivalEntries', {
  extend: 'Ext.app.Controller',

  stores: ['PurchaseReceivalEntries', 'PurchaseReceivals'],
  models: ['PurchaseReceivalEntry'],

  views: [
    'inventory.purchasereceivalentry.List',
    'inventory.purchasereceivalentry.Form',
		'inventory.purchasereceival.List'
  ],

  refs: [
		{
			ref: 'list',
			selector: 'purchasereceivalentrylist'
		},
		{
			ref : 'parentList',
			selector : 'purchasereceivallist'
		}
	],

  init: function() {
    this.control({
      'purchasereceivalentrylist': {
        itemdblclick: this.editObject,
        selectionchange: this.selectionChange 
      },
      'purchasereceivalentryform button[action=save]': {
        click: this.updateObject
      },
      'purchasereceivalentrylist button[action=addObject]': {
        click: this.addObject
      },
      'purchasereceivalentrylist button[action=editObject]': {
        click: this.editObject
      },
      'purchasereceivalentrylist button[action=deleteObject]': {
        click: this.deleteObject
      },

			// monitor parent(purchase_receival) update
			'purchasereceivallist' : {
				'updated' : this.reloadStore,
				'confirmed' : this.reloadStore,
				'deleted' : this.cleanList
			}
		
    });
  },

	reloadStore : function(record){
		var list = this.getList();
		var store = this.getPurchaseReceivalEntriesStore();
		
		store.load({
			params : {
				purchase_receival_id : record.get('id')
			}
		});
		
		list.setObjectTitle(record);
	},
	
	cleanList : function(){
		var list = this.getList();
		var store = this.getPurchaseReceivalEntriesStore();
		
		list.setTitle('');
		// store.removeAll(); 
		store.loadRecords([], {addRecords: false});
	},
 

  addObject: function() {
		
		// I want to get the currently selected item 
		var record = this.getParentList().getSelectedObject();
		if(!record){
			return; 
		}
		 
    var view = Ext.widget('purchasereceivalentryform');
		view.setParentData( record );
    view.show(); 
  },

  editObject: function() {
		var parentRecord = this.getParentList().getSelectedObject();
		
    var record = this.getList().getSelectedObject();
		if(!record || !parentRecord){
			return; 
		}

    var view = Ext.widget('purchasereceivalentryform');

    view.down('form').loadRecord(record);
		view.setParentData( parentRecord );
		view.setComboBoxData(record); 
  },

  updateObject: function(button) {
    var win = button.up('window');
    var form = win.down('form');

		var parentRecord = this.getParentList().getSelectedObject();
    var store = this.getPurchaseReceivalEntriesStore();
    var record = form.getRecord();
    var values = form.getValues();

		
		if( record ){
			record.set( values );
			 
			form.setLoading(true);
			record.save({
				params : {
					purchase_receival_id : parentRecord.get('id')
				},
				success : function(record){
					form.setLoading(false);
					//  since the grid is backed by store, if store changes, it will be updated
					// form.fireEvent('item_quantity_changed');
					store.load({
						params: {
							purchase_receival_id : parentRecord.get('id')
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
			var newObject = new AM.model.PurchaseReceivalEntry( values ) ;
			
			// learnt from here
			// http://www.sencha.com/forum/showthread.php?137580-ExtJS-4-Sync-and-success-failure-processing
			// form.mask("Loading....."); 
			form.setLoading(true);
			newObject.save({
				params : {
					purchase_receival_id : parentRecord.get('id')
				},
				success: function(record){
					//  since the grid is backed by store, if store changes, it will be updated
					store.load({
						params: {
							purchase_receival_id : parentRecord.get('id')
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
      var store = this.getPurchaseReceivalEntriesStore();
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
