Ext.define('AM.store.DeliveryLostEntries', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.DeliveryLostEntry'],
  	model: 'AM.model.DeliveryLostEntry',
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
