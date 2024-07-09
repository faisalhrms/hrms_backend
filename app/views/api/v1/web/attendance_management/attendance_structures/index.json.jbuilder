index_count = 0
json.attendance_structures @attendance_structures.each do |attendance_structure|
	json.index_value								index_count
	json.id 												attendance_structure.try(:id)
	json.name 											attendance_structure.try(:name)
	json.code 											attendance_structure.try(:code)
	json.location_name							attendance_structure.location_name
	json.start_date 								ReportFormat.date_format(attendance_structure.start_date)
	json.end_date 									ReportFormat.date_format(attendance_structure.end_date)
	json.is_active 									attendance_structure.try(:is_active)
	index_count = index_count + 1
end