json.relaxation_approval_request do
	json.id 							@relaxation_approval_request.id
	if @relaxation_approval_request.requestable_type == "RelaxationRequest"
		relaxation_request = RelaxationRequest.find(@relaxation_approval_request.requestable_id)
		json.request_type 					"Relaxation"
		json.request_status					relaxation_request.request_status
		json.attendance_type_name		relaxation_request.attendance_type_name
		json.employee_id						relaxation_request.employee_id
		json.employee_name					relaxation_request.employee_name
		json.employee_code					relaxation_request.employee_code
		json.request_count					relaxation_request.request_count
		json.reason									relaxation_request.reason
		json.apply_date							ReportFormat.date_format(relaxation_request.created_at)
		json.start_date							ReportFormat.date_format(relaxation_request.start_date)
		json.end_date								ReportFormat.date_format(relaxation_request.end_date)
	end
end