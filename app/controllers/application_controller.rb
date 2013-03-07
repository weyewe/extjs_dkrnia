class ApplicationController < ActionController::Base
  include TheRole::Requires
  protect_from_forgery
  
  # before_filter :set_cache_buster
  #   def set_cache_buster
  #     if Rails.env.development?
  #       response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
  #       response.headers["Pragma"] = "no-cache"
  #       response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  #     end
  #   end
    
    
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
