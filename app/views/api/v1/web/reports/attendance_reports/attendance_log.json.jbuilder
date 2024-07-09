json.attendance_logs @attendance_logs.each do |attendance_log|
	json.employee_full_name				attendance_log.employee_full_name
	json.employee_code						attendance_log.employee_code
	json.machine_name							attendance_log.machine_name
	json.actual_attendance_date		attendance_log.actual_attendance_date
end