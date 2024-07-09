json.employees @employees.each do |employee|
	json.employee_code 				employee.employee_code
	json.full_name 						employee.full_name
	json.father_name 					employee.father_name
	json.grade_name 					employee.grade_name
	json.designation_name 		employee.designation_name
	json.location_name 				employee.location_name
	json.branch_name 					employee.branch_name
	json.department_name 			employee.department_name
	json.sub_department_name 	employee.sub_department_name
	json.job_title_name 			employee.job_title_name
	json.employee_type_name 	employee.employee_type_name
	json.on_probation 				ReportFormat.boolean_in_text_as_confirmed(employee.on_probation)
  json.hiring_shift 	      employee.hiring_shift
	json.cnic_number 					ReportFormat.cnic_format(employee.cnic_number)
	json.date_of_birth 				ReportFormat.date_format(employee.date_of_birth)
	json.joining_date 				ReportFormat.date_format(employee.joining_date)
	json.confirmation_date 		ReportFormat.date_format(employee.confirmation_date)
	json.contract_start_date  ReportFormat.date_format(employee.contract_start_date)
	json.contract_end_date    ReportFormat.date_format(employee.contract_end_date)
	json.date_of_retirement 	"-"
	json.official_email 			employee.official_email
	json.official_number 			ReportFormat.phone_format(employee.official_mobile_number)
	json.personal_number 			ReportFormat.phone_format(employee.personal_number)
	json.emergency_number 		employee.emergency_contact_phone.blank? ? 'N/A' : ReportFormat.phone_format(employee.emergency_contact_phone)
	json.current_address 			employee.current_address
	json.permanent_address 		employee.permanent_address
	json.service_tenure 			ReportFormat.date_in_human_readable(employee.joining_date)
	json.employee_experince		ReportFormat.employee_experince(employee.joining_date)
	json.blood_group					employee.blood_group
	json.martial_status				employee.martial_status
	json.gross_salary 				employee.gross_salary
  json.incentive            employee.incentives
	json.line_manager 				employee.line_manager_name
end