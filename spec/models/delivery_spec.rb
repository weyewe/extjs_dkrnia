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
    @employee = Employee.create :name => "Joni"
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

    @second_test_item  = Item.create_by_employee(  @admin,  {
      :name => "Second Test Item",
      :supplier_code => "BEL3224234423224324",
      :customer_code => 'CCCL22343222',
      :item_category_id => @base_item_category.id 
    })

    # create stock migration
    @migration_quantity = 200 
    @test_item_migration =  StockMigration.create_by_employee(@admin, {
      :item_id => @test_item.id,
      :quantity => @migration_quantity
    })  
    
    @second_test_item_migration  = StockMigration.create_by_employee(@admin, {
      :item_id => @second_test_item.id,
      :quantity => 10
    })
 
    @test_item.reload 
    
    
    @initial_pending_receival = @test_item.pending_receival
     @purchase_order = PurchaseOrder.create_by_employee( @admin, {
       :vendor_id => @vendor.id 
     } )
     
     @quantity_purchased  =  6
     @purchase_order_entry = PurchaseOrderEntry.create_by_employee( @admin, @purchase_order, {
       :item_id => @test_item.id ,
       :quantity => @quantity_purchased
     } ) 
 
    @test_item.reload 
    @final_pending_receival = @test_item.pending_receival
    @pre_confirm_pending_receival = @test_item.pending_receival
    @purchase_order.confirm(@admin)
    @test_item.reload
    @post_confirm_pending_receival = @test_item.pending_receival
    @update_quantity = 9
    @test_item.reload 
    @pre_update_pending_receival = @test_item.pending_receival
    @purchase_order_entry.update_by_employee(@admin, {
      :quantity => @update_quantity,
      :item_id => @test_item.id 
      })    
    @test_item.reload
    
    @purchase_receival = PurchaseReceival.create_by_employee( @admin, {
      :vendor_id => @vendor.id
    } )
    
    @diff = 2
    @received_quantity = @purchase_order_entry.quantity - @diff  
    @purchase_receival_entry = PurchaseReceivalEntry.create_by_employee( @admin, 
              @purchase_receival, 
              {
                :purchase_order_entry_id => @purchase_order_entry.id ,
                :quantity => @received_quantity
              })
    
    @test_item.reload 
    @initial_ready_quantity = @test_item.ready
    @initial_pending_receival_quantity =  @test_item.pending_receival
    @purchase_receival.confirm(@admin) 
    @test_item.reload
  end
   
  it 'should have some ready item' do
    puts "The received quantity : #{@received_quantity}"
    @test_item.ready.should == @received_quantity + @migration_quantity
  end
  
  it 'should create delivery' do 
    @delivery = Delivery.create_by_employee(@admin, {
      :employee_id => @employee.id 
    })
    @delivery.should be_valid 
  end
  
  it 'should not create delivery without employee' do
    @delivery = Delivery.create_by_employee(@admin, {
      :employee_id =>  nil 
    })
    @delivery.should_not be_valid
  end
  
  context "create delivery entry" do
    before(:each) do
      @delivery = Delivery.create_by_employee(@admin, {
        :employee_id => @employee.id 
      })
    end
    
    it 'should be able to create delivery entry' do
      @delivery_entry = DeliveryEntry.create_by_employee( @admin, @delivery, {
        :item_id => @test_item.id ,
        :quantity_sent => 5 
      } ) 
      @delivery_entry.should be_valid 
    end
    
    it 'should not create delivery entry if quantity sent ==0   ' do
      @delivery_entry = DeliveryEntry.create_by_employee( @admin, @delivery, {
        :item_id => @test_item.id ,
        :quantity_sent => 0 
      } ) 
      @delivery_entry.should_not be_valid
    end
    
    it 'should not do double delivery entry ( from the same item ) ' do
      @delivery_entry = DeliveryEntry.create_by_employee( @admin, @delivery, {
        :item_id => @test_item.id ,
        :quantity_sent => 3
      } ) 
      @delivery_entry.should be_valid
      
      @delivery_entry = DeliveryEntry.create_by_employee( @admin, @delivery, {
        :item_id => @test_item.id ,
        :quantity_sent => 1 
      } ) 
      @delivery_entry.should_not be_valid
    end
    
    context "confirming delivery" do
      before(:each) do
        @test_item.reload 
        @initial_ready_quantity  = @test_item.ready 
        @quantity_sent = 3  
        @delivery_entry = DeliveryEntry.create_by_employee( @admin, @delivery, {
          :item_id => @test_item.id ,
          :quantity_sent => @quantity_sent
        } )
        
        @delivery.confirm(@admin)
        @test_item.reload 
        @delivery_entry.reload 
      end
      
      it 'should confirm delivery' do
        @delivery.is_confirmed.should be_true 
      end
      
      it 'should create stock mutation' do
        @delivery_entry.stock_mutation.should be_valid 
      end
      
      it 'should provide the appropriate stock mutation quantity' do
        @delivery_entry.stock_mutation.quantity.should == @delivery_entry.quantity_sent 
      end
      
      it 'should deduct the ready quantity' do
        @final_ready_quantity  = @test_item.ready 
        diff=  @initial_ready_quantity - @final_ready_quantity
        diff.should == @quantity_sent
      end
      
      
      context 'post confirm update: item and quantity' do
        before(:each) do
          @delivery_entry.reload
          @new_quantity = 5
          @quantity_sent = @delivery_entry.quantity_sent  
          @test_item.reload
          @second_test_item.reload 
          @initial_first_ready_item = @test_item.ready 
          @initial_second_ready_item = @second_test_item.ready
          @delivery_entry.post_confirm_update( @admin, {
            :item_id => @second_test_item.id,
            :quantity_sent => @new_quantity 
          })
          @delivery_entry.reload 
          @second_test_item.reload 
          @test_item.reload 
        end
        
        it 'should have no error' do
          @delivery_entry.errors.messages.each do |msg|
            puts "The MSG: #{msg}"
          end
          @delivery_entry.errors.size.should == 0 
        end
        
        it 'should update the stock mutation and quantity sent' do
          @delivery_entry.confirmed_delivery_stock_mutation.quantity.should == @new_quantity
        end
        
        
        it 'should change the quantity_sent' do
          @delivery_entry.quantity_sent = @new_quantity
        end
        
        it 'should add the first_test_item by quantity_sent' do
          
          puts "quantity sent: #{@quantity_sent}"
          @final_first_ready_item = @test_item.ready
          puts "initial first ready item: #{@initial_first_ready_item}"
          puts "final first ready item: #{@final_first_ready_item}"
          
          puts "initial second ready_item: #{@initial_second_ready_item}"
          puts "final second ready_item: #{@second_test_item.ready}"
          diff = @final_first_ready_item - @initial_first_ready_item
          diff.should == @quantity_sent 
        end
        
        it 'should deduct the second_test_item by new_quantity' do
          @final_second_ready_item = @second_test_item.ready 
          diff = @initial_second_ready_item - @final_second_ready_item
          diff.should == @new_quantity
        end
      end
      
      context 'post confirm delete' do
        before(:each) do
          @test_item.reload
          @initial_item_ready = @test_item.ready
          @quantity_sent = @delivery_entry.quantity_sent 
          @delivery_entry.delete(@admin)
          @test_item.reload
        end
        
        it 'should delete the delivery stock mutation' do
          StockMutation.where(
            :source_document_entry_id => @delivery_entry.id,
            :source_document_entry => @delivery_entry.class.to_s 
          ).count.should == 0 
        end
        
        it 'should recover the item ready quantity' do
          @final_item_ready = @test_item.ready
          diff = @final_item_ready - @initial_item_ready
          diff = @quantity_sent 
        end
      end
      
      context "finalizing the delivery entry: no lost or returned" do
        before(:each) do
          @delivery_entry.update_post_delivery( @admin, {
            :quantity_confirmed => @quantity_sent,
            :quantity_returned => 0,  # create stock mutation
            :quantity_lost =>  0  # create stock mutation 
            } ) 
        end
        
        it 'should be able to update post dleivery' do
          @delivery_entry.errors.size.should == 0 
          
          @delivery.delivery_entries.count.should == 1 
          
          @delivery_entry.quantity_confirmed.should == @quantity_sent
          @delivery_entry.quantity_returned.should == 0 
          @delivery_entry.quantity_lost.should == 0 
        end
        
        context "finalize delivery" do
          before(:each) do 
            @delivery_entry.reload
            @delivery.finalize( @admin ) 
            @delivery_entry.reload 
          end
          
          it 'should update the ready quantity using the finalized quantity' do
            @delivery.is_finalized.should be_true 
          end
          
          it 'should not create return stock mutation' do
            @delivery_entry.delivery_return_stock_mutation.should be_nil 
          end
          
          it 'should not create lost stock mutation' do
            @delivery_entry.delivery_lost_stock_mutation.should be_nil 
          end
          
          context "post finalize update" do
            before(:each) do
              
              @new_quantity_sent = @quantity_sent +1  
              @new_quantity_confirmed = @quantity_sent -1 
              @new_quantity_returned = 1 
              @new_quantity_lost = 1 
              @test_item.reload 
              @initial_item_ready = @test_item.ready 
              @delivery_entry.reload 
              @delivery_entry.update_post_delivery( @admin, {
                :quantity_sent =>  @new_quantity_sent,
                :quantity_confirmed =>  @new_quantity_confirmed ,
                :quantity_returned => @new_quantity_returned ,
                :quantity_lost =>  @new_quantity_lost
              } ) 
              @delivery_entry.reload 
              @test_item.reload  
            end
            
            it 'should create valid delivery entry' do
              @delivery_entry.errors.size.should == 0 
            end
            
            it 'should update the stock mutation' do
              @delivery_entry.delivery_lost_stock_mutation.quantity.should == @new_quantity_lost
              @delivery_entry.confirmed_delivery_stock_mutation.quantity.should == @new_quantity_sent
              @delivery_entry.delivery_return_stock_mutation.quantity.should == @new_quantity_returned
            end
          end
          
          context "post finalize delete" do
            before(:each) do
              @test_item.reload
              @initial_item_ready = @test_item.ready 
              @quantity_sent = @delivery_entry.quantity_sent 
              @delivery_entry.reload 
              @delivery_entry.delete(@admin)
              @test_item.reload 
            end
           
            it 'should update the ready item' do
              @final_item_ready = @test_item.ready 
              diff = @final_item_ready - @initial_item_ready
              diff.should == @quantity_sent 
            end
          end
         
        end
      end
      
      context "finalizing the delivery entry: with return" do
        before(:each) do
          @quantity_returned = 1 
          @delivery_entry.update_post_delivery( @admin, {
            :quantity_confirmed => @quantity_sent -  @quantity_returned,
            :quantity_returned => @quantity_returned,  # create stock mutation
            :quantity_lost =>  0  # create stock mutation 
            } ) 
        end
        
        it 'should be able to update post dleivery' do
          @delivery_entry.errors.messages.each do |x| 
            puts "THe error messages is : #{x}"
          end
          @delivery_entry.errors.size.should == 0 
        end
        
        it 'should manifest the quantity confirmed and quantity returned' do
          @delivery_entry.reload
          @delivery_entry.quantity_confirmed.should == @quantity_sent -  @quantity_returned
          @delivery_entry.quantity_returned.should == @quantity_returned
          @delivery_entry.quantity_lost.should == 0  
        end
        
        it 'should save' do
          @delivery_entry.persisted?.should be_true 
        end
        
        context "finalizing " do
          before(:each) do
            puts "\n\n************ BEFORE FINALIZE With RETURN"
            
            @delivery_entry.reload
            @delivery.reload
            @test_item.reload
            @pre_finalization_ready = @test_item.ready 
            @delivery.finalize(@admin)
            @delivery_entry.reload 
            @delivery.reload 
            @test_item.reload 
          end
          
          it 'should produce diff in ready item, equal to the number of returned goods' do
            @final_ready_item = @test_item.ready
            diff =  @final_ready_item  - @pre_finalization_ready 
            puts "quantity_sent: #{@delivery_entry.quantity_sent}"
            puts "quantity_confirmed: #{@delivery_entry.quantity_confirmed}"
            puts "quantity_returned: #{@delivery_entry.quantity_returned}"
            puts "quantity_lost: #{@delivery_entry.quantity_lost}"
            diff.should == @quantity_returned
          end
          
          it 'should reduce the stock mutation for delivery' do
            @delivery_entry.confirmed_delivery_stock_mutation.quantity.should == @delivery_entry.quantity_sent
          end
          
          it 'should create delivery return stock mutation' do
            @delivery_entry.delivery_return_stock_mutation.quantity.should == @quantity_returned
          end
          
          it 'should finalize the delivery' do
             @delivery.is_finalized.should be_true 
           end
           
           it 'should preserve the data inside the delivery_entry' do
             @delivery_entry.reload
             @delivery_entry.quantity_confirmed.should == @quantity_sent -  @quantity_returned
             @delivery_entry.quantity_returned.should == @quantity_returned
             @delivery_entry.quantity_lost.should == 0
           end
           
           it 'should update the ready quantity using the finalized quantity' do
             @delivery_entry.errors.messages.each do |msg|
               puts "The message is : #{msg}"
             end
             @delivery_entry.is_finalized.should be_true 
           end
           
           it 'should not create return stock mutation' do
             @delivery_entry.delivery_return_stock_mutation.should be_valid 
           end
           
           it 'should not create lost stock mutation' do
             @delivery_entry.delivery_lost_stock_mutation.should be_nil 
           end
        end
      end
      
      
      context "finalizing the delivery entry: with lost" do
        before(:each) do
          @quantity_lost = 1 
          @delivery_entry.update_post_delivery( @admin, {
            :quantity_confirmed => @quantity_sent -  @quantity_lost,
            :quantity_returned =>  0 ,  # create stock mutation
            :quantity_lost =>  @quantity_lost # create stock mutation 
            } )
           
          @delivery.finalize(@admin)
          @delivery_entry.reload 
        end
        
        it 'should save' do
          @delivery_entry.persisted?.should be_true 
        end
        
        context "finalizing " do
          before(:each) do
            @delivery_entry.reload
            @delivery.reload
            @test_item.reload
            @pre_finalization_ready = @test_item.ready
            @delivery.finalize(@admin)
            @delivery_entry.reload 
            @delivery.reload 
            @test_item.reload
          end
          
          
          
          it 'should finalize the delivery' do
            @delivery.is_finalized.should be_true 
          end
          
          it 'should preserve the data inside the delivery_entry' do
            @delivery_entry.reload
            @delivery_entry.quantity_confirmed.should == @quantity_sent -  @quantity_lost
            @delivery_entry.quantity_returned.should == 0
            @delivery_entry.quantity_lost.should == @quantity_lost
          end
          
          it 'should update the ready quantity using the finalized quantity' do
            @delivery_entry.errors.messages.each do |msg|
              puts "The message is : #{msg}"
            end
            @delivery_entry.is_finalized.should be_true 
          end
          
          it 'should not create return stock mutation' do
            @delivery_entry.delivery_return_stock_mutation.should be_nil 
          end
          
          it 'should not create lost stock mutation' do
            @delivery_entry.delivery_lost_stock_mutation.should be_valid 
          end
        end
      end
                
          
          
    end
  end
  
  

end
