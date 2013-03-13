Ext.define('AM.model.Customer', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'name', type: 'string' } ,
			'contact_person',
			'phone',
			'mobile',
			'email',
			'bbm_pin',
			'office_address'
  	],

	 


   
  	idProperty: 'id' ,proxy: {
			url: 'api/customers',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'customers',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { customer : record.data };
				}
			}
		}
	
  
});
