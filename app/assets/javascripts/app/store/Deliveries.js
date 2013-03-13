Ext.define('AM.store.Deliveries', {
  	extend: 'Ext.data.Store',
		require : ['AM.model.Delivery'],
  	model: 'AM.model.Delivery',
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
