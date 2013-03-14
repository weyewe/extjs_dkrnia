require 'spec_helper'

describe PurchaseReceival do
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
    
    @po_quantity1 = 30
    @po_entry1 = PurchaseOrderEntry.create_by_employee(@admin, @po, {
      :item_id => @test_item1.id ,
      :quantity => @po_quantity1 
    })
    
    @po_quantity2 = 30
    @po_entry2 = PurchaseOrderEntry.create_by_employee(@admin, @po, {
      :item_id => @test_item2.id ,
      :quantity => @po_quantity2 
    })
    
    @po_quantity3 = 30
    @po_entry3 = PurchaseOrderEntry.create_by_employee(@admin, @po, {
      :item_id => @test_item3.id ,
      :quantity => @po_quantity3
    })
    
    @po.confirm(@admin)
    @po_entry1.reload
    @po_entry2.reload
    @po_entry3.reload
    @test_item1.reload
    @test_item2.reload 
    @test_item3.reload 
  end
  
  it 'should have confirmed all purchase orders' do
    @po_entry1.is_confirmed.should be_true
    @po_entry2.is_confirmed.should be_true 
    @po.is_confirmed.should be_true 
  end
  
  it 'should create purchase receival' do
    @pr = PurchaseReceival.create_by_employee(@admin,{
      :vendor_id => @vendor.id 
    } )
    
    @pr.should be_valid 
  end
  
  context "post pr creation" do
    before(:each) do
      @pr = PurchaseReceival.create_by_employee(@admin,{
        :vendor_id => @vendor.id 
      } )
    end
    
    it 'should be allowed to create pr entry' do
      pr_entry = PurchaseReceivalEntry.create_by_employee(@admin, @pr, {
        :purchase_order_entry_id => @po_entry1.id ,
        :quantity => @po_quantity1 
      })
      pr_entry.should be_valid
    end
    
    it 'should ensure unique entry' do
      diff = 5 
      pr_entry = PurchaseReceivalEntry.create_by_employee(@admin, @pr, {
        :purchase_order_entry_id => @po_entry1.id ,
        :quantity => @po_quantity1  - diff
      })
      pr_entry.should be_valid
      
      pr_entry = PurchaseReceivalEntry.create_by_employee(@admin, @pr, {
        :purchase_order_entry_id => @po_entry1.id ,
        :quantity => diff  
      })
      pr_entry.should_not be_valid
    end
    
    it 'should not be allowed to receive more than ordered' do
      pr_entry = PurchaseReceivalEntry.create_by_employee(@admin, @pr, {
        :purchase_order_entry_id => @po_entry1.id ,
        :quantity => @po_quantity1 + 5  
      })
      pr_entry.should_not be_valid
    end
    
    it 'should not be allowed to receive 0 or minus' do
      pr_entry = PurchaseReceivalEntry.create_by_employee(@admin, @pr, {
        :purchase_order_entry_id => @po_entry1.id ,
        :quantity =>  0 
      })
      pr_entry.should_not be_valid
      
      pr_entry = PurchaseReceivalEntry.create_by_employee(@admin, @pr, {
        :purchase_order_entry_id => @po_entry1.id ,
        :quantity =>  -5 
      })
      pr_entry.should_not be_valid
    end
    
    context "pr_entry creation" do
      before(:each) do
        @pr_quantity1 = @po_quantity1 - 5 
        @pr_entry1 = PurchaseReceivalEntry.create_by_employee(@admin, @pr, {
          :purchase_order_entry_id => @po_entry1.id ,
          :quantity => @pr_quantity1 
        })
        
        @pr_quantity2 = @po_quantity2 - 5
        @pr_entry2 = PurchaseReceivalEntry.create_by_employee(@admin, @pr, {
          :purchase_order_entry_id => @po_entry2.id ,
          :quantity => @pr_quantity2 
        })
        @pr.reload 
      end
      
      it 'should have created valid pr_entry' do
        @pr_entry1.should be_valid
        @pr_entry2.should be_valid 
        @pr.purchase_receival_entries.count.should == 2 
      end
      
      it 'should allow update in quantity or purchase_order_entry' do
        @pr_entry1.update_by_employee(@admin, {
          :purchase_order_entry_id => @po_entry3.id,
          :quantity => @po_quantity3
        })
        
        @pr_entry1.should be_valid 
        @pr_entry1.reload 
        @pr_entry1.purchase_order_entry_id.should == @po_entry3.id 
        @pr_entry1.quantity.should == @po_quantity3
      end
      
      it 'should still preserve the unique entry on update' do
        @pr_entry1.update_by_employee(@admin, {
          :purchase_order_entry_id => @po_entry2.id,
          :quantity => @po_quantity2
        })
        @pr_entry1.should_not be_valid 
      end
      
      context "confirm purchase receival" do
        before(:each) do
          @pr.reload
          @pr_entry1.reload
          @pr_entry2.reload 
          @test_item1.reload
          @test_item2.reload 
          @test_item3.reload
          @initial_pending_receival1 = @test_item1.pending_receival
          @initial_pending_receival2 = @test_item2.pending_receival
          
          @initial_ready1 = @test_item1.ready
          @initial_ready2 = @test_item2.ready
          
          @pr.confirm(@admin)
          @pr_entry1.reload
          @pr_entry2.reload 
          @test_item1.reload
          @test_item2.reload
        end
        
        it 'should deduct the pending receival and increase the ready quantity ' do
          @final_pending_receival1  = @test_item1.pending_receival
          @final_pending_receival2  = @test_item2.pending_receival
          @final_ready1  = @test_item1.ready
          @final_ready2  = @test_item2.ready
          
          diff_pending_receival1 = @initial_pending_receival1 - @final_pending_receival1
          diff_pending_receival2 = @initial_pending_receival2 - @final_pending_receival2
          
          diff_ready1 = @final_ready1 - @initial_ready1
          diff_ready2 = @final_ready2 - @initial_ready2
          
          diff_pending_receival1.should == @pr_entry1.quantity 
          diff_pending_receival2.should == @pr_entry2.quantity 
          
          diff_ready1 == @pr_entry1.quantity 
          diff_ready2  == @pr_entry2.quantity 
        end
        
        it 'should confirm the pr and its entries' do
          @pr.is_confirmed.should be_true 
          @pr_entry1.is_confirmed.should be_true 
          @pr_entry2.is_confirmed.should be_true 
        end
        
        
        # FIRST BRANCH: update post confirm 
        it 'should preserve entry uniqueness post confirm' do
          @pr_entry1.update_by_employee(@admin, {
            :purchase_order_entry_id => @po_entry2.id,
            :quantity => 5
          })
          @pr_entry1.should_not be_valid 
        end
        
        it 'should  allow quantity update => change pending receival + ready ' do
          @extra_diff = 3 
          initial_pending_receival = @test_item1.pending_receival
          initial_ready  = @test_item1.ready  
          @pr_entry1.update_by_employee(@admin, {
            :purchase_order_entry_id => @po_entry1.id,
            :quantity => @pr_quantity1 + @extra_diff 
          })
          @pr_entry1.should be_valid 
          
          
          @test_item1.reload
          final_pending_receival = @test_item1.pending_receival
          diff_pending_receival = final_pending_receival - initial_pending_receival
          diff_pending_receival.should == (-1)*@extra_diff # because it is decreasing 
          
          final_ready = @test_item1.ready
          diff_ready = final_ready - initial_ready
          diff_ready.should == @extra_diff
        end
        
        # SECOND BRANCH: delete post confirm
        # IT HAS NO FURTHER COUPLING => The goods are in our warehouse, safe and sound.. well, actually, it has coupling . but fuck it
        it 'should allow delete on purchase_receival entry' do
          @test_item1.reload
          @initial_ready =  @test_item1.ready 
          @initial_pending_receival = @test_item1.pending_receival 
          quantity = @pr_entry1.quantity
          source_document_entry =  @pr_entry1.class.to_s
          source_document_entry_id = @pr_entry1.id 
          @pr_entry1.delete(@admin)
          @pr_entry1.persisted?.should be_false
          
          StockMutation.where(
            :source_document_entry_id => source_document_entry_id ,
            :source_document_entry => source_document_entry
          ).count.should == 0 
          
          @test_item1.reload
          
          @final_ready = @test_item1.ready
          @final_pending_receival = @test_item1.pending_receival 
          
          diff_ready = @initial_ready - @final_ready
          diff_pending_receival = @final_pending_receival - @initial_pending_receival 
          
          diff_ready.should == quantity 
          diff_pending_receival.should == quantity
        end 
      end
      
    
    end
  end
   
end
