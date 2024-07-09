json.certification_types @certification_types do |certification_type|
  json.id   			certification_type.try(:id)
  json.name 			certification_type.try(:name)
  json.is_active 	certification_type.try(:is_active)
end