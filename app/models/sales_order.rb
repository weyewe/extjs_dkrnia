class SalesOrder < ActiveRecord::Base
  validates_presence_of :creator_id
  validates_presence_of :customer_id  
  has_many :sales_order_entries 
  
  belongs_to :customer 
  
  
  # scope :live_search, lambda { |search| 
  #    search = "%#{search}%"
  #    joins(:customer).where{ (code =~ search) |  
  #          (customer.name =~ search )} 
  #   }
   
  def self.active_objects
    self.where(:is_deleted => false ).order("id DESC")
  end
  
  def active_sales_order_entries
    self.sales_order_entries.where(:is_deleted => false ).order("id DESC")
  end
  
  def delete(employee) 
    return nil if employee.nil? 
    if self.is_confirmed?  
      ActiveRecord::Base.transaction do
        self.post_confirm_delete( employee) 
      end
      return self
    end
   
    self.sales_order_entries.each do |si|
      si.delete(employee)
    end
    self.destroy
  end
  
  def post_confirm_delete( employee) 
    
    # if one of its child is delivered, can't delete 
    # wtf.. just delete.
    
    sales_order_entry_id_list = self.sales_order_entries.map{|x| x.id }
    if DeliveryEntry.where(:sales_order_entry_id => sales_order_entry_id_list).count != 0 
      self.errors.add(:delete_fail , "Sudah ada pengiriman." )  
      return self
    end
    
     
    self.sales_order_entries.each do |si|
      si.delete( employee ) 
    end 
    
    self.is_deleted = true 
    self.save 
  end
  
  
  
  def update_by_employee( employee, params ) 
    if self.is_confirmed?
      return self
    end
    self.customer_id = params[:customer_id]
    self.save
    return self 
  end
  
  
=begin
  BASIC
=end
  def self.create_by_employee( employee, params ) 
    return nil if employee.nil? 
    
    new_object = SalesOrder.new
    new_object.creator_id   = employee.id
    new_object.customer_id  = params[:customer_id]
    # new_object.payment_term = params[:payment_term]

    if new_object.save
      new_object.generate_code
    end
    
    return new_object 
  end
  
  def generate_code
    # get the total number of sales order created in that month 
    
    # total_sales_order = SalesOrder.where()
    start_datetime = Date.today.at_beginning_of_month.to_datetime
    end_datetime = Date.today.next_month.at_beginning_of_month.to_datetime
    
    counter = self.class.where{
      (self.created_at >= start_datetime)  & 
      (self.created_at < end_datetime )
    }.count
    
    if self.is_confirmed?
      counter = self.class.where{
        (self.created_at >= start_datetime)  & 
        (self.created_at < end_datetime ) & 
        (self.is_confirmed.eq true )
      }.count
    end
    
  
    header = ""
    if not self.is_confirmed?  
      header = "[pending]"
    end
    
    
    string = "#{header}SO" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s + '/' + 
              counter.to_s
              
    self.code =  string 
    self.save 
  end
   
  
  def confirm(employee) 
    return nil if employee.nil? 
    return nil if self.active_sales_order_entries.count == 0 
    return nil if self.is_confirmed == true  
    
    # transaction block to confirm all the sales item  + sales order confirmation 
    ActiveRecord::Base.transaction do
      self.confirmer_id = employee.id 
      self.confirmed_at = DateTime.now 
      self.is_confirmed = true 
      self.save 
      self.generate_code
      self.active_sales_order_entries.each do |sales_order_entry|
        sales_order_entry.confirm 
      end
    end 
  end
end
