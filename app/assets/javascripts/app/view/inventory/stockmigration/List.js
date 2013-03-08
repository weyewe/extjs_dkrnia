Ext.define('AM.view.inventory.stockmigration.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.stockmigrationlist',

  	store: 'StockMigrations', 
 

	initComponent: function() {
		this.columns = [
			{ header: 'Code',  dataIndex: 'code',  flex: 1 , sortable: false},
			{ header: 'Quantity',  dataIndex: 'quantity',  flex: 1 , sortable: false} 
		];

		this.addObjectButton = new Ext.Button({
			text: 'Add StockMigration',
			action: 'addObject',
			disabled : true 
		});

		this.editObjectButton = new Ext.Button({
			text: 'Edit StockMigration',
			action: 'editObject',
			disabled: true
		});

	 
 



		this.tbar = [this.addObjectButton, this.editObjectButton ];
		this.bbar = Ext.create("Ext.PagingToolbar", {
			store	: this.store, 
			displayInfo: true,
			displayMsg: 'Displaying topics {0} - {1} of {2}',
			emptyMsg: "No topics to display" 
		});

		this.callParent(arguments);
	},
 
	loadMask	: true,
	
	getSelectedObject: function() {
		return this.getSelectionModel().getSelection()[0];
	},

	enableRecordButtons: function() {
		this.editObjectButton.enable();
		// this.deleteObjectButton.enable();
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		// this.deleteObjectButton.disable();
	},
	enableAddButton: function(){
		this.addObjectButton.enable();
	},
	disableAddButton : function(){
		this.addObjectButton.disable();
	}
});
