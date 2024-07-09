json.custom_tax_slabs @custom_tax_slabs.each do |custom_tax_slab|
	json.id 					custom_tax_slab.try(:id)
	json.name 				custom_tax_slab.try(:name)
	json.code 				custom_tax_slab.try(:code)
	json.is_active 		custom_tax_slab.try(:is_active)
end


	