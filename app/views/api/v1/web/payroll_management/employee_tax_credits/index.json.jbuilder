json.employee_tax_credits @employee_tax_credits.each do |employee_tax_credit|
	json.id 														employee_tax_credit.try(:id)
	json.combine_name 									"#{employee_tax_credit.employee_code} | #{employee_tax_credit.employee_name}"
	json.employee_name 									employee_tax_credit.employee_name
	json.employee_code 									employee_tax_credit.employee_code
	json.tax_credit_amount							employee_tax_credit.tax_credit_amount
	json.tax_credit_formatted_month 		employee_tax_credit.try(:tax_credit_formatted_month)
end