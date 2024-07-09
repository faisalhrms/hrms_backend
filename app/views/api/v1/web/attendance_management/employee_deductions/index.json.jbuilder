json.employee_deductions @employee_deductions.each do |employee_deduction|
	json.id 								employee_deduction.try(:id)
	json.employee_name			employee_deduction.employee_name
	json.employee_code			employee_deduction.employee_code
	json.deduction_days 		employee_deduction.try(:deduction_days)
	json.deduction_type 		employee_deduction.try(:deduction_type)
	json.deductions_month 	ReportFormat.date_format(employee_deduction.deductions_month)
	json.status 						employee_deduction.try(:status)
end