Ext.define('AM.model.Vendor', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'name', type: 'string' } ,
			'phone',
			'mobile',
			'email',
			'bbm_pin',
			'address'
  	],
 
		
		// vendor.purchase_orders() will return data store of model PurchaseOrder

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/purchase_orders',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'purchase_orders',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { purchase_order : record.data };
				}
			}
		}
	
  
});