employee_codes = @employee_attendances.collect(&:employee_code).uniq.map(&:to_i).sort
json.employee_attendances employee_codes.each do |employee_code|	
	employee = Employee.find_by_employee_code(employee_code)
	if not employee.nil?
		if employee.is_active == true && employee.salary_exempted == false && employee.excluded_from_reports == false
			json.employee_code 			employee.employee_code
			json.employee_name 			employee.full_name
			json.location_name 			employee.location_name
			json.branch_name 				employee.branch_name
			json.grade_name 				employee.grade_name
			json.designation_name 	employee.designation_name
			if params[:as_on_month] == 'false'
				if not employee.joining_date.nil?
					if employee.joining_date.to_date <= params[:start_date].to_date
						start_date  = params[:start_date].to_date
						date_range = (start_date.to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
						date_range = date_range.count
					else
						end_date = params[:end_date].to_date
						date_range = (employee.joining_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
						date_range = date_range.count
					end
				else
					start_date  = params[:start_date].to_date
					date_range = (start_date.to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
					date_range = date_range.count
				end
			else
				if not employee.joining_date.nil?
					if employee.joining_date.to_date <= params[:start_date].to_date
						date_range = params[:end_date].to_date.end_of_month.day.to_f
					else
						if employee.joining_date.to_date <= (params[:start_date].to_date).to_date
							date_range = params[:end_date].to_date.end_of_month.day.to_f
						else
							date_range = (TimeDifference.between(employee.joining_date.to_date, params[:end_date].to_date.end_of_month).in_days) + 1	
						end
					end
				else
					date_range = 0
				end
			end
			arrear_days 					= EmployeeArrear.where(:employee_id => employee.id).where("arrears_month >= ? AND arrears_month <= ?", params[:start_date].to_date, params[:end_date].to_date).sum(:arrear_days).to_f.round(2)
			deduction_days        = EmployeeDeduction.where(:employee_id => employee.id).where("deductions_month >= ? AND deductions_month <= ?", params[:start_date].to_date, params[:end_date].to_date).sum(:deduction_days).to_f.round(2)
			pay_deduction 				= @employee_attendances.where(:employee_id => employee.id, :deduction_from_salary => true).sum(:pay_deduction)
			pay_deduction 				= pay_deduction + deduction_days
			working_days 					= date_range - pay_deduction.to_f.round(2)
			json.no_of_late 			@employee_attendances.where(:attendance_status => "Late", :employee_id => employee.id).count
			json.no_of_half_day 	@employee_attendances.where(:attendance_status => "Half Day", :employee_id => employee.id).count
			json.no_of_absent 		@employee_attendances.where(:attendance_status => "Absent", :employee_id => employee.id).count
			json.month_days 			date_range
			json.arrear 					arrear_days
			json.over_time 				@employee_attendances.where(:employee_id => employee.id).sum(:over_time_hours)
			json.cpl_earned 			@employee_attendances.where(:employee_id => employee.id).sum("no_of_cpl")
			json.off_days 				@employee_attendances.where(:employee_id => employee.id).sum("off_days_payment_days")
			json.worked_days 			working_days.to_f.round(2)
			json.total_pay_days 	(working_days.to_f.round(2) + @employee_attendances.where(:employee_id => employee.id).sum("off_days_payment_days")).round(2) + arrear_days.to_f.round(2)
			json.leave_avalied 		@employee_attendances.where(:is_on_leave => true, :employee_id => employee.id).count
			json.leave_deduction 	LeaveRequest.where("start_date >= ? AND end_date <= ?", params[:start_date].to_date, params[:end_date].to_date).where(:is_cancelled => false, :request_status => "System Deducted", :employee_id => employee.id).sum(:request_count)
			json.pay_deduction 		pay_deduction
			json.encashable_quota @employee_attendances.where(:employee_id => employee.id).sum(:encashable_quota)
		end
	end
end
