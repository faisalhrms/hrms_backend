json.leave_requests @resulted_data.find_each(batch_size: 10000) do |leave_request|
	json.id 									leave_request.try(:id)
	json.leave_type_name			leave_request.leave_type_name
	json.employee_name				leave_request.employee_name
	json.employee_code				leave_request.employee_code
	json.request_count				leave_request.request_count
	json.request_status				leave_request.request_status
	json.apply_status					leave_request.apply_status
	json.request_sender_name 	leave_request.request_sender_name
	json.apply_date						ReportFormat.date_format(leave_request.created_at)
	json.start_date						ReportFormat.date_format(leave_request.start_date)
	json.end_date							ReportFormat.date_format(leave_request.end_date)
	json.approval_name 				leave_request.approval_name
	json.approval_datetime 		ReportFormat.complete_datetime_format(leave_request.approval_datetime)
end