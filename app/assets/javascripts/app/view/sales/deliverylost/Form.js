Ext.define('AM.view.sales.deliverylost.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.deliverylostform',

  title : 'Add / Edit Delivery Lost',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
	
  initComponent: function() {
	
		var remoteJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'delivery_search',
			fields	: [
	 				{
						name : 'delivery_id',
						mapping : "id"
					},
					{
						name : 'delivery_code',
						mapping : 'code'
					},
					{
						name : 'customer_name',
						mapping : 'customer_name'
					}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_delivery',
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
					fieldLabel: ' Delivery ',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'delivery_code',
					valueField : 'delivery_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteJsonStore, 
					listConfig : {
						getInnerTpl: function(){
							return '<div data-qtip="{delivery_code}">' +  
												'<div class="combo-name">{delivery_code}</div>' + 
												'<div class="">{customer_name}</div>' +
										 '</div>';
						}
					},
					name : 'delivery_id' 
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
		var comboBox = this.down('form').getForm().findField('delivery_id'); 
		var selectedRecordId = record.get("delivery_id");
		
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : selectedRecordId
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( selectedRecordId );
			}
		});
	}
});

