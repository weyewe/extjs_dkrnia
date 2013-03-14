class CreateDeliveryLostEntries < ActiveRecord::Migration
  def change
    create_table :delivery_lost_entries do |t|
      t.integer :creator_id
      t.integer :delivery_lost_id  
      t.integer :delivery_entry_id 
      t.string :code 
      t.integer :quantity 
      
      t.boolean :is_confirmed, :default => false 
      
      t.timestamps
    end
  end
end
