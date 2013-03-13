json.success true 
json.total @total
json.delivery_entries @objects do |object|
	json.delivery_code 							object.delivery.code 
	json.code 											object.code
	json.id 												object.id 
	json.sales_order_entry_id 			object.sales_order_entry.id
	json.sales_order_entry_code 		object.sales_order_entry.code
	json.quantity_sent 							object.quantity_sent
	json.item_name 									object.sales_order_entry.item.name 
	
	json.is_confirmed object.is_confirmed 
end
