Ext.define('AM.view.inventory.itemdatabase.Form', {
  extend: 'Ext.window.Window',
  alias : 'widget.itemdatabaseform',

  title : 'Add / Edit Item',
  layout: 'fit',
	width	: 500,
  autoShow: true,  // does it need to be called?
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
	        name : 'id',
	        fieldLabel: 'id'
	      },{
	        xtype: 'textfield',
	        name : 'name',
	        fieldLabel: ' Name'
	      },{
					xtype: 'textfield',
					name : 'customer_code',
					fieldLabel: 'Customer Code'
				},{
					xtype: 'textfield',
					name : 'supplier_code',
					fieldLabel: 'Supplier Code'
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
  }
});

