json.employee_arrear do
	json.id 						@employee_arrear.try(:id)
	json.employee_name	@employee_arrear.employee_name
	json.employee_code	@employee_arrear.employee_code
	json.arrear_days 		@employee_arrear.try(:arrear_days)
	json.arrear_type 		@employee_arrear.try(:arrear_type)
	json.arrears_month 	@employee_arrear.try(:arrears_month)
	json.arrear_kind 		@employee_arrear.try(:arrear_kind)
end