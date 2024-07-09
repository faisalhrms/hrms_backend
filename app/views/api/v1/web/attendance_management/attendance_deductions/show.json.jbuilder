json.attendance_deduction do
	json.id 									@attendance_deduction.try(:id)
	json.company_id 					@attendance_deduction.try(:company_id)
	json.attendance_type_id 	@attendance_deduction.try(:attendance_type_id)
	json.name 								@attendance_deduction.try(:name)
	json.deduction_from 			@attendance_deduction.try(:deduction_from)
	json.deduction_type 			@attendance_deduction.try(:deduction_type)
	json.exempted_in_month 		@attendance_deduction.try(:exempted_in_month)
	json.deduction_value 			@attendance_deduction.try(:deduction_value)
	json.description 					@attendance_deduction.try(:description)
end