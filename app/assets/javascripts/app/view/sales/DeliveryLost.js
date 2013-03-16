Ext.define('AM.view.sales.DeliveryLost', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.deliverylostProcess',
	 
		layout : {
			type : 'vbox',
			align : 'stretch'
		},
		
		items : [
			// {
			// 	type : 'panel',
			// 	html : 'this is the delivery lost'
			// }
			{
				xtype : 'deliverylostlist' ,
				flex : 1  
			},
			{
				xtype : 'deliverylostentrylist',
				flex : 1 
			}
		]
});