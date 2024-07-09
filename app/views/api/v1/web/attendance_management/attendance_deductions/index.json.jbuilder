json.attendance_deductions @attendance_deductions.each do |attendance_deduction|
	json.id 										attendance_deduction.try(:id)
	json.attendance_type_name 	attendance_deduction.attendance_type_name
	json.name 									attendance_deduction.try(:name)
	json.deduction_from 				attendance_deduction.try(:deduction_from)
	json.deduction_type 				attendance_deduction.try(:deduction_type)
	json.deduction_value 				attendance_deduction.try(:deduction_value)
end