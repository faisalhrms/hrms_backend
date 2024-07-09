json.attendance_cutoff do
	json.id 												@attendance_cutoff.try(:id)
	json.company_id 								@attendance_cutoff.try(:company_id)
	json.location_id 								@attendance_cutoff.try(:location_id)
	json.branch_id 									@attendance_cutoff.try(:branch_id)
	json.name 											@attendance_cutoff.try(:name)
	json.start_date 								@attendance_cutoff.try(:start_date)
	json.end_date 									@attendance_cutoff.try(:end_date)
	json.description 								@attendance_cutoff.try(:description)
	json.salary_unit_id 						@attendance_cutoff.try(:salary_unit_id)
	json.salary_unit_wise 					@attendance_cutoff.try(:salary_unit_wise)
end