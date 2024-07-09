json.custom_tax_slab do
	json.id 								@custom_tax_slab.try(:id)
	json.company_id 				@custom_tax_slab.try(:company_id)
	json.name 							@custom_tax_slab.try(:name)
	json.code 							@custom_tax_slab.try(:code)
	json.is_active 					@custom_tax_slab.try(:is_active)
	json.description 				@custom_tax_slab.try(:description)	
	json.custom_tax_slab_details 	@custom_tax_slab.custom_tax_slab_details.order('id ASC').each do |custom_tax_slab_detail|
		json.custom_tax_slab_detail_id		custom_tax_slab_detail.try(:id)
		json.tax_slab_id									custom_tax_slab_detail.try(:tax_slab_id)
		json.lower_limit									custom_tax_slab_detail.try(:lower_limit)
		json.upper_limit									custom_tax_slab_detail.try(:upper_limit)
		json.tax_percentage								custom_tax_slab_detail.try(:tax_percentage)
		json.fixed_amount									custom_tax_slab_detail.try(:fixed_amount)
	end
end