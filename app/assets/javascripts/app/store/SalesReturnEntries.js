Ext.define('AM.store.SalesReturnEntries', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.SalesReturnEntry'],
  	model: 'AM.model.SalesReturnEntry',
  	// autoLoad: {start: 0, limit: this.pageSize},
		autoLoad : false, 
  	autoSync: false,
	pageSize : 10, 
	
	
		
		
	sorters : [
		{
			property	: 'id',
			direction	: 'DESC'
		}
	], 

	listeners: {

	} 
});
