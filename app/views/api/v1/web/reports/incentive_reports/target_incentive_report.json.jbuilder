json.target_incentives @target_incentives.each do |target_incentive|
	employee = Employee.find(target_incentive.employee_id)
	json.employee_code 			employee.employee_code
	json.employee_name 			employee.full_name
	json.grade_name 				employee.grade_name
	json.designation_name 	employee.designation_name
	json.month_days 				target_incentive.month_days.round(2)
	json.gross_salary 			target_incentive.gross_salary.round(2)
	json.per_day_salary 		target_incentive.per_day_salary.round(2)
	json.present_days 			target_incentive.present_days.round(2)
	json.propionate 				target_incentive.propionate.round(2)
	json.incentive_amount 	target_incentive.incentive_amount.round(2)
	json.present_day_salary target_incentive.present_day_salary.round(2)
end

json.total_detail do
	json.total_gross_salary 				@target_incentives.sum(:gross_salary).to_f.round(2)
	json.total_present_day_salary 	@target_incentives.sum(:present_day_salary).to_f.round(2)
	json.total_incentive_amount 		@target_incentives.sum(:incentive_amount).to_f.round(2)
	json.total_proionate_ratio 			@target_incentives.sum(:propionate).to_f.round(2)
end