json.left_reason do
  json.id           @left_reason.try(:id)
  json.name         @left_reason.try(:name)
  json.is_active    @left_reason.try(:is_active)
  json.description  @left_reason.try(:description)
end