json.grade do
  json.id           	@grade.try(:id)
  json.name 					@grade.try(:name)
	json.code 					@grade.try(:code)
	json.company_id 		@grade.try(:company_id)
	json.currency_title @grade.try(:currency_title)
	json.sort_order 		@grade.try(:sort_order)
	json.is_active 			@grade.try(:is_active)
	json.description 		@grade.try(:description)
  json.management_type 		@grade.try(:management_type)
  json.management_tier 		@grade.try(:management_tier)
end