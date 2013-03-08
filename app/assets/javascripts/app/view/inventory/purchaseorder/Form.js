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
			fields	: ['id','name'],
			proxy  	: {
				type : 'ajax',
				url : 'api/search_vendor',
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
	        xtype: 'hidden',
	        name : 'id',
	        fieldLabel: 'id'
	      },
				{
					name : 'vendor_id',
					fieldLabel: ' Vendor ',
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
							'<div class="combo-full-address">{address}</div>' + 
							'<div class="combo-full-adderss">{city}  {state} {zip}</div>' + 
							'</div>';
						}
					}

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

