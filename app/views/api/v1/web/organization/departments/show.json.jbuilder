json.department do
  json.id           @department.try(:id)
  json.company_id 	@department.try(:company_id)
	json.name 				@department.try(:name)
	json.code 				@department.try(:code)
	json.description 	@department.try(:description)
	json.is_active 		@department.try(:is_active)
end

	



