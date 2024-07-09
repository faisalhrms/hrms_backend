json.divisions @divisions do |division|
  json.id   			division.try(:id)
  json.name 			division.try(:name)
end