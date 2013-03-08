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
				xtype : 'tabpanel',
				activeTab : 0 ,
				flex : 1  ,
				items : [
					{
						xtype : "stockmigrationlist",
						title: 'Stock Migration'
					},
					{
						html : "The Stock Adjustment",
						title : 'Stock Adjustment'
					},
					{
						html : "This is the third tab",
						title : 'tab 3'
					}
				]
			}
		]
		 

});