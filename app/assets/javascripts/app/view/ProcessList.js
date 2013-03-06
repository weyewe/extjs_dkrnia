Ext.define('AM.view.ProcessList', {
    extend: 'Ext.tree.Panel',
    alias: 'widget.processList',
		// requires : [
		// 	'AM.view.management.Employee'
		// ],
		    
// to perform lazy loading 
    // requires: [
    //     'KitchenSink.store.Examples',
    //     'KitchenSink.view.examples.Example',
    //     'KitchenSink.view.examples.PanelExample',
    //     'KitchenSink.view.examples.forms.Contact',
    //     'KitchenSink.view.examples.forms.Login',
    //     'KitchenSink.view.examples.forms.Register',
    //     'KitchenSink.view.examples.grids.BasicGrid',
    //     'KitchenSink.view.examples.grids.GroupedGrid',
    //     'KitchenSink.view.examples.grids.GroupedHeaderGrid',
    //     'KitchenSink.view.examples.grids.LockedGrid',
    //     'KitchenSink.view.examples.panels.BasicPanel',
    //     'KitchenSink.view.examples.panels.FramedPanel',
    //     'KitchenSink.view.examples.tabs.BasicTabs',
    //     'KitchenSink.view.examples.tabs.FramedTabs',
    //     'KitchenSink.view.examples.tabs.IconTabs',
    //     'KitchenSink.view.examples.tabs.TitledTabPanels',
    //     'KitchenSink.view.examples.toolbars.BasicToolbar',
    //     'KitchenSink.view.examples.toolbars.DockedToolbar',
    //     'KitchenSink.view.examples.trees.BasicTree',
    //     'KitchenSink.view.examples.windows.BasicWindow'
    // ],
    
    title: 'Process List',
    rootVisible: false,
		cls: 'examples-list',
    lines: false,
    useArrows: true,

		store: 'Navigations'
});
