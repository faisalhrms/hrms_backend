json.official_duty do 
	json.id 									@official_duty.id
	json.employee_code 				@official_duty.employee_code
	json.employee_name 				@official_duty.employee_name
	json.request_count 				@official_duty.request_count
	json.start_date 					ReportFormat.date_format(@official_duty.start_date)
	json.end_date 						ReportFormat.date_format(@official_duty.end_date)
	json.apply_date 					ReportFormat.date_format(@official_duty.created_at)
	json.request_status 			@official_duty.request_status
	json.apply_status 				@official_duty.apply_status
	json.is_full_day 					@official_duty.is_full_day
	if @official_duty.start_time.nil?
		json.start_time 				"-"
	else
		json.start_time 				@official_duty.start_time.strftime("%I:%M%p")
	end
	if @official_duty.end_time.nil?
		json.end_time 					"-"
	else
		json.end_time 					@official_duty.end_time.strftime("%I:%M%p")
	end
	json.reason 							@official_duty.reason
end