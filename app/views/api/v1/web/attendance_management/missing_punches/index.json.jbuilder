json.missing_punches @missing_punches.each do |missing_punch|
	json.id 					missing_punch.try(:id)
	json.name 				missing_punch.try(:name)
	json.code 				missing_punch.try(:code)
	json.is_active 		missing_punch.try(:is_active)
end


	