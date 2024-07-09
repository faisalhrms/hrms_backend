json.relaxation_approvals @relaxation_approvals.each do |relaxation_approval|
	json.id 								relaxation_approval.id
	if relaxation_approval.requestable_type == "RelaxationRequest"
		relaxation_request = RelaxationRequest.find(relaxation_approval.requestable_id)
		json.request_type 					"Relaxation"
		json.request_status					relaxation_approval.approval_request_status
		json.employee_name					relaxation_request.employee_name
		json.employee_code					relaxation_request.employee_code
		json.request_count					relaxation_request.request_count
		json.apply_date							ReportFormat.date_format(relaxation_request.created_at)
		json.start_date							ReportFormat.date_format(relaxation_request.start_date)
		json.end_date								ReportFormat.date_format(relaxation_request.end_date)
	end
end