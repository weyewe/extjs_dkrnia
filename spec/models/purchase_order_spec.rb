require 'spec_helper'

describe PurchaseOrder do
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
    
    # create item category
    @base_item_category =  ItemCategory.create_base_object( @admin, :name => "Base Item" ) 
    
    # create item  
    @test_item  = Item.create_by_employee(  @admin,  {
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

    @test_item.reload
    
    @migration_quantity = 200 
    @test_item_migration =  StockMigration.create_by_employee(@admin, {
      :item_id => @test_item.id,
      :quantity => @migration_quantity
    })
    
    @test_item2.reload
    
    @migration_quantity2 = 100 
    @test_item_migration2 =  StockMigration.create_by_employee(@admin, {
      :item_id => @test_item2.id,
      :quantity => @migration_quantity2
    })
    
    @test_item.reload 
  end
  
  it 'should create purchase order' do
    po = PurchaseOrder.create_by_employee(@admin, {
      :vendor_id => @vendor.id 
    })
    
    po.should be_valid 
  end
  
  context 'post po creation' do
    before(:each) do
      @po = PurchaseOrder.create_by_employee(@admin, {
        :vendor_id => @vendor.id 
      })
    end
    
    it 'should be allowed to create po_entry' do
      po_entry = PurchaseOrderEntry.create_by_employee(@admin, @po, {
        :item_id => @test_item.id ,
        :quantity => 15 
      })
      po_entry.should be_valid 
    end
    
    it 'should ensure unique entry' do
      po_entry = PurchaseOrderEntry.create_by_employee(@admin, @po, {
        :item_id => @test_item.id ,
        :quantity => 15 
      })
      po_entry.should be_valid
      
      po_entry = PurchaseOrderEntry.create_by_employee(@admin, @po, {
        :item_id => @test_item.id ,
        :quantity => 20 
      })
      po_entry.should_not be_valid
    end
    
    it 'should not allow quantity less or equal to 0' do
      po_entry = PurchaseOrderEntry.create_by_employee(@admin, @po, {
        :item_id => @test_item.id ,
        :quantity => -5 
      })
      po_entry.should_not be_valid
      
      po_entry = PurchaseOrderEntry.create_by_employee(@admin, @po, {
        :item_id => @test_item.id ,
        :quantity => 0 
      })
      po_entry.should_not be_valid
    end
    
    context 'po_entry creation' do
      before(:each) do
        @po_quantity1 = 15
        @po_entry1 = PurchaseOrderEntry.create_by_employee(@admin, @po, {
          :item_id => @test_item.id ,
          :quantity => @po_quantity1 
        })
        
        @po_quantity2 = 30
        @po_entry2 = PurchaseOrderEntry.create_by_employee(@admin, @po, {
          :item_id => @test_item2.id ,
          :quantity => @po_quantity2 
        })
      end
      
      it 'should create valid po_entry as long as it is unique' do
        @po_entry1.should be_valid 
        @po_entry2.should be_valid 
        
        @po.purchase_order_entries.count.should == 2 
      end
      
      it 'should allow update in quantity or item' do
        @po_entry1.update_by_employee(@admin, {
          :item_id => @test_item3.id,
          :quantity => @po_quantity1
        })
        
        @po_entry1.should be_valid 
        @po_entry1.reload 
        @po_entry1.item_id.should == @test_item3.id 
        @po_entry1.quantity.should == @po_quantity1
      end
      
      it 'should still preserve the unique entry on update' do
        @po_entry1.update_by_employee(@admin, {
          :item_id => @test_item2.id,
          :quantity => @po_quantity1
        })
        @po_entry1.should_not be_valid 
      end
      
      context "confirm purchase order" do
        before(:each) do
          @po.reload
          @test_item.reload
          @test_item2.reload 
          @po_entry1.reload
          @po_entry2.reload
          @initial_pending_receival1 = @test_item.pending_receival
          @initial_pending_receival2 = @test_item2.pending_receival
          
          @po.confirm(@admin)
          @test_item.reload
          @test_item2.reload 
          @po_entry1.reload
          @po_entry2.reload 
        end
        
        it 'should confirm the po and its entries' do
          @po.is_confirmed.should be_true 
          @po_entry1.is_confirmed.should be_true 
          @po_entry2.is_confirmed.should be_true 
        end
        
        it 'should update the pending receival' do
          @final_pending_receival1 = @test_item.pending_receival
          @final_pending_receival2 = @test_item2.pending_receival 
          
          diff1 = @final_pending_receival1 - @initial_pending_receival1 
          diff2 = @final_pending_receival2 - @initial_pending_receival2 
          diff1.should == @po_quantity1 
          diff2.should == @po_quantity2 
        end
        
        
        # FIRST BRANCH: update post confirm 
        it 'should preserve entry uniqueness post confirm' do
          @po_entry1.update_by_employee(@admin, {
            :item_id => @test_item2.id,
            :quantity => 15
          })
          @po_entry1.should_not be_valid 
        end
        
        it 'should  allow quantity update => change pending receival' do
          @extra_diff = 5 
          initial_pending_receival = @test_item.pending_receival 
          @po_entry1.update_by_employee(@admin, {
            :item_id => @test_item.id,
            :quantity => @po_quantity1 + @extra_diff 
          })
          @po_entry1.should be_valid 
          
          
          @test_item.reload
          final_pending_receival = @test_item.pending_receival
          diff = final_pending_receival - initial_pending_receival
          diff.should == @extra_diff
        end
        
        # SECOND BRANCH: delete post confirm 
        
        it 'should allow deletion' do
          initial_pending_receival1 = @test_item.pending_receival
          quantity = @po_entry1.quantity 
          @po_entry1.delete(@admin)
          
          @test_item.reload 
          final_pending_receival1 = @test_item.pending_receival
          
          diff =  initial_pending_receival1 - final_pending_receival1 
          diff.should == quantity 
          
          @po_entry1.persisted?.should be_false 
        end
        
        
        
        
        context "coupled has takes place (in this case: purchase receival)" do
          
          # FIRST Branch : on update  # can't update the item anymore if there is purchase receival
          # Second Branch : on delete  # can't delete the purchase order entry if there is purchase receival
        end 
        
      end
    end
    
  end
end
