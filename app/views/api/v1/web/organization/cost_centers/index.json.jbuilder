json.cost_centers @cost_centers do |cost_center|
  json.id   			cost_center.try(:id)
  json.name 			cost_center.try(:name)
  json.is_active 	cost_center.try(:is_active)
end