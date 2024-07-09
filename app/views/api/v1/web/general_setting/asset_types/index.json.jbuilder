json.asset_types @asset_types do |asset_type|
  json.id   			asset_type.try(:id)
  json.name 			asset_type.try(:name)
  json.is_active 	asset_type.try(:is_active)
end