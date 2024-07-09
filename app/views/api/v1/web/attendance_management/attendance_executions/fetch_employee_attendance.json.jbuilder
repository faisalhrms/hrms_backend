json.employee_attendances @date_range.each do |single_date|
	employee_attendance = EmployeeAttendance.find_by(:employee_id => params[:employee_id], :attendance_date => single_date)
	if employee_attendance.nil?	
		json.attendance_status					"No Record"
		json.in_time 										nil
		json.out_time 									nil
		json.office_in_time 						nil
		json.office_out_time 						nil
		json.attendance_date 						ReportFormat.date_format1(single_date)
	else
		json.employee_attendance_id 		employee_attendance.id
		json.attendance_status					employee_attendance.attendance_status
		if employee_attendance.in_time.nil?
			json.in_time nil
		else
			json.in_time employee_attendance.in_time.to_datetime.strftime("%d-%b-%Y %H:%M")
		end
		if employee_attendance.out_time.nil?
			json.out_time nil
		else
			json.out_time employee_attendance.out_time.to_datetime.strftime("%d-%b-%Y %H:%M")
		end
		if employee_attendance.office_in_time.nil?
			json.office_in_time 					nil
		else
			json.office_in_time 					employee_attendance.office_in_time.to_datetime.strftime("%d-%b-%Y %H:%M")
		end
		if employee_attendance.office_out_time.nil?
			json.office_out_time 					nil
		else
			json.office_out_time 					employee_attendance.office_out_time.to_datetime.strftime("%d-%b-%Y %H:%M")
		end
		json.attendance_date 						ReportFormat.date_format1(employee_attendance.attendance_date)
	end
end