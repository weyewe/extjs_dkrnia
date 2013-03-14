class DeliveryLostEntry < ActiveRecord::Base
  include StockMutationDocumentEntry
  # attr_accessible :title, :body
 
  belongs_to :delivery_entry
    
  
  validates_presence_of :delivery_entry_id
  validates_presence_of :creator_id
  validates_presence_of :quantity 
   
   
  validate :quantity_must_not_less_than_zero 
  validate :quantity_must_not_exceed_max_quantity
  validate :entry_must_come_from_single_delivery 
  validate :entry_uniqueness 
  
  after_save  :update_item_statistics, :update_item_pending_delivery, :update_delivery_stock_mutations
  after_destroy  :update_item_statistics, :update_item_pending_delivery
  
  def update_item_pending_delivery
    return nil if not self.is_confirmed? 
    return nil if self.delivery_entry.sales_order_entry.item.nil? 
    
    item = self.delivery_entry.sales_order_entry.item
    item.reload 
    item.update_pending_delivery
  end
  
  
   
  def update_delivery_stock_mutations
    return nil if not self.is_confirmed? 
    StockMutation.create_or_update_delivery_lost_stock_mutation( self ) 
  end
  
  def update_item_pending_receival
    return nil if not self.is_confirmed? 
    return nil if self.delivery_entry.sales_order_entry.item.nil? 
    
    item = self.delivery_entry.sales_order_entry.item
    item.reload 
    item.update_pending_receival
  end
  
  def update_item_statistics
    return nil if not self.is_confirmed? 
    return nil if self.delivery_entry.sales_order_entry.item.nil? 
    
    item = self.delivery_entry.sales_order_entry.item
    item.reload
    item.update_ready_quantity
  end
 
     
  def quantity_must_not_less_than_zero
    if quantity.present? and quantity <= 0 
      msg = "Kuantitas  tidak boleh 0 atau negative "
      errors.add(:quantity, msg )
    end
  end
  
  def quantity_must_not_exceed_max_quantity
    return nil if not  self.quantity.present? 
    delivery_entry = self.delivery_entry 
    max_return =  delivery_entry.quantity_sent - delivery_entry.quantity_returned  
    
    if self.quantity > max_return 
      msg = "Jumlah maksimum dikembalikan: #{max_return}"
      self.errors.add(:quantity , msg )  
    end
  end
  
     

  def entry_uniqueness
    delivery_entry = self.delivery_entry 
    return nil if delivery_entry.nil? 

    parent = self.delivery_lost 


    delivery_lost_entry_count = DeliveryLostEntry.where(
      :delivery_entry_id => self.delivery_entry_id,
      :delivery_lost_id => parent.id  
    ).count 

    item = delivery_entry.sales_order_entry.item 
    delivery  = delivery_entry.delivery 
    msg = "Item #{item.name} dari pengiriman #{delivery_entry.code} sudah terdaftar di penerimaan ini"

    if not self.persisted? and delivery_lost_entry_count != 0
      errors.add(:delivery_entry_id , msg ) 
    elsif self.persisted? and not self.delivery_entry_id_changed? and delivery_lost_entry_count > 1
      errors.add(:delivery_entry_id , msg ) 
    elsif self.persisted? and self.delivery_entry_id_changed? and delivery_lost_entry_count != 0 
      errors.add(:delivery_entry_id , msg ) 
    end
  end

  def entry_must_come_from_single_delivery
    delivery_entry = self.delivery_entry 
    return nil if delivery_entry.nil?
    delivery = delivery_entry.delivery 
    return nil if delivery.nil? 
    
    delivery_entry_id_list = delivery.delivery_entries.map {|x| x.id }
    if not delivery_entry_id_list.include?( delivery_entry.id )
      errors.add(:delivery_entry_id , "Tidak ada di daftar pengiriman #{delivery_entry.delivery.code}" ) 
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
  
  
  
  def self.create_by_employee( employee, delivery_lost, params ) 
    return nil if employee.nil?
    return nil if delivery_lost.nil? 
    
    new_object = self.new
    new_object.creator_id = employee.id 
    
    new_object.delivery_entry_id = params[:delivery_entry_id]
    new_object.quantity          = params[:quantity]       
    new_object.delivery_lost_id   = delivery_lost.id 

    if new_object.save 
      new_object.generate_code 
    end
    
    return new_object 
  end
  
  def update_by_employee( employee, params ) 
    if self.is_confirmed?  
      ActiveRecord::Base.transaction do
        self.post_confirm_update( employee, params) 
        return self 
      end
    end

    self.quantity          = params[:quantity]       
    self.delivery_entry_id = params[:delivery_entry_id]
    self.save 

    return self 
  end
  
  def post_confirm_update(employee, params)
    old_item = self.delivery_entry.sales_order_entry.item 
    is_item_changed = false
    is_quantity_changed = false 
    
    if params[:delivery_entry_id] != self.delivery_entry_id 
      is_item_changed = true
    end
    
    if params[:delivery_entry_id] == self.delivery_entry_id and   
        self.quantity != params[:quantity]
      is_quantity_changed = true 
    end
    
    
    if is_item_changed
      puts "773 THE ITEM IS CHANGED"      
      self.delivery_entry_id = params[:delivery_entry_id]
      self.quantity = params[:quantity] 
      self.save
    end
    
    if is_quantity_changed 
      puts "8824 the quantity is changed "
      self.quantity_sent     = params[:quantity_sent]
      self.save
    end 
    
    
   
    if is_item_changed
      old_item.reload
      self.reload
      old_item.update_ready_quantity
      self.delivery_entry.sales_order_entry.item.update_ready_quantity
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
    
    string = "#{header}DLE" + 
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
      # self.update_delivery_stock_mutations # it is in the after_save callback 
    end
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
   
  def delivery_lost_stock_mutation
    StockMutation.where(
      :source_document_entry_id => self.id,
      :source_document_entry => self.class.to_s ,
      :mutation_case => MUTATION_CASE[:delivery_lost],
      :mutation_status => MUTATION_STATUS[:deduction]
    ).first 
  end
  
end
