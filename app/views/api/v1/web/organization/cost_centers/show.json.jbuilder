json.cost_center do
  json.id           		@cost_center.try(:id)
  json.name         		@cost_center.try(:name)
  json.is_active    		@cost_center.try(:is_active)
  json.description  		@cost_center.try(:description)
  json.company_id  			@cost_center.try(:company_id)
  json.salary_unit_id  	@cost_center.try(:salary_unit_id)
end