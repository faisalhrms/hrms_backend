json.request_flow do
  json.id										@request_flow.try(:id)
  json.company_id						@request_flow.try(:company_id)
  json.name 								@request_flow.try(:name)
  json.request_flow_type 		@request_flow.try(:request_flow_type)
  json.request_node 				@request_flow.try(:request_node)
  json.criteria 			    	@request_flow.try(:criteria)
  json.back_date_limit 			    	@request_flow.try(:back_date_limit)
  json.back_date_apply 			    	@request_flow.try(:back_date_apply)

  json.request_flow_details @request_flow.request_flow_details.order('id ASC').each do |request_flow_detail|
		json.detail_id						request_flow_detail.try(:id)
    json.branch_id     				request_flow_detail.try(:branch_id)
    json.department_id				request_flow_detail.try(:department_id)
		json.employee_id					request_flow_detail.try(:employee_id)
		json.request_node					request_flow_detail.try(:request_node)
		json.specific_condition		request_flow_detail.try(:specific_condition)
	end

end