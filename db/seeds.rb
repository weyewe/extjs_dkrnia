User.create :email => 'w.yunnal@gmail.com', :password => 'willy1234', :password_confirmation => 'willy1234'


admin_role = {
  :system => {
    :administrator => true
  }
}

Role.create!(
:name        => ROLE_NAME[:admin],
:title       => 'Administrator',
:description => 'Role for administrator',
:the_role    => admin_role.to_json
)
admin_role = Role.find_by_name ROLE_NAME[:admin]

coffee_maker_role = {
  :coffee_maker => {
    :make_coffee => true  
  }
}
 
coffee_maker_role = Role.create!(
:name        => ROLE_NAME[:coffee_maker],
:title       => 'Data Entry',
:description => 'Role for data entry',
:the_role    => coffee_maker_role.to_json
)

janitor_role = {
  :janitor => {
    :clean_toilet => true 
  }
}

janitor_role  = Role.create!(
:name        => ROLE_NAME[:janitor],
:title       => 'Janitor',
:description => 'Role for janitor',
:the_role    => janitor_role.to_json
)


coffee_maker = User.create :email => 'coffee_maker@gmail.com', :password => 'coffee1234', :password_confirmation => 'coffee1234'
janitor = User.create :email => 'janitor@gmail.com', :password => 'jani1234', :password_confirmation => 'jani1234'
admin = User.create :email => 'admin@gmail.com', :password => 'admin1234', :password_confirmation => 'admin1234'

coffee_maker.role_id = coffee_maker_role.id
coffee_maker.save 

janitor.role_id = janitor_role.id
janitor.save 

admin.role_id = admin_role.id 
admin.save 

vendor_name_array = ["jimmy", "Mohan", "Sitorus", "Sitanggang", "Ando Smith", "Siburian", "benny", "Bernard",
      "Monkey", "Tiger", "Lion", "jaune" , "mandarin", "Zhong", "Superman", "Shinta", "Hardy", "Shinto"]

vendor_name_array.each do |x|
  Vendor.create :name => x
end

item_name_array = [ "itemA", "itemB", "itemC", "itemD", "itemE", "itemF", "itemG", "itemH",
                    "itemI", "itemJ"]

item_name_array.each do |item_name|
  Item.create_by_employee(admin,  {
    :name => item_name,
    :supplier_code => "SC_#{item_name}",
    :customer_code => "CC_#{item_name}"
  } )
end                
 