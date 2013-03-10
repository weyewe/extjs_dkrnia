class Api::PurchaseOrdersController < Api::BaseApiController
  
  def index
    @objects = PurchaseOrder.joins(:vendor).active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
    @total = PurchaseOrder.active_objects.count
    # render :json => { :purchase_orders => @objects , :total => PurchaseOrder.active_objects.count, :success => true }
  end

  def create
    @object = PurchaseOrder.create_by_employee(current_user,  params[:purchase_order] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :purchase_orders => [@object] , 
                        :total => PurchaseOrder.active_objects.count }  
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
    
    @object = PurchaseOrder.find_by_id params[:id] 
    @object.update_by_employee(current_user,  params[:purchase_order])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :purchase_orders => [@object],
                        :total => PurchaseOrder.active_objects.count  } 
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
    @object = PurchaseOrder.find(params[:id])
    @object.delete(current_user)

    if ( @object.is_confirmed? and @object.is_deleted) or (  not @object.is_confirmed? and not @object.persisted?)  
      render :json => { :success => true, :total => PurchaseOrder.active_objects.count }  
    else
      render :json => { :success => false, :total => PurchaseOrder.active_objects.count }  
    end
  end
  
  def confirm
    @object = PurchaseOrder.find_by_id params[:id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @object.confirm( current_user  )  
    
    if @object.is_confirmed? 
      render :json => { :success => true, :total => PurchaseOrder.active_objects.count }  
    else
      render :json => { :success => false, :total => PurchaseOrder.active_objects.count }  
    end
  end
end
