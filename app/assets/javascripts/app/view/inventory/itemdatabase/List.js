Ext.define('AM.view.inventory.itemdatabase.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.itemdatabaselist',

  	store: 'Items', 
 

	initComponent: function() {
		this.columns = [
			{ header: 'Nama',  dataIndex: 'name',  flex: 1 , sortable: false},
			{ header: 'Supplier Code',  dataIndex: 'supplier_code',  flex: 1 , sortable: false},
			{ header: 'Customer Code',  dataIndex: 'customer_code',  flex: 1 , sortable: false}
		];

		this.addObjectButton = new Ext.Button({
			text: 'Add Item',
			action: 'addObject'
		});

		this.editObjectButton = new Ext.Button({
			text: 'Edit Item',
			action: 'editObject',
			disabled: true
		});

		this.deleteObjectButton = new Ext.Button({
			text: 'Delete Item',
			action: 'deleteObject',
			disabled: true
		});
 



		this.tbar = [this.addObjectButton, this.editObjectButton, this.deleteObjectButton];
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
		this.deleteObjectButton.enable();
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
	}
});
