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
        :customer_id => @customer.id 
      } )
    end
    
    it 'should be allowed to create so entry' do
      so_entry = SalesOrderEntry.create_by_employee(@admin, @po, {
        :item_id => @test_item1.id ,
        :quantity => 15 
      })
      so_entry.should be_valid
    end
  end
   
end
