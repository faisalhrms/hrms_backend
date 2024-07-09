json.tax_slabs @tax_slabs.each do |tax_slab|
	json.id 					tax_slab.try(:id)
	json.name 				tax_slab.try(:name)
	json.code 				tax_slab.try(:code)
	json.is_active 		tax_slab.try(:is_active)
end


	