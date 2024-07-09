json.early_lefts @early_lefts.each do |early_left|
	json.id 					early_left.try(:id)
	json.name 				early_left.try(:name)
	json.code 				early_left.try(:code)
	json.is_active 		early_left.try(:is_active)
end


	