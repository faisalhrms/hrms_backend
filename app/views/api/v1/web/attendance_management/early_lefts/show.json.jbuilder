json.early_left do
	json.id 					@early_left.try(:id)
	json.company_id 	@early_left.try(:company_id)
	json.name 				@early_left.try(:name)
	json.code 				@early_left.try(:code)
	json.is_active 		@early_left.try(:is_active)
	json.description 	@early_left.try(:description)
	
	json.early_left_slabs @early_left.early_left_slabs.order('id ASC').each do |early_left_slab|
		json.slab_id											early_left_slab.try(:id)
		json.early_left_id								early_left_slab.try(:early_left_id)
		json.attendance_deduction_id			early_left_slab.try(:attendance_deduction_id)
		json.fallback_id									early_left_slab.try(:fallback_id)
		json.start_minute									early_left_slab.try(:start_minute)
		json.end_minute										early_left_slab.try(:end_minute)
	end
	
end


	