Ext.define('AM.view.Header', {
    extend: 'Ext.toolbar.Toolbar',
    alias : 'widget.appHeader',
    require : [
			'AM.view.header.EditPassword'
		],
    
    height: 53,
    
    items: [
        {
            text: 'Button1',
            // iconCls: 'book',
            action: 'panelUtama'  
        },
				'->',
				{
					text: "Options",
					menu: [
						{
							action: 'editPassword',
							text: "Ganti Password",
							listeners: {
								click: function() {

									// Ext.create('AM.view.header.EditPassword').show();
									console.log("Update Password is clicked");
									var editPasswordWindow = Ext.create('AM.view.header.EditPassword');

									if( editPasswordWindow){
										console.log(" the editPasswordWindow is not null");
										console.log( editPasswordWindow );
									}else{
										console.log("the editPasswordWindow is null" );
									}

									
									editPasswordWindow.show();

								}
							}
						},
						{
							text: "Ganti Profile"
						}
					]
				},
				// {
				// 	text: 'Options',
				// 	itemId: 'option',
				// 	iconCls: 'options_icon',
				// 	menu: [
				// 		{
				// 		text: 'Ganti Password',
				// 		listeners: {
				// 			click: function() {
				// 				Ext.create('PL.view.gantipassword.edit').show();
				// 			}
				// 		}
				// 	}, 
				// 	// This  shit is hidden 
				// 	{
				// 		text: 'Lihat Arsip',
				// 		listeners: {
				// 			click: function() {
				// 				var win = Ext.create('PL.view.arsip.edit',{
				// 					parent: me
				// 					}),
				// 					frm = win.down('form');
				// 					win.show();
				// 					frm.getForm().waitMsgTarget = win.getEl();
				// 					frm.getForm().load({
				// 						url: 'store/arsip/dataLoad.php',
				// 						waitMsg: 'Loading...'
				// 					});
				// 
				// 				}
				// 			},
				// 			hidden : true
				// 		}, 
				// 		// this is shown 
				// 		{
				// 			text: 'Reset Data',
				// 			listeners: {
				// 				click: function() {
				// 					Ext.create('PL.view.resetdata.edit').show();
				// 				}
				// 			}
				// 			}
				//   ]
				// },
				'-',
				{
            text: 'Logout',
            // iconCls: 'book',
            action: 'logoutUser'  
        }
    ]
});
