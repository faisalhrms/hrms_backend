json.employees @employees.each do |employee|
	json.employee_code 				employee.employee_code
	json.full_name 						employee.full_name
	json.location_name 				employee.location_name
	json.branch_name 					employee.branch_name
	json.department_name 			employee.department_name
	json.grade_name 					employee.grade_name
	json.designation_name 		employee.designation_name
	json.cnic_number					ReportFormat.cnic_format(employee.cnic_number)
	json.joining_date 				ReportFormat.date_format(employee.joining_date)
	json.date_of_birth 				ReportFormat.date_format(employee.date_of_birth)
	json.current_address 			employee.current_address
	json.employee_age 				ReportFormat.date_in_human_readable(employee.date_of_birth)
	json.gross_salary					employee.gross_salary
end