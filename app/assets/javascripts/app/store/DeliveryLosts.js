Ext.define('AM.store.DeliveryLosts', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.DeliveryLost'],
  	model: 'AM.model.DeliveryLost',
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
