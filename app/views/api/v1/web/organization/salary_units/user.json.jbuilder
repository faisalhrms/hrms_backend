json.users @users do |users|
  json.id   			      users.try(:id)
  json.email 			      users.try(:email)
  json.combine_name    "#{users.id} | #{users.first_name} | #{users.email}"
end
