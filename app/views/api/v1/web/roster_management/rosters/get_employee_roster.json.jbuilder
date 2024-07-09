json.employee_rosters @employee_rosters.each do |employee_roster|
	json.roster_date ReportFormat.date_format(employee_roster.roster_date)
	json.employee_roster_id 	employee_roster.id
	if employee_roster.is_rest_day == true
		json.restday_name "Yes"
	else
		json.restday_name "No"
	end
	json.shift_name "#{employee_roster.formated_start_time} - #{employee_roster.formated_end_time}" 
	if employee_roster.is_flexi == true
		json.flexi_shift "Yes"
	else
		json.flexi_shift "No"
	end
end
