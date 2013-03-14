require 'spec_helper'

describe Delivery do
  before(:each) do
    role = {
      :system => {
        :@administrator => true
      }
    }

    Role.create!(
    :name        => ROLE_NAME[:admin],
    :title       => 'Administrator',
    :description => 'Role for @administrator',
    :the_role    => role.to_json
    )
    @admin_role = Role.find_by_name ROLE_NAME[:admin]
    first_role = Role.first

    @company = Company.create(:name => "Super metal", :address => "Tanggerang", :phone => "209834290840932")
    @admin = User.create_main_user(   :email => "admin@gmail.com" ,:password => "willy1234", :password_confirmation => "willy1234") 

    @admin.set_as_main_user

    # create vendor  => OK 
    @vendor = Vendor.create({
        :name =>"Monkey Crazy", 
        :contact_person =>"", 
        :phone =>"", 
        :mobile =>"", 
        :bbm_pin =>"", 
        :email =>"", 
        :address =>""})
    
    @customer = Customer.create(:name => "McDonald Teluk Bitung")
    @employee = Employee.create( :name => "Yongky")
    # create item category
    @base_item_category =  ItemCategory.create_base_object( @admin, :name => "Base Item" ) 
    
    # create item  
    @test_item1  = Item.create_by_employee(  @admin,  {
      :name => "Test Item",
      :supplier_code => "BEL324234",
      :customer_code => 'CCCL222',
      :item_category_id => @base_item_category.id 
    })
    
    @test_item2  = Item.create_by_employee(  @admin,  {
      :name => "Test Item 2 ",
      :supplier_code => "BEL3242eafj34",
      :customer_code => 'efa',
      :item_category_id => @base_item_category.id 
    })
    
    @test_item3  = Item.create_by_employee(  @admin,  {
      :name => "Test Item 3",
      :supplier_code => "SPLCOD",
      :customer_code => 'CUSTCOD',
      :item_category_id => @base_item_category.id 
    })

    @test_item1.reload
    
    @migration_quantity1 = 30 
    @test_item_migration =  StockMigration.create_by_employee(@admin, {
      :item_id => @test_item1.id,
      :quantity => @migration_quantity1
    })
    
    @test_item2.reload
    
    @migration_quantity2 = 30 
    @test_item_migration2 =  StockMigration.create_by_employee(@admin, {
      :item_id => @test_item2.id,
      :quantity => @migration_quantity2
    })
    
    @test_item3.reload
    
    @migration_quantity3 = 30 
    @test_item_migration3 =  StockMigration.create_by_employee(@admin, {
      :item_id => @test_item3.id,
      :quantity => @migration_quantity3
    })
    
    @test_item1.reload
    @test_item2.reload
    @test_item3.reload
    
    @so = SalesOrder.create_by_employee(@admin,{
      :customer_id => @customer.id ,
      :employee_id => @employee.id 
    } )
    
    @so_quantity1 = 5
    @so_entry1 = SalesOrderEntry.create_by_employee(@admin, @so, {
      :item_id => @test_item1.id ,
      :quantity => @so_quantity1 
    })
    
    @so_quantity2 = 5
    @so_entry2 = SalesOrderEntry.create_by_employee(@admin, @so, {
      :item_id => @test_item2.id ,
      :quantity => @so_quantity2 
    })
    
    @so_quantity3 = 7
    @so_entry3 = SalesOrderEntry.create_by_employee(@admin, @so, {
      :item_id => @test_item3.id ,
      :quantity => @so_quantity3
    })
    
    @so.confirm(@admin)
    @so_entry1.reload 
    @so_entry2.reload 
    @test_item1.reload
    @test_item2.reload
    @test_item3.reload
    
    
  end
  
  it 'should be sane' do
    @test_item1.ready.should == @migration_quantity1 
    @test_item2.ready.should == @migration_quantity2
    @test_item3.ready.should == @migration_quantity3 
    @so.is_confirmed.should be_true
    @so_entry1.is_confirmed.should be_true 
    @so_entry2.is_confirmed.should be_true 
  end
  
  it 'should create delivery' do
    @del = Delivery.create_by_employee(@admin,{
      :customer_id => @customer.id ,
      :employee_id => @employee.id 
    } )
    
    @del.should be_valid 
  end
  
  context "post del creation" do
    before(:each) do
      @del = Delivery.create_by_employee(@admin,{
        :customer_id => @customer.id ,
        :employee_id => @employee.id 
      } )
    end
    
    it 'should be allowed to create del entry' do
      del_entry = DeliveryEntry.create_by_employee(@admin, @del, {
        :sales_order_entry_id => @so_entry1.id ,
        :quantity_sent => @so_quantity1 
      })
      del_entry.should be_valid
    end
    
    it 'should ensure unique entry' do
      diff = 1
      del_entry = DeliveryEntry.create_by_employee(@admin, @del, {
        :sales_order_entry_id => @so_entry1.id ,
        :quantity_sent => @so_quantity1  - diff
      })
      del_entry.should be_valid
      
      del_entry = DeliveryEntry.create_by_employee(@admin, @del, {
        :sales_order_entry_id => @so_entry1.id ,
        :quantity_sent => diff  
      })
      del_entry.should_not be_valid
    end
    
    it 'should not be allowed to delivery more than ordered' do
      del_entry = DeliveryEntry.create_by_employee(@admin, @del, {
        :sales_order_entry_id => @so_entry1.id ,
        :quantity_sent => @so_quantity1 + 5  
      })
      del_entry.should_not be_valid
    end
    
    it 'should not be allowed to receive 0 or minus' do
      del_entry = DeliveryEntry.create_by_employee(@admin, @del, {
        :sales_order_entry_id => @so_entry1.id ,
        :quantity_sent =>  0 
      })
      del_entry.should_not be_valid
      
      del_entry = DeliveryEntry.create_by_employee(@admin, @del, {
        :sales_order_entry_id => @so_entry1.id ,
        :quantity_sent =>  -5 
      })
      del_entry.should_not be_valid
    end
    
    context "delivery entry creation" do
      before(:each) do 
        @diff1 = 1
        @diff2 = 1 
        @diff3 = 4
        @del_quantity1 = @so_quantity1 - @diff1   # 5-1 = 4 
        @del_entry1 = DeliveryEntry.create_by_employee(@admin, @del, {
          :sales_order_entry_id => @so_entry1.id ,
          :quantity_sent => @del_quantity1 
        })
        
        @del_quantity2 = @so_quantity2 - @diff2 
        
        @del_quantity3 = @so_quantity3 - @diff3
        @del_entry2 = DeliveryEntry.create_by_employee(@admin, @del, {
          :sales_order_entry_id => @so_entry2.id ,
          :quantity_sent => @del_quantity2 
        })
        @del.reload
      end
      
      it 'should have created valid del_entry' do
        @del_entry1.should be_valid
        @del_entry2.should be_valid 
        @del.delivery_entries.count.should == 2 
      end
      
      it 'should allow update in quantity or sales_order_entry' do
        @del_entry1.update_by_employee(@admin, {
          :sales_order_entry_id => @so_entry3.id,
          :quantity_sent => @del_quantity3
        })
        
        @del_entry1.should be_valid 
        @del_entry1.reload 
        @del_entry1.sales_order_entry_id.should == @so_entry3.id 
        @del_entry1.quantity_sent.should == @del_quantity3
      end
      
      it 'should still preserve the unique entry on update' do
        @del_entry1.update_by_employee(@admin, {
          :sales_order_entry_id => @so_entry2.id,
          :quantity_sent => @del_quantity2
        })
        @del_entry1.should_not be_valid 
      end
      
      context "confirm delivery" do 
        before(:each) do
          @del.reload
          @del_entry1.reload
          @del_entry2.reload 
          @test_item1.reload
          @test_item2.reload 
          @test_item3.reload
          @initial_pending_delivery1 = @test_item1.pending_delivery
          @initial_pending_delivery2 = @test_item2.pending_delivery
          
          @initial_ready1 = @test_item1.ready
          @initial_ready2 = @test_item2.ready
          
          @del.confirm(@admin)
          @del.reload 
          @del_entry1.reload
          @del_entry2.reload 
          @test_item1.reload
          @test_item2.reload
        end
        
        it 'should be confirmed' do
          @del.is_confirmed.should be_true 
        end
        
        it 'should have confirmed the delivery_entries' do
          @del_entry1.is_confirmed.should be_true
          @del_entry2.is_confirmed.should be_true 
        end
        
        it 'should deduct the pending delivery and deduct the ready quantity ' do
          @final_pending_delivery1  = @test_item1.pending_delivery
          @final_pending_delivery2  = @test_item2.pending_delivery
          @final_ready1  = @test_item1.ready
          @final_ready2  = @test_item2.ready
          
          diff_pending_delivery1 = @initial_pending_delivery1 - @final_pending_delivery1
          diff_pending_delivery2 = @initial_pending_delivery2 - @final_pending_delivery2
          
          diff_ready1 = @final_ready1 - @initial_ready1
          diff_ready2 = @final_ready2 - @initial_ready2
          
          diff_ready1   == (-1)*@del_entry1.quantity_sent 
          diff_ready2   == (-1)*@del_entry2.quantity_sent
        
          diff_pending_delivery1.should == @del_entry1.quantity_sent 
          diff_pending_delivery2.should == @del_entry2.quantity_sent 
        end
        
        # FIRST BRANCH: update post confirm 
        it 'should preserve entry uniqueness post confirm' do
          @del_entry1.update_by_employee(@admin, {
            :sales_order_entry_id => @so_entry2.id,
            :quantity_sent => 5
          })
          @del_entry1.should_not be_valid 
        end
        
        it 'should  allow quantity update => change pending delivery + ready ' do
          @extra_diff = 1 
          initial_pending_delivery = @test_item1.pending_delivery
          initial_ready  = @test_item1.ready  
          quantity_sent  = @del_entry1.quantity_sent 
          @del_entry1.update_by_employee(@admin, {
            :sales_order_entry_id => @so_entry1.id,
            :quantity_sent => quantity_sent + @extra_diff 
          })
          @del_entry1.should be_valid 
          
          
          @test_item1.reload
          final_pending_delivery = @test_item1.pending_delivery
          diff_pending_delivery = final_pending_delivery - initial_pending_delivery
          diff_pending_delivery.should == (-1)*@extra_diff # because it is decreasing 
          
          final_ready = @test_item1.ready
          diff_ready = final_ready - initial_ready
          diff_ready.should == (-1)*@extra_diff
        end
        
        # SECOND BRANCH: delete post confirm
        # IT HAS  FURTHER COUPLING => The sales return and delivery lost 
        it 'should allow delete on delivery_entry' do
          @test_item1.reload
          @initial_ready =  @test_item1.ready 
          @initial_pending_delivery = @test_item1.pending_delivery
          quantity = @del_entry1.quantity_sent
          source_document_entry =  @del_entry1.class.to_s
          source_document_entry_id = @del_entry1.id 
          @del_entry1.delete(@admin)
          @del_entry1.persisted?.should be_false
          
          StockMutation.where(
            :source_document_entry_id => source_document_entry_id ,
            :source_document_entry => source_document_entry
          ).count.should == 0 
          
          @test_item1.reload
          
          @final_ready = @test_item1.ready
          @final_pending_delivery = @test_item1.pending_delivery
          
          diff_ready = @final_ready - @initial_ready 
          diff_pending_delivery = @final_pending_delivery - @initial_pending_delivery
          
          diff_ready.should == quantity 
          diff_pending_delivery.should == quantity
        end
        
        context "should not allow deletion if there is sales_return/delivery_lost" do
        end
        
      end
      
    end
  end
   
end
