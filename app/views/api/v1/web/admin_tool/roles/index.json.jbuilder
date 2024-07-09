json.roles @roles do |role|
  json.id           role.try(:id)
  json.name         role.try(:name)
  json.is_active    role.try(:is_active)
end