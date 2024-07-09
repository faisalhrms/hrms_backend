json.attendance_overtime do
	json.id 												@attendance_overtime.try(:id)
	json.company_id 								@attendance_overtime.try(:company_id)
	json.name 											@attendance_overtime.try(:name)
	json.code 											@attendance_overtime.try(:code)
	json.is_active 									@attendance_overtime.try(:is_active)
	json.description 								@attendance_overtime.try(:description)	
	json.overtime_after_office_end 	@attendance_overtime.try(:overtime_after_office_end)	
	json.overtime_slabs @attendance_overtime.attendance_overtime_slabs.order('id ASC').each do |attendance_overtime_slab|
		json.slab_id											attendance_overtime_slab.try(:id)
		json.attendance_overtime_id				attendance_overtime_slab.try(:attendance_overtime_id)
		json.attendance_earning_id				attendance_overtime_slab.try(:attendance_earning_id)
		json.fallback_id									attendance_overtime_slab.try(:fallback_id)
		json.min_minute										attendance_overtime_slab.try(:min_minute)
		json.max_minute										attendance_overtime_slab.try(:max_minute)
	end
end