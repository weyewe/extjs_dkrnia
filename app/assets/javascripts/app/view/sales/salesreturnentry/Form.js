Ext.define('AM.view.sales.salesreturnentry.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.salesreturnentryform',

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
			storeId : 'delivery_entry_search',
			fields	: [
				{
					name : 'delivery_entry_id',
					mapping  :'id'
				},
				{
					name : 'delivery_entry_code',
					mapping  :'code'
				},
				{
					name : 'item_name',
					mapping : 'item_name'
				}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_delivery_entry',
				extraParams: {
					delivery_id : this.parentRecord.get('delivery_id')
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
					fieldLabel: 'Sales Return',
					name: 'sales_return_code',
					value: '10'
				},
				{
					fieldLabel: 'Item',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'item_name',
					valueField : 'delivery_entry_id',
					pageSize : 5,
					minChars : 1, 
					triggerAction: 'all',
					store : remoteJsonStore, 
					listConfig : {
						getInnerTpl: function(){
							return  '<div data-qtip="{item_name}">' + 
												'<div class="combo-name">{item_name}</div>' + 
												'<div class="combo-name">{delivery_entry_code}</div>' + 
											'</div>';
						}
					},
					name : 'delivery_entry_id'
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
		this.down('form').getForm().findField('sales_return_code').setValue(record.get('code')); 
	},
	
	setComboBoxData : function( record){

		var me = this; 
		me.setLoading(true);
		var comboBox = this.down('form').getForm().findField('delivery_entry_id'); 
		
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : record.get("delivery_entry_id")
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( record.get("delivery_entry_id"));
			}
		});
	}
});

