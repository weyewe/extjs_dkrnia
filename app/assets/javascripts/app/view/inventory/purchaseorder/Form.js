Ext.define('AM.view.inventory.purchaseorder.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.purchaseorderform',

  title : 'Add / Edit Purchase Order',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
	
  initComponent: function() {
	
		var remoteJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'vendor_search',
			fields	: [
				{
					name : 'vendor_id',
					mapping : "id"
				},
				{
					name : 'vendor_name',
					mapping : 'name'
				}
					// 'id','name'
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_vendor',
				reader : {
					type : 'json',
					root : 'records', 
					totalProperty  : 'total'
				}
			},
			autoLoad : false 
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
	        xtype: 'hidden',
	        name : 'id',
	        fieldLabel: 'id'
	      },
				{
					fieldLabel: ' Vendor ',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'vendor_name',
					valueField : 'vendor_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteJsonStore, 
					listConfig : {
						getInnerTpl: function(){
							return '<div data-qtip="{vendor_name}">' + 
												'<div class="combo-name">{vendor_name}</div>' + 
												'<div class="combo-full-address">{address}</div>' + 
												'<div class="combo-full-adderss">{city}  {state} {zip}</div>' + 
											'</div>';
						}
					},
					name : 'vendor_id' 
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

	setComboBoxData : function( record){
		var me = this; 
		me.setLoading(true);
		var comboBox = this.down('form').getForm().findField('vendor_id'); 
		// comboBox.value = record.get("vendor_id");
		// comboBox.lastSelectionText = record.get("vendor_name");
		// 
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : record.get("vendor_id")
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( record.get("vendor_id"));
			}
		});
	}
});

