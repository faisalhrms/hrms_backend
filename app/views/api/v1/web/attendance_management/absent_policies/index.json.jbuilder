json.absent_policies @absent_policies.each do |absent_policy|
	json.id 					absent_policy.try(:id)
	json.name 				absent_policy.try(:name)
	json.code 				absent_policy.try(:code)
	json.is_active 		absent_policy.try(:is_active)
end


	