employee_ids = @employee_attendances.collect(&:employee_id).uniq
employees = Employee.where(:id => employee_ids).order('employee_code ASC')
json.employee_attendances employees.each do |employee|
	json.attendance_list @employee_attendances.where(:employee_id => employee.id).order('attendance_date ASC').each do |employee_attendance|
		json.employee_code 				employee_attendance.employee.employee_code
		json.employee_name 				employee_attendance.employee.full_name
		json.location_name 				employee_attendance.employee.location_name
		json.branch_name 					employee_attendance.employee.branch_name
		json.grade_name 					employee_attendance.employee.grade_name
		json.designation_name 		employee_attendance.employee.designation_name
		json.employee_type_name 	employee_attendance.employee.employee_type_name
		if not employee_attendance.in_time.nil?
			if not employee_attendance.out_time.nil?
				served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
				if employee_attendance.employee_roster.break_effect == "Exclusive"
	  		json.working_hours					Time.at(served_hours * 60 * 60).utc.strftime("%H:%M")
			else
				json.working_hours					"-"
			end
		else
			json.working_hours						"-"
		end
		if employee_attendance.over_time_hours > 0
			json.over_time_hours					Time.at(employee_attendance.over_time_hours * 60 * 60).utc.strftime("%H:%M")
		else
			json.over_time_hours					"-"
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
		if employee_attendance.employee_roster.nil?
			json.shift_name 							"No Roster Assinged"
			json.shift_timing 						"No Roster Assinged"
		else
			json.shift_name								employee_attendance.employee_roster.time_slot_name
			json.shift_timing 						"#{employee_attendance.employee_roster.formated_start_time} #{employee_attendance.employee_roster.formated_end_time}"
		end
		json.attendance_status					employee_attendance.attendance_status
		if employee_attendance.is_rest_day == true
			json.rest_day 								employee_attendance.attendance_date.to_date.strftime("%A")	
		else
			json.rest_day 								"-"
		end
	end
end