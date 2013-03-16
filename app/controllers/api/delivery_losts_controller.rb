class Api::DeliveryLostsController < Api::BaseApiController
  
  def index
    @objects = DeliveryLost.joins(:delivery => [:customer]).active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
    @total = DeliveryLost.active_objects.count
  end

  def create
    @object = DeliveryLost.create_by_employee(current_user,  params[:delivery_lost] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :delivery_losts => [@object] , 
                        :total => DeliveryLost.active_objects.count }  
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
    
    @object = DeliveryLost.find_by_id params[:id] 
    @object.update_by_employee(current_user,  params[:delivery_lost])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :delivery_losts => [@object],
                        :total => DeliveryLost.active_objects.count  } 
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
    @object = DeliveryLost.find(params[:id])
    @object.delete(current_user)

    if not @object.persisted? 
      render :json => { :success => true, :total => DeliveryLost.active_objects.count }  
    else
      render :json => { 
                  :success => false, 
                  :total => DeliveryLost.active_objects.count,
                  :message => {
                    :errors => extjs_error_format( @object.errors )  
                  }
               }  
    end
  end
  
  def confirm
    @object = DeliveryLost.find_by_id params[:id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @object.confirm( current_user  )  
    
    if @object.is_confirmed? 
      render :json => { :success => true, :total => DeliveryLost.active_objects.count }  
    else
      render :json => { :success => false, :total => DeliveryLost.active_objects.count }  
    end
  end
  
end
