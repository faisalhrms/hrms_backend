json.official_duty_requests @resulted_data.each do |official_duty_request|
	json.id 											official_duty_request.try(:id)
	json.employee_name						official_duty_request.employee_name
	json.employee_code						official_duty_request.employee_code
	json.request_count						official_duty_request.request_count
	json.request_status						official_duty_request.request_status
	json.official_duty_mode			official_duty_request.normalized_official_duty_mode
	json.apply_status							official_duty_request.apply_status
	json.request_sender_name			official_duty_request.request_sender_name
	json.apply_date								ReportFormat.date_format(official_duty_request.created_at)
	json.start_date								ReportFormat.date_format(official_duty_request.start_date)
	json.end_date									ReportFormat.date_format(official_duty_request.end_date)
	json.approval_name 						official_duty_request.approval_name
	json.approval_datetime 				ReportFormat.complete_datetime_format(official_duty_request.approval_datetime)
end
