Ext.define('AM.view.inventory.stockmigration.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.stockmigrationform',

  title : 'Add / Edit StockMigration',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
	modal : true, 
// win.show() 
// if autoShow == true.. on instantiation, will automatically be called 
	
  initComponent: function() {
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
	        name : 'item_id',
	        fieldLabel: 'item_id'
	      },
				{
					xtype: 'displayfield',
					fieldLabel: 'Nama Item',
					name: 'item_name',
					value: '10'
				},
				{
					xtype: 'displayfield',
					fieldLabel: 'Code Customer',
					name: 'item_customer_code',
					value: '10'
				},
				{
					xtype: 'displayfield',
					fieldLabel: 'Code Supplier',
					name: 'item_supplier_code',
					value: '10'
				},
				{
	        xtype: 'textfield',
	        name : 'quantity',
	        fieldLabel: ' Quantity'
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
		this.down('form').getForm().findField('item_name').setValue(record.get('name'));
		this.down('form').getForm().findField('item_customer_code').setValue( record.get('customer_code'));
		this.down('form').getForm().findField('item_supplier_code').setValue( record.get('supplier_code'));
		this.down('form').getForm().findField('item_id').setValue( record.get('id'));
	}
});

