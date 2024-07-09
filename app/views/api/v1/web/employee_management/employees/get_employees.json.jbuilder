json.employees @employees.each do |employee|
	json.id 													employee.id
	json.employee_code 								employee.employee_code
	json.full_name 										employee.full_name
	json.combine_name 								"#{employee.employee_code} | #{employee.full_name}"
	json.location_name 								employee.location_name
	json.branch_name 									employee.branch_name
	json.department_name 							employee.department_name
	json.job_title_name 							employee.job_title_name
	json.grade_name 									employee.grade_name
	json.designation_name 						employee.designation_name
	json.display_joining_date 				ReportFormat.date_format(employee.joining_date)
	json.display_probation_end_date 	ReportFormat.date_format(employee.confimration_due_date)
	json.display_confirmation_date 		ReportFormat.date_format(employee.confirmation_date)
	json.joining_date									employee.joining_date
	json.employee_code								employee.employee_code
	json.prev_employee_code						employee.prev_employee_code
	begin
		json.avatar employee.try(:avatar).url
	  json.avatar_file_name employee.try(:avatar_file_name)
		if employee.avatar_file_name.nil? or employee.avatar_file_name.blank?
	    json.avatar_present false
	  else
	    json.avatar_present true
	  end
	rescue Exception => e
		json.avatar ""
		json.avatar_file_name ""
		json.avatar_present false
	end
end