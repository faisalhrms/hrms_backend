json.relationships @relationships do |relationship|
  json.id   			relationship.try(:id)
  json.name 			relationship.try(:name)
  json.is_active 	relationship.try(:is_active)
end