json.over_strength_request do 
	json.id 										@over_strength_request.id
	json.employee_code 					@over_strength_request.employee_code
	json.employee_name 					@over_strength_request.employee_name
	json.department_name				@over_strength_request.department_name
	json.request_count 					@over_strength_request.request_count
	json.start_date 						ReportFormat.date_format(@over_strength_request.start_date)
	json.end_date 							ReportFormat.date_format(@over_strength_request.end_date)
	json.apply_date 						ReportFormat.date_format(@over_strength_request.created_at)
	json.request_status 				@over_strength_request.request_status
	json.apply_status 					@over_strength_request.apply_status
	json.reason 								@over_strength_request.reason
end