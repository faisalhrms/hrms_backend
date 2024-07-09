json.documents @documents.each do |document|
	json.id 				document.try(:id)
	json.name 			document.try(:name)
	json.code 			document.try(:code)
	json.is_active 	document.try(:is_active)
end