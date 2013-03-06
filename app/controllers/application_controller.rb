class ApplicationController < ActionController::Base
  
  include TheRole::Requires
  protect_from_forgery
  
  def access_denied
    
    respond_to do |format|
      format.html do 
        render :text => 'access_denied: requires an role' and return
      end
      
      format.json do 
        render :json => {:success => false , :access_denied => true } and return
      end
    end
    
  end

  alias_method :login_required,     :authenticate_user!
  alias_method :role_access_denied, :access_denied
  
   
end
