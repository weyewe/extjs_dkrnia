Ext.define('AM.view.inventory.Vendor', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.vendorProcess',
	 
		
		items : [
			{
				xtype : 'vendorlist' ,
				flex : 1 
			} 
		]
});