Ext.define('AM.view.management.User', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.userProcess',
		// html: "This is the employee... ",
		layout: 'hbox',
		
		items : [
			{
				text : "The grid",
				xtype : 'panel'
			},
			{
				text : "the details viewer",
				xtype : 'panel'
			}
		]
});
