json.leave_list @leave_requests.each do |leave_request|
	json.employee_name 					leave_request.employee_name
	json.employee_code 					leave_request.employee_code
	json.location_name					leave_request.location_name
	json.branch_name						leave_request.branch_name
	json.department_name				leave_request.department_name
	json.job_title_name					leave_request.job_title_name
	json.grade_name							leave_request.grade_name
	json.designation_name				leave_request.designation_name
	json.request_count					leave_request.request_count
	json.request_status					leave_request.request_status
	json.apply_date							ReportFormat.date_format(leave_request.created_at)
	json.start_date							ReportFormat.date_format(leave_request.start_date)
	json.end_date								ReportFormat.date_format(leave_request.end_date)
end