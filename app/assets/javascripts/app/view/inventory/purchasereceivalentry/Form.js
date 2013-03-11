Ext.define('AM.view.inventory.purchasereceivalentry.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.purchasereceivalentryform',

  title : 'Add / Edit Entry',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
		var remoteJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'purchase_order_entry_search',
			fields	: ['id','item_name', 'purchase_order_entry_code', 'purchase_order_code'],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_purchase_order_entry',
				// baseParams:{
				// 	action: 'mgr/contacts/groupslist'
				// },  // try to put vendor id over there: only display the pending receival from a given vendor
				reader : {
					type : 'json',
					root : 'records', 
					totalProperty  : 'total'
				}
			}
		});
		
    this.items = [{
      xtype: 'form',
			msgTarget	: 'side',
			border: false,
      bodyPadding: 10,
			fieldDefaults: {
          labelWidth: 165,
					anchor: '100%'
      },
      items: [
				
				{
					xtype: 'displayfield',
					fieldLabel: 'Purchase Receival',
					name: 'purchase_receival_code',
					value: '10'
				},
				{
					fieldLabel: 'Purchase Order Entry',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'item_name',
					valueField : 'id',
					pageSize : 5,
					minChars : 1, 
					triggerAction: 'all',
					store : remoteJsonStore, 
					listConfig : {
						getInnerTpl: function(){
							return '<div data-qtip="{item_name}">' + 
							'<div class="combo-name">{item_name}</div>' + 
							'<div class="combo-full-address">{purchase_order_entry_code}</div>' + 
							'<div class="combo-full-address">{purchase_order_code}</div>' + 
							'</div>';
						}
					},
					name : 'purchase_order_entry_id'
				},
				{
	        xtype: 'textfield',
	        fieldLabel: ' Quantity',
					name : 'quantity',
	      } 
			]
    }];

    this.buttons = [{
      text: 'Save',
      action: 'save'
    }, {
      text: 'Cancel',
      scope: this,
      handler: this.close
    }];

    this.callParent(arguments);
  },

	
	// we pass the parent_record 
	setParentData: function( record ){
		this.down('form').getForm().findField('purchase_receival_code').setValue(record.get('code')); 
	}
});

