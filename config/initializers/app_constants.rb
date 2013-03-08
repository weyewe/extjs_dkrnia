ROLE_NAME = {
  :admin => "admin",
  :data_entry => "dataentry",
  :janitor => 'janitor',
  :coffee_maker => 'coffeemaker',
  :accountant => 'accountant',
  :engineer => 'engineer'
}

=begin
PRINTING RELATED
=end
CONTINUOUS_FORM_WIDTH = 792
HALF_CONTINUOUS_FORM_LENGTH = 342
FULL_CONTINUOUS_FORM_LENGTH = 684



# each entry case must be supported by the document 
STOCK_ENTRY_CASE = {
  # => 0-199 == addition 
    # => 0-9 == internal addition
  :stock_migration => 0 , 
  :stock_adjustment =>1,
  :scrap => 2,  # broken 
  :stock_conversion =>3, 
  :stock_adjustment => 4 , 
  :purchase_receival => 5, 


    # => 10-19 == related to vendor 
  :purchase => 10 ,  
  :purchase_return => 11,

    # => 20-29 == related to sales to customer  
  :sales => 20 ,
  :sales_return => 21 

} 

STOCK_ENTRY_USAGE = {
  :delivery         => 1,
  :stock_adjustment => 2, 
  :in_house_repair  => 3 
}

MUTATION_CASE = {
  :stock_migration => 0, 
  :sales_order => 1 ,
  :stock_conversion_source => 2 ,
  :scrap_item => 3,  # ready item -> scrap item
  :purchase_receival => 4 ,
  
  :stock_adjustment => 33 ,
   # deduction from now on
  
  :delivery => 34,
  :delivery_lost => 35,
  :delivery_returned => 36
}

MUTATION_STATUS = {
  :deduction  => 1 ,
  :addition => 2 
}

ITEM_STATUS = {
  :ready => 1 , 
  :scrap => 2, 
  :ordered => 3 , # from the supplier , but hasn't arrived at destination
  :sold => 4 ,  # to the customer, hasn't even left the warehouse 
  :on_delivery => 5  # to the customer. has left the warehouse. but not yet  # do they need this info? no idea
}
 
 

STOCK_ADJUSTMENT_CASE = {
  :deduction => 1 ,
  :addition => 2
}
