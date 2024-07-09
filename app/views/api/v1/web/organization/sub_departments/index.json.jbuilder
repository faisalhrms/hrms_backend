json.sub_departments @sub_departments do |sub_department|
  json.id   			sub_department.try(:id)
  json.name 			sub_department.try(:name)
  json.code 			sub_department.try(:code)
  json.is_active 	sub_department.try(:is_active)
end