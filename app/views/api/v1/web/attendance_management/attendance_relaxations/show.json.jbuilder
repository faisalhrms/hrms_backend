json.attendance_relaxation do
	json.id 					@attendance_relaxation.try(:id)
	json.company_id 	@attendance_relaxation.try(:company_id)
	json.name 				@attendance_relaxation.try(:name)
	json.code 				@attendance_relaxation.try(:code)
	json.is_active 		@attendance_relaxation.try(:is_active)
	json.description 	@attendance_relaxation.try(:description)	
	json.relaxation_slabs @attendance_relaxation.attendance_relaxation_slabs.order('id ASC').each do |attendance_relaxation_slab|
		json.slab_id											attendance_relaxation_slab.try(:id)
		json.attendance_relaxation_id			attendance_relaxation_slab.try(:attendance_relaxation_id)
		json.attendance_deduction_id			attendance_relaxation_slab.try(:attendance_deduction_id)
		json.fallback_id									attendance_relaxation_slab.try(:fallback_id)
		json.start_minute									attendance_relaxation_slab.try(:start_minute)
		json.end_minute										attendance_relaxation_slab.try(:end_minute)
	end
end