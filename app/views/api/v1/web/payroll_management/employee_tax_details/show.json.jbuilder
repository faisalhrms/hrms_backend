json.employee_taxable_incomes @pay_invoices.each do |pay_invoice|
	employee_taxable_income = pay_invoice.employee_taxable_income
	json.pay_invoice_id 									pay_invoice.id
	json.pay_month 												pay_invoice.pay_month
	json.employee_taxable_income_id 			employee_taxable_income.id
	json.current_taxable_amount 					ReportFormat.verification_of_nan(employee_taxable_income.current_taxable_amount).to_f.round
	json.prev_taxable_amount 							ReportFormat.verification_of_nan(employee_taxable_income.prev_taxable_amount).to_f.round
	json.predicated_taxable_amount 				ReportFormat.verification_of_nan(employee_taxable_income.predicated_taxable_amount).to_f.round
	json.taxable_amount_to_date 					ReportFormat.verification_of_nan(employee_taxable_income.taxable_amount_to_date).to_f.round
	json.total_taxable_amount 						ReportFormat.verification_of_nan(employee_taxable_income.total_taxable_amount).to_f.round
	json.yearly_total_tax 								ReportFormat.verification_of_nan(employee_taxable_income.yearly_total_tax).to_f.round
	json.monthly_tax_amount 							ReportFormat.verification_of_nan(employee_taxable_income.monthly_tax_amount).to_f.round
	json.total_paid_tax 									ReportFormat.verification_of_nan(employee_taxable_income.total_paid_tax).to_f.round
	json.remaing_tax_to_be_paid 					ReportFormat.verification_of_nan(employee_taxable_income.remaing_tax_to_be_paid).to_f.round
	json.prev_vehicle_tax 								ReportFormat.verification_of_nan(employee_taxable_income.prev_vehicle_tax).to_f.round
	json.current_month_vehicle_tax 				ReportFormat.verification_of_nan(employee_taxable_income.current_month_vehicle_tax).to_f.round
	json.predicted_vehicle_tax 						ReportFormat.verification_of_nan(employee_taxable_income.predicted_vehicle_tax).to_f.round
	json.employeer_pf_value 							ReportFormat.verification_of_nan(employee_taxable_income.employeer_pf_value).to_f.round
	json.predicted_pf_value 							ReportFormat.verification_of_nan(employee_taxable_income.predicted_pf_value).to_f.round
	json.pf_tax_value 										ReportFormat.verification_of_nan(employee_taxable_income.pf_tax_value).to_f.round
  json.cpr_date 										    employee_taxable_income.cpr_date.try(:strftime, '%Y-%m-%d')
  json.cpr_number  										  employee_taxable_income.cpr_number
end