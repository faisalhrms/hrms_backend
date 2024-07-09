json.asset_type do
  json.id           @asset_type.try(:id)
  json.name         @asset_type.try(:name)
  json.is_active    @asset_type.try(:is_active)
  json.description  @asset_type.try(:description)
end