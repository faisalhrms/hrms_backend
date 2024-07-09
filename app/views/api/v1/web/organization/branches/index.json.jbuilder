json.branches @branches do |branch|
  json.id   						branch.try(:id)
  json.name 						branch.try(:name)
  json.code 						branch.try(:code)
  json.location_name 		branch.try(:location_name)
  json.is_active 				branch.try(:is_active)
end