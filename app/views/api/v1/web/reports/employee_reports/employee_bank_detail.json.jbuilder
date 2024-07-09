json.employees @employees.each do |employee|
	json.employee_code 				employee.employee_code
	json.full_name 						employee.full_name
	json.bank_name 						ReportFormat.non_text_to_dash(employee.bank_name)
	json.bank_branch_name 		ReportFormat.non_text_to_dash(employee.bank_branch_name)
	json.bank_branch_code 		ReportFormat.non_text_to_dash(employee.bank_branch_code)
	json.bank_account_title 	ReportFormat.non_text_to_dash(employee.bank_account_title)
	json.bank_account_number 	ReportFormat.non_text_to_dash(employee.bank_account_number)
end