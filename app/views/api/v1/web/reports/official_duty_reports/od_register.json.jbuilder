json.od_list @official_duties.each do |official_duty|
	json.employee_name 					official_duty.employee_name
	json.employee_code 					official_duty.employee_code
	json.location_name					official_duty.location_name
	json.branch_name						official_duty.branch_name
	json.department_name				official_duty.department_name
	json.job_title_name					official_duty.job_title_name
	json.grade_name							official_duty.grade_name
	json.designation_name				official_duty.designation_name
	json.request_count					official_duty.request_count
	json.request_status					official_duty.request_status
	json.official_duty_mode		official_duty.normalized_official_duty_mode
	json.apply_date							ReportFormat.date_format(official_duty.created_at)
	json.start_date							ReportFormat.date_format(official_duty.start_date)
	json.end_date								ReportFormat.date_format(official_duty.end_date)
end
