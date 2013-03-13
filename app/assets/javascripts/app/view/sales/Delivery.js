Ext.define('AM.view.sales.Delivery', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.deliveryProcess',
	 
		layout : {
			type : 'vbox',
			align : 'stretch'
		},
		
		items : [
			{
				xtype : 'deliverylist' ,
				flex : 1  
			},
			{
				xtype : 'deliveryentrylist',
				flex : 1 
			}
		]
});