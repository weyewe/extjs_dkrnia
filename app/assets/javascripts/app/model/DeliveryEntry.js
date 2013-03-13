Ext.define('AM.model.DeliveryEntry', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'code', type: 'string' } ,
			{ name: 'delivery_code', type: 'string' },
			{ name: 'delivery_id', type: 'int' },
			{ name: 'item_name', type: 'string'},
			
			// purchase order entry  related 
			{ name: 'quantity_sent',type: 'int'}, 
			// sent using delivery. give no shit. 
			// if there is lost delivery, create a lost delivery form. 
			{ name: 'sales_order_entry_id', type: 'int'},
			{ name: 'sales_order_code', type: 'string'},
			{ name: 'sales_order_entry_code', type: 'string'},
			
			{ name: 'is_confirmed',type: 'boolean', defaultValue: false }  
  	],

	 

  	idProperty: 'id' ,proxy: {
			url: 'api/delivery_entries',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'delivery_entries',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { delivery_entry : record.data };
				}
			}
		}
	
  
});
