class Api::DeliveryEntriesController < Api::BaseApiController
  
  def index
    @parent = Delivery.find_by_id params[:delivery_id]
    @objects = @parent.active_delivery_entries.joins( :delivery, :sales_order_entry =>[:item]).page(params[:page]).per(params[:limit]).order("id DESC")
    @total = @parent.active_delivery_entries.count
  end

  def create
    @parent = Delivery.find_by_id params[:delivery_id]
    @object = DeliveryEntry.create_by_employee(current_user, @parent,  params[:delivery_entry] )  
    
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :delivery_entries => [@object] , 
                        :total => @parent.active_delivery_entries.count }  
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
    
    @object = DeliveryEntry.find_by_id params[:id] 
    @parent = @object.delivery 
    @object.update_by_employee(current_user,  params[:delivery_entry])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :delivery_entries => [@object],
                        :total => @parent.active_delivery_entries.count  } 
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
    @object = DeliveryEntry.find(params[:id])
    @parent = @object.delivery 
    @object.delete(current_user)

    if ( @object.persisted? and @object.is_deleted ) or ( not @object.persisted? )
      render :json => { :success => true, :total => @parent.active_delivery_entries.count }  
    else
      render :json => { :success => false, :total =>@parent.active_delivery_entries.count }  
    end
  end
end
