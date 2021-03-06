class SalesReturn < ActiveRecord::Base
  include StockMutationDocument
  # attr_accessible :title, :body
  validates_presence_of :creator_id
  validates_presence_of :delivery_id  
  validates_uniqueness_of :delivery_id 
  
  has_many :sales_return_entries  
  belongs_to :delivery   
  
  validate :delivery_must_be_confirmed
  
  
  
  def delivery_must_be_confirmed
    return nil if self.delivery_id.nil?
    
    if not delivery.is_confirmed?
      errors.add(:delivery_id, "Delivery harus dikonfirmasi dahulu")
    end
  end
  
  def self.active_objects
    self.where(:is_deleted => false ).order("created_at DESC")
  end
  
  def delete(employee) 
    return nil if employee.nil? 
    
    self.sales_return_entries.each do |sre|
      sre.delete( employee ) 
    end
   
    self.destroy 
  end
  
  
   
  
  
  def active_sales_return_entries 
    self.sales_return_entries.order("created_at DESC")
  end
  
  def update_by_employee( employee, params ) 
    if self.is_confirmed?
      return self
    end
    
    self.delivery_id  = params[:delivery_id]
    self.save
    return self 
  end
  
  
=begin
  BASIC
=end
  def self.create_by_employee( employee, params ) 
    return nil if employee.nil? 
    
    new_object = self.new
    new_object.creator_id = employee.id
    new_object.delivery_id = params[:delivery_id]

    
    if new_object.save
      new_object.generate_code
    end
    
    return new_object 
  end
  
  def generate_code
    # get the total number of sales receival created in that month 
    
    # total_sales_receival = SalesOrder.where()
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
    
    
    string = "#{header}SR" + "/" + 
              self.created_at.year.to_s + '/' + 
              self.created_at.month.to_s + '/' + 
              counter.to_s
              
    self.code =  string 
    self.save 
  end
   
  
  def confirm(employee) 
    return nil if employee.nil? 
    return nil if self.active_sales_return_entries.count == 0 
    return nil if self.is_confirmed == true  
    
    # transaction block to confirm all the sales item  + sales receival confirmation 
    ActiveRecord::Base.transaction do
      self.confirmer_id = employee.id 
      self.confirmed_at = DateTime.now 
      self.is_confirmed = true 
      self.save 
      self.generate_code
      self.sales_return_entries.each do |sre|
        sre.confirm 
      end
    end 
  end
   
  
=begin
  Sales Invoice Printing
=end
  def printed_code
    self.code.gsub('/','-')
  end

  def printed_sales_invoice_code
    self.code.gsub('/','-')
  end

  def calculated_vat
    BigDecimal("0")
  end

  def calculated_delivery_charges
    BigDecimal("0")
  end

  def calculated_sales_tax
    BigDecimal('0')
  end
end
