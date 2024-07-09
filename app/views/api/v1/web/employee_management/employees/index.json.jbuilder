index_value = 0
json.employees @employees.each do |employee|
	json.index_value 						index_value
	json.id 										employee.id
	json.employee_code 					employee.employee_code
	json.employee_code1 				employee.employee_code.to_s
	json.full_name 							employee.full_name
	json.father_name 						employee.father_name
	json.combine_name 					"#{employee.employee_code} | #{employee.full_name}"
	json.location_name 					employee.location_name
	json.branch_name 						employee.branch_name
	json.department_name 				employee.department_name
	json.job_title_name 				employee.job_title_name
	json.grade_name 						employee.grade_name
	json.designation_name 			employee.designation_name
  json.cnic_number 						employee.cnic_number
	json.joining_date 					ReportFormat.date_format(employee.joining_date)
	json.gross_salary 					employee.gross_salary
	json.confimration_due_date 	ReportFormat.date_format(employee.confimration_due_date)
	json.confirmation_date 			ReportFormat.date_format(employee.confirmation_date)
  json.floor_id                             employee.floor_id
  if employee.is_incharge == true and employee.group_id.present?
    json.group_id                            employee.group_id.split(',').map(&:to_i)
  else
    json.group_id                             employee.group_id.to_i
  end
  json.category_id                          employee.category_id
  json.incharge_id                          employee.incharge_id
  json.line_id                              employee.line_id
  json.is_incharge                          employee.is_incharge
	index_value = index_value + 1
end