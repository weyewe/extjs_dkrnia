Ext.define("AM.controller.Authentication", {
	extend : "Ext.app.Controller",
	views : [
		"AuthenticationForm",
		'Viewport',
		"ProtectedContent"
	],
	
	currentUser : null, 
 
	
	refs: [
		{
			ref: 'viewport',
			selector: 'vp'
		} 
	],
	
	
	
	onViewportLoaded: function(){
		// console.log("The viewport is loaded");
		var me = this;
		var currentUserBase = localStorage.getItem('currentUser');
		if( currentUserBase === null){
			// show the login page
			me.showLoginForm(); 
		}else{
			// decode the currentUserBase
			me.currentUser = Ext.decode( currentUserBase ) ;
			// show the protected content
			me.showProtectedArea(); 
		}
	},
	
	init : function( application ) {
		var me = this; 
		
		me.control({
			"button#loginBtn" : {
				click : this.onLoginClick
			},
			
			"button[action=logoutUser]": {
				click : this.onLogoutClick
			},
			'vp' : {
				'render' : this.onViewportLoaded
			} 
		});
	},
 
	
	onLoginClick: function( button ){
		var me = this; 
		
		var fieldset = button.up('fieldset');
		// button.up('fieldset').setLoading( true ) ;
		fieldset.setLoading( true ) ;
	
		var form =  button.up('form');
		var emailField = form.getForm().findField('email');
		var passwordField = form.getForm().findField('password');
				
		me.authenticateUser({
			user_login : {
				email : emailField.getValue(),
				password : passwordField.getValue()
			}
		}, fieldset); 
	
	},
	
	onLogoutClick: function( button ){
		var me = this;
		
		
		
		me.destroyAuthentication();
		// this could go to the localStorage. much more awesome 
		// me.showLoginForm();
		// window.location.reload(); 
	},
	
	destroyAuthentication: function(){
		var me = this; 
		me.getViewport().setLoading( true ) ;
		Ext.Ajax.request({
		    url: 'api/users/sign_out',
		    method: 'DELETE',
		    params: {
		    },
		    jsonData: {},
		    success: function(result, request ) {
					me.getViewport().setLoading( false ) ;
					me.currentUser  = null; 
					localStorage.removeItem('currentUser');
					
					me.showLoginForm();
				
		    },
		    failure: function(result, request ) {
						me.getViewport().setLoading( false ) ;
						Ext.Msg.alert("Logout Error", "Can't Logout");
		    }
		});
	},
	
	authenticateUser : function( data , fieldset ){
		var me = this; 
		Ext.Ajax.request({
		    url: 'api/users/sign_in',
		    method: 'POST',
		    params: {
		    },
		    jsonData: data,
		    success: function(result, request ) {
						fieldset.setLoading( false ) ;
						// cleaning the form data
						var form = fieldset.up('form');
						var passwordField = form.getForm().findField('password');
						var emailField = form.getForm().findField('email');
						passwordField.setValue('');
						emailField.setValue('');
						
						
						var responseText=  result.responseText; 
						var data = Ext.decode(responseText ); 
						var currentUserObject = {
							'auth_token' : data['auth_token'] ,
							'email'				: data['email'],
							'role'				: Ext.decode( data['role'] ) 
						};
				 
						localStorage.setItem('currentUser', Ext.encode( currentUserObject ));
						me.currentUser = currentUserObject;
						me.showProtectedArea(); 
		    },
		    failure: function(result, request ) {
						fieldset.setLoading( false ) ;
						Ext.Msg.alert("Login Error", "The email-password combination is invalid");
		    }
		});
	},
	
	showProtectedArea : function(){
		var me = this; 
		me.getViewport().getLayout().setActiveItem( 1) ;
		// hide all objects 
	},
	showLoginForm : function(){
		// console.log("The login form is shown");
		var me = this;
		me.getViewport().getLayout().setActiveItem( 0 ) ;
		
		// unhide all objects based on authroization
	}
});