json.approval_request do
	json.id 							@approval_request.id
	if @approval_request.requestable_type == "LeaveRequest"
		leave_request = 			LeaveRequest.find(@approval_request.requestable_id)
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
	elsif @approval_request.requestable_type == "OfficialDuty"
		official_duty = 			OfficialDuty.find(@approval_request.requestable_id)
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
  elsif @approval_request.requestable_type == 'CplEarning'
    cpl_earning = 			CplEarning.find(@approval_request.requestable_id)
    json.request_type 		'Cpl'
    json.request_status		@approval_request.approval_request_status
    json.employee_id			cpl_earning.employee_id
    json.employee_name		cpl_earning.employee_name
    json.employee_code		cpl_earning.employee.employee_code
    json.reason						cpl_earning.reason
    json.apply_date				ReportFormat.date_format(cpl_earning.created_at)
    json.start_date				ReportFormat.date_format(cpl_earning.employee_attendance.attendance_date)
    json.end_date					ReportFormat.date_format(cpl_earning.employee_attendance.attendance_date)
    json.in_time					cpl_earning.employee_attendance.in_time
    json.out_time					cpl_earning.employee_attendance.out_time
    served_hours = TimeDifference.between(cpl_earning.employee_attendance.in_time, cpl_earning.employee_attendance.out_time).in_hours
    json.served_hours  Time.at(served_hours * 60 * 60).utc.strftime('%H:%M')
  elsif @approval_request.requestable_type == "RelaxationRequest"
		relaxation = 								RelaxationRequest.find(@approval_request.requestable_id)
		json.request_type 					"Relaxation"
		json.request_status					relaxation.request_status
		json.employee_id						relaxation.employee_id
		json.employee_name					relaxation.employee_name
		json.employee_code					relaxation.employee_code
		json.request_count					relaxation.request_count
		json.attendance_type_name		relaxation.attendance_type_name
		json.reason									relaxation.reason
		json.apply_date							ReportFormat.date_format(relaxation.created_at)
		json.start_date							ReportFormat.date_format(relaxation.start_date)
		json.end_date								ReportFormat.date_format(relaxation.end_date)
	end
end