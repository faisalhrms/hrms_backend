json.employee_arrears @employee_arrears.each do |employee_arrear|
	json.id 						employee_arrear.try(:id)
	json.employee_name	employee_arrear.employee_name
	json.employee_code	employee_arrear.employee_code
	json.arrear_days 		employee_arrear.try(:arrear_days)
	json.arrear_type 		employee_arrear.try(:arrear_type)
	json.arrear_kind 		employee_arrear.try(:arrear_kind)
	json.arrears_month 	ReportFormat.date_format(employee_arrear.arrears_month)
	json.status 				employee_arrear.try(:status)
end