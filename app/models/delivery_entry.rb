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
  validate :quantity_must_not_exceed_pending_delivery
  validate :entry_uniqueness 
  
  # how about the sales order entry statistic? later. 
  after_save  :update_item_statistics, :update_item_pending_delivery
  after_destroy  :update_item_statistics, :update_item_pending_delivery
  
  def update_item_pending_delivery
    self.reload  if self.persisted?

    return  if not self.is_confirmed? 
    return  if self.sales_order_entry.nil? 
    
    item = self.sales_order_entry.item  
    item.reload 
    item.update_pending_delivery
  end
  
  def update_item_statistics
    self.reload  if self.persisted?
   
    return  if not self.is_confirmed? 
    return  if self.sales_order_entry.nil? 
    
    item = self.sales_order_entry.item
    item.reload
    item.update_ready_quantity
  end
  
  def update_quantity_confirmed
    self.reload 
    self.quantity_returned = 0 
    if not self.sales_return_entry.nil? 
      self.quantity_returned = self.sales_return_entry.quantity
    end
    
    self.quantity_lost = 0 
    if not self.delivery_lost_entry.nil? 
      self.quantity_lost = self.delivery_lost_entry.quantity
    end
    
    self.quantity_confirmed = self.quantity_sent - self.quantity_returned - self.quantity_lost 
    self.save
    # on save, it will update the pending delivery and ready item 
  end
  
  def quantity_must_not_less_than_zero
    if quantity_sent.present? and quantity_sent <= 0 
      msg = "Kuantitas  tidak boleh 0 atau negative "
      errors.add(:quantity_sent, msg )
    end
  end
  
  def quantity_must_not_exceed_pending_delivery
    return if sales_order_entry.nil?  or quantity_sent.nil? 
    if not self.is_confirmed? 
      max_quantity = sales_order_entry.pending_delivery
    else
      max_quantity = sales_order_entry.max_delivery_quantity( self )
    end
    
    
    if quantity_sent  > max_quantity
      errors.add(:quantity_sent , "Maksimal quantity: #{max_quantity}")
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
    sales_order_entry = SalesOrderEntry.find_by_id params[:sales_order_entry_id]
    
    new_object = self.new
    new_object.creator_id = employee.id 
    
    new_object.delivery_id = delivery.id 
    new_object.quantity_sent                = params[:quantity_sent]       
    new_object.sales_order_entry_id                 = params[:sales_order_entry_id]
    new_object.item_id = sales_order_entry.item_id 
    
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
    end

    self.quantity_sent = params[:quantity_sent]       
    self.sales_order_entry_id       = params[:sales_order_entry_id]
    sales_order_entry = SalesOrderEntry.find_by_id params[:sales_order_entry_id]
    self.item_id = sales_order_entry.item_id 
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
      self.sales_order_entry_id = params[:sales_order_entry_id]
      self.quantity_sent = params[:quantity_sent] 
      self.quantity_confirmed = self.quantity_sent - self.quantity_returned - self.quantity_lost  
      sales_order_entry = SalesOrderEntry.find_by_id params[:sales_order_entry_id]
      self.item_id = sales_order_entry.item_id 
      self.save
      return self if self.errors.size != 0 
    end
    
    if is_quantity_changed 
      self.quantity_sent     = params[:quantity_sent]
      self.quantity_confirmed = self.quantity_sent - self.quantity_returned - self.quantity_lost 
      self.save
    end 
    
    
    # confirmed_delivery_stock_mutation.update_delivered_quantity( self )  if not self.confirmed_delivery_stock_mutation.nil?
   
    StockMutation.create_or_update_delivery_stock_mutation( self ) 
    if is_item_changed
      old_item.reload
      self.reload
      old_item.update_ready_quantity
      old_item.update_pending_delivery
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
  
      self.is_confirmed = true 
      self.quantity_confirmed = self.quantity_sent 
   
      self.save
   
      self.reload 
      self.generate_code 
      self.update_delivery_stock_mutations
  end
  

  
  # def update_quantity_returned
  #   quantity = 0 
  #   if  not self.sales_return_entry.nil?
  #     quantity = self.sales_return_entry.quantity
  #   end
  #   self.quantity_returned = quantity 
  #   self.save 
  # end
  # 
  # def update_quantity_lost
  #   quantity = 0 
  #   if  not self.delivery_lost_entry.nil?
  #     quantity = self.delivery_lost_entry.quantity
  #   end
  #   self.quantity_lost = quantity 
  #   self.save
  # end
 
  
  # def quantity_returned
  #   return 0 if self.sales_return_entry.nil? 
  #   return self.sales_return_entry.quantity
  # end
  # 
  # def quantity_lost
  #   return 0 if self.delivery_lost_entry.nil? 
  #   return self.delivery_lost_entry.quantity
  # end


  def update_delivery_stock_mutations
    StockMutation.create_or_update_delivery_stock_mutation( self ) 
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
