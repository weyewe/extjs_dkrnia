require 'spec_helper'

describe SalesOrder do
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
    @employee = Employee.create(:name => "Yongky")
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
    
    @migration_quantity = 200 
    @test_item_migration =  StockMigration.create_by_employee(@admin, {
      :item_id => @test_item1.id,
      :quantity => @migration_quantity
    })
    
    @test_item2.reload
    
    @migration_quantity2 = 100 
    @test_item_migration2 =  StockMigration.create_by_employee(@admin, {
      :item_id => @test_item2.id,
      :quantity => @migration_quantity2
    })
    
    @test_item1.reload 
    
    
    @po = PurchaseOrder.create_by_employee(@admin, {
      :vendor_id => @vendor.id 
    })
    
    @po_quantity1 = 15
    @po_entry1 = PurchaseOrderEntry.create_by_employee(@admin, @po, {
      :item_id => @test_item1.id ,
      :quantity => @po_quantity1 
    })
    
    @po_quantity2 = 30
    @po_entry2 = PurchaseOrderEntry.create_by_employee(@admin, @po, {
      :item_id => @test_item2.id ,
      :quantity => @po_quantity2 
    })
    
    @po.confirm(@admin)
    @po_entry1.reload
    @po_entry2.reload
    @test_item1.reload
    @test_item2.reload 
  end
  
  it 'should have confirmed all purchase orders' do
    @po_entry1.is_confirmed.should be_true
    @po_entry2.is_confirmed.should be_true 
    @po.is_confirmed.should be_true 
  end
  
  it 'should create sales order' do
    @so = SalesOrder.create_by_employee(@admin,{
      :customer_id => @customer.id 
    } )
    
    @so.should be_valid 
  end
  
  context "post so creation" do
    before(:each) do
      @so = SalesOrder.create_by_employee(@admin,{
        :customer_id => @customer.id ,
        :employee_id => @employee.id 
      } )
    end
    
    it 'should be allowed to create so entry' do
      so_entry = SalesOrderEntry.create_by_employee(@admin, @so, {
        :item_id => @test_item1.id,
        :quantity => 15 
      })
      so_entry.should be_valid
    end
    
    it 'should ensure unique entry' do
      diff = 5 
      so_entry = SalesOrderEntry.create_by_employee(@admin, @so, {
        :item_id => @test_item1.id ,
        :quantity =>  5 
      })
      so_entry.should be_valid
      
      so_entry = SalesOrderEntry.create_by_employee(@admin, @so, {
        :item_id => @test_item1.id ,
        :quantity => 3  
      })
      so_entry.should_not be_valid
    end
    
    it 'should not be allowed to receive 0 or minus' do
      so_entry = SalesOrderEntry.create_by_employee(@admin, @so, {
        :item_id => @test_item1.id ,
        :quantity =>  0 
      })
      so_entry.should_not be_valid
      
      so_entry = SalesOrderEntry.create_by_employee(@admin, @so, {
        :item_id => @test_item1.id ,
        :quantity =>  -5 
      })
      so_entry.should_not be_valid
    end
    
    context "so_entry creation" do
      before(:each) do
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
      end
      
      it 'should create valid so_entry as long as it is unique' do
        @so_entry1.should be_valid 
        @so_entry2.should be_valid 
        
        @so.sales_order_entries.count.should == 2 
      end
      
      it 'should allow update in quantity or item' do
        @so_entry1.update_by_employee(@admin, {
          :item_id => @test_item3.id,
          :quantity => @so_quantity1
        })
        
        @so_entry1.should be_valid 
        @so_entry1.reload 
        @so_entry1.item_id.should == @test_item3.id 
        @so_entry1.quantity.should == @so_quantity1
      end
      
      it 'should still preserve the unique entry on update' do
        @so_entry1.update_by_employee(@admin, {
          :item_id => @test_item2.id,
          :quantity => @so_quantity1
        })
        @so_entry1.should_not be_valid 
      end
      
      context "confirm sales order" do
        before(:each) do
          @so.reload
          @test_item1.reload
          @test_item2.reload 
          @so_entry1.reload
          @so_entry2.reload
          @initial_pending_delivery1 = @test_item1.pending_delivery
          @initial_pending_delivery2 = @test_item2.pending_delivery
          
          @so.confirm(@admin)
          @test_item1.reload
          @test_item2.reload 
          @so_entry1.reload
          @so_entry2.reload
        end
        
        it 'should confirm the so and its entries' do
          @so.is_confirmed.should be_true 
          @so_entry1.is_confirmed.should be_true 
          @so_entry2.is_confirmed.should be_true 
        end
        
        it 'should update the pending delivery' do
          @final_pending_delivery1 = @test_item1.pending_delivery
          @final_pending_delivery2 = @test_item2.pending_delivery
          
          diff1 = @final_pending_delivery1 - @initial_pending_delivery1 
          diff2 = @final_pending_delivery2 - @initial_pending_delivery2 
          diff1.should == @so_quantity1 
          diff2.should == @so_quantity2 
        end
        
        # FIRST BRANCH: update post confirm 
        it 'should preserve entry uniqueness post confirm' do
          @so_entry1.update_by_employee(@admin, {
            :item_id => @test_item2.id,
            :quantity => 15
          })
          @so_entry1.should_not be_valid 
        end
        
        it 'should allow item change update' do
          @test_item1.reload
          @test_item3.reload
          
          initial_so1_quantity = @so_entry1.quantity 
          initial_pending_delivery1 = @test_item1.pending_delivery 
          initial_pending_delivery3 = @test_item3.pending_delivery
          @so_entry1.update_by_employee(@admin, {
            :item_id => @test_item3.id,
            :quantity => @so_quantity1  
          })
          @so_entry1.should be_valid 
          
          
          @test_item1.reload
          @test_item3.reload 
          
          final_pending_delivery1 = @test_item1.pending_delivery
          final_pending_delivery3 = @test_item3.pending_delivery
          
          diff1 = initial_pending_delivery1  - final_pending_delivery1 
          diff1.should == initial_so1_quantity
          
          diff3 = final_pending_delivery3 - initial_pending_delivery3
          diff3.should == @so_quantity1
        end
        
        it 'should  allow quantity update => change pending delivery' do
          @extra_diff = 5 
          initial_pending_delivery = @test_item1.pending_delivery
          @so_entry1.update_by_employee(@admin, {
            :item_id => @test_item1.id,
            :quantity => @so_quantity1 + @extra_diff 
          })
          @so_entry1.should be_valid 
          
          
          @test_item1.reload
          final_pending_delivery = @test_item1.pending_delivery
          diff = final_pending_delivery - initial_pending_delivery
          diff.should == @extra_diff
          
        end
        
        # SECOND BRANCH: delete post confirm 
        
        it 'should allow deletion' do
          initial_pending_delivery1 = @test_item1.pending_delivery
          quantity = @so_entry1.quantity 
          @so_entry1.delete(@admin)
          
          @test_item1.reload 
          final_pending_delivery1 = @test_item1.pending_delivery
          
          diff =  initial_pending_delivery1 - final_pending_delivery1 
          diff.should == quantity 
          
          @so_entry1.persisted?.should be_false 
        end
        
        context "coupled has takes place (in this case: Delivery)" do
        end
        
      end
    end
  end
   
end
