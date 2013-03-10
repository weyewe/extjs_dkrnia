json.success true 
json.total @total
json.purchase_receival_entries @objects do |object|
	json.purchase_receival_code object.purchase_receival.code 
	json.code 			object.code
	json.id 				object.id 
	json.item_name 				object.purchase_order_entry.item.name  
	json.purchase_order_code 				object.purchase_order_entry.purchase_order.code
	json.purchase_order_entry_code 				object.purchase_order_entry.code
	json.quantity 				object.quantity
	json.is_confirmed object.is_confirmed 
end
