json.leave_types @leave_types do |leave_type|
  json.id   						leave_type.try(:id)
  json.name 						leave_type.try(:name)
  json.short_name 			leave_type.try(:short_name)
  json.location_name 		leave_type.location_name
  json.sort_order 			leave_type.try(:sort_order)
  json.is_active 				leave_type.try(:is_active)
end
if mill_instance?
  json.employee_doj " DOJ: #{@employee.try(:joining_date).try(:strftime, '%d-%b-%Y')}"
end