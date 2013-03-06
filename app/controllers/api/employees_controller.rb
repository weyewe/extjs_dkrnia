class Api::EmployeesController < Api::BaseApiController
  
  def index
    @objects = Employee.page(params[:page]).per(params[:limit]).order("id DESC")
    render :json => { :employees => @objects , :total => Employee.all.count, :success => true }
  end

  def create
    @object = Employee.new(params[:employee])

    respond_to do |format|
      if @object.save
        render :json => { :success => true, 
                          :employees => [@object] , 
                          :total => Employee.all.count }  
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
  end

  def update
    @object = Employee.find(params[:id])
    # sleep 2 
    respond_to do |format|
      if @object.update_attributes(params[:employee])
        render :json => { :success => true,   
                          :employees => [@object],
                          :total => Employee.all.count  } 
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
  end

  def destroy
    @object = Employee.find(params[:id])
    @object.destroy

    render :json => { :success => true, :total => Employee.all.count }  
  end
end
