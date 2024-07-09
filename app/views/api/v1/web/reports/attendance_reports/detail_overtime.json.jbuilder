json.employee_list @employees.each do |employee|
	total_served_hours_in_seconds 	= 0
	total_overtime_hours_in_seconds = 0
	total_actual_total_earned_hours = 0
	total_approved_overtime_hours_in_seconds = 0
	json.employee_attendances @employee_attendances.where(:employee_id => employee.id, :attendance_date => params[:start_date].to_date..params[:end_date].to_date).order('attendance_date ASC').each do |employee_attendance|
		json.employee_code 			employee.employee_code
		json.employee_name 			employee.full_name
		json.designation_name 	employee.designation_name
		json.job_title_name 		employee.job_title_name
		json.employee_type_name 	employee.employee_type_name
		json.gross_salary 				employee_attendance.employee.gross_salary
		if not employee_attendance.in_time.nil?
			if not employee_attendance.out_time.nil?
				served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
				total_served_hours_in_seconds = total_served_hours_in_seconds + (served_hours * 60 * 60)
				json.working_hours					Time.at(served_hours * 60 * 60).utc.strftime("%H:%M")
			else
				json.working_hours					"-"
			end
		else
			json.working_hours						"-"
		end
		if employee_attendance.approval_base_overtime == false
			if employee_attendance.over_time_hours > 0
				total_overtime_hours_in_seconds = total_overtime_hours_in_seconds + (employee_attendance.over_time_hours * 60 * 60)
				total_actual_total_earned_hours = total_actual_total_earned_hours + (employee_attendance.over_time_hours * 60 * 60)
				total_approved_overtime_hours_in_seconds = total_approved_overtime_hours_in_seconds + (employee_attendance.over_time_hours * 60 * 60)
				json.over_time_hours						Time.at(employee_attendance.over_time_hours * 60 * 60).utc.strftime("%H:%M")
				json.actual_total_earned_hours	Time.at(employee_attendance.over_time_hours * 60 * 60).utc.strftime("%H:%M")
				json.approved_overtime					Time.at(employee_attendance.over_time_hours * 60 * 60).utc.strftime("%H:%M")
			else
				json.over_time_hours						"-"
				json.actual_total_earned_hours	"-"
				json.approved_overtime					"-"
			end
		else
      json.actual_total_earned_hours	"-"
			if employee_attendance.approved_overtime > 0
				total_approved_overtime_hours_in_seconds = total_approved_overtime_hours_in_seconds + (employee_attendance.approved_overtime * 60 * 60)
				json.approved_overtime					Time.at(employee_attendance.approved_overtime * 60 * 60).utc.strftime("%H:%M")
			else
				json.approved_overtime					"-"
			end
		end
		json.attendance_date 						ReportFormat.date_format(employee_attendance.attendance_date)
		if employee_attendance.in_time.nil?
			json.in_time 										"-"
		else
			json.in_time 									employee_attendance.in_time.to_datetime.strftime("%-l:%M %P")
		end
		if employee_attendance.out_time.nil?
			json.out_time 									"-"
		else
			json.out_time 								employee_attendance.out_time.to_datetime.strftime("%-l:%M %P")
		end
	end
	json.total_working_hours 							Time.at(total_served_hours_in_seconds * 60 * 60).utc.strftime("%H:%M")
	json.total_overtime_hours 						ReportFormat.overtime_value_into_overtime_hours(total_overtime_hours_in_seconds)
	json.total_actual_total_earned_hours 	ReportFormat.overtime_value_into_overtime_hours(total_actual_total_earned_hours)
	json.total_approved_overtime_hours_in_seconds ReportFormat.overtime_value_into_overtime_hours(total_approved_overtime_hours_in_seconds)
end