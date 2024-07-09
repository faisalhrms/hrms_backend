json.branch do
  json.id           					@branch.try(:id)
	json.company_id 						@branch.try(:company_id)
	json.location_id 						@branch.try(:location_id)
	json.country_id 						@branch.try(:country_id)
	json.state_id 							@branch.try(:state_id)
	json.city_id 								@branch.try(:city_id)
	json.shop_id 								@branch.try(:shop_id)
	json.name 									@branch.try(:name)
	json.code 									@branch.try(:code)
	json.description 						@branch.try(:description)
	json.is_active 							@branch.try(:is_active)
	json.employee_code_prefix  	@branch.try(:employee_code_prefix)
end