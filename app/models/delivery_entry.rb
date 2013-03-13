class DeliveryEntry < ActiveRecord::Base
  include StockMutationDocumentEntry
  # attr_accessible :title, :body
  belongs_to :delivery
  belongs_to :item 

  belongs_to :sales_order_entry
    
  has_one :sales_return_entry 
  has_one :delivery_lost_entry # goods lost in delivery 
  
  validates_presence_of :sales_order_entry_id
  validates_presence_of :creator_id
  validates_presence_of :quantity_sent
   
   
  validate :quantity_must_not_less_than_zero 
  # validate :quantity_must_not_exceed_available_quantity
  validate :entry_uniqueness 
  
  after_save  :update_item_statistics
  after_destroy  :update_item_statistics
  
  def update_item_pending_receival
    return nil if not self.is_confirmed? 
    return nil if self.sales_order_entry.nil? 
    
    item = self.sales_order_entry.item  
    item.reload 
    item.update_pending_receival
  end
  
  def update_item_statistics
    return nil if not self.is_confirmed? 
    return nil if self.sales_order_entry.nil? 
    
    item = self.sales_order_entry.item
    item.reload
    item.update_ready_quantity
  end
  
  def update_purchase_order_entry_fulfilment_status
    purchase_order_entry = self.purchase_order_entry 
    purchase_order_entry.update_fulfillment_status
    # what if they change the purchase_order_entry
  end
     
  def quantity_must_not_less_than_zero
    if quantity_sent.present? and quantity_sent <= 0 
      msg = "Kuantitas  tidak boleh 0 atau negative "
      errors.add(:quantity_sent, msg )
    end
  end
     

  def entry_uniqueness
    sales_order_entry = self.sales_order_entry 
    return nil if sales_order_entry.nil? 

    parent = self.delivery 


    delivery_entry_count = DeliveryEntry.where(
      :sales_order_entry_id => self.sales_order_entry_id,
      :delivery_id => parent.id  
    ).count 

    item = sales_order_entry.item 
    sales_order = sales_order_entry.sales_order
    msg = "Item #{item.name} dari penjualan #{sales_order.code} sudah terdaftar di penerimaan ini"

    if not self.persisted? and delivery_entry_count != 0
      errors.add(:sales_order_entry_id , msg ) 
    elsif self.persisted? and not self.sales_order_entry_id_changed? and delivery_entry_count > 1
      errors.add(:sales_order_entry_id , msg ) 
    elsif self.persisted? and self.sales_order_entry_id_changed? and delivery_entry_count != 0 
      errors.add(:sales_order_entry_id , msg ) 
    end
  end


     
  def delete(employee)
    return nil if employee.nil?
    if self.is_confirmed?   # the same thing if it is post finalized
      ActiveRecord::Base.transaction do
        self.post_confirm_delete( employee)  
        return self
      end 
    end
    
    self.destroy 
  end
  
  def post_confirm_delete( employee)  
    # if there is stock_usage_entry.. refresh => dispatch to other available shite 
    # stock_entry.update_stock_migration_stock_entry( self ) if not stock_entry.nil? 
    
    # stock_entry.destroy 
    self.destroy_stock_mutations
    self.destroy 
  end
  
  
  
  def self.create_by_employee( employee, delivery, params ) 
    return nil if employee.nil?
    return nil if delivery.nil? 
    
    new_object = self.new
    new_object.creator_id = employee.id 
    
    new_object.delivery_id = delivery.id 
    new_object.quantity_sent                = params[:quantity_sent]       
    new_object.sales_order_entry_id                 = params[:sales_order_entry_id]
    
    if new_object.save 
      new_object.generate_code 
    end
    
    return new_object 
  end
  
  def update_by_employee( employee, params ) 
    if self.is_confirmed?  and not self.is_finalized? 
      ActiveRecord::Base.transaction do
        self.post_confirm_update( employee, params) 
        return self 
      end
    elsif self.is_confirmed? and self.is_finalized?
     ActiveRecord::Base.transaction do
       self.post_finalize_update( employee, params) 
       return self 
     end
    end

    self.quantity_sent = params[:quantity_sent]       
    self.sales_order_entry_id       = params[:sales_order_entry_id]
    self.save 
    return self 
  end
  
  def post_confirm_update(employee, params)
    old_item = self.sales_order_entry.item 
    is_item_changed = false
    is_quantity_changed = false 
    
    if params[:sales_order_entry_id] != self.sales_order_entry_id 
      is_item_changed = true
    end
    
    if params[:sales_order_entry_id] == self.sales_order_entry_id and   
        self.quantity_sent != params[:quantity_sent]
      is_quantity_changed = true 
    end
    
    
    if is_item_changed
      puts "773 THE ITEM IS CHANGED"      
      self.sales_order_entry_id = params[:sales_order_entry_id]
      self.quantity_sent = params[:quantity_sent] 
      self.save
    end
    
    if is_quantity_changed 
      puts "8824 the quantity is changed "
      self.quantity_sent     = params[:quantity_sent]
      self.save
    end 
    
    
    # confirmed_delivery_stock_mutation.update_delivered_quantity( self )  if not self.confirmed_delivery_stock_mutation.nil?
   
    StockMutation.create_or_update_delivery_stock_mutation( self ) 
    if is_item_changed
      old_item.reload
      self.reload
      old_item.update_ready_quantity
      self.sales_order_entry.item.update_ready_quantity
    end
    # update stock mutation
  end
  
  def generate_code
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
    
    string = "#{header}DE" + 
              ( self.created_at.year%1000).to_s + "-" + 
              ( self.created_at.month).to_s + '-' + 
              ( counter.to_s ) 
              
    self.code =  string 
    self.save 
  end
   
  def confirm
    return nil if self.is_confirmed == true 
    ActiveRecord::Base.transaction do
      self.is_confirmed = true 
      self.save
      self.reload 
      self.generate_code 
      self.update_delivery_stock_mutations
      
    end
    
  end
  
  
=begin
  UPDATE THE DELIVERY RESULT
=end
  def validate_post_delivery_quantity 
    if quantity_confirmed.nil? or quantity_confirmed < 0 
      self.errors.add(:quantity_confirmed , "Tidak boleh kurang dari 0" ) 
    end
    
    if quantity_returned.nil? or quantity_returned < 0 
      self.errors.add(:quantity_returned , "Tidak boleh kurang dari 0" ) 
    end
    
    if quantity_lost.nil? or quantity_lost < 0 
      self.errors.add(:quantity_lost , "Tidak boleh kurang dari 0" ) 
    end
  end
  
  def validate_post_delivery_total_sum
    if self.quantity_confirmed + self.quantity_returned + self.quantity_lost != self.quantity_sent 
      msg = "Jumlah yang terkirim: #{self.quantity_sent}. " +
              "Konfirmasi #{self.quantity_confirmed} + " + 
              " Retur #{self.quantity_returned }+ " + 
              " Hilang #{self.quantity_lost} tidak sesuai."
      self.errors.add(:quantity_confirmed , msg ) 
      self.errors.add(:quantity_returned ,  msg ) 
      self.errors.add(:quantity_lost ,      msg ) 
    end
  end
   
  
  
  def validate_post_delivery_update 
    self.validate_post_delivery_quantity 
    self.validate_post_delivery_total_sum   
  end
    
  def update_post_delivery( employee, params ) 
    return nil if employee.nil? 
    if self.is_finalized?
      ActiveRecord::Base.transaction do
        self.post_finalize_update( employee, params)
        return self 
      end
    end 
    self.quantity_confirmed        = params[:quantity_confirmed]
    self.quantity_returned         = params[:quantity_returned]
    self.quantity_lost             = params[:quantity_lost]
    self.validate_post_delivery_update
    # puts "after validate_post_production_update, errors: #{self.errors.size.to_s}"
    self.errors.messages.each do |message|
      puts "The message: #{message}"
    end
    
    return self if  self.errors.size != 0 
    self.save  
    return self  
  end
  
  
  def finalize 
    return nil if self.is_confirmed == false 
    return nil if self.is_finalized == true 
      
    self.validate_post_delivery_update
    
    if  self.errors.size != 0 
      self.errors.messages.each do |key, values| 
        puts "The key is #{key.to_s}"
        values.each do |value|
          puts "\tthe value is #{value}"
        end
      end
      
      raise ActiveRecord::Rollback, "Call tech support!" 
    end
    
    ActiveRecord::Base.transaction do
      self.is_finalized = true 
      self.save 
      self.update_delivery_stock_mutations 
    end
  end
  
  def quantity_returned
    return 0 if self.sales_return_entry.nil? 
    return self.sales_return_entry.quantity
  end
  
  def quantity_lost
    return 0 if self.delivery_lost_entry.nil? 
    return self.delivery_lost_entry.quantity
  end
  
=begin
  What if some numbers need to be adjusted after the delivery? 
=end

  def post_finalize_update( employee, params ) 
    return nil if employee.nil? 
    
    self.quantity_sent      = params[:quantity_sent]
    self.quantity_confirmed = params[:quantity_confirmed]
    self.quantity_returned  = params[:quantity_returned]
    self.quantity_lost      = params[:quantity_lost]
    self.validate_post_delivery_update
    
    return self if  self.errors.size != 0 
    self.save  
    self.update_delivery_stock_mutations 
    return self  
  end

  def update_delivery_stock_mutations
    StockMutation.create_or_update_delivery_stock_mutation( self ) 
    StockMutation.create_or_update_delivery_return_stock_mutation( self ) 
    StockMutation.create_or_update_delivery_lost_stock_mutation( self )
  end
  
  def stock_entry_usages
    StockEntryUsage.where(
      :source_document_entry_id => self.id,
      :source_document_entry => self.class.to_s ,
      :case => STOCK_ENTRY_USAGE[:delivery]  
    )
  end
  
  def destroy_stock_mutations
    StockMutation.where(
      :source_document_entry_id => self.id,
      :source_document_entry => self.class.to_s  
    ).each {|x| x.destroy }
  end
   
  def delivery_return_stock_mutation
    StockMutation.where(
      :source_document_entry_id => self.id,
      :source_document_entry => self.class.to_s ,
      :mutation_case => MUTATION_CASE[:delivery_returned],
      :mutation_status => MUTATION_STATUS[:addition]
    ).first 
  end
  
  def confirmed_delivery_stock_mutation
    StockMutation.where(
      :source_document_entry_id => self.id,
      :source_document_entry => self.class.to_s ,
      :mutation_case => MUTATION_CASE[:delivery],
      :mutation_status => MUTATION_STATUS[:deduction]
    ).first
  end
  
  def delivery_lost_stock_mutation
    StockMutation.where(
      :source_document_entry_id => self.id,
      :source_document_entry => self.class.to_s ,
      :mutation_case => MUTATION_CASE[:delivery_lost],
      :mutation_status => MUTATION_STATUS[:deduction]
    ).first 
  end
  
  
end
