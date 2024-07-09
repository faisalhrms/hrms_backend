json.designation do
  json.id           @designation.try(:id)
  json.company_id 	@designation.try(:company_id)
  json.grade_id 		@designation.try(:grade_id)
	json.name 				@designation.try(:name)
	json.code 				@designation.try(:code)
	json.description 	@designation.try(:description)
	json.is_active 		@designation.try(:is_active)
end

	



