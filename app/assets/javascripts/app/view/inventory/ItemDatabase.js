Ext.define('AM.view.inventory.ItemDatabase', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.itemdatabaseProcess',
	 
		
 		layout : {
			type : 'vbox',
			align : 'stretch'
		},
		
		items : [
			{
				xtype: 'itemdatabaselist',
				flex : 1  
			},
			{
				xtype : 'stockmigrationlist',
				flex : 1  
			}
		]
		 

});