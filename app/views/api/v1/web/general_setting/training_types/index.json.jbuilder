json.training_types @training_types do |training_type|
  json.id					training_type.try(:id)
  json.name 			training_type.try(:name)
  json.is_active 	training_type.try(:is_active)
end