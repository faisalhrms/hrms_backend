json.incentive_policy do
	json.id 					@incentive_policy.try(:id)
	json.company_id 	@incentive_policy.try(:company_id)
	json.name 				@incentive_policy.try(:name)
	json.is_active 		@incentive_policy.try(:is_active)
	json.description 	@incentive_policy.try(:description)	
	json.incentive_slabs @incentive_policy.incentive_slabs.order('id ASC').each do |incentive_slab|
		json.slab_id													incentive_slab.try(:id)
		json.min_target_sale_percentage				incentive_slab.try(:min_target_sale_percentage)
		json.max_target_sale_percentage				incentive_slab.try(:max_target_sale_percentage)
		json.sale_incentive_percentage				incentive_slab.try(:sale_incentive_percentage)
	end
end