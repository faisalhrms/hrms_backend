json.companies @companies do |company|
  json.id   			company.try(:id)
  json.name 			company.try(:name)
  json.code 			company.try(:code)
  json.short_name company.try(:short_name)
  json.is_active 	company.try(:is_active)
end