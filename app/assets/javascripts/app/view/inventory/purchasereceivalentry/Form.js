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
					fieldLabel: 'Purchase Order',
					name: 'purchase_order_code',
					value: '10'
				},
				{
					fieldLabel: 'Item',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'name',
					valueField : 'id',
					pageSize : 5,
					minChars : 1, 
					triggerAction: 'all',
					store : remoteJsonStore, 
					listConfig : {
						getInnerTpl: function(){
							return '<div data-qtip="{name}">' + 
							'<div class="combo-name">{name}</div>' + 
							'<div class="combo-full-address">{customer_code}</div>' + 
							'<div class="combo-full-address">{supplier_code}</div>' + 
							'</div>';
						}
					},
					name : 'item_id'
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


	setParentData: function( record ){
		this.down('form').getForm().findField('purchase_order_code').setValue(record.get('code')); 
		this.down('form').getForm().findField('item_id').setValue(record.get('item_id')); 
	}
});

