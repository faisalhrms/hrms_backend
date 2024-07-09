json.absent_policy do
	json.id 											@absent_policy.try(:id)
	json.company_id 							@absent_policy.try(:company_id)
	json.attendance_deduction_id 	@absent_policy.try(:attendance_deduction_id)
	json.fallback_id							@absent_policy.try(:fallback_id)
	json.name 										@absent_policy.try(:name)
	json.code 										@absent_policy.try(:code)
	json.is_active 								@absent_policy.try(:is_active)
	json.description 							@absent_policy.try(:description)	
end