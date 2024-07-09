json.tax_slab do
	json.id 								@tax_slab.try(:id)
	json.company_id 				@tax_slab.try(:company_id)
	json.name 							@tax_slab.try(:name)
	json.code 							@tax_slab.try(:code)
	json.is_active 					@tax_slab.try(:is_active)
	json.description 				@tax_slab.try(:description)	
	json.tax_slab_details 	@tax_slab.tax_slab_details.order('id ASC').each do |tax_slab_detail|
		json.tax_slab_detail_id						tax_slab_detail.try(:id)
		json.tax_slab_id									tax_slab_detail.try(:tax_slab_id)
		json.lower_limit									tax_slab_detail.try(:lower_limit)
		json.upper_limit									tax_slab_detail.try(:upper_limit)
		json.tax_percentage								tax_slab_detail.try(:tax_percentage)
		json.fixed_amount									tax_slab_detail.try(:fixed_amount)
	end
end