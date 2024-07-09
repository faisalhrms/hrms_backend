json.districts @districts do |district|
  json.id   			district.try(:id)
  json.name 			district.try(:name)
end