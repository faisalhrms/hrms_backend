json.employee_deduction do
	json.id 								@employee_deduction.try(:id)
	json.employee_name			@employee_deduction.employee_name
	json.employee_code			@employee_deduction.employee_code
	json.deduction_days 		@employee_deduction.try(:deduction_days)
	json.deduction_type 		@employee_deduction.try(:deduction_type)
	json.deductions_month 	@employee_deduction.try(:deductions_month)
end