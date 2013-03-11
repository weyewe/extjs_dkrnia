class Api::PurchaseOrderEntriesController < Api::BaseApiController
  
  def index
    @parent = PurchaseOrder.find_by_id params[:purchase_order_id]
    @objects = @parent.active_purchase_order_entries.joins(:purchase_order, :item).
                    page(params[:page]).
                    per(params[:limit]).order("id DESC")
                    
    @total = @parent.active_purchase_order_entries.count
  end

  def create
    @parent = PurchaseOrder.find_by_id params[:purchase_order_id]
    @object = PurchaseOrderEntry.create_by_employee(current_user, @parent,  params[:purchase_order_entry] )  
    
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :purchase_order_entries => [@object] , 
                        :total => @parent.active_purchase_order_entries.count }  
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
    
    @object = PurchaseOrderEntry.find_by_id params[:id] 
    @parent = @object.purchase_order 
    @object.update_by_employee(current_user,  params[:purchase_order_entry])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :purchase_order_entries => [@object],
                        :total => @parent.active_purchase_order_entries.count  } 
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
    @object = PurchaseOrderEntry.find(params[:id])
    @parent = @object.purchase_order 
    @object.delete(current_user)

    if @object.is_deleted
      render :json => { :success => true, :total => @parent.active_purchase_order_entries.count }  
    else
      render :json => { :success => false, :total =>@parent.active_purchase_order_entries.count }  
    end
  end
end
