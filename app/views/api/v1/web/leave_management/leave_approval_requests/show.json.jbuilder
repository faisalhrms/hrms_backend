json.leave_approval_request do
	json.id 							@leave_approval_request.id
	if @leave_approval_request.requestable_type == "LeaveRequest"
		leave_request = 			LeaveRequest.find(@leave_approval_request.requestable_id)
		json.request_type 		"Leave"
		json.request_status		leave_request.request_status
		json.leave_category		leave_request.leave_category
		json.leave_type_name	leave_request.leave_type_name
		json.employee_id			leave_request.employee_id
		json.employee_name		leave_request.employee_name
		json.employee_code		leave_request.employee_code
		json.request_count		leave_request.request_count
		json.reason						leave_request.reason
		json.apply_date				ReportFormat.date_format(leave_request.created_at)
		json.start_date				ReportFormat.date_format(leave_request.start_date)
		json.end_date					ReportFormat.date_format(leave_request.end_date)
	end
end