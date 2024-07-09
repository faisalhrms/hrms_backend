json.attendance_exceptions @attendance_exceptions.each do |attendance_exception|
	json.id 												attendance_exception.try(:id)
	if attendance_exception.salary_unit_wise == true
		json.location_name 							"-"
		json.branch_name								"-"
		json.salary_unit_name						attendance_exception.salary_unit_name	
	else
		json.location_name 							attendance_exception.location_name
		json.branch_name								attendance_exception.branch_name
		json.salary_unit_name						"-"
	end
	json.name 											attendance_exception.try(:name)
	json.attendance_exception_type 	attendance_exception.try(:attendance_exception_type)
	json.start_date 								ReportFormat.date_format(attendance_exception.start_date)
	json.end_date 									ReportFormat.date_format(attendance_exception.end_date)
end