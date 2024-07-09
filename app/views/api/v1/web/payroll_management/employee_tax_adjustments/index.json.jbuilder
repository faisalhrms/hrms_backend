json.employee_tax_adjustments @employee_tax_adjustments.each do |employee_tax_adjustment|
	json.id 																employee_tax_adjustment.try(:id)
	json.combine_name 											"#{employee_tax_adjustment.employee_code} | #{employee_tax_adjustment.employee_name}"
	json.employee_name 											employee_tax_adjustment.employee_name
  location = Employee.find_by(employee_code: employee_tax_adjustment.employee_code)
	json.location_name 											location.location_name
	json.employee_code 											employee_tax_adjustment.employee_code
	json.is_active 													employee_tax_adjustment.is_active
	json.amount 														employee_tax_adjustment.amount
	json.tax_adjustment_formatted_month 		employee_tax_adjustment.try(:tax_adjustment_formatted_month)
end