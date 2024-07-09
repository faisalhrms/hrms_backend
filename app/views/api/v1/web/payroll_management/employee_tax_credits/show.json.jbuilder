json.employee_tax_credit do
	json.id 														@employee_tax_credit.try(:id)
	json.combine_name 									"#{@employee_tax_credit.employee_code} | #{@employee_tax_credit.employee_name}"
	json.employee_name 									@employee_tax_credit.employee_name
	json.employee_code 									@employee_tax_credit.employee_code
	json.employee_id										@employee_tax_credit.try(:employee_id)
	json.company_id											@employee_tax_credit.try(:company_id)
	json.fiscal_year_id									@employee_tax_credit.try(:fiscal_year_id)
	json.tax_credit_month								@employee_tax_credit.try(:tax_credit_month)
	json.tax_credit_formatted_month			@employee_tax_credit.try(:tax_credit_formatted_month)
	json.tax_credit_amount							@employee_tax_credit.try(:tax_credit_amount)
	json.tax_credit_type								@employee_tax_credit.try(:tax_credit_type)
end