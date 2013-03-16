Ext.define('AM.model.DeliveryLost', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'code', type: 'string' } ,
			{ name: 'customer_name', type: 'string'},
			
			{ name: 'delivery_id', type: 'int' },
			{ name: 'delivery_code', type: 'string'},
			{ name: 'is_confirmed',type: 'boolean', defaultValue: false } 
  	],

	 

  	idProperty: 'id' ,proxy: {
			url: 'api/delivery_losts',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'delivery_losts',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { delivery_lost : record.data };
				}
			}
		}
	
  
});
