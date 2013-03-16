Ext.define('AM.model.SalesReturnEntry', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'code', type: 'string' } ,
			{ name: 'delivery_entry_code', type: 'string' },
			{ name: 'delivery_entry_id', type: 'int' },
			{ name: 'item_name', type: 'string'},
			{ name: 'quantity',type: 'int'}
  	],

  	idProperty: 'id' ,proxy: {
			url: 'api/sales_return_entries',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'sales_return_entries',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { sales_return_entry : record.data };
				}
			}
		}
	
  
});
