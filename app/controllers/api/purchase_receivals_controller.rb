class Api::PurchaseReceivalsController < Api::BaseApiController
  
  def index
    @objects = PurchaseReceival.joins(:vendor).active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
    @total = PurchaseReceival.active_objects.count
    # render :json => { :purchase_receivals => @objects , :total => PurchaseReceival.active_objects.count, :success => true }
  end

  def create
    @object = PurchaseReceival.create_by_employee(current_user,  params[:purchase_receival] )  
    
    
 
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :purchase_receivals => [@object] , 
                        :total => PurchaseReceival.active_objects.count }  
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
    
    @object = PurchaseReceival.find_by_id params[:id] 
    @object.update_by_employee(current_user,  params[:purchase_receival])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :purchase_receivals => [@object],
                        :total => PurchaseReceival.active_objects.count  } 
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
    @object = PurchaseReceival.find(params[:id])
    @object.delete(current_user)

    if ( @object.is_confirmed? and @object.is_deleted) or (  not @object.is_confirmed? and not @object.persisted?)  
      render :json => { :success => true, :total => PurchaseReceival.active_objects.count }  
    else
      render :json => { :success => false, :total => PurchaseReceival.active_objects.count }  
    end
  end
  
  def confirm
    @object = PurchaseReceival.find_by_id params[:id]
    # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
    @object.confirm( current_user  )  
    
    if @object.is_confirmed? 
      render :json => { :success => true, :total => PurchaseReceival.active_objects.count }  
    else
      render :json => { :success => false, :total => PurchaseReceival.active_objects.count }  
    end
  end
end
