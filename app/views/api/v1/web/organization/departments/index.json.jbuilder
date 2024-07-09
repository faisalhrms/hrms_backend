json.departments @departments do |department|
  json.id   			department.try(:id)
  json.name 			department.try(:name)
  json.code 			department.try(:code)
  json.is_active 	department.try(:is_active)
end