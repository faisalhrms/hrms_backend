date_ranges = (params[:start_date].to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}		
json.date_range date_ranges.each do |single_date|
	json.selected_date ReportFormat.date_format2(single_date)
end

employee_ids = @employee_attendances.collect(&:employee_id).uniq
employees = Employee.where(:id => employee_ids, :excluded_from_reports => false).order('employee_code ASC')
json.attendance_list employees.each do |employee|
	if employee.is_active == true && employee.salary_exempted == false
		json.employee_code 			employee.employee_code
		json.employee_name 			employee.full_name
		json.grade_name 				employee.grade_name
		json.designation_name 	employee.designation_name
		json.employee_attendances Array.new(date_ranges.count).each_index do |index|
			employee_attendance = @employee_attendances.find_by(:employee_id => employee.id, :attendance_date => date_ranges[index].to_date)
			if not employee_attendance.nil?
				if employee_attendance.is_rest_day == true
					if employee_attendance.in_time.nil?
						json.attendance_status employee_attendance.attendance_status		
					else
						json.attendance_status "Present"
					end
				elsif employee_attendance.is_public_holiday == true
					if employee_attendance.in_time.nil?
						json.attendance_status employee_attendance.attendance_status		
					else
						json.attendance_status "Present"
					end
				else
					json.attendance_status employee_attendance.attendance_status
				end
			else
				json.attendance_status "-"
			end
		end
	end
end