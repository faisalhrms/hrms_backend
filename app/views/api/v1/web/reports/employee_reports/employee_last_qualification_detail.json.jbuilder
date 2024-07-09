json.employees @employees.each do |employee|
  if @employee_qualifications.where(:employee_id => employee.id).count > 0
		employee_qualification = @employee_qualifications.where(:employee_id => employee.id).first
		json.employee_code 											employee_qualification.employee_code
		json.full_name 													employee_qualification.employee_name
		json.institute_name 										ReportFormat.non_text_to_dash(employee_qualification.institute_name)
		json.qualification_level 								ReportFormat.non_text_to_dash(employee_qualification.qualification_level)
		json.program_name 											ReportFormat.non_text_to_dash(employee_qualification.program_name)
		json.specialization_name 								ReportFormat.non_text_to_dash(employee_qualification.specialization_name)
		json.status 														ReportFormat.non_text_to_dash(employee_qualification.status)
		json.start_date 												ReportFormat.date_only_year(employee_qualification.start_date)
		json.end_date 													ReportFormat.date_only_year(employee_qualification.end_date)
		if employee_qualification.status == "Grade" or employee_qualification.status == "Pass/Fail" or employee_qualification.status == "Division"
			json.achievement 											ReportFormat.non_text_to_dash(employee_qualification.status_text)
		elsif employee_qualification.status == "GPA" or employee_qualification.status == "Percentage"
			json.achievement 											ReportFormat.non_float_to_dash(employee_qualification.gpa_or_percentage)
		else
			json.achievement 											"-"
		end
	end
end