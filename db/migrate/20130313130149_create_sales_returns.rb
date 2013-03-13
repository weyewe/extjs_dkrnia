class CreateSalesReturns < ActiveRecord::Migration
  def change
    create_table :sales_returns do |t|
      t.integer :creator_id
      t.string :code
      t.integer :delivery_id 
      
      t.boolean :is_confirmed, :default => false 
      t.integer :confirmer_id
      t.datetime :confirmed_at 
      
      t.boolean :is_deleted, :default => false 

      t.timestamps
    end
  end
end
