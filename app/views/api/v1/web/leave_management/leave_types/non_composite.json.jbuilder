json.leave_types @leave_types do |leave_type|
  json.id   						leave_type.try(:id)
  json.name 						leave_type.try(:name)
  json.short_name 			leave_type.try(:short_name)
  json.status 					"Allowed"
end