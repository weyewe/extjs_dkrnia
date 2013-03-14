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

     
    
    @test_item.reload 
  
  end
  
  it 'should create valid admin' do
    @admin.should be_valid 
  end
  
  it 'should create vendor' do
    @vendor.should be_valid
  end
  
  it 'should create base item category' do
    @base_item_category.should be_valid 
  end
  
  it 'should create test item' do
    @test_item.should be_valid 
  end
  
  it 'should be allowed to create stock migration' do
    @migration_quantity = 200 
    @test_item_migration =  StockMigration.create_by_employee(@admin, {
      :item_id => @test_item.id,
      :quantity => @migration_quantity
    })
    
    @test_item_migration.errors.messages.each do |msg|
      puts "The MSG: #{msg}"
    end
    @test_item_migration.should be_valid 
  end
  
  context 'post stock migration creation' do
    before(:each) do
      @initial_ready_item = @test_item.ready 
      @migration_quantity = 200 
      @test_item_migration =  StockMigration.create_by_employee(@admin, {
        :item_id => @test_item.id,
        :quantity => @migration_quantity
      })
      @test_item_migration.reload 
      @test_item.reload 
    end
    
    it 'should update the ready item quantity' do
      @final_ready_item = @test_item.ready
      diff = @final_ready_item - @initial_ready_item 
      diff.should == @migration_quantity
    end
    
    it 'should create stock mutation' do
      @test_item_migration.stock_mutations.count == 1 
      @test_item_migration.stock_mutation.quantity.should == @migration_quantity 
      @test_item_migration.stock_mutation.mutation_case.should == MUTATION_CASE[:stock_migration] 
      @test_item_migration.stock_mutation.mutation_status.should == MUTATION_STATUS[:addition] 
    end
    
    it 'should not allow double stock migration for the same item' do
      @migration_quantity = 200 
      @test_item_migration =  StockMigration.create_by_employee(@admin, {
        :item_id => @test_item.id,
        :quantity => @migration_quantity
      })
      @test_item_migration.should_not be_valid 
      
    end
    
    it 'should be allowed to update the stock migration'  do
      @new_migration_quantity= 100 
      @test_item_migration.update_by_employee(@admin,   {
        :item_id => @test_item.id ,
        :quantity => @new_migration_quantity
      })
      @test_item_migration.should be_valid 
    end
    
    context 'post stock migration update' do
      before(:each) do
        @pre_update_ready_quantity = @test_item.ready 
        @new_migration_quantity= 100 
        @test_item_migration.update_by_employee(@admin,   {
          :item_id => @test_item.id ,
          :quantity => @new_migration_quantity
        })
        
        @test_item.reload 
        @test_item_migration.reload 
      end
      
      it 'should change the ready quantity' do
        @post_update_ready_quantity = @test_item.ready 
        diff = @post_update_ready_quantity - @pre_update_ready_quantity 
        diff_stock_migration_quantity = @new_migration_quantity - @migration_quantity 
        diff.should == diff_stock_migration_quantity
      end
      
      it "should change the stock mutation's quantity" do
        @test_item_migration.stock_mutations.count.should == 1 
        @test_item_migration.stock_mutation.quantity.should == @new_migration_quantity 
      end
    end
  end
  
 
 

end
