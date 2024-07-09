json.grades @grades do |grade|
  json.id   				grade.try(:id)
  json.name 				grade.try(:name)
  json.code 				grade.try(:code)
  json.sort_order 	grade.try(:sort_order)
  json.is_active 		grade.try(:is_active)
end