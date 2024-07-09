json.employee_tax_adjustment do
	json.id 																@employee_tax_adjustment.try(:id)
	json.combine_name 											"#{@employee_tax_adjustment.employee_code} | #{@employee_tax_adjustment.employee_name}"
	json.employee_name 											@employee_tax_adjustment.employee_name
	json.employee_code 											@employee_tax_adjustment.employee_code
	json.employee_id												@employee_tax_adjustment.try(:employee_id)
	json.company_id													@employee_tax_adjustment.try(:company_id)
	json.is_active													@employee_tax_adjustment.try(:is_active)
	json.tax_adjustment_month								@employee_tax_adjustment.try(:tax_adjustment_month)
	json.tax_adjustment_formatted_month			@employee_tax_adjustment.try(:tax_adjustment_formatted_month)
	json.amount															@employee_tax_adjustment.try(:amount)
	json.reason															@employee_tax_adjustment.try(:reason)
end