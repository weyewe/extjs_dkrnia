Ext.define('AM.model.DeliveryLostEntry', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'code', type: 'string' } ,

			{ name: 'delivery_lost_code', type: 'string' },
			{ name: 'delivery_lost_id', type: 'int' },
			
			{ name: 'delivery_entry_id', type: 'int' },
			{ name: 'delivery_entry_code', type: 'string' },
			
			{ name: 'item_name', type: 'string'},
			{ name: 'quantity',type: 'int'}
  	],

  	idProperty: 'id' ,proxy: {
			url: 'api/delivery_lost_entries',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'delivery_lost_entries',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { delivery_lost_entry : record.data };
				}
			}
		}
	
  
});
