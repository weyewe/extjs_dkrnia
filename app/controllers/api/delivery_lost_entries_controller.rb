class Api::DeliveryLostEntriesController < Api::BaseApiController
  
  def index
    @parent = DeliveryLost.find_by_id params[:delivery_lost_id]
    @objects = @parent.active_delivery_lost_entries.joins( :delivery_lost, :delivery_entry => [:sales_order_entry => [:item]]).page(params[:page]).per(params[:limit]).order("id DESC")
    @total = @parent.active_delivery_lost_entries.count
  end

  def create
    @parent = DeliveryLost.find_by_id params[:delivery_lost_id]
    @object = DeliveryLostEntry.create_by_employee(current_user, @parent,  params[:delivery_lost_entry] )  
    
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :delivery_lost_entries => [@object] , 
                        :total => @parent.active_delivery_lost_entries.count }  
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
    
    @object = DeliveryLostEntry.find_by_id params[:id] 
    @parent = @object.delivery_lost 
    @object.update_by_employee(current_user,  params[:delivery_lost_entry])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :delivery_lost_entries => [@object],
                        :total => @parent.active_delivery_lost_entries.count  } 
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
  
  def update_post_delivery_lost
    @object = DeliveryLostEntry.find_by_id params[:id]
    @parent = @object.delivery_lost
    
    @object.update_post_delivery_lost( current_user, params[:delivery_lost_entry] )
    
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :delivery_lost_entries => [@object],
                        :total => @parent.active_delivery_lost_entries.count  } 
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
    @object = DeliveryLostEntry.find(params[:id])
    @parent = @object.delivery_lost 
    @object.delete(current_user)

    if ( @object.persisted? and @object.is_deleted ) or ( not @object.persisted? )
      render :json => { :success => true, :total => @parent.active_delivery_lost_entries.count }  
    else
      render :json => { :success => false, :total =>@parent.active_delivery_lost_entries.count }  
    end
  end
end
