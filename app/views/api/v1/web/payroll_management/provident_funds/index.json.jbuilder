json.provident_funds @provident_funds do |provident_fund|
	json.id							provident_fund.try(:id)
  json.name 					provident_fund.try(:name)
  json.is_active 			provident_fund.try(:is_active)
end