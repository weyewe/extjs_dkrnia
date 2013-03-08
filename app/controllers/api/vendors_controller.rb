class Api::VendorsController < Api::BaseApiController
  
  def index
    @objects = Vendor.active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
    render :json => { :vendors => @objects , :total => Vendor.active_objects.count, :success => true }
  end

  def create
    @object = Vendor.new(params[:vendor])
 
    if @object.save
      render :json => { :success => true, 
                        :vendors => [@object] , 
                        :total => Vendor.active_objects.count }  
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
    @object = Vendor.find(params[:id])
    
    if @object.update_attributes(params[:vendor])
      render :json => { :success => true,   
                        :vendors => [@object],
                        :total => Vendor.active_objects.count  } 
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
    @object = Vendor.find(params[:id])
    @object.delete(current_user)

    if @object.is_deleted
      render :json => { :success => true, :total => Vendor.active_objects.count }  
    else
      render :json => { :success => false, :total => Vendor.active_objects.count }  
    end
  end
  
  def search
    search_params = params[:query]
    
    query = '%' + search_params + '%'
    # on PostGre SQL, it is ignoring lower case or upper case 
    
    @objects = Vendor.where{ (name =~ query)  & (is_deleted.eq false) }.
                      page(params[:page]).
                      per(params[:limit]).
                      order("id DESC")
    
    
    render :json => { :records => @objects , :total => @objects.count, :success => true }
  end
end
