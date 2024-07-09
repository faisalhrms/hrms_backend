json.employees @employees.each do |employee|
	json.employee_code 				employee.employee_code
	json.full_name 						employee.full_name
	json.grade_name 					employee.grade_name
	json.designation_name 		employee.designation_name
	json.location_name 				employee.location_name
	json.department_name 			employee.department_name
	json.job_title_name 			employee.job_title_name
	json.salary_unit_name 		employee.salary_unit_name
	json.gender 							employee.gender	
	json.cnic_number 					ReportFormat.cnic_format(employee.cnic_number)
	json.insurance_number 		"-"
	json.category_plan 				"-"
	json.date_of_joining 			ReportFormat.insurance_report_date_format(employee.joining_date)
	json.date_of_enrollment 	ReportFormat.insurance_report_date_format(employee.joining_date)
	if employee.is_active == false
		employee_transaction_history = employee.employee_transaction_histories.where(:transaction_type => "End of Employment").last
		if employee_transaction_history.nil?
			json.date_of_leaving 	"-"
		else	
			json.date_of_leaving 	ReportFormat.insurance_report_date_format(employee_transaction_history.transaction_date)
		end
	else
		json.date_of_leaving 		"-"
	end
	json.date_of_birth 				ReportFormat.insurance_report_date_format(employee.date_of_birth)
	json.age 									ReportFormat.date_of_birth_in_years(employee.date_of_birth)
	json.relation 						"Employee"
	json.remarks 							"-"
end