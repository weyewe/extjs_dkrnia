Ext.define("AM.controller.Authorization", {
	extend : "Ext.app.Controller",
	views : [
		"ProtectedContent"
	],

	 
	
	refs: [
		{
			ref: 'protectedContent',
			selector: 'protected'
		},
		{
			ref : 'userMenu',
			selector : 'appHeader #optionsMenu'
		}
	],
	

	 
	init : function( application ) {
		var me = this; 
		 
		me.control({
			"protected" : {
				activate : this.onActiveProtectedContent
			} 
			
		});
		
	},
	
	onActiveProtectedContent: function( panel, options) {
		var me  = this; 
		var currentUser = Ext.decode( localStorage.getItem('currentUser'));
		var email = currentUser['email'];
		// console.log("onActive Protected Content");
		
		// build the navigation tree 
		var processList = panel.down('processList');
		processList.setLoading(true);
	
		var treeStore = processList.getStore();
		treeStore.removeAll(); 
		 
		
		var data = {
		    text:"text root",
		    children: 
		        [
		            {
		                text:'Management', 
		                viewClass:'', 
		                iconCls:'text-folder', 
		                expanded: true,
		                children:
		                [
		                    
	                    { 
	                        text:'Employee', 
	                        viewClass:'AM.view.management.Employee', 
	                        leaf:true, 
	                        iconCls:'text' 
	                    },
	                    { 
	                        text:'User', 
	                        viewClass:'AM.view.management.User', 
	                        leaf:true, 
	                        iconCls:'text' 
	                    }
		                    
		                ]
		            },
								{
									text:'Inventory', 
	                viewClass:'Will', 
	                iconCls:'text-folder', 
	                expanded: true,
	                children:
	                [
										{ 
		                     text:'Vendor', 
		                     viewClass:'AM.view.inventory.Vendor', 
		                     leaf:true, 
		                     iconCls:'text' 
		                 },
                    { 
                        text:'Item Database', 
                        viewClass:'AM.view.inventory.ItemDatabase', 
                        leaf:true, 
                        iconCls:'text' 
                    },
                    { 
                        text:'Pembelian', 
                        viewClass:'AM.view.inventory.PurchaseOrder', 
                        leaf:true, 
                        iconCls:'text' 
                    },
										{ 
                        text:'Penerimaan', 
                        viewClass:'AM.view.inventory.PurchaseReceival', 
                        leaf:true, 
                        iconCls:'text' 
                    }
	                    
	                ]
								},
								{
									text:'Sales', 
	                viewClass:'Will', 
	                iconCls:'text-folder', 
	                expanded: true,
	                children:
	                [
	                    
                    { 
                        text:'Customer', 
                        viewClass:'AM.view.sales.Customer', 
                        leaf:true, 
                        iconCls:'text' 
                    },
                    { 
                        text:'Penjualan', 
                        viewClass:'AM.view.sales.SalesOrder', 
                        leaf:true, 
                        iconCls:'text' 
                    },
										{ 
                        text:'Pengiriman', 
                        viewClass:'AM.view.sales.Delivery', 
                        leaf:true, 
                        iconCls:'text' 
                    },
										{ 
                        text:'Sales Return', 
                        viewClass:'AM.view.sales.SalesReturn', 
                        leaf:true, 
                        iconCls:'text' 
                    },
										{ 
                        text:'Delivery Lost', 
                        viewClass:'AM.view.sales.DeliveryLost', 
                        leaf:true, 
                        iconCls:'text' 
                    }
	                    
	                ]
								}
		        ]
	
		    };
		
		
		treeStore.setRootNode(data);
		processList.setLoading(false);
		
		// Update the title of the menu button
		// console.log("Gonna update the user menu");
		var userMenu = me.getUserMenu();

		userMenu.setText( email );
	}
});