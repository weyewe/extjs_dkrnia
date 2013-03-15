Ext.define('AM.store.SalesReturns', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.SalesReturn'],
  	model: 'AM.model.SalesReturn',
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
