total_approved_hours = 0
index_value = 0
json.employee_attendances @employee_attendances.each do |employee_attendance|
	if employee_attendance.actual_overtime_hours > 0
		json.employee_attendance_id 				employee_attendance.id
		json.employee_code 									employee_attendance.employee_code
		json.employee_name 									employee_attendance.employee_full_name
		json.grade_name 										employee_attendance.grade_name
		json.department_name 								employee_attendance.department_name
		json.attendance_date 								ReportFormat.date_format1(employee_attendance.attendance_date)
		json.is_ot_approved 								employee_attendance.is_ot_approved
    json.index_value										index_value
    index_value += 1
		if employee_attendance.is_public_holiday == true
			json.day_status 					"Public Day"
		elsif employee_attendance.is_rest_day == true
			json.day_status 					"Rest Day"
		else
			json.day_status 					"Working Day"
		end
		if employee_attendance.is_ot_approved == false
			if employee_attendance.actual_overtime_hours > 0
				json.actual_overtime_hours				Time.at(employee_attendance.actual_overtime_hours * 60 * 60).utc.strftime("%H:%M")
				json.is_ot 												true
			else
				json.actual_overtime_hours				"-"
				json.is_ot 												false
			end
			if employee_attendance.actual_overtime_hours > 0
				json.approved_earned_overtime_hours			Time.at(employee_attendance.actual_overtime_hours * 60 * 60).utc.strftime("#{employee_attendance.attendance_date.strftime('%d-%b-%Y')} %H:%M")
			else	
				json.approved_earned_overtime_hours			"-"
			end
		else
			if employee_attendance.actual_overtime_hours > 0
				json.actual_overtime_hours				Time.at(employee_attendance.actual_overtime_hours * 60 * 60).utc.strftime("%H:%M")
				json.is_ot 												true
			else
				json.actual_overtime_hours				"-"
				json.is_ot 												false
			end
			if employee_attendance.approved_overtime_hours > 0
				# first_value = employee_attendance.approved_overtime_hours.to_s.split('.')[0]
				# last_value 	= (employee_attendance.approved_overtime_hours.to_s.split('.')[1].to_f/2.0).to_i
				# if employee_attendance.approved_overtime_hours >= 24
				# 	json.approved_earned_overtime_hours			"#{first_value}:#{last_value}"
				# else
				# 	json.approved_earned_overtime_hours			Time.at(employee_attendance.approved_overtime_hours * 60 * 60).utc.strftime("%H:%M")	
				# end
				json.approved_earned_overtime_hours			ReportFormat.overtime_value_into_overtime_hours(employee_attendance.approved_overtime_hours * 60 * 60)
			else
				json.approved_earned_overtime_hours			"-"
			end
			if employee_attendance.approved_overtime > 0
				total_approved_hours = total_approved_hours + employee_attendance.approved_overtime
				# first_value = employee_attendance.approved_overtime.to_s.split('.')[0]
				# last_value 	= (employee_attendance.approved_overtime.to_s.split('.')[1].to_f/2.0).to_i
				# if employee_attendance.approved_overtime_hours >= 24
				# 	json.approved_overtime			"#{first_value}:#{last_value}"
				# else
				# 	json.approved_overtime			Time.at(employee_attendance.approved_overtime_hours * 60 * 60).utc.strftime("%H:%M")	
				# end
				json.approved_overtime					ReportFormat.overtime_value_into_overtime_hours(employee_attendance.approved_overtime_hours * 60 * 60)
			else
				json.approved_overtime					"-"
			end
		end
	end
end

if total_approved_hours > 0
	json.total_approved_hours_value 	total_approved_hours.to_f.round(2)
	json.total_approved_hours					ReportFormat.overtime_value_into_overtime_hours(total_approved_hours * 60 * 60)
else
	json.total_approved_hours 				"-"
	json.total_approved_hours_value 	0
end



