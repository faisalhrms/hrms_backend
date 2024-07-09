json.location do
  json.id           					@location.try(:id)
  json.name         					@location.try(:name)
  json.code         					@location.try(:code)
  json.company_id   					@location.try(:company_id)
  json.is_active    					@location.try(:is_active)
  json.description  					@location.try(:description)
  json.employee_code_prefix  	@location.try(:employee_code_prefix)
end