class Api::SalesReturnEntriesController < Api::BaseApiController
  
  def index
    @parent = SalesReturn.find_by_id params[:sales_return_id]
    @objects = @parent.active_sales_return_entries.joins( :sales_return, :delivery_entry => [:sales_order_entry => [:item]]).page(params[:page]).per(params[:limit]).order("id DESC")
    @total = @parent.active_sales_return_entries.count
  end

  def create
    @parent = SalesReturn.find_by_id params[:sales_return_id]
    @object = SalesReturnEntry.create_by_employee(current_user, @parent,  params[:sales_return_entry] )  
    
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :sales_return_entries => [@object] , 
                        :total => @parent.active_sales_return_entries.count }  
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
    
    @object = SalesReturnEntry.find_by_id params[:id] 
    @parent = @object.sales_return 
    @object.update_by_employee(current_user,  params[:sales_return_entry])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :sales_return_entries => [@object],
                        :total => @parent.active_sales_return_entries.count  } 
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
  
  def update_post_sales_return
    @object = SalesReturnEntry.find_by_id params[:id]
    @parent = @object.sales_return
    
    @object.update_post_sales_return( current_user, params[:sales_return_entry] )
    
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :sales_return_entries => [@object],
                        :total => @parent.active_sales_return_entries.count  } 
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
    @object = SalesReturnEntry.find(params[:id])
    @parent = @object.sales_return 
    @object.delete(current_user)

    if ( @object.persisted? and @object.is_deleted ) or ( not @object.persisted? )
      render :json => { :success => true, :total => @parent.active_sales_return_entries.count }  
    else
      render :json => { :success => false, :total =>@parent.active_sales_return_entries.count }  
    end
  end
end
