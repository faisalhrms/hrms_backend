json.attendance_relaxations @attendance_relaxations.each do |attendance_relaxation|
	json.id 					attendance_relaxation.try(:id)
	json.name 				attendance_relaxation.try(:name)
	json.code 				attendance_relaxation.try(:code)
	json.is_active 		attendance_relaxation.try(:is_active)
end


	