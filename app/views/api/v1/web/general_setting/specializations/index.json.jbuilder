json.specializations @specializations do |specialization|
  json.id  				specialization.try(:id)
  json.name 			specialization.try(:name)
  json.is_active 	specialization.try(:is_active)
end