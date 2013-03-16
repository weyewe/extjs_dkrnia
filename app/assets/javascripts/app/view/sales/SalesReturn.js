Ext.define('AM.view.sales.SalesReturn', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.salesreturnProcess',
	 
		layout : {
			type : 'vbox',
			align : 'stretch'
		},
		
		items : [
			{
				type : 'panel',
				html : 'this is the sales return'
			}
			// {
			// 	xtype : 'salesreturnlist' ,
			// 	flex : 1  
			// }//,
			// {
			// 	xtype : 'salesreturnentrylist',
			// 	flex : 1 
			// }
		]
});