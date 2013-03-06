Ext.define("AM.controller.Navigation", {
	extend : "Ext.app.Controller",
	views : [
		"ProcessList"
	],

	 
	
	refs: [
		{
			ref: 'processList',
			selector: 'processList'
		} ,
		{
			ref : 'worksheetPanel',
			selector : '#worksheetPanel'
		}
	],
	 
	init : function( application ) {
		var me = this; 
		 
		me.control({
			"processList" : {
				'select' : this.onTreeRecordSelected
			} 
			
		});
		
	},
	
	onTreeRecordSelected : function( me, record, item, index, e ){
		if (!record.isLeaf()) {
        return;
    }

		console.log("The viewClass: " + record.get('viewClass'));
		console.log("The text: " + record.get("text"));
		this.setActiveExample( record.get('viewClass'), record.get('text'));
	},
	setActiveExample: function(className, title) {
      var worksheetPanel = this.getWorksheetPanel();
      
      // if (!title) {
      //     title = className.split('.').reverse()[0];
      // }
      // 
      //update the title on the panel
      worksheetPanel.setTitle(title);
      
      //remember the className so we can load up this example next time
      // location.hash = title.toLowerCase().replace(' ', '-');

      //set the browser window title
      // document.title = document.title.split(' - ')[0] + ' - ' + title;
      
      //create the example
      worksheet = Ext.create(className);
      
      //remove all items from the example panel and add new example
// if it is deleted and created.. will the controller still recognize it? 
// wait, remove doesn't mean destroy. it is just 'removing' the component out of the vbox 
// NOPE. remove does mean DESTROY.. se.. example = Ext.create( className ); 
// one thing to check: will the controller still be waiting to control the assigned data? 
      worksheetPanel.removeAll();
      worksheetPanel.add(worksheet);
// what makes sense is using card layout. triggered by this examples.. Or, we can check out the code base for 
// try_ext .. 
  }
});