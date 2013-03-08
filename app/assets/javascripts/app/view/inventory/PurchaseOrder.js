Ext.define('AM.view.inventory.PurchaseOrder', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.purchaseorderProcess',
	 
		
		items : [
			{
				xtype : 'purchaseorderlist' ,
				flex : 1  
			} 
		]
});