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
			url: 'api/vendors',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'vendors',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { vendor : record.data };
				}
			}
		}
	
  
});
