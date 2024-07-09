json.attendance_list @date_range.each do |single_date|
	temp_staff_attendance = TempStaffAttendance.find_by(:temporary_staff_id => params[:temporary_staff_id], :attendance_date => single_date)
	if temp_staff_attendance.nil?	
		json.attendance_status					"Present"
		json.in_time 										nil
		json.out_time 									nil
		json.attendance_date 						ReportFormat.date_format1(single_date)
	else
		json.temp_staff_attendance_id 	temp_staff_attendance.id
		json.attendance_status					temp_staff_attendance.attendance_status
		if temp_staff_attendance.in_time.nil?
			json.in_time nil
		else
			json.in_time temp_staff_attendance.in_time.to_datetime.strftime("%d-%b-%Y %H:%M")
		end
		if temp_staff_attendance.out_time.nil?
			json.out_time nil
		else
			json.out_time temp_staff_attendance.out_time.to_datetime.strftime("%d-%b-%Y %H:%M")
		end
		json.attendance_date 						ReportFormat.date_format1(temp_staff_attendance.attendance_date)
	end
end