require 'spec_helper'

describe DeliveryLost do
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
    
    
    @del = Delivery.create_by_employee(@admin,{
      :customer_id => @customer.id ,
      :employee_id => @employee.id 
    } )
    @diff1 = 1
    @diff2 = 1 
    @diff3 = 4
    @del_quantity1 = @so_quantity1 - @diff1   # 5-1 = 4 
    @del_entry1 = DeliveryEntry.create_by_employee(@admin, @del, {
      :sales_order_entry_id => @so_entry1.id ,
      :quantity_sent => @del_quantity1 
    })
    
    @del_quantity2 = @so_quantity2 - @diff2  #5-1 = 4 
    
    
    @del_entry2 = DeliveryEntry.create_by_employee(@admin, @del, {
      :sales_order_entry_id => @so_entry2.id ,
      :quantity_sent => @del_quantity2 
    })
    
    @del_quantity3 = @so_quantity3 - @diff3 # 7-4 = 3 
    @del_entry3 = DeliveryEntry.create_by_employee(@admin, @del, {
      :sales_order_entry_id => @so_entry3.id ,
      :quantity_sent => @del_quantity3
    })
    @del.reload
    
  end
  
  it 'can only be created if delivery is confirmed' do
    dl = DeliveryLost.create_by_employee( @admin, {
      :delivery_id => @del.id 
    })
    dl.should_not be_valid
  end
  
  context "confirming delivery" do
    before(:each) do
      @del.confirm(@admin)

      @test_item1.reload
      @test_item2.reload
      @del.reload
      @del_entry1.reload
      @del_entry2.reload
    end
    
    it 'should create sales return if delivery is confirmed' do
      dl = DeliveryLost.create_by_employee( @admin, {
        :delivery_id => @del.id 
      })
      dl.should be_valid
    end
    
    it 'should not allow more than one sales return' do
      dl = DeliveryLost.create_by_employee( @admin, {
        :delivery_id => @del.id 
      })
      dl.should be_valid
      
      dl = DeliveryLost.create_by_employee( @admin, {
        :delivery_id => @del.id 
      })
      dl.should_not be_valid
    end
    
    
    context "post create sales return" do
      before(:each) do
        @dl = DeliveryLost.create_by_employee( @admin, {
          :delivery_id => @del.id 
        })
      end
      
      it 'should create valid sr' do
        @dl.should be_valid
      end
      
      it 'should allow creation of sales return entry' do
        @dle = DeliveryLostEntry.create_by_employee(@admin,@dl, {
          :delivery_entry_id => @del_entry1.id,
          :quantity => 1
        })
        @dle.should be_valid
      end
      
      it 'should preserve unique entry' do
        @dle = DeliveryLostEntry.create_by_employee(@admin,@dl, {
          :delivery_entry_id => @del_entry1.id,
          :quantity => 1
        })
        @dle.should be_valid
        
        @dle = DeliveryLostEntry.create_by_employee(@admin,@dl, {
          :delivery_entry_id => @del_entry1.id,
          :quantity => 1
        })
        @dle.should_not be_valid
      end
      
      it 'should NOT allow  negative or 0 quantity' do
        @dle = DeliveryLostEntry.create_by_employee(@admin,@dl, {
          :delivery_entry_id => @del_entry1.id,
          :quantity => -1
        })
        @dle.should_not be_valid
        
        @dle = DeliveryLostEntry.create_by_employee(@admin,@dl, {
          :delivery_entry_id => @del_entry1.id,
          :quantity => 0
        })
        @dle.should_not be_valid
      end
      
      it 'should not exceed max quantity (quantity_sent - delivery_lost)' do
        
        @dle = DeliveryLostEntry.create_by_employee(@admin,@dl, {
          :delivery_entry_id => @del_entry1.id,
          :quantity => @del_quantity1   + 1 
          })
          
        @dle.should_not be_valid 
      end
      
      it 'should allow return of all delivered quantity' do
        @dle = DeliveryLostEntry.create_by_employee(@admin,@dl, {
          :delivery_entry_id => @del_entry1.id,
          :quantity => @del_quantity1  
          })
        @dle.should be_valid 
      end
      
      context 'on confirming sales return entry' do
        before(:each) do
          @test_item1.reload
          @so_entry1 = @del_entry1.sales_order_entry 
          @so_entry1.reload 
          @dle1 = DeliveryLostEntry.create_by_employee(@admin,@dl, {
            :delivery_entry_id => @del_entry1.id,
            :quantity => @del_quantity1  
            })
        
          @dle2 = DeliveryLostEntry.create_by_employee(@admin,@dl, {
            :delivery_entry_id => @del_entry2.id,
            :quantity => @del_quantity1  
            })
            
          @initial_so_pending_delivery = @so_entry1.pending_delivery 
          @initial_pending_delivery = @test_item1.pending_delivery 
          @dl.confirm(@admin)
          @dle1.reload 
          @so_entry1.reload 
          @test_item1.reload
          @del_entry1.reload 
        end
        
        it 'should have 2 sales return entries' do
          @dl.delivery_lost_entries.count.should == 2
        end
        
        it 'should increase the pending delivery ' do
          @final_pending_delivery =  @test_item1.pending_delivery
          diff = @final_pending_delivery - @initial_pending_delivery
          diff.should == @del_quantity1
        end
        
        it 'should increase the sales order entry pending delivery' do
          @final_so_pending_delivery = @so_entry1.pending_delivery
        
          diff = @final_so_pending_delivery - @initial_so_pending_delivery
          diff.should == @del_quantity1
        end
        
        it 'should create 1 stock mutation' do
          @dle1.stock_mutation.should be_valid 
          @dle1.stock_mutation.quantity.should == @dle1.quantity
        end
        
        
        # BRANCH 1 : post confirm update
        it 'should preserve uniqueness' do
        
          @dle1.update_by_employee(@admin,{
            :delivery_entry_id => @del_entry2.id ,
            :quantity => 1
          })
          
          @dle1.should_not be_valid 
        end
        
        
        it 'should change the stock mutation on update quantity' do
          @dle1.update_by_employee(@admin,  {
            :delivery_entry_id => @del_entry1.id,
            :quantity => 1 
            })
            
          @dle1.should be_valid
          @dle1.stock_mutation.quantity.should ==  1
          @del_entry1.reload 
          @del_entry1.quantity_confirmed.should == @del_entry1.quantity_sent - 1 
          
          @dle1.update_by_employee(@admin,  {
            :delivery_entry_id => @del_entry1.id,
            :quantity => @del_quantity1
            })
          @dle1.should be_valid 
          
          @dle1.update_by_employee(@admin,  {
            :delivery_entry_id => @del_entry1.id,
            :quantity => @del_quantity1 + 2 
            })
          @dle1.should_not be_valid
        end
        

        
        # BRANCH 2 : post confirm delete 
        context "delete post confirm" do
          before(:each) do
            @stock_mutation = @dle1.stock_mutation 
            @dle1.delete(@admin)
            @del_entry1.reload 
          end
          
          it 'should update the quantity confirmed in delivery entry' do
            @del_entry1.quantity_confirmed = @del_entry1.quantity_sent 
          end

          it 'should destroy the associated stock mutation' do
            StockMutation.find_by_id( @stock_mutation.id).should be_nil 
          end
        end
        
         
      end
    end
  end
  
  
   
end
