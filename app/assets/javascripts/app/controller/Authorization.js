Ext.define("AM.controller.Authorization", {
	extend : "Ext.app.Controller",
	views : [
		"ProtectedContent"
	],

	 
	
	refs: [
		{
			ref: 'protectedContent',
			selector: 'protected'
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
		console.log("onActive Protected Content");
		
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
                        text:'Item Database', 
                        viewClass:'Alpha', 
                        leaf:true, 
                        iconCls:'text' 
                    },
                    { 
                        text:'Stock Adjustment', 
                        viewClass:'Bravo', 
                        leaf:true, 
                        iconCls:'text' 
                    }
	                    
	                ]
								}
		        ]
	
		    };
		
		
		treeStore.setRootNode(data);
		processList.setLoading(false);
		
		
		// re build the treeStore data 
		
		// console.log("FROM the Authorization controller. on active protected content");
		// var coffeeBtn = panel.down('#coffeeBtn');
		
		// if( coffeeBtn ){
		// 	console.log("Coffee button is fond");
		// }
		
		// console.log("The type of currentUser in Authorization: " + typeof currentUser);
		// 
		// console.log("The type of currentUser['role']:" + typeof currentUser['role'] )
		
		// if( currentUser && currentUser['role'] && 
		// 			currentUser['role']['coffee_maker'] && 
		// 			currentUser['role']['coffee_maker']['make_coffee']){
		// 	coffeeBtn.setVisible(true ) ;
		// }
		
		
		// check authorization.. check the role
		// build the navigation 
		// getNavigationsStore.removeAll();
		
	}
});