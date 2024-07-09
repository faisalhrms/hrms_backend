json.asset_details @asset_details do |asset_detail|
  json.id   						asset_detail.try(:id)
  json.item_name 				asset_detail.try(:item_name)
  json.item_type 				asset_detail.try(:item_type)
  json.is_active 				asset_detail.try(:is_active)
end