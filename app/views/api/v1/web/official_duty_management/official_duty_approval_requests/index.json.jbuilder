json.official_duty_approvals @official_duty_approvals.find_each(batch_size: 10000) do |official_duty_approval|
  json.id 							official_duty_approval.id
  official_duty = 			official_duty_approval.requestable
  json.request_type 		'OD'
  json.request_status		official_duty_approval.approval_request_status
  json.employee_name		official_duty.employee_name
  json.employee_code		official_duty.employee_code
  json.request_count		official_duty.request_count
  json.apply_date				ReportFormat.date_format(official_duty.created_at)
  json.start_date				ReportFormat.date_format(official_duty.start_date)
  json.end_date					ReportFormat.date_format(official_duty.end_date)
end