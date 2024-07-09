json.tehsils @tehsils do |tehsil|
  json.id   			tehsil.try(:id)
  json.name 			tehsil.try(:name)
end