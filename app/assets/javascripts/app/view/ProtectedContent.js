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
								width: 250,
								bodyPadding: 5,
								xtype: 'processList'
							}, 
              {
                  flex: 1,
                  title: '&nbsp;',
                  id   : 'worksheetPanel',
                  layout: {
                      type: 'vbox'// ,
                      //                       align: 'center',
                      //                       pack: 'center'
                  },
                  overflowY: 'auto',
                  bodyPadding: 0,
									items : [
										{
											html : "This is the placeholder"
										}
									]
              }
            ]
        }
    ]
});
