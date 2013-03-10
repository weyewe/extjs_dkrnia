json.success true 
json.total @total
json.purchase_receivals @objects do |object|
	json.code 			object.code
	json.vendor_name object.vendor.name 
	json.vendor_id   object.vendor_id 
	json.id 				object.id 
	json.is_confirmed object.is_confirmed 
end
