json.fixed_pay_items @fixed_pay_items.each do |fixed_pay_item|
	json.id 											fixed_pay_item.try(:id)
	json.employee_name 						fixed_pay_item.employee_name
	json.employee_code 						fixed_pay_item.employee_code
	json.pay_item_name 						fixed_pay_item.pay_item_name
	json.item_amount 							fixed_pay_item.try(:item_amount)
	json.is_active 								fixed_pay_item.try(:is_active)
	json.item_type 								fixed_pay_item.try(:item_type)
end