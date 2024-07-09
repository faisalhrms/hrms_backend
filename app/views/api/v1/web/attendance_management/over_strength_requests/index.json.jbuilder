json.over_strength_requests @over_strength_requests.each do |over_strength_request|
	json.id 										over_strength_request.try(:id)
	json.employee_name					over_strength_request.employee_name
	json.employee_code					over_strength_request.employee_code
	json.department_name				over_strength_request.department_name
	json.apply_status						over_strength_request.apply_status
	json.request_status					over_strength_request.request_status
	json.request_sender_name		over_strength_request.request_sender_name
	json.request_count					over_strength_request.request_count
	json.apply_date							ReportFormat.date_format(over_strength_request.created_at)
	json.start_date							ReportFormat.date_format(over_strength_request.start_date)
	json.end_date								ReportFormat.date_format(over_strength_request.end_date)
end