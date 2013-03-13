Ext.define('AM.store.DeliveryEntries', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.DeliveryEntry'],
  	model: 'AM.model.DeliveryEntry',
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
