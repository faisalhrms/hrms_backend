json.employees @employees.each do |employee|
	json.employee_code 						employee.employee_code
	json.full_name 								employee.full_name
	json.official_email						ReportFormat.non_text_to_dash(employee.official_email)
	json.official_mobile_number		ReportFormat.phone_format(employee.official_mobile_number)
	json.personal_email						ReportFormat.non_text_to_dash(employee.personal_email)
	json.personal_number					ReportFormat.phone_format(employee.personal_number)
	json.current_address					ReportFormat.non_text_to_dash(employee.current_address)
	json.permanent_address				ReportFormat.non_text_to_dash(employee.permanent_address)
	json.emergency_contact_name		ReportFormat.non_text_to_dash(employee.emergency_contact_name)
	json.emergency_contact_email	ReportFormat.non_text_to_dash(employee.emergency_contact_email)
	json.emergency_contact_phone	ReportFormat.phone_format(employee.emergency_contact_phone)
	json.relationship_name				employee.relationship_name
end