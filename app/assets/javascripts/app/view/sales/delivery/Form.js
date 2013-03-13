Ext.define('AM.view.sales.delivery.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.deliveryform',

  title : 'Add / Edit Delivery',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
	
  initComponent: function() {
	
		var remoteJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'employee_search',
			fields	: [
	 				{
						name : 'employee_id',
						mapping : "id"
					},
					{
						name : 'employee_name',
						mapping : 'name'
					}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_employee',
				reader : {
					type : 'json',
					root : 'records', 
					totalProperty  : 'total'
				}
			},
			autoLoad : false 
		});
		
		var customerJsonStore = Ext.create(Ext.data.JsonStore, {
			storeId : 'customer_search',
			fields	: [
	 				{
						name : 'customer_id',
						mapping : "id"
					},
					{
						name : 'customer_name',
						mapping : 'name'
					}
			],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_customer',
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
					fieldLabel: ' Employee ',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'employee_name',
					valueField : 'employee_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : remoteJsonStore, 
					listConfig : {
						getInnerTpl: function(){
							return '<div data-qtip="{employee_name}">' +  
												'<div class="combo-name">{employee_name}</div>' + 
										 '</div>';
						}
					},
					name : 'employee_id' 
				},
				{
					fieldLabel: ' Customer ',
					xtype: 'combo',
					queryMode: 'remote',
					forceSelection: true, 
					displayField : 'customer_name',
					valueField : 'customer_id',
					pageSize : 5,
					minChars : 1, 
					allowBlank : false, 
					triggerAction: 'all',
					store : customerJsonStore, 
					listConfig : {
						getInnerTpl: function(){
							return '<div data-qtip="{customer_name}">' +  
												'<div class="combo-name">{customer_name}</div>' + 
										 '</div>';
						}
					},
					name : 'customer_id' 
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
		console.log("Gonna set combo box data for delivery form");
		var me = this; 
		// me.setLoading(true);
		var comboBox = this.down('form').getForm().findField('employee_id'); 
		comboBox.setLoading(true);
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : record.get("employee_id")
			},
			callback : function(records, options, success){
				comboBox.setLoading(false);
				comboBox.setValue( record.get("employee_id"));
			}
		});
		
		var comboBox2 = this.down('form').getForm().findField('customer_id'); 
		comboBox2.setLoading( true ) ;
		var store2 = comboBox2.store; 
		store2.load({
			params: {
				selected_id : record.get("customer_id")
			},
			callback : function(records, options, success){
				comboBox2.setLoading(false);
				comboBox2.setValue( record.get("customer_id"));
			}
		});
	}
});

