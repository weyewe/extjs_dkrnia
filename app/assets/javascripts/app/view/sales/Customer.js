Ext.define('AM.view.sales.Customer', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.customerProcess',
	 
		
		items : [
			// {
			// 	xtype : 'panel',
			// 	html : "The customer panel"
			// }
			{
				xtype : 'customerlist' ,
				flex : 1 
			} 
		]
});