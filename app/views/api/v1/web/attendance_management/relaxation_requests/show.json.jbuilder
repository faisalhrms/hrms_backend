json.relaxation_request do 
	json.id 										@relaxation.id
	json.employee_code 					@relaxation.employee_code
	json.employee_name 					@relaxation.employee_name
	json.request_count 					@relaxation.request_count
  json.criteria      					RequestFlow.last.criteria
  json.relaxation_start_date 	ReportFormat.date_format(@relaxation.relaxation_start_date)
  json.relaxation_end_date 		ReportFormat.date_format(@relaxation.relaxation_end_date)
	json.start_date 						ReportFormat.date_format(@relaxation.start_date)
	json.end_date 							ReportFormat.date_format(@relaxation.end_date)
	json.apply_date 						ReportFormat.date_format(@relaxation.created_at)
	json.request_status 				@relaxation.request_status
	json.apply_status 					@relaxation.apply_status
	json.attendance_type_name 	@relaxation.attendance_type_name
	if @relaxation.start_time.nil?
		json.start_time 				"-"
	else
		json.start_time 					@relaxation.start_time.strftime("%I:%M%p")
	end
	if @relaxation.end_time.nil?
		json.end_time 					"-"
	else
		json.end_time 						@relaxation.end_time.strftime("%I:%M%p")
	end
	json.reason 								@relaxation.reason
end