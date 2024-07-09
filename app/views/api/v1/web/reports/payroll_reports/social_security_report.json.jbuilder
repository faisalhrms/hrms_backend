json.report_data @pay_invoices.each do |pay_invoice|
	employee = pay_invoice.employee
	employee_eobi_value 	=	PayRollReportData.employee_eobi_value(pay_invoice)
	employeer_eobi_value 	= PayRollReportData.employeer_eobi_value(pay_invoice)
	json.full_name								pay_invoice.employee_name
	json.employee_code 						pay_invoice.employee_code
	json.father_name 							employee.father_name
	json.cnic_number 							ReportFormat.cnic_format(employee.cnic_number)
	json.date_of_birth 						ReportFormat.date_format(employee.date_of_birth)
	json.joining_date 						ReportFormat.date_format(employee.joining_date)
	json.grade_name 							pay_invoice.grade_name
	json.designation_name 				pay_invoice.designation_name
	json.location_name 						pay_invoice.location_name
	json.branch_name 							pay_invoice.branch_name
	json.department_name 					pay_invoice.department_name
	json.gross_salary							pay_invoice.actual_salary.round
	json.payable_gross						pay_invoice.payable_gross.round
	if pay_invoice.actual_salary.to_f.round <= 22000
		json.social_security_amount ((pay_invoice.payable_gross.to_f.round * 6).to_f/100.0).to_f.round
	else
		json.social_security_amount 0.0
	end
end