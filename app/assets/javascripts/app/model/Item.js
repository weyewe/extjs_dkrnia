Ext.define('AM.model.Item', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'name', type: 'string' },
  		'supplier_code',
			'customer_code',
			'ready',
			'pending_delivery',
			'on_delivery',
			'pending_receival',
			{ name: 'ready', type: 'int' }
  	],

  	idProperty: 'id' ,proxy: {
			url: 'api/items',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'items',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { item : record.data };
				}
			}
		}
	
  
});
