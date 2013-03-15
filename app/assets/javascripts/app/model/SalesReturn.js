Ext.define('AM.model.SalesReturn', {
  	extend: 'Ext.data.Model',
  	fields: [
    	
			{ name: 'customer_name', type: 'string'},
			{ name: 'delivery_id', type: 'int'},
			{ name: 'delivery_name', type: 'string'},
			
			{ name: 'id', type: 'int' },
    	{ name: 'code', type: 'string' } ,
			{ name: 'is_confirmed',type: 'boolean', defaultValue: false } 
  	],

	 

  	idProperty: 'id' ,proxy: {
			url: 'api/sales_returns',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'sales_returns',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { sales_return : record.data };
				}
			}
		}
	
  
});
