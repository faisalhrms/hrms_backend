json.employee_transactions @employee_transactions.each do |employee_transaction|
	json.employee_code 				employee_transaction.employee.employee_code
	json.full_name 						employee_transaction.employee.full_name
	json.location_name 				employee_transaction.employee.location_name
	json.branch_name 					employee_transaction.employee.branch_name
	json.department_name 			employee_transaction.employee.department_name
	json.grade_name 					employee_transaction.employee.grade_name
	json.designation_name 		employee_transaction.employee.designation_name
	json.transaction_date			ReportFormat.date_format(employee_transaction.transaction_date)
	json.transfer_type				employee_transaction.transfer_type
	if employee_transaction.transfer_type == "Branch"
		json.transfer_from			employee_transaction.prve_branch_name
		json.transfer_to				employee_transaction.current_branch_name
	elsif employee_transaction.transfer_type == "Department"
		json.transfer_from			employee_transaction.prve_department_name
		json.transfer_to				employee_transaction.current_department_name
	else
		json.transfer_from			"-"
		json.transfer_to				"-"
	end
end