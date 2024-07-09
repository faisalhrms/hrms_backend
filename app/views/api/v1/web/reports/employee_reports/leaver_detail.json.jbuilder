employees_ids = []
json.employee_transactions @employee_transactions.each do |employee_transaction|
	if employees_ids.include?(employee_transaction.employee_id) == false
		json.employee_code 				employee_transaction.employee.employee_code
		json.full_name 						employee_transaction.employee.full_name
		json.father_name 					employee_transaction.employee.father_name
		json.location_name 				employee_transaction.employee.location_name
		json.branch_name 					employee_transaction.employee.branch_name
		json.department_name 			employee_transaction.employee.department_name
		json.grade_name 					employee_transaction.employee.grade_name
		json.designation_name 		employee_transaction.employee.designation_name
		json.file_number 					ReportFormat.non_text_to_dash(employee_transaction.employee.file_number)
		json.basic_salary 				(employee_transaction.employee_gross_salary * 0.67).round
		json.employee_age 				ReportFormat.employee_age(employee_transaction.employee.date_of_birth)
		json.cnic_number 					ReportFormat.cnic_format(employee_transaction.employee.cnic_number)
		json.date_of_birth 				ReportFormat.date_format(employee_transaction.employee.date_of_birth)
		json.joining_date 				ReportFormat.date_format(employee_transaction.employee.joining_date)
		json.transaction_date			ReportFormat.date_format(employee_transaction.transaction_date)
		employees_ids << employee_transaction.employee_id
	end
end