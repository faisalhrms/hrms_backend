json.missing_punch do
	json.id 											@missing_punch.try(:id)
	json.company_id 							@missing_punch.try(:company_id)
	json.attendance_deduction_id 	@missing_punch.try(:attendance_deduction_id)
	json.fallback_id							@missing_punch.try(:fallback_id)
	json.name 										@missing_punch.try(:name)
	json.code 										@missing_punch.try(:code)
	json.is_active 								@missing_punch.try(:is_active)
	json.description 							@missing_punch.try(:description)	
end