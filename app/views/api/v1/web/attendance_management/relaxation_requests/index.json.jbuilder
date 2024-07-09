json.relaxation_requests @relaxation_requests.each do |relaxation_request|
	json.id 										relaxation_request.try(:id)
	json.employee_name					relaxation_request.employee_name
	json.employee_code					relaxation_request.employee_code
	json.request_count					relaxation_request.request_count
  json.criteria      					RequestFlow.last.criteria
  json.request_status					relaxation_request.request_status
	json.apply_status						relaxation_request.apply_status
	json.request_sender_name		relaxation_request.request_sender_name
	json.attendance_type_name 	relaxation_request.attendance_type_name
	json.apply_date							ReportFormat.date_format(relaxation_request.created_at)
	json.start_date							ReportFormat.date_format(relaxation_request.start_date)
	json.end_date								ReportFormat.date_format(relaxation_request.end_date)
  json.relaxation_start_date	ReportFormat.date_format(relaxation_request.relaxation_start_date)
  json.relaxation_end_date		ReportFormat.date_format(relaxation_request.relaxation_end_date)
	json.approval_name 					relaxation_request.approval_name
  json.approval_datetime 			ReportFormat.complete_datetime_format(relaxation_request.approval_datetime)
end
json.back_date_data do
  @request_flow = RequestFlow.find_by(:company_id => 1,:id => 3)
  if @request_flow.back_date_apply == true
    json.min_apply_date 					(Time.now - @request_flow.back_date_limit.day).to_date
  else
    json.min_apply_date 					(Time.now - 60.day).to_date
  end
end
json.criteria_data do
  json.criteria 					@request_flow.criteria
end