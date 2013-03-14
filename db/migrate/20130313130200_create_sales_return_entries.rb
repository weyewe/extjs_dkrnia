class CreateSalesReturnEntries < ActiveRecord::Migration
  def change
    create_table :sales_return_entries do |t|
      t.integer :creator_id 
      t.integer :sales_return_id 
      t.integer :delivery_entry_id 
      t.string :code 
      t.integer :quantity 
      
      t.boolean :is_confirmed, :default => false 
      

      t.timestamps
    end
  end
end
