json.incentive_policies @incentive_policies.each do |incentive_policy|
	json.id 					incentive_policy.try(:id)
	json.name 				incentive_policy.try(:name)
	json.is_active 		incentive_policy.try(:is_active)
end


	