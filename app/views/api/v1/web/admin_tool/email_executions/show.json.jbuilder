json.email_execution do 
	json.id 											@email_execution.try(:id)
	json.company_id								@email_execution.try(:company_id)
	json.location_id							@email_execution.try(:location_id)
	json.branch_id								@email_execution.try(:branch_id)
	json.grade_id									@email_execution.try(:grade_id)
	json.name											@email_execution.try(:name)
	json.email_template_id				@email_execution.try(:email_template_id)
	json.trigger									@email_execution.try(:trigger)
	json.no_of_days								@email_execution.try(:no_of_days)
end