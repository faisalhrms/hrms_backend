required_man_hours_in_seconds 	= 0
total_served_hours_in_seconds 	= 0
total_overtime_hours_in_seconds = 0
total_encashable_cpl_hours_in_seconds = 0
json.employee_attendances @employee_attendances.each do |employee_attendance|
	if employee_attendance.is_rest_day == false && employee_attendance.is_public_holiday == false
    if not employee_attendance.office_in_time.nil?
      if not employee_attendance.office_out_time.nil?
        required_working_hours = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.office_out_time).in_hours
        required_man_hours_in_seconds = required_man_hours_in_seconds + (required_working_hours * 60 * 60)
      end
    end
  end
	if not employee_attendance.in_time.nil?
		if not employee_attendance.out_time.nil?
			served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
			total_served_hours_in_seconds = total_served_hours_in_seconds + (served_hours * 60 * 60)
			json.working_hours					Time.at(served_hours * 60 * 60).utc.strftime("%H:%M")
		else
			json.working_hours					"-"
		end
	else
		json.working_hours						"-"
	end
	if employee_attendance.is_ot_approved == false
		if employee_attendance.over_time_hours > 0
			total_overtime_hours_in_seconds = total_overtime_hours_in_seconds + (employee_attendance.over_time_hours * 60 * 60)
			if employee_attendance.over_time_hours >= 24
				first_value = employee_attendance.over_time_hours.to_s.split('.')[0]
				last_value 	= (employee_attendance.over_time_hours.to_s.split('.')[1].to_f/2.0).to_i
				json.over_time_hours			"#{first_value}:#{last_value}"
			else
				json.over_time_hours						Time.at(employee_attendance.over_time_hours * 60 * 60).utc.strftime("%H:%M")	
			end
		else
			json.over_time_hours						"-"
		end
	else
		if employee_attendance.approved_overtime > 0
			total_overtime_hours_in_seconds = total_overtime_hours_in_seconds + (employee_attendance.approved_overtime * 60 * 60)
			if employee_attendance.approved_overtime >= 24
				first_value = employee_attendance.approved_overtime.to_s.split('.')[0]
				last_value 	= (employee_attendance.approved_overtime.to_s.split('.')[1].to_f/2.0).to_i
				json.over_time_hours			"#{first_value}:#{last_value}"
			else
				json.over_time_hours						Time.at(employee_attendance.approved_overtime * 60 * 60).utc.strftime("%H:%M")	
			end
		else
			json.over_time_hours						"-"
		end
	end
	if employee_attendance.encashable_quota > 0
		total_encashable_cpl_hours_in_seconds = total_encashable_cpl_hours_in_seconds + (employee_attendance.encashable_quota * 60 * 60)
	end
	json.attendance_date 						ReportFormat.time_card_date_format(employee_attendance.attendance_date)
	if employee_attendance.in_time.nil?
		json.in_time 										"-"
	else
		json.in_time 									employee_attendance.in_time.to_datetime.strftime("%-l:%M %P")
	end
	if employee_attendance.out_time.nil?
		json.out_time 									"-"
	else
		json.out_time 								employee_attendance.out_time.to_datetime.strftime("%-l:%M %P")
	end
	if employee_attendance.employee_roster.nil?
		json.shift_name 							"No Roster Assinged"
		json.shift_timing							"-"
	else
		json.shift_name								ReportFormat.shift_name(employee_attendance)
		json.shift_timing							ReportFormat.shift_timing(employee_attendance)
	end
	json.attendance_status					employee_attendance.attendance_status
	json.checkin_deduction					employee_attendance.checkin_deduction.to_f
	if employee_attendance.early_left_status.blank?
		json.early_left_status 				"-"
	else
		json.early_left_status					employee_attendance.early_left_status
	end
	json.checkout_deduction					employee_attendance.checkout_deduction.to_f
	if (employee_attendance.checkout_deduction.to_f + employee_attendance.checkin_deduction.to_f).round(2) > 1
		json.deduction_value 1
	else
		json.deduction_value					(employee_attendance.checkout_deduction.to_f + employee_attendance.checkin_deduction.to_f).round(2)
	end
	json.remarks										employee_attendance.remarks
	json.other_remarks							employee_attendance.other_remarks
	json.mark_as_manual							employee_attendance.mark_as_manual
end

total_count = 0
if @employee_attendances.count > 0
	work_day 						= @employee_attendances.where(:attendance_status => ["Present", "Rest Day", "Public Holiday"]).count
	no_of_late 					= @employee_attendances.where(:attendance_status => ["Late"]).count
	no_of_half_day 			= @employee_attendances.where(:attendance_status => ["Half Day"]).count
	no_of_offical_duty 	= @employee_attendances.where(:is_official_duty => true).count
	no_of_relaxation 		= @employee_attendances.where(:is_relaxation => true).count
	# cpl_earned 					= @employee_attendances.where(:remarks => ["CPL Earned"]).sum(:no_of_cpl)
	cpl_earned 					= @employee_attendances.sum(:no_of_cpl)
	off_day_payment 		= @employee_attendances.where(:remarks => ["Off Day Working"]).count
	no_of_leaves 				= @employee_attendances.where(:is_on_leave => true).count
	no_of_absent 				= @employee_attendances.where(:attendance_status => "Absent").count
	total_count 				= total_count + (work_day + no_of_late + no_of_half_day + no_of_offical_duty + no_of_relaxation + cpl_earned + off_day_payment + no_of_leaves)
else
	work_day 						= 0
	no_of_late 					= 0
	no_of_half_day 			= 0
	no_of_offical_duty 	= 0
	no_of_relaxation 		= 0
	cpl_earned 					= 0
	off_day_payment 		= 0
	no_of_leaves 				= 0
	no_of_absent 				= 0
	total_count 				= 0
end

json.summary_detail do
	json.total_count 				total_count
	json.work_day 					work_day
	json.no_of_absent				no_of_absent
	json.no_of_late 				no_of_late
	json.no_of_half_day 		no_of_half_day
	json.no_of_offical_duty no_of_offical_duty
	json.no_of_relaxation 	no_of_relaxation
	json.cpl_earned 				cpl_earned
	json.off_day_payment 		off_day_payment
	json.no_of_leaves 			no_of_leaves 
end

# json.hours_detail do
# 	json.required_man_hours_in_seconds 		ReportFormat.overtime_value_into_overtime_hours(required_man_hours_in_seconds)
# 	json.total_served_hours_in_seconds 		ReportFormat.overtime_value_into_overtime_hours(total_served_hours_in_seconds)
# 	json.total_overtime_hours_in_seconds 	@employee_attendances.sum(:over_time_hours).round(2)
# 	json.total_encashable_cpl_hours_in_seconds ReportFormat.overtime_value_into_overtime_hours(total_encashable_cpl_hours_in_seconds)
# end

json.hours_detail do
	json.required_man_hours_in_seconds 					"-"
	json.total_served_hours_in_seconds 					"-"
	json.total_overtime_hours_in_seconds 				"-"
	json.total_encashable_cpl_hours_in_seconds 	"-"
end

leave_types = LeaveType.where(:is_active => true, :is_composite => false).order('sort_order ASC')
json.leave_types leave_types.each do |leave_type|
  if not params[:single_employee_information].nil?
  	leave_allocation = LeaveAllocation.find_by(:employee_id => params[:single_employee_information][:id], :is_active => true, :leave_type_id => leave_type.id)
	  if not leave_allocation.nil?
	  	in_process_quota 			= leave_allocation.in_process_quota
	    json.leave_type_name 	leave_type.name
	    json.allocated_quota 	leave_allocation.allocated_quota
	    json.used_quota 			(leave_allocation.used_quota - in_process_quota)
	    json.remaining_quota 	leave_allocation.remaining_quota
	    json.in_process_quota in_process_quota
	  end	
  end
end
if @minute_policy
  consumed = @employee_attendances.last ? @employee_attendances.last.get_leverage_minutes : 0
  json.leverage_minutes EmployeeAttendance::TOTAL_LEVERAGE_MIN
  json.consumed_minutes consumed
  json.remaining_minutes (EmployeeAttendance::TOTAL_LEVERAGE_MIN - consumed)
end
