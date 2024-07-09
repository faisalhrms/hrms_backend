json.date_ranges @date_range.each_index do |index|
	json.shift_date 	@date_range[index]
end

json.rosters @employees.each do |employee|
	json.employee_id 		employee.id
	json.employee_code 	employee.employee_code
	json.employee_name 	employee.full_name
	json.is_active 			employee.is_active
	json.roster_detail 	@new_date_range.each_index do |index|
    employee_roster = @employee_roster_data[employee.id] ? @employee_roster_data[employee.id].select{|roster| roster.roster_date.strftime('%D') == @new_date_range[index].to_date.strftime('%D')}.first : nil
		json.roster_date @new_date_range[index]
		if employee_roster.nil?
			json.roster_present 			false
			json.is_rest_day 					false
			json.is_flexi 						false
			json.is_transfer 					false
			json.shift_name 					"No Roster"
			json.restday_name					""
			json.flexi_shift					""
		else
			json.employee_roster_id 	employee_roster.id
			json.roster_present 			true
			json.is_rest_day 					employee_roster.is_rest_day
			json.is_transfer 					employee_roster.is_transfer
			json.is_flexi 						employee_roster.is_flexi
			if employee_roster.is_rest_day
				json.restday_name "Rest Day"
			end
			json.shift_name "#{employee_roster.formated_start_time} - #{employee_roster.formated_end_time}" 
			if employee_roster.is_flexi
				json.flexi_shift "Flexi"
			else
				json.flexi_shift ""
			end
		end
	end
end

json.employee_rosters @employees.each do |employee|
	json.employee_id 						employee.id
	json.employee_code 					employee.employee_code
	json.employee_name 					employee.full_name
	json.company_id							employee.company_id
	json.location_id						employee.location_id
	json.branch_id							employee.branch_id
	json.department_id					employee.department_id
	json.grade_id								employee.grade_id
	json.joining_date						employee.joining_date
	json.location_name 					employee.location_name
	json.branch_name 						employee.branch_name
	json.department_name 				employee.department_name
	json.grade_name 						employee.grade_name
	json.is_active 							employee.is_active
end