json.employee_types @employee_types do |employee_type|
  json.id   			employee_type.try(:id)
  json.name 			employee_type.try(:name)
  json.is_active 	employee_type.try(:is_active)
end