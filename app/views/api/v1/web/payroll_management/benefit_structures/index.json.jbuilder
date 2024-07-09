json.benefit_structures @benefit_structures do |benefit_structure|
  json.id   								benefit_structure.try(:id)
  json.name 								benefit_structure.try(:name)
  json.code 								benefit_structure.try(:code)
  json.location_name 				benefit_structure.location_name
  json.grade_name 					benefit_structure.grade_name
  json.employee_type_name 	benefit_structure.employee_type_name
  json.is_active 						benefit_structure.try(:is_active)
end