json.sale_incentives @sale_incentives.each do |sale_incentive|
	employee = Employee.find(sale_incentive.employee_id)
	json.employee_code 			employee.employee_code
	json.employee_name 			employee.full_name
	json.grade_name 				employee.grade_name
	json.designation_name 	employee.designation_name
	json.month_days 				sale_incentive.month_days.round(2)
	json.gross_salary 			sale_incentive.gross_salary.round(2)
	json.per_day_salary 		sale_incentive.per_day_salary.round(2)
	json.present_days 			sale_incentive.present_days.round(2)
	json.propionate 				sale_incentive.propionate.round(2)
	json.incentive_amount 	sale_incentive.incentive_amount.round(2)
	json.present_day_salary sale_incentive.present_day_salary.round(2)
end

json.total_detail do
	json.total_gross_salary 				@sale_incentives.sum(:gross_salary).to_f.round(2)
	json.total_present_day_salary 	@sale_incentives.sum(:present_day_salary).to_f.round(2)
	json.total_incentive_amount 		@sale_incentives.sum(:incentive_amount).to_f.round(2)
	json.total_proionate_ratio 			@sale_incentives.sum(:propionate).to_f.round(2)
end