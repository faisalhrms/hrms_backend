start_date 	= params[:start_date]
end_date 		= params[:end_date]

json.shift_details @date_range.each_index do |index|
  json.shift_date 	@date_range[index]
end

json.time_slot do
  json.time_slot_id 					@time_slot.id
  json.actual_start_time			@time_slot.actual_start_time
  json.actual_end_time				@time_slot.actual_end_time
  json.start_buffer 					@time_slot.start_buffer
  json.end_buffer							@time_slot.end_buffer
  json.is_flexi								@time_slot.is_flexi
  if @time_slot.is_flexi == true
    json.flexi_status					"Yes"
  else
    json.flexi_status					"No"
  end
end

all_roster = EmployeeRoster.where(roster_date: @complete_date_range)
json.roster_list @employees.each do |employee|
  json.is_selected						true
  json.employee_id 						employee.id
  json.employee_code 					employee.employee_code
  json.employee_name 					employee.full_name
  json.full_name 							employee.full_name
  json.combine_name 					"#{employee.employee_code} | #{employee.full_name}"
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
  json.sub_department_id 			employee.sub_department_id
  json.time_slot_id 					@time_slot.id
  @employee_rosters_exist = EmployeeRoster.where(:employee_id => employee.id, :roster_date => start_date.to_date..end_date.to_date).exists?
  if @employee_rosters_exist
    json.roster_status 				"-"
  else
    json.roster_status 				"No Confit"
  end
  all_employee_roster = all_roster.select{|roster| roster.employee_id == employee.id}
  json.roster_dates @complete_date_range.each_index do |index|
    employee_roster = all_employee_roster.select{|a| a.roster_date.to_date == @complete_date_range[index].to_date}.try(:first)
    if employee_roster.nil?
      json.already_exist false
    else
      json.already_exist true
      json.employee_roster_id employee_roster.id
    end
    json.date @complete_date_range[index]
    if @formated_date_range.include?(@complete_date_range[index]) == false
      json.is_rest_day true
    else
      json.is_rest_day false
    end
  end
end