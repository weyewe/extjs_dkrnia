Ext.define('AM.model.Employee', {
  	extend: 'Ext.data.Model',
  	fields: [
    	{ name: 'id', type: 'int' },
    	{ name: 'name', type: 'string' } 
  	],

   
  	idProperty: 'id' ,proxy: {
			url: '/employees',
			type: 'rest',
			format: 'json',

			reader: {
				root: 'employees',
				successProperty: 'success',
				totalProperty : 'total'
			},

			writer: {
				getRecordData: function(record) {
					return { employee : record.data };
				}
			}
		}
	
  
});
