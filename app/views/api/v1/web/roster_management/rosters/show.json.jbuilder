json.time_slots @time_slots do |time_slot|
  json.id   						time_slot.try(:id)
  json.name 						time_slot.try(:name)
  json.code 						time_slot.try(:code)
  json.location_name 		time_slot.location_name
  json.branch_name 			time_slot.branch_name
  json.is_active 				time_slot.try(:is_active)
end

json.employee_roster do
	if params[:id].to_i != 0
		roster = EmployeeRoster.find(params[:id])
		json.employee_roster_id   roster.id
		json.time_slot_id   			roster.time_slot_id
		json.is_rest_day   				roster.is_rest_day
		json.is_flexi   					roster.is_flexi
	else
		json.is_rest_day   				false
		json.is_flexi   					false
	end
	json.employee_id 						@employee.id
	json.employee_code 					@employee.employee_code
	json.employee_name 					@employee.full_name
	json.company_id							@employee.company_id
	json.location_id						@employee.location_id
	json.branch_id							@employee.branch_id
	json.department_id					@employee.department_id
	json.grade_id								@employee.grade_id
	json.joining_date						@employee.joining_date
	json.location_name 					@employee.location_name
	json.branch_name 						@employee.branch_name
	json.department_name 				@employee.department_name
	json.grade_name 						@employee.grade_name
end