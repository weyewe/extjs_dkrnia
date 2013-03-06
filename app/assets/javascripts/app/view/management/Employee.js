Ext.define('AM.view.management.Employee', {
    extend: 'Ext.panel.Panel',
    alias: 'widget.employeeProcess',
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
