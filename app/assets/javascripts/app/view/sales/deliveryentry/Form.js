Ext.define('AM.view.sales.deliveryentry.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.deliveryentryform',

  title : 'Add / Edit Entry',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	parentRecord : null, 

	constructor : function(cfg){
		this.parentRecord = cfg.parentRecord;
		this.callParent(arguments);
	},
	
  initComponent: function() {

		if( !this.parentRecord){ return; }
	
		var remoteJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'sales_order_entry_search',
			fields	: [
				{
					name : 'sales_order_entry_id',
					mapping  :'id'
				},
				{
					name : 'sales_order_entry_code',
					mapping : 'code'
				},
				{
					name : 'item_name',
					mapping : 'item_name'
				},
				{
					name : 'sales_order_code',
					mapping : 'sales_order_code'
				}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_sales_order_entry',
				extraParams: {
					customer_id : this.parentRecord.get('customer_id')
		    },
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
					fieldLabel: 'Sales Order',
					name: 'delivery_code',
					value: '10'
				},
				{
					fieldLabel: 'Item',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'item_name',
					valueField : 'sales_order_entry_id',
					pageSize : 5,
					minChars : 1, 
					triggerAction: 'all',
					store : remoteJsonStore, 
					listConfig : {
						getInnerTpl: function(){
							return  '<div data-qtip="{item_name}">' + 
												'<div class="combo-name">{item_name}</div>' + 
												'<div class="combo-full-address">{sales_order_entry_code}</div>' + 
												'<div class="combo-full-address">{sales_order_code}</div>' +
											'</div>';
						}
					},
					name : 'sales_order_entry_id'
				},
				{
	        xtype: 'textfield',
	        fieldLabel: ' Quantity',
					name : 'quantity_sent',
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
		this.down('form').getForm().findField('delivery_code').setValue(record.get('code')); 
	},
	
	setComboBoxData : function( record){

		var me = this; 
		me.setLoading(true);
		var comboBox = this.down('form').getForm().findField('sales_order_entry_id'); 
		
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : record.get("sales_order_entry_id")
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( record.get("sales_order_entry_id"));
			}
		});
	}
});

