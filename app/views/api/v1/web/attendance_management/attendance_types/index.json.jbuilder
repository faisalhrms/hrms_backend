json.attendance_types @attendance_types do |attendance_type|
  json.id   				attendance_type.try(:id)
  json.name 				attendance_type.try(:name)
  json.code 				attendance_type.try(:code)
  json.sort_order 	attendance_type.try(:sort_order)
  json.is_active 		attendance_type.try(:is_active)
end