json.employees @employees.each do |employee|
  if @employee_experiences.where(:employee_id => employee.id).count > 0
		employee_experience = @employee_experiences.where(:employee_id => employee.id).first
		json.employee_code 									employee_experience.employee_code
		json.full_name 											employee_experience.employee_name
		json.organization 									ReportFormat.non_text_to_dash(employee_experience.organization)
		json.job_title 											ReportFormat.non_text_to_dash(employee_experience.job_title)
		json.left_reason 										ReportFormat.non_text_to_dash(employee_experience.left_reason)
		json.salary 												ReportFormat.non_float_to_dash(employee_experience.salary)
		json.start_date 										ReportFormat.date_format(employee_experience.start_date)
		json.end_date 											ReportFormat.date_format(employee_experience.end_date)
		json.previous_experince 						ReportFormat.employee_previous_experince(employee_experience.employee)
	end
end