Ext.define('AM.view.inventory.ItemDatabase', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.itemdatabaseProcess',
	 
		
		items : [
			{
				xtype : 'itemdatabaselist' ,
				flex : 1 
			} 
		]
});