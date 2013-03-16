json.success true 
json.total @total
json.sales_return_entries @objects do |object|
	json.code 			object.code
	json.id 				object.id

	json.sales_return_code 	object.sales_return.code 
	json.sales_return_id 		object.sales_return_id 
	
	json.delivery_entry_code 	object.delivery_entry.code 
	json.delivery_entry_id 		object.delivery_entry_id
	 
	json.item_name 				object.delivery_entry.sales_order_entry.item.name   
	
	json.quantity 				object.quantity
	
	json.is_confirmed object.is_confirmed 
end

 