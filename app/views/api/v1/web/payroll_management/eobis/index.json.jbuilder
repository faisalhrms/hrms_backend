json.eobis @eobis do |eobi|
	json.id							eobi.try(:id)
  json.name 					eobi.try(:name)
  json.is_active 			eobi.try(:is_active)
end