json.success true 
json.total @total
json.delivery_losts @objects do |object|
	
	json.customer_name object.delivery.customer.name 
	json.delivery_id   object.delivery.id 
	json.delivery_code   object.delivery.code 
	 
	json.id 				object.id 
	json.code 			object.code
	json.is_confirmed object.is_confirmed 
end
