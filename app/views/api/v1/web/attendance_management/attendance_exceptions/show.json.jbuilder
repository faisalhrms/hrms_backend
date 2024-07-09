json.attendance_exception do
	json.id 												@attendance_exception.try(:id)
	json.company_id 								@attendance_exception.try(:company_id)
	json.location_id 								@attendance_exception.try(:location_id)
	json.branch_id 									@attendance_exception.try(:branch_id)
	json.name 											@attendance_exception.try(:name)
	json.attendance_exception_type 	@attendance_exception.try(:attendance_exception_type)
	json.grace_time 								@attendance_exception.try(:grace_time)
	json.start_date 								@attendance_exception.try(:start_date)
	json.end_date 									@attendance_exception.try(:end_date)
	json.description 								@attendance_exception.try(:description)
	json.salary_unit_id 						@attendance_exception.try(:salary_unit_id)
	json.salary_unit_wise 					@attendance_exception.try(:salary_unit_wise)
end