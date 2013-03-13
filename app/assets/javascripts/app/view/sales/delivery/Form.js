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
		var comboBox = this.down('form').getForm().findField('employee_id'); 
		
		var store = comboBox.store; 
		store.load({
			params: {
				selected_id : record.get("employee_id")
			},
			callback : function(records, options, success){
				me.setLoading(false);
				comboBox.setValue( record.get("employee_id"));
			}
		});
	}
});

