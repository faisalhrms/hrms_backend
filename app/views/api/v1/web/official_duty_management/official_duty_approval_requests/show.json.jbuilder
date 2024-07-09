json.official_duty_approval_request do
	json.id 							@official_duty_approval_request.id
	if @official_duty_approval_request.requestable_type == "OfficialDuty"
		official_duty = 			OfficialDuty.find(@official_duty_approval_request.requestable_id)
		json.request_type 		"OD"
		json.request_status		official_duty.request_status
		json.employee_id			official_duty.employee_id
		json.employee_name		official_duty.employee_name
		json.employee_code		official_duty.employee_code
		json.request_count		official_duty.request_count
		json.reason						official_duty.reason
		json.apply_date				ReportFormat.date_format(official_duty.created_at)
		json.start_date				ReportFormat.date_format(official_duty.start_date)
		json.end_date					ReportFormat.date_format(official_duty.end_date)
	end
end