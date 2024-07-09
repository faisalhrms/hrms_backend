json.salary_units @salary_units do |salary_unit|
  json.id   			salary_unit.try(:id)
  json.name 			salary_unit.try(:name)
  json.is_active 	salary_unit.try(:is_active)
end