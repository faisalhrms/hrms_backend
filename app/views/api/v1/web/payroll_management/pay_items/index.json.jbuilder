json.pay_items @pay_items.each do |pay_item|
	json.id 											pay_item.try(:id)
	json.name 										pay_item.try(:name)
	json.code 										pay_item.try(:code)
	json.item_type 								pay_item.try(:item_type)
	json.calculation_type 				pay_item.try(:calculation_type)
	json.sort_order 							pay_item.try(:sort_order)
	json.is_active 								pay_item.try(:is_active)
	json.is_static_item						pay_item.try(:is_static_item)
end