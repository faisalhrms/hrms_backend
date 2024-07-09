json.department_wise_salaries @departments.each do |department|
	json.department_name      department.name
	depatment_wise_pay_invoices = @pay_invoices.where(:department_id => department.id).order('employee_id ASC')
	json.salary_detail depatment_wise_pay_invoices.each do |pay_invoice|
		employee = pay_invoice.employee
		if not employee.nil?
			json.employee_code 			employee.employee_code
			json.employee_name 			employee.full_name
			json.father_name 				employee.father_name
			json.designation_name 	employee.designation_name
			json.joining_date 			ReportFormat.date_format(employee.joining_date)
			json.closing_date 			ReportFormat.date_format(pay_invoice.pay_execution.created_at)
			json.service_month 			ReportFormat.month_difference(employee.joining_date, pay_invoice.actual_pay_month)
			json.no_of_absent 			pay_invoice.deduction_days.to_f
			json.gross_salary				pay_invoice.actual_salary.to_f
			json.month_days					pay_invoice.pay_execution.total_pay_days(employee).to_f
			json.total_pay_days			pay_invoice.pay_execution.total_pay_days(employee).to_f - pay_invoice.short_joining_days.to_f
			json.incentive_amount		pay_invoice.pay_invoice_details.where(:item_name => ["Incentive Amount"]).sum(:amount).round
			json.earned_salary			pay_invoice.pay_invoice_details.where(:item_name => ["Basic Salary", "House Rent", "Utility Allowance"]).sum(:amount).round
			json.total_salary				pay_invoice.total_earning.round
			json.income_tax					pay_invoice.monthly_tax.round	
			json.other_deduction 		pay_invoice.pay_invoice_details.where(:item_name => ["Other Deduction"]).sum(:amount).round
			json.mobile_amount			pay_invoice.pay_invoice_details.where(:item_name => ["Mobile"]).sum(:amount).round
			json.loan_advance 			pay_invoice.pay_invoice_details.where(:item_name => ["Loan & Advance"]).sum(:amount).round
			json.vehicle_deduction 	pay_invoice.pay_invoice_details.where(:item_name => ["Vehicle Deduction"]).sum(:amount).round
			json.eobi_amount 				pay_invoice.pay_invoice_details.where(:item_name => ["EOBI"]).sum(:amount).round
			json.other_amount 			pay_invoice.pay_invoice_details.where(:item_name => ["Other Amount"]).sum(:amount).round
			json.total_deduction 		pay_invoice.total_deduction.round
			json.net_salary 				(pay_invoice.total_earning - (pay_invoice.total_deduction.round + pay_invoice.monthly_tax.round)).round
			json.account_number 		employee.bank_account_number
		end
	end
end






