json.employees @employees.each do |employee|
	json.employee_code 				employee.employee_code
	json.full_name 						employee.full_name
	json.grade_name 					employee.grade_name
	json.designation_name 		employee.designation_name
	json.location_name 				employee.location_name
	json.branch_name 					employee.branch_name
	json.department_name 			employee.department_name
	json.job_title_name 			employee.job_title_name
	json.line_manager_name 		employee.line_manager_name
	json.cnic_number 					ReportFormat.cnic_format(employee.cnic_number)
	json.joining_date 				ReportFormat.date_format(employee.joining_date)
	json.date_of_birth 				ReportFormat.date_format(employee.date_of_birth)
	json.official_email 			employee.official_email
	json.official_number 			ReportFormat.phone_format(employee.official_mobile_number)
end
