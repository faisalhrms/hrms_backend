json.cities @cities do |city|
  json.id   				city.try(:id)
  json.name 				city.try(:name)
end