index_count = 0
json.attendance_cutoffs @attendance_cutoffs.each do |attendance_cutoff|
	json.id 												attendance_cutoff.try(:id)
	json.index_value								index_count
	json.location_name 							attendance_cutoff.location_name
	json.branch_name								attendance_cutoff.branch_name
	json.salary_unit_name						attendance_cutoff.salary_unit_name
	json.is_executed 								attendance_cutoff.try(:is_executed)
	json.name 											attendance_cutoff.try(:name)
	json.start_date 								ReportFormat.date_format(attendance_cutoff.start_date)
	json.end_date 									ReportFormat.date_format(attendance_cutoff.end_date)
	index_count = index_count + 1
end