json.relationship do
  json.id           @relationship.try(:id)
  json.name         @relationship.try(:name)
  json.is_active    @relationship.try(:is_active)
  json.description  @relationship.try(:description)
end