json.users @members do |member|
  json.id                member.try(:id)
  json.first_name        member.first_name
  json.last_name         member.last_name
  json.full_name         member.full_name
  json.user_full_name    "#{member.full_name}"
  json.email             member.try(:email)
  json.is_active         member.try(:is_active)
end