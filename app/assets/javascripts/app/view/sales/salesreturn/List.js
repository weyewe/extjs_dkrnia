Ext.define('AM.view.sales.deliverylost.List' ,{
  	extend: 'Ext.grid.Panel',
  	alias : 'widget.deliverylostlist',

  	store: 'DeliveryLosts', 
 

	initComponent: function() {
		this.columns = [
			{ header: 'ID', dataIndex: 'id'},
			{ header: 'Code',  dataIndex: 'code',  flex: 1 , sortable: false},
			{ header: 'Customer',  dataIndex: 'customer_name',  flex: 1 , sortable: false},
			{ header: 'Delivery Code',  dataIndex: 'delivery_code',  flex: 1 , sortable: false},
			{ header: 'Confirmed?',  dataIndex: 'is_confirmed',  flex: 1 , sortable: false},
		];

		this.addObjectButton = new Ext.Button({
			text: 'Add Delivery Lost',
			action: 'addObject'
		});

		this.editObjectButton = new Ext.Button({
			text: 'Edit Delivery Lost',
			action: 'editObject',
			disabled: true
		});

		this.deleteObjectButton = new Ext.Button({
			text: 'Delete Delivery Lost',
			action: 'deleteObject',
			disabled: true
		});
		
		this.confirmObjectButton = new Ext.Button({
			text: 'Confirm',
			action: 'confirmObject',
			disabled: true
		});



		this.tbar = [this.addObjectButton, this.editObjectButton, this.deleteObjectButton, this.confirmObjectButton ];
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
		this.confirmObjectButton.enable();
	},

	disableRecordButtons: function() {
		this.editObjectButton.disable();
		this.deleteObjectButton.disable();
		this.confirmObjectButton.disable();
	}
});
