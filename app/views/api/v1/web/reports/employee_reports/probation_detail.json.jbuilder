json.employees @employees.each do |employee|
	json.employee_code 				employee.employee_code
	json.full_name 						employee.full_name
	json.location_name 				employee.location_name
	json.branch_name 					employee.branch_name
	json.department_name 			employee.department_name
	json.grade_name 					employee.grade_name
	json.designation_name 		employee.designation_name
	json.job_title_name 			employee.job_title_name
	json.joining_date 				ReportFormat.date_format(employee.joining_date)
	json.probation_end_date 	ReportFormat.date_format(employee.confimration_due_date)
end