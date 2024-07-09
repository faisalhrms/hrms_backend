json.qualfication_types @qualfication_types do |qualfication_type|
  json.id   			qualfication_type.try(:id)
  json.name 			qualfication_type.try(:name)
  json.is_active 	qualfication_type.try(:is_active)
end