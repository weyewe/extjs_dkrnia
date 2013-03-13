Ext.define('AM.model.StockMigration', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'code', type: 'string' } ,
			{ name: 'quantity', type: 'int' },
			{ name: 'item_id', type: 'int' },
			{ name: 'item_name', type: 'string' }
  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/stock_migrations',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'stock_migrations',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { stock_migration : record.data };
				}
			}
		}
	
  
});
