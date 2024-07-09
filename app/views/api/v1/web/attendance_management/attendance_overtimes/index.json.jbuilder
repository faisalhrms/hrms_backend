json.attendance_overtimes @attendance_overtimes.each do |attendance_overtime|
	json.id 					attendance_overtime.try(:id)
	json.name 				attendance_overtime.try(:name)
	json.code 				attendance_overtime.try(:code)
	json.is_active 		attendance_overtime.try(:is_active)
end


	