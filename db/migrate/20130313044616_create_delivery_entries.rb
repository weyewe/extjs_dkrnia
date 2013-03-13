class CreateDeliveryEntries < ActiveRecord::Migration
  def change
    create_table :delivery_entries do |t|
      t.integer :creator_id 
      t.integer :sales_order_entry_id 
      
      t.integer :delivery_id  # Surat Jalan 
      t.string  :code 
 
      t.integer     :quantity_sent  , :default => 0 
   
=begin
  After customer approval 
=end
      t.integer     :quantity_confirmed  , :default =>0  # => migrate the on_delivery to fulfilled 
      
      t.integer     :quantity_returned, :default => 0  # => sales_return
      
      t.integer     :quantity_lost  , :default => 0   # => sales_lost 
       
      
      t.boolean :is_deleted, :default => false 

      t.boolean :is_confirmed , :default => false 
      t.boolean :is_finalized, :default => false  # finalized
      
      t.timestamps
    end
  end
end
