json.left_reasons @left_reasons do |left_reason|
  json.id   			left_reason.try(:id)
  json.name 			left_reason.try(:name)
  json.is_active 	left_reason.try(:is_active)
end