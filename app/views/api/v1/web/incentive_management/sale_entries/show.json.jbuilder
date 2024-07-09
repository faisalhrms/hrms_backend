json.sale_entry do
	json.id 						@sale_entry.id
	json.company_id 		@sale_entry.try(:company_id)
	json.location_id 		@sale_entry.try(:location_id)
	json.branch_id 			@sale_entry.try(:branch_id)
	json.name 					@sale_entry.try(:name)
	json.sale_month 		@sale_entry.try(:sale_month)
	json.sale_value 		@sale_entry.try(:sale_value)
  json.incentive_payable 		@sale_entry.try(:incentive_payable)
  json.profit_value 	@sale_entry.try(:profit_value)
	json.loss_value 		@sale_entry.try(:loss_value)
	json.target_value 	@sale_entry.try(:target_value)
end