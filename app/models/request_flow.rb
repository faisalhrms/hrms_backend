class RequestFlow < ApplicationRecord

	########## Validation ############
	validates :name, 							:uniqueness => { scope: :company_id }
	validates :request_flow_type, :uniqueness => { scope: :company_id }
	validate 	:validate_applied_request

	####### Relation Ship #########
	belongs_to 	:company
	has_many		:approval_requests, 		:dependent => :restrict_with_error
	has_many    :request_flow_details,  :dependent => :restrict_with_error	

	def validate_applied_request
		if self.request_flow_type == "Leave Request"
			if LeaveRequest.where(:request_status => "Waiting For Approval").count > 0
				self.errors.add(:base, "Request Flow can't be changed beacause total no of #{LeaveRequest.where(:request_status => "Waiting For Approval").count} leave requests in Approval Process")
			end
		end
	end

	def self.verification_of_request_flow(requested_employee, flow_type)
		request_flow_status = false
		message = ""
		request_flow = RequestFlow.find_by(:company_id => requested_employee.company_id, :request_flow_type => flow_type)
		if request_flow.nil?
			request_flow_status = false
			message = "No Approval Request Flow Exist. You are not allowed to applied request"
		else
			if request_flow.request_node == "Line Manager"
				if requested_employee.line_manager_id.nil?
					request_flow_status = false
					message = "Your Line Manager Not Exist"
				else
					if requested_employee.line_manager.is_active == true
						request_flow_status = true
						message = "Request will send to your Line Manager #{requested_employee.line_manager.full_name}"
					else
						request_flow_status = false
						message = "Your Line Manager #{requested_employee.line_manager.full_name} is not active employee of system. You are not allowed to applied request"
					end					
				end
			elsif request_flow.request_node == "HOD"
				deparment_head = Employee.deparment_head(requested_employee)
				if deparment_head.nil?
					request_flow_status = false
					message = "Your HOD Not Exist"
				else
					if deparment_head.is_active == true
						request_flow_status = true
						message = "Request will send to your HOD #{deparment_head.full_name}"
					else
						request_flow_status = false
						message = "Your HOD #{requested_employee.line_manager.full_name} is not active employee of system. You are not allowed to applied request"
					end
				end
			else
				request_flow_status = false
				message = "Request Flow Hierarchy not defined"
			end
		end
		return request_flow_status, message
	end

	def self.request_flow_username(requested_employee, flow_type)
		user_fullname = "-"
		request_flow = RequestFlow.find_by(:company_id => requested_employee.company_id, :request_flow_type => flow_type)
		if request_flow.nil?
			user_fullname = "-"
		else
			if request_flow.request_node == "Line Manager"
				if requested_employee.line_manager_id.nil?
					user_full_name = "-"
				else
					if requested_employee.line_manager.is_active == true
						user_full_name = requested_employee.line_manager.full_name
					else
						user_full_name = "-"
					end					
				end
			elsif request_flow.request_node == "HOD"
				deparment_head = Employee.deparment_head(requested_employee)
				if deparment_head.nil?
					user_full_name = "-"
				else
					if deparment_head.is_active == true
						user_full_name = deparment_head.full_name
					else
						user_full_name = "-"
					end
				end
			else
				user_full_name = "-"
			end
		end
		return user_full_name
	end

end
