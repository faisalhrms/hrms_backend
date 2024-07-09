class RequestFlowDetail < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:request_flow
	belongs_to 	:location
	belongs_to 	:branch
	belongs_to 	:department
	belongs_to 	:employee

	# RequestFlowDetail.request_flow_employee_id(request_flow, approval_request)
	def self.request_flow_employee_id(request_flow, approval_request)
		return_value = nil
		if request_flow.request_flow_details.where(:specific_condition => true,:branch_id => approval_request.request_sender.branch_id ,:department_id => approval_request.request_sender.department_id).count == 1
			request_flow_detail = request_flow.request_flow_details.where(:specific_condition => true,:branch_id => approval_request.request_sender.branch_id, :department_id => approval_request.request_sender.department_id).first
			if not request_flow_detail.nil?
				return_value = request_flow_detail.employee_id
			end
		end
		return return_value
	end

end
