class Api::AppUsersController < Api::BaseApiController
  
  def index
    @objects = User.active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
    render :json => { :users => @objects , :total => User.active_objects.count, :success => true }
  end

  def create
    @object = User.create_by_employee(current_user,  params[:user] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :users => [@object] , 
                        :total => User.active_objects.count }  
    else
      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors )  
        }
      }
      
      render :json => msg                         
    end
  end

  def update
    
    @object = User.find_by_id params[:id] 
    @object.update_by_employee(current_user,  params[:user])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :users => [@object],
                        :total => User.active_objects.count  } 
    else
      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors )  
        }
      }
      
      render :json => msg 
    end
  end

  def destroy
    @object = User.find(params[:id])
    @object.delete(current_user)

    if @object.is_deleted
      render :json => { :success => true, :total => User.active_objects.count }  
    else
      render :json => { :success => false, :total => User.active_objects.count }  
    end
  end
end
