class Api::EmployeesController < Api::BaseApiController
  
  def index
    @objects = Employee.active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
    render :json => { :employees => @objects , :total => Employee.active_objects.count, :success => true }
  end

  def create
    @object = Employee.new(params[:employee])
 
    if @object.save
      render :json => { :success => true, 
                        :employees => [@object] , 
                        :total => Employee.active_objects.count }  
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
    @object = Employee.find(params[:id])
    
    if @object.update_attributes(params[:employee])
      render :json => { :success => true,   
                        :employees => [@object],
                        :total => Employee.active_objects.count  } 
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
    @object = Employee.find(params[:id])
    @object.destroy

    if self.is_deleted
      render :json => { :success => true, :total => Employee.active_objects.count }  
    else
      render :json => { :success => false, :total => Employee.active_objects.count }  
    end
  end
end
