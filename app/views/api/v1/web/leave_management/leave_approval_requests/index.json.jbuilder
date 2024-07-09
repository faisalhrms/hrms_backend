json.leave_approvals @leave_approvals.each do |leave_approval|
  json.id 							leave_approval.id
  leave_request = 			leave_approval.requestable
  json.request_type 		'Leave'
  json.request_status		leave_approval.approval_request_status
  json.employee_name		leave_request.employee_name
  json.employee_code		leave_request.employee_code
  json.request_count		leave_request.request_count
  json.apply_date				ReportFormat.date_format(leave_request.created_at)
  json.start_date				ReportFormat.date_format(leave_request.start_date)
  json.end_date					ReportFormat.date_format(leave_request.end_date)
  json.is_hod_submitted false
  json.is_hod_approved false
  if leave_request.employee.line_manager.present?
    if leave_request.employee.line_manager.employee_code == "400740"
      json.is_hod_submitted leave_approval.is_hod_submitted
      json.is_hod_approved leave_approval.is_hod_approved
    end
  end
end