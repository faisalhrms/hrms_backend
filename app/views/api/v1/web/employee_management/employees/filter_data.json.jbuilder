json.employees @employees.each do |employee|
	json.id 									employee.id
	json.employee_code 				employee.employee_code
	json.full_name 						employee.full_name
	json.combine_name 			"#{employee.employee_code} | #{employee.full_name}"
  if employee.is_incharge == true and employee.group_id.present?
    json.group_id           employee.group_id.split(',').map(&:to_i)
  else
    json.group_id             employee.group_id.to_i
  end
  json.is_incharge            employee.is_incharge
	json.combine_name 				"#{employee.employee_code} | #{employee.full_name}"
end