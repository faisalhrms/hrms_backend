json.fixed_pay_item do
	json.id 											@fixed_pay_item.try(:id)
	json.company_id 							@fixed_pay_item.try(:company_id)
	json.employee_id 							@fixed_pay_item.try(:employee_id)
	json.pay_item_id 							@fixed_pay_item.try(:pay_item_id)
	json.item_amount 							@fixed_pay_item.try(:item_amount)
	json.is_active 								@fixed_pay_item.try(:is_active)
	json.pay_item_name 						@fixed_pay_item.pay_item_name
	json.employee_name 						@fixed_pay_item.employee_name
	json.employee_code 						@fixed_pay_item.employee_code
	json.item_type 								@fixed_pay_item.item_type
	json.pay_month 								@fixed_pay_item.pay_month
	json.formated_pay_month 			@fixed_pay_item.formated_pay_month
	json.description 							@fixed_pay_item.description
end