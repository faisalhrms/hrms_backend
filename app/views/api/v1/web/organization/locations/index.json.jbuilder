json.locations @locations do |location|
  json.id   			location.try(:id)
  json.name 			location.try(:name)
  json.code 			location.try(:code)
  json.is_active 	location.try(:is_active)
end