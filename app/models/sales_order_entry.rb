class SalesOrderEntry < ActiveRecord::Base
  belongs_to :sales_order
  belongs_to :item 
  
  validates_presence_of :item_id 
  validates_presence_of :quantity 
  
  validate :entry_uniqueness
  validate :quantity_must_not_less_than_zero
  
  def quantity_must_not_less_than_zero
    if quantity.present? and quantity <= 0 
      msg = "Kuantitas  tidak boleh 0 atau negative "
      errors.add(:quantity , msg )
    end
  end
  
  def entry_uniqueness
    item = self.item 
    return nil if item.nil? 
    
    parent = self.sales_order 
    
    # on update, this validation is called before_save 
    # so, when we are searching, it won't be found out. 
    # there is only 1 in the database. with this new shite. it is gonna be 2. 
    
    # but on create, this validation somewhow shows the data. NO.it is our fault
    # in the create action, it calls 2 #CREATE action
    sales_order_entry_count = SalesOrderEntry.where(
      :item_id => self.item_id,
      :sales_order_id => parent.id  
    ).count 
    
    msg = "Item #{item.name}  sudah terdaftar di penerimaan ini"
    
    if not self.persisted? and sales_order_entry_count != 0
      errors.add(:item_id , msg ) 
    elsif self.persisted? and not self.item_id_changed? and sales_order_entry_count > 1
      errors.add(:item_id , msg ) 
    elsif self.persisted? and self.item_id_changed? and sales_order_entry_count != 0 
      errors.add(:item_id , msg ) 
    end
  end
  
  def delete(employee)
    return nil if employee.nil?
    if self.is_confirmed?  
      ActiveRecord::Base.transaction do
        self.post_confirm_delete( employee)  
        return 
      end 
    end
    
    self.destroy 
  end
  
  def post_confirm_delete( employee)  
    if self.delivery_entries.count != 0 
      self.errors.add(:generic_errors , "Sudah ada pengiriman barang" )
      return self
    end
    
    self.destroy 
  end
  
  def self.create_by_employee( employee, sales_order, params ) 
    return nil if employee.nil?
    return nil if sales_order.nil?
    item = Item.find_by_id params[:item_id]
    
    new_object = self.new
    new_object.creator_id = employee.id 
    new_object.sales_order_id = sales_order.id 
    
    new_object.item_id        = item.id 
    new_object.quantity       = params[:quantity]   
    
    if new_object.save 
      new_object.generate_code 
    end
    
    return new_object 
  end
  
  def update_by_employee( employee, params ) 
    if self.is_confirmed? 
      # later on, put authorization 
      ActiveRecord::Base.transaction do
        self.post_confirm_update( employee, params) 
        return self
      end 
    end

    self.quantity                = params[:quantity]       
    self.item_id                 = params[:item_id]
 
    self.save 
    return self 
  end
  
  def post_confirm_update(employee, params)
    
   
    is_item_changed = false
    is_quantity_changed = false
    
    
    if params[:item_id] != self.item_id
      is_item_changed = true 
    end
    
    if params[:item_id] == self.item_id and 
        params[:quantity] != self.quantity
      is_quantity_changed = true 
    end
    
    if  is_item_changed
      self.item_id                 =  params[:item_id]
      self.quantity                = params[:quantity]

      self.save 
      return self if self.errors.size != 0 
    end
    
    if is_quantity_changed
      self.quantity                = params[:quantity]
      self.save
    end
    
    
    # update the pending delivery in the item 
    
    # stock_mutation.purchase_receival_change_item( self )  if not self.stock_mutation.nil?
    # 
    # if purchase_order_entry.id != old_purchase_order_entry.id 
    #   old_purchase_order_entry.reload 
    #   old_purchase_order_entry.update_fulfillment_status
    # end
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
    
    string = "#{header}PRCE" + 
              ( self.created_at.year%1000).to_s + "-" + 
              ( self.created_at.month).to_s + '-' + 
              ( counter.to_s ) 
              
    
    self.code =  string 
    self.save 
  end
   
  def confirm
    return nil if self.is_confirmed == true 
    self.is_confirmed = true 
    self.save
    self.generate_code 
    self.reload 
    
    # create  stock_entry and the associated stock mutation 
    # StockEntry.generate_purchase_receival_stock_entry( self  ) 
    # StockMutation.generate_purchase_receival_stock_mutation( self  ) 
    
    
    # update the pending delivery 
  end
end
