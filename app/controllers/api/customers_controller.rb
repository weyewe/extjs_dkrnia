class Api::CustomersController < Api::BaseApiController
  
  def index
    @objects = Customer.active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
    render :json => { :customers => @objects , :total => Customer.active_objects.count, :success => true }
  end

  def create
    @object = Customer.new(params[:customer])
 
    if @object.save
      render :json => { :success => true, 
                        :customers => [@object] , 
                        :total => Customer.active_objects.count }  
    else
      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors ) 
          # :errors => {
          #   :name => "Nama tidak boleh bombastic"
          # }
        }
      }
      
      render :json => msg                         
    end
  end

  def update
    @object = Customer.find(params[:id])
    
    if @object.update_attributes(params[:customer])
      render :json => { :success => true,   
                        :customers => [@object],
                        :total => Customer.active_objects.count  } 
    else
      msg = {
        :success => false, 
        :message => {
          :errors => {
            :name => "Nama tidak boleh kosong"
          }
        }
      }
      
      render :json => msg 
    end
  end

  def destroy
    @object = Customer.find(params[:id])
    @object.delete(current_user)

    if @object.is_deleted
      render :json => { :success => true, :total => Customer.active_objects.count }  
    else
      render :json => { :success => false, :total => Customer.active_objects.count }  
    end
  end
end
