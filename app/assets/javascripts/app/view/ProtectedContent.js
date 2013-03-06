// Ext.define("AM.view.ProtectedContent", {
// 	extend : "Ext.form.Panel",
// 	alias : 'widget.protected',
// 	
// 	layout : {
// 		align : 'center',
// 		pack : 'center',
// 		type : 'vbox'
// 	},
// 	
// 	items : [
// 		{
// 			xtype : "button",
// 			anchor : "100%",
// 			itemId : 'logoutBtn',
// 			text : 'Log out',
// 			hidden: false
// 		},
// 		{
// 			xtype : "button",
// 			anchor : "100%",
// 			itemId : 'coffeeBtn',
// 			text : 'Coffee',
// 			hidden: true
// 		},
// 		{
// 			xtype : "button",
// 			anchor : "100%",
// 			itemId : 'massageBtn',
// 			text : 'Massage',
// 			hidden: true
// 		},
// 	]
// });
// 


Ext.define('AM.view.ProtectedContent', {
    extend: 'Ext.panel.Panel',
		alias : 'widget.protected',
    
    layout: 'border',
    
    items: [
        {
            region: 'north',
            xtype : 'appHeader'
        },
        
        {
            region: 'center',
            
            layout: {
                type : 'hbox',
                align: 'stretch'
            },
            
            items: [
									{
										html : "This is the process List",
										width : 250
									},
									{
										html : 'This is the worksheet',
										flex:  1
									}
                // {
                //      width: 250,
                //      bodyPadding: 5,
                //      xtype: 'processList'
                //  },
                //  
                //  {
                //      flex: 1,
                //      title: '&nbsp;',
                //      id   : 'worksheetPanel',
                //      layout: {
                //          type: 'vbox',
                //          align: 'center',
                //          pack: 'center'
                //      },
                //      overflowY: 'auto',
                //      bodyPadding: 0
                //  }
            ]
        }
    ]
});
