json.report_data @pay_invoices.each do |pay_invoice|
	employee = pay_invoice.employee
	employee_pf_value 		=	PayRollReportData.employee_pf_value(pay_invoice)
	employeer_pf_value 		= PayRollReportData.employeer_pf_value(pay_invoice)
	basic_salary_value 		= PayRollReportData.basic_salary_value(pay_invoice)
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
	json.basic_salary_value 			basic_salary_value
	json.employee_pf_value  			employee_pf_value.round
	json.employeer_pf_value 			employeer_pf_value.round
	json.total_contribution				(employee_pf_value + employeer_pf_value).round
	json.net_payable							(pay_invoice.total_earning - (pay_invoice.total_deduction.round + pay_invoice.monthly_tax.round)).round
end