json.general_types @general_types do |type|
  json.id   			type.try(:id)
  json.name 			type.try(:name)
  json.company 			type.company.try(:name)
end