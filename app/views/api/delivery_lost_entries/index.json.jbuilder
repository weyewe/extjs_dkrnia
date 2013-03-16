json.success true 
json.total @total
json.delivery_lost_entries @objects do |object|
	json.code 			object.code
	json.id 				object.id

	json.delivery_lost_code 	object.delivery_lost.code 
	json.delivery_lost_id 		object.delivery_lost_id 
	
	json.delivery_entry_code 	object.delivery_entry.code 
	json.delivery_entry_id 		object.delivery_entry_id
	 
	json.item_name 				object.delivery_entry.sales_order_entry.item.name   
	
	json.quantity 				object.quantity
	
	json.is_confirmed object.is_confirmed 
end

