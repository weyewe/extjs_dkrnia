Ext.define('AM.view.management.Employee', {
    extend: 'AM.view.Worksheet',
    alias: 'widget.employeeProcess',
		// html: "This is the employee... ",
		// layout: 'hbox',
		layout : {
			type : 'vbox'
		},
		
		items : [
			{
				html : "The grid",
				xtype : 'panel',
				height : 250
			},
			{
				html : "the details viewer",
				xtype : 'panel',
				flex : 1 
			}
		]
});