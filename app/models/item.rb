class Item < ActiveRecord::Base
  include UniqueNonDeleted
  # attr_accessible :name, :recommended_selling_price, :category_id
  has_many :stock_entry 
  belongs_to :item_category
  
  belongs_to :item_category 
  has_one :stock_migration
  has_many :stock_mutations 
  has_many :purchase_order_entries 
  has_many :purchase_receival_entries 
   
  validates_presence_of :name ,  :supplier_code, :customer_code #  , :item_category_id ,
  
  validate :unique_non_deleted_name
  
  def unique_object
    "item "
  end 
   
  
  def self.active_objects
    Item.where(:is_deleted => false).order("created_at DESC")
  end
=begin
  INITIAL MIGRATION 
=end 
  def has_past_migration?
    StockMigration.where(:item_id => self.id , :is_confirmed => true ).count > 0 
  end
  
  def self.create_by_employee(  employee, object_params) 
    return nil if employee.nil? 
    
    new_object = Item.new  
    
    # base_category = ItemCategory.first 
    
    new_object.creator_id                = employee.id 
    new_object.name                      = object_params[:name] 
    # new_object.item_category_id          = base_category.id # object_params[:item_category_id]   
    new_object.supplier_code = object_params[:supplier_code]
    new_object.customer_code = object_params[:customer_code]

    new_object.save 
    return new_object 
  end
  
  def  update_by_employee(  employee,   object_params)  
    return nil if employee.nil? 
    
    # base_category = ItemCategory.first 
    self.creator_id                = employee.id 
    self.name                      = object_params[:name] 
    # self.item_category_id          = base_category.id 
    self.supplier_code = object_params[:supplier_code]
    self.customer_code = object_params[:customer_code]
    self.save 
    return self 
  end
  
  
  def add_stock_and_recalculate_average_cost_post_stock_entry_addition( new_stock_entry )  
    total_amount = ( self.average_cost * self.ready)   + 
                   ( new_stock_entry.base_price_per_piece * new_stock_entry.quantity ) 
                  
    total_quantity = self.ready + new_stock_entry.quantity 
    
    if total_quantity == 0 
      self.average_cost = BigDecimal('0')
    else
      self.average_cost = total_amount / total_quantity .to_f
    end
    self.ready = total_quantity 
    self.save 
  end
  
  def update_ready_quantity 
    addition = self.stock_mutations.where(
      :mutation_status  => MUTATION_STATUS[:addition] ,
      :item_status  => ITEM_STATUS[:ready]
    ).sum("quantity")
    
    deduction = self.stock_mutations.where(
      :mutation_status  => MUTATION_STATUS[:deduction] ,
      :item_status  => ITEM_STATUS[:ready]
    ).sum("quantity")
    
    self.ready = addition - deduction 
    self.save 
  end
  
  def delete(current_user)
    return nil if current_user.nil? 
    
    self.is_deleted = true
    self.save 
  end
  
 
=begin
  BECAUSE OF SALES
=end
  def deduct_ready_quantity( quantity)
    self.ready -= quantity 
    self.save
  end
  
  def add_ready_quantity( quantity ) 
    self.ready += quantity 
    self.save
  end
  
=begin
  BECAUSE OF SCRAP -> SCRAP EXCHANGE
=end
  
  def deduct_scrap_quantity( quantity )
    self.scrap -= quantity 
    self.ready += quantity 
    self.save
  end
  
  def add_scrap_quantity( quantity ) 
    self.scrap += quantity 
    self.ready -= quantity 
    self.save 
  end
  
=begin
  UPDATE ITEM STATISTIC
=end
  
  def update_pending_receival
    self.pending_receival = self.purchase_order_entries.where(:is_confirmed => true ).sum("quantity") - 
              self.purchase_receival_entries.where(:is_confirmed => true ).sum("quantity")
    self.save 
  end
  
  def update_pending_delivery
    self.pending_receival = self.sales_order_entries.where(:is_confirmed => true ).sum("quantity") - 
              self.delivery_entries.where(:is_confirmed => true ).sum("quantity")
    self.save
  end
end
