index_count = 0
json.approval_requests @approval_requests.each do |approval_request|
	json.id 							approval_request.id
	if approval_request.requestable_type == "LeaveRequest"
		json.index_value			index_count
		leave_request = 			LeaveRequest.find(approval_request.requestable_id)
		json.request_type 		"Leave"
		json.request_status		approval_request.approval_request_status
		json.employee_name		leave_request.employee_name
		json.employee_code		leave_request.employee_code
		json.request_count		leave_request.request_count
		json.apply_date				ReportFormat.date_format(leave_request.created_at)
		json.start_date				ReportFormat.date_format(leave_request.start_date)
		json.end_date					ReportFormat.date_format(leave_request.end_date)
		index_count = index_count + 1
	elsif approval_request.requestable_type == "OfficialDuty"
		json.index_value			index_count
		official_duty = 			OfficialDuty.find(approval_request.requestable_id)
		json.request_type 		"OD"
		json.request_status		approval_request.approval_request_status
		json.employee_name		official_duty.employee_name
		json.employee_code		official_duty.employee_code
		json.request_count		official_duty.request_count
		json.apply_date				ReportFormat.date_format(official_duty.created_at)
		json.start_date				ReportFormat.date_format(official_duty.start_date)
		json.end_date					ReportFormat.date_format(official_duty.end_date)
		index_count = index_count + 1
	elsif approval_request.requestable_type == "RelaxationRequest"
		json.index_value			index_count
		relaxation = 					RelaxationRequest.find(approval_request.requestable_id)
		json.request_type 		"Relaxation"
		json.request_status		approval_request.approval_request_status
		json.employee_name		relaxation.employee_name
		json.employee_code		relaxation.employee_code
		json.request_count		relaxation.request_count
		json.apply_date				ReportFormat.date_format(relaxation.created_at)
		json.start_date				ReportFormat.date_format(relaxation.start_date)
		json.end_date					ReportFormat.date_format(relaxation.end_date)
  elsif approval_request.requestable_type == 'CplEarning'
		json.index_value			index_count
		cpl_earning = 	CplEarning.find(approval_request.requestable_id)
    json.request_type 		'Cpl'
    json.request_status		approval_request.approval_request_status
    json.employee_code         cpl_earning.employee.employee_code
    json.employee_name         cpl_earning.employee_name
    json.apply_date   cpl_earning.created_at.to_date.strftime("%B %d, %Y")
    json.start_date				ReportFormat.date_format(cpl_earning.employee_attendance.attendance_date)
    json.end_date				ReportFormat.date_format(cpl_earning.employee_attendance.attendance_date)
    index_count = index_count + 1
	end
end