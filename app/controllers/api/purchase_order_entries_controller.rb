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
  
  def search
    search_params = params[:query]
    selected_id = params[:selected_id]
    if params[:selected_id].nil?  or params[:selected_id].length == 0 
      selected_id = nil
    end
    
    query = "%#{search_params}%"
    # on PostGre SQL, it is ignoring lower case or upper case 
    
    if  selected_id.nil?
      @objects = PurchaseOrderEntry.joins(:item, :purchase_order).where{ (item.name =~ query )   & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    else
      @objects = PurchaseOrderEntry.joins(:item, :purchase_order).where{ (id.eq selected_id)  & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    end
    
    @total = @objects.count
    @success = true 
    # render :json => { :records => @objects , :total => @objects.count, :success => true }
  end
end
