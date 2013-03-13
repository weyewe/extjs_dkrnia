class CreateSalesOrderEntries < ActiveRecord::Migration
  def change
    create_table :sales_order_entries do |t|
      t.integer :creator_id
      t.integer :sales_order_id 
      
      t.string  :code
      
      t.integer :quantity 
      t.integer :item_id 

       
     t.boolean :is_confirmed, :default => false  
     
     t.boolean :is_deleted, :default => false
      t.timestamps
    end
  end
end
