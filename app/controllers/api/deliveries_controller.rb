class Api::DeliveriesController < Api::BaseApiController
  
  def index
    @objects = Delivery.joins(:employee).active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
    @total = Delivery.active_objects.count
  end

  def create
    @object = Delivery.create_by_employee(current_user,  params[:delivery] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :deliveries => [@object] , 
                        :total => Delivery.active_objects.count }  
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
    
    @object = Delivery.find_by_id params[:id] 
    @object.update_by_employee(current_user,  params[:delivery])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :deliveries => [@object],
                        :total => Delivery.active_objects.count  } 
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
    @object = Delivery.find(params[:id])
    @object.delete(current_user)

    if ( @object.is_confirmed? and @object.is_deleted) or (  not @object.is_confirmed? and not @object.persisted?)  
      render :json => { :success => true, :total => Delivery.active_objects.count }  
    else
      render :json => { 
                  :success => false, 
                  :total => Delivery.active_objects.count,
                  :message => {
                    :errors => extjs_error_format( @object.errors )  
                  }
               }  
    end
  end
  
  def confirm
    @object = Delivery.find_by_id params[:id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @object.confirm( current_user  )  
    
    if @object.is_confirmed? 
      render :json => { :success => true, :total => Delivery.active_objects.count }  
    else
      render :json => { :success => false, :total => Delivery.active_objects.count }  
    end
  end
end
