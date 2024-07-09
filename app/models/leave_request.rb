class LeaveRequest < ApplicationRecord
	include RestrictRequest

	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:employee
	belongs_to 	:leave_type
	has_one    	:approval_request, class_name: 'ApprovalRequest', as: :requestable
	has_many		:leave_transaction_histories
	has_many		:leave_request_details, 				:dependent => :restrict_with_error

	########## Validation ############
  validate 		:validate_the_apply_date

  after_save 	:leave_approval_request

  ########## Validation of Leave Application ##########
	def validate_the_apply_date
		applied_status = false
		if self.request_status == "Waiting For Approval"
			if self.id.present?
				LeaveRequest.where.not(id:self.id).where(employee_id: self.employee_id, is_cancelled: false, request_status: ["Waiting For Approval","Availed","System Deducted"]).each do |leave_request|
					if self.id != leave_request.id
						if leave_request.start_date.present? and leave_request.end_date.present?
							if (leave_request.start_date <= self.start_date and leave_request.end_date >= self.start_date) or (leave_request.end_date >= self.end_date and leave_request.start_date <= self.end_date)
								applied_status = true
								self.errors.add(:base, "Leave Request Already Applied! from #{leave_request.start_date.to_date.strftime("%d-%b-%Y")} to #{leave_request.end_date.to_date.strftime("%d-%b-%Y")}")
							end
						end
					end
				end
			else
				LeaveRequest.where(employee_id: self.employee_id, is_cancelled: false, request_status: ["Waiting For Approval","Availed","System Deducted"]).each do |leave_request|
					if self.id != leave_request.id
						if leave_request.start_date.present? and leave_request.end_date.present?
							if (leave_request.start_date <= self.start_date and leave_request.end_date >= self.start_date) or (leave_request.end_date >= self.end_date and leave_request.start_date <= self.end_date)
								applied_status = true
								self.errors.add(:base, "Leave Request Already Applied! from #{leave_request.start_date.to_date.strftime("%d-%b-%Y")} to #{leave_request.end_date.to_date.strftime("%d-%b-%Y")}")
							end
						end
					end
				end
			end
		end
		
		if self.request_status == "Waiting For Approval"
			employee_leave_ledger = LeaveAllocation.find_by(:company_id => self.company_id, :is_active => true, :leave_type_id => self.leave_type_id, :employee_id => self.employee_id)
			if not employee_leave_ledger.leave_year_start_date.nil?
				if not (employee_leave_ledger.leave_year_start_date <= self.start_date and employee_leave_ledger.leave_year_end_date >= self.start_date)
					self.errors.add(:base, "Leave Calender Year Not In Range of your Leave Request Date Range! #{self.start_date.to_date.strftime("%d-%b-%Y")} to #{self.end_date.to_date.strftime("%d-%b-%Y")}")
				end
			end
			requested_employee = Employee.find(self.employee_id)
			if self.is_composite == false
				if SystemSetting.advance_leave_allowed(self.company_id) == false
					allocated_leave = LeaveAllocation.find_by(:company_id => requested_employee.company_id, :is_active => true, :leave_type_id => self.leave_type_id, :employee_id => self.employee_id)
					if allocated_leave.remaining_quota < self.request_count
						self.errors.add(:base, "Your Requested quota is greater than your remainng balance")
					end
				else
					allocated_leave = LeaveAllocation.find_by(:company_id => requested_employee.company_id, :is_active => true, :leave_type_id => self.leave_type_id, :employee_id => self.employee_id)
					if allocated_leave.remaining_quota < 0
						self.errors.add(:base, "You already availed leave in advance")
					else
						remaining_quota = allocated_leave.remaining_quota + SystemSetting.advance_leave_limit(self.company_id)
						if remaining_quota < self.request_count
							self.errors.add(:base, "Your Requested quota is greater than your remainng balance")
						end
					end
				end
			else
				merge_leave_type_ids = self.leave_type.composite_leave_types.where(:status => "Allowed").collect(&:merge_leave_type_id)
				remaining_quota = LeaveAllocation.where(:company_id => requested_employee.company_id, :is_active => true, :leave_type_id => merge_leave_type_ids, :employee_id => self.employee_id).sum(:remaining_quota)
				if remaining_quota < self.request_count
					self.errors.add(:base, 'Your Requested quota is greater than your remaining balance')
				end
			end
		end
		logger.info "#{self.errors}"
	end

	########## Calculation of Leave that requested to Applied ##########
	def self.calculate_employee_leave(leave_type, employee, start_date, end_date, leave_category)
		message = "No issue in Leave Request. You are allowed to apply leave."
		sandwich_count = 0
		date_range = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
		request_count  = date_range.count
		
		################ Leave Category for Leave Division ###############
		if leave_category == "Short Day"
			request_count = request_count * 0.25
		elsif leave_category == "Half Day"
			request_count = request_count * 0.5
		elsif leave_category == "Full Day"
			request_count = request_count * 1.0
		else			
			request_count = 0
		end
		splitable = true

		################ Roster Rest Day Count in Leaves ###############
		EmployeeRoster.where(:employee_id => employee.id, :roster_date => start_date.to_date..end_date.to_date).each do |employee_roster|
			if employee_roster.is_rest_day == true
				sandwich_count = sandwich_count + 1
			end
		end

		sandwich_count = sandwich_count + Holiday.calculate_holidays(start_date, end_date, employee)

		if leave_type.sandwich == false
			request_count = request_count - sandwich_count
			sandwich_count = 0
		end
		
		if leave_type.splitable == true
			splitable = true
		else
			if request_count == LeaveAllocation.where(:employee_id => employee.id, :leave_type_id => leave_type.id).sum(:allocated_quota)
				splitable = true
			else
				splitable = false
			end
		end
		
		############## Verification of Leave Request	##############
		request_flow_status = RequestFlow.verification_of_request_flow(employee, "Leave Request")

		if splitable == true
			if request_flow_status[0] == true
				if leave_type.limit_request_in_tenure == true
					if leave_type.limit_request_tenure == "Monthly"
						if LeaveRequest.where(:employee_id => employee.id, :leave_type_id => leave_type.id, :request_status => ["Waiting For Approval","Availed"]).where(['start_date > ? AND end_date < ?', start_date.to_date.beginning_of_month, end_date.to_date.end_of_month]).count >= leave_type.limit_request_count
							sandwich_count 	= 0
							request_count 	= 0
							message = "Leave Apply Limit within the #{leave_type.limit_request_tenure} tenure reached."
						end
					elsif leave_type.limit_request_tenure == "Annually"
						if LeaveRequest.where(:employee_id => employee.id, :leave_type_id => leave_type.id, :request_status => ["Waiting For Approval","Availed"]).where(['start_date > ? AND end_date < ?', start_date.to_date.beginning_of_year, end_date.to_date.end_of_year]).count >= leave_type.limit_request_count
							sandwich_count 	= 0
							request_count 	= 0
							message = "Leave Apply Limit within the #{leave_type.limit_request_tenure} tenure reached."
						end
					end
				end

				########################################################################
				############## Verification of Leave Request on Probation ##############
				########################################################################
				if employee.on_probation == true
					if leave_type.probation_limit_request_in_tenure == true
						if leave_type.probation_limit_request_tenure == "Monthly"
							if LeaveRequest.where(:employee_id => employee.id, :leave_type_id => leave_type.id, :request_status => ["Waiting For Approval","Availed"]).where(['start_date > ? AND end_date < ?', start_date.to_date.beginning_of_month, end_date.to_date.end_of_month]).count >= leave_type.probation_limit_request_count
								sandwich_count 	= 0
								request_count 	= 0
								message = "Leave Apply Limit within the #{leave_type.limit_request_tenure} Probation tenure reached."
							end
						elsif leave_type.probation_limit_request_tenure == "Annually"
							if LeaveRequest.where(:employee_id => employee.id, :leave_type_id => leave_type.id, :request_status => ["Waiting For Approval","Availed"]).where(['start_date > ? AND end_date < ?', start_date.to_date.beginning_of_year, end_date.to_date.end_of_year]).count >= leave_type.probation_limit_request_count
								sandwich_count 	= 0
								request_count 	= 0
								message = "Leave Apply Limit within the #{leave_type.limit_request_tenure} Probation tenure reached."
							end
						end
					end
				end
				########################################################################
				############## Verification of Leave Request on Probation ##############
				########################################################################

			else
				sandwich_count 	= 0
				request_count 	= 0
				message					= request_flow_status[1]
			end
		else
			sandwich_count 	= 0
			request_count 	= 0
			message					= "You can't apply leave in split form."
		end

		if message != request_flow_status[1]
			message = "#{message} #{request_flow_status[1]}"
		end

		return request_count, sandwich_count, message
	end

	########## Calculation of Composite Leave that requested to Applied ##########
	def self.calculate_composite_employee_leave(leave_type, employee, start_date, end_date, leave_category)
		message = "No issue in Leave Request. You are allowed to apply leave."
		sandwich_count = 0
		date_range = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
		request_count  = date_range.count
		
		################ Leave Category for Leave Division ###############
		if leave_category == "Short Day"
			request_count = request_count * 0.25
		elsif leave_category == "Half Day"
			request_count = request_count * 0.5
		elsif leave_category == "Full Day"
			request_count = request_count * 1.0
		else			
			request_count = 0
		end

		################ Roster Rest Day Count in Leaves ###############
		EmployeeRoster.where(:employee_id => employee.id, :roster_date => start_date.to_date..end_date.to_date).each do |employee_roster|
			if employee_roster.is_rest_day == true
				sandwich_count = sandwich_count + 1
			end
		end
		
		sandwich_count = sandwich_count + Holiday.calculate_holidays(start_date, end_date, employee)

		if leave_type.sandwich == false
			request_count = request_count - sandwich_count
			sandwich_count = 0
		end

		############## Verification of Leave Request	##############
		request_flow_status = RequestFlow.verification_of_request_flow(employee, "Leave Request")

		if request_flow_status[0] == true
			if leave_type.limit_request_in_tenure == true
				if leave_type.limit_request_tenure == "Monthly"
					if LeaveRequest.where(:employee_id => employee.id, :leave_type_id => leave_type.id, :request_status => ["Waiting For Approval","Availed"]).where(['start_date > ? AND end_date < ?', start_date.to_date.beginning_of_month, end_date.to_date.end_of_month]).count >= leave_type.limit_request_count
						sandwich_count 	= 0
						request_count 	= 0
						message = "Leave Apply Limit within the #{leave_type.limit_request_tenure} tenure reached."
					end
				elsif leave_type.limit_request_tenure == "Annually"
					if LeaveRequest.where(:employee_id => employee.id, :leave_type_id => leave_type.id, :request_status => ["Waiting For Approval","Availed"]).where(['start_date > ? AND end_date < ?', start_date.to_date.beginning_of_year, end_date.to_date.end_of_year]).count >= leave_type.limit_request_count
						sandwich_count 	= 0
						request_count 	= 0
						message = "Leave Apply Limit within the #{leave_type.limit_request_tenure} tenure reached."
					end
				end
			end

			########################################################################
			############## Verification of Leave Request on Probation ##############
			########################################################################
			if employee.on_probation == true
				if leave_type.probation_limit_request_in_tenure == true
					if leave_type.probation_limit_request_tenure == "Monthly"
						if LeaveRequest.where(:employee_id => employee.id, :leave_type_id => leave_type.id, :request_status => ["Waiting For Approval","Availed"]).where(['start_date > ? AND end_date < ?', start_date.to_date.beginning_of_month, end_date.to_date.end_of_month]).count >= leave_type.probation_limit_request_count
							sandwich_count 	= 0
							request_count 	= 0
							message = "Leave Apply Limit within the #{leave_type.limit_request_tenure} Probation tenure reached."
						end
					elsif leave_type.probation_limit_request_tenure == "Annually"
						if LeaveRequest.where(:employee_id => employee.id, :leave_type_id => leave_type.id, :request_status => ["Waiting For Approval","Availed"]).where(['start_date > ? AND end_date < ?', start_date.to_date.beginning_of_year, end_date.to_date.end_of_year]).count >= leave_type.probation_limit_request_count
							sandwich_count 	= 0
							request_count 	= 0
							message = "Leave Apply Limit within the #{leave_type.limit_request_tenure} Probation tenure reached."
						end
					end
				end
			end
			########################################################################
			############## Verification of Leave Request on Probation ##############
			########################################################################
				
		else
			sandwich_count 	= 0
			request_count 	= 0
			message					= request_flow_status[1]
		end

		if message != request_flow_status[1]
			message = "#{message} #{request_flow_status[1]}"
		end

		return request_count, sandwich_count, message
	end

	########## Leave Approval Request ##########
	def leave_approval_request
		requested_employee 				= self.employee
		leave_type 								= self.leave_type
		requested_quota 					= self.request_count
		if self.is_composite == false
			allocated_leave = LeaveAllocation.find_by(:company_id => requested_employee.company_id, :is_active => true, :leave_type_id => self.leave_type_id, :employee_id => self.employee_id)
			if self.request_status == "Waiting For Approval"
				request_flow = RequestFlow.find_by(:company_id => requested_employee.company_id, :request_flow_type => "Leave Request")
				if request_flow.nil?
					########## Deducted Leave Quota ##########
					LeaveAllocation.deducted_leave_qouta(allocated_leave, requested_quota, requested_employee, leave_type, self, "Leave deducted becasue leave applied")
					self.request_status = "Availed"
					self.save
				else
					if request_flow.request_node == "Line Manager"
						approval_employee = self.employee.line_manager
						########## Deducted Leave Quota ##########
						LeaveAllocation.deducted_leave_qouta(allocated_leave, requested_quota, requested_employee, leave_type, self, "Leave deducted becasue leave applied")
						########## Send Approval Request ##########
						ApprovalRequest.generate_approval_request(requested_employee.company_id, requested_employee.id, approval_employee.id, request_flow.id, "Waiting For Approval", self.id, self.class.name)
						#############################################
						########## Notification Generation ##########
						#############################################
						request_by_user = requested_employee.user
						request_to_user = approval_employee.user
						if not request_by_user.nil?
							Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "Your #{leave_type.name} of #{self.request_count} Quota has forward to #{approval_employee.full_name} for Approval")
						end
						if not request_to_user.nil?
							Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "#{requested_employee.full_name} submitted a Leave Request")
						end
						if not (request_by_user.nil? or request_to_user.nil?)
							email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Leave Request")
							if not email_template.nil?
								EmailOutbound.initiate_email_notification(email_template, request_to_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user, self.approval_request)
							end
						end
						#############################################
						########## Notification Generation ##########
						#############################################
					elsif request_flow.request_node == "HOD"
						approval_employee = Employee.department_head(requested_employee)
						if not approval_employee.nil?
							########## Deducted Leave Quota ##########
							LeaveAllocation.deducted_leave_qouta(allocated_leave, requested_quota, requested_employee, leave_type, self, "Leave deducted becasue leave applied")
							########## Send Approval Request ##########
							ApprovalRequest.generate_approval_request(requested_employee.company_id, requested_employee.id, approval_employee.id, request_flow.id, "Waiting For Approval", self.id, self.class.name)
							#############################################
							########## Notification Generation ##########
							#############################################
							request_by_user = requested_employee.user
							request_to_user = approval_employee.user
							if not request_by_user.nil?
								Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "Your #{leave_type.name} of #{self.request_count} Quota has forward to #{approval_employee.full_name} for Approval")
							end
							if not request_to_user.nil?
								Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "#{requested_employee.full_name} submitted a Leave Request")
							end
							if not (request_by_user.nil? or request_to_user.nil?)
								email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Leave Request")
								if not email_template.nil?
									EmailOutbound.initiate_email_notification(email_template, request_to_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user, self.approval_request)
								end
							end
							#############################################
							########## Notification Generation ##########
							#############################################
						else
							########## Deducted Leave Quota ##########
							LeaveAllocation.deducted_leave_qouta(allocated_leave, requested_quota, requested_employee, leave_type, self, "Leave deducted becasue leave applied")
							#############################################
							########## Notification Generation ##########
							#############################################
							request_by_user = requested_employee.user
							request_to_user = approval_employee.user
							if not request_by_user.nil?
								Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "You Availed #{self.request_count} Quota of your #{leave_type.name}")
							end
							if not request_by_user.nil?
								email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Leave Approved")
								if not email_template.nil?
									EmailOutbound.initiate_email_notification(email_template, request_by_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user, self.approval_request)
								end
							end
							#############################################
							########## Notification Generation ##########
							#############################################
						end
					else
						########## Deducted Leave Quota ##########
						LeaveAllocation.deducted_leave_qouta(allocated_leave, requested_quota, requested_employee, leave_type, self, "Leave deducted becasue leave applied")
						#############################################
						########## Notification Generation ##########
						#############################################
						request_by_user = requested_employee.user
						request_to_user = approval_employee.user
						if not request_by_user.nil?
							Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "You Availed #{self.request_count} Quota of your #{leave_type.name}")
						end
						if not request_by_user.nil?
							email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Official Duty Approved")
							if not email_template.nil?
								EmailOutbound.initiate_email_notification(email_template, request_by_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user, self.approval_request)
							end
						end
						#############################################
						########## Notification Generation ##########
						#############################################
					end	
				end
			elsif self.request_status == "System Deducted"
				########## Deducted Leave Quota ##########
				LeaveAllocation.deducted_leave_qouta(allocated_leave, requested_quota, requested_employee, leave_type, self, "Leave Deducted By System")
			elsif self.request_status == "Cancelled"
				########## Revert Leave Quota ##########
				LeaveAllocation.revert_leave_qouta(allocated_leave, requested_quota, requested_employee, leave_type, self, "Leave Cancelled")
				########## Revert Approval Request ##########
				ApprovalRequest.revert_leave_request(self)
			elsif self.request_status == "Rejected"
				########## Revert Leave Quota ##########
				LeaveAllocation.revert_leave_qouta(allocated_leave, requested_quota, requested_employee, leave_type, self, "Leave Rejected")
			elsif self.request_status == "Revert"
				########## Revert Leave Quota ##########
				LeaveAllocation.revert_leave_qouta(allocated_leave, requested_quota, requested_employee, leave_type, self, "Leave Revert")
			end
		else
			merge_leave_type_ids = self.leave_type.composite_leave_types.where(:status => "Allowed").collect(&:merge_leave_type_id)
			leave_types = LeaveType.where(:id => merge_leave_type_ids).order('sort_order ASC')
			if self.request_status == "Waiting For Approval"
				request_flow = RequestFlow.find_by(:company_id => requested_employee.company_id, :request_flow_type => "Leave Request")
				if request_flow.nil?
					###################################################
					###################################################
					########## Combine Leave Deduction Logic ##########
					###################################################
					###################################################
					requested_quota_verification = self.combine_leave_deduction_pattern(leave_types, requested_employee, requested_quota)
					self.request_status = "Availed"
					self.save
				else
					if request_flow.request_node == "Line Manager"
						approval_employee = self.employee.line_manager
						###################################################
						###################################################
						########## Combine Leave Deduction Logic ##########
						###################################################
						###################################################
						requested_quota_verification = self.combine_leave_deduction_pattern(leave_types, requested_employee, requested_quota)
						########## Send Approval Request ##########
						ApprovalRequest.generate_approval_request(requested_employee.company_id, requested_employee.id, approval_employee.id, request_flow.id, "Waiting For Approval", self.id, self.class.name)
						#############################################
						########## Notification Generation ##########
						#############################################
						request_by_user = requested_employee.user
						request_to_user = approval_employee.user
						if not request_by_user.nil?
							Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "Your #{leave_type.name} of #{self.request_count} Quota has forward to #{approval_employee.full_name} for Approval")
						end
						if not request_to_user.nil?
							Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "#{requested_employee.full_name} submitted a Leave Request")
						end
						if not (request_by_user.nil? or request_to_user.nil?)
							email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Leave Request")
							if not email_template.nil?
								EmailOutbound.initiate_email_notification(email_template, request_to_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user, self.approval_request)
							end
						end
						#############################################
						########## Notification Generation ##########
						#############################################
					elsif request_flow.request_node == "HOD"
						approval_employee = Employee.department_head(requested_employee)
						if not approval_employee.nil?
							###################################################
							###################################################
							########## Combine Leave Deduction Logic ##########
							###################################################
							###################################################
							requested_quota_verification = self.combine_leave_deduction_pattern(leave_types, requested_employee, requested_quota)
							########## Send Approval Request ##########
							ApprovalRequest.generate_approval_request(requested_employee.company_id, requested_employee.id, approval_employee.id, request_flow.id, "Waiting For Approval", self.id, self.class.name)
							#############################################
							########## Notification Generation ##########
							#############################################
							request_by_user = requested_employee.user
							request_to_user = approval_employee.user
							if not request_by_user.nil?
								Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "Your #{leave_type.name} of #{self.request_count} Quota has forward to #{approval_employee.full_name} for Approval")
							end
							if not request_to_user.nil?
								Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "#{requested_employee.full_name} submitted a Leave Request")
							end
							if not (request_by_user.nil? or request_to_user.nil?)
								email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Leave Request")
								if not email_template.nil?
									EmailOutbound.initiate_email_notification(email_template, request_to_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user, self.approval_request)
								end
							end
							#############################################
							########## Notification Generation ##########
							#############################################
						else
							###################################################
							###################################################
							########## Combine Leave Deduction Logic ##########
							###################################################
							###################################################
							requested_quota_verification = false
							leave_types.each do |single_leave_type|
								allocated_leave = LeaveAllocation.find_by(:company_id => requested_employee.company_id, :is_active => true, :leave_type_id => single_leave_type.id, :employee_id => self.employee_id)
								if requested_quota_verification == false
									if allocated_leave.remaining_quota > 0
										if requested_quota == allocated_leave.remaining_quota
											requested_quota_verification = true
											LeaveRequestDetail.create(:leave_request_id => self.id, :leave_type_id => single_leave_type.id, :allocated_quota => allocated_leave.allocated_quota, :used_quota => allocated_leave.used_quota, :remaining_quota => allocated_leave.remaining_quota, :quota_transaction => requested_quota)
											LeaveAllocation.deducted_leave_qouta(allocated_leave, requested_quota, requested_employee, single_leave_type, self, "Leave deducted becasue leave applied")
										elsif requested_quota < allocated_leave.remaining_quota
											requested_quota_verification = true
											LeaveRequestDetail.create(:leave_request_id => self.id, :leave_type_id => single_leave_type.id, :allocated_quota => allocated_leave.allocated_quota, :used_quota => allocated_leave.used_quota, :remaining_quota => allocated_leave.remaining_quota, :quota_transaction => requested_quota)
											LeaveAllocation.deducted_leave_qouta(allocated_leave, requested_quota, requested_employee, single_leave_type, self, "Leave deducted becasue leave applied")
										elsif requested_quota > allocated_leave.remaining_quota
											deducted_quota 	= allocated_leave.remaining_quota
											requested_quota = requested_quota - allocated_leave.remaining_quota
											requested_quota_verification = false
											LeaveRequestDetail.create(:leave_request_id => self.id, :leave_type_id => single_leave_type.id, :allocated_quota => allocated_leave.allocated_quota, :used_quota => allocated_leave.used_quota, :remaining_quota => allocated_leave.remaining_quota, :quota_transaction => deducted_quota)
											LeaveAllocation.deducted_leave_qouta(allocated_leave, deducted_quota, requested_employee, single_leave_type, self, "Leave deducted becasue leave applied")
										end
									else
										requested_quota_verification = false
									end
								end
							end
							#############################################
							########## Notification Generation ##########
							#############################################
							request_by_user = requested_employee.user
							request_to_user = approval_employee.user
							if not request_by_user.nil?
								Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "You Availed #{self.request_count} Quota of your #{leave_type.name}")
							end
							if not request_by_user.nil?
								email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Leave Approved")
								if not email_template.nil?
									EmailOutbound.initiate_email_notification(email_template, request_by_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user, self.approval_request)
								end
							end
							#############################################
							########## Notification Generation ##########
							#############################################
						end
					else
						###################################################
						###################################################
						########## Combine Leave Deduction Logic ##########
						###################################################
						###################################################
						requested_quota_verification = self.combine_leave_deduction_pattern(leave_types, requested_employee, requested_quota)
						#############################################
						########## Notification Generation ##########
						#############################################
						request_by_user = requested_employee.user
						request_to_user = approval_employee.user
						if not request_by_user.nil?
							Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "You Availed #{self.request_count} Quota of your #{leave_type.name}")
						end
						if not request_by_user.nil?
							email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Official Duty Approved")
							if not email_template.nil?
								EmailOutbound.initiate_email_notification(email_template, request_by_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user, self.approval_request)
							end
						end
						#############################################
						########## Notification Generation ##########
						#############################################
					end	
				end
			elsif self.request_status == "Cancelled"
				########## Revert Leave Quota ##########
				self.leave_request_details.each do |leave_request_detail|
					single_leave_type = LeaveType.find leave_request_detail.leave_type_id
					allocated_leave = LeaveAllocation.find_by(:company_id => requested_employee.company_id, :is_active => true, :leave_type_id => single_leave_type.id, :employee_id => self.employee_id)
					LeaveAllocation.revert_leave_qouta(allocated_leave, leave_request_detail.quota_transaction, requested_employee, single_leave_type, self, "Leave Cancelled")
				end
				########## Revert Approval Request ##########
				ApprovalRequest.revert_leave_request(self)
			elsif self.request_status == "Rejected"
				########## Revert Leave Quota ##########
				self.leave_request_details.each do |leave_request_detail|
					single_leave_type = LeaveType.find leave_request_detail.leave_type_id
					allocated_leave = LeaveAllocation.find_by(:company_id => requested_employee.company_id, :is_active => true, :leave_type_id => single_leave_type.id, :employee_id => self.employee_id)
					LeaveAllocation.revert_leave_qouta(allocated_leave, leave_request_detail.quota_transaction, requested_employee, single_leave_type, self, "Leave Rejected")
				end
			elsif self.request_status == "Revert"
				########## Revert Leave Quota ##########
				self.leave_request_details.each do |leave_request_detail|
					single_leave_type = LeaveType.find leave_request_detail.leave_type_id
					allocated_leave = LeaveAllocation.find_by(:company_id => requested_employee.company_id, :is_active => true, :leave_type_id => single_leave_type.id, :employee_id => self.employee_id)
					LeaveAllocation.revert_leave_qouta(allocated_leave, leave_request_detail.quota_transaction, requested_employee, single_leave_type, self, "Leave Revert")
				end
			end
		end

		if self.request_status == "Availed"
			########## Add Impact on Attendance ##########
			EmployeeAttendance.auto_impact_on_attendance_of_request("leave_request", self.start_date, self.end_date, self.employee)
		end

		if self.request_status == "Revert"
			########## Remove Impact on Attendance ##########
			LeaveRequest.remove_impact_on_attendance_of_request(self.start_date, self.end_date, self.employee)
		end
	end

	########## Combine Leave Deduction Logic ##########
	def combine_leave_deduction_pattern(leave_types, requested_employee, requested_quota)
		########## Default Value False ##########
		requested_quota_verification = false
		leave_types.each do |single_leave_type|
			allocated_leave = LeaveAllocation.find_by(:company_id => requested_employee.company_id, :is_active => true, :leave_type_id => single_leave_type.id, :employee_id => self.employee_id)
			########## Verification of Leave Allocated to Employee or Not ##########
			if not allocated_leave.nil?
				########## Validation of Applied Quota Deducted ##########
				if requested_quota_verification == false
					########## Validation of Applied Quota Deducted ##########
					if allocated_leave.remaining_quota > 0
						if requested_quota == allocated_leave.remaining_quota
							########## Applied Quota equal to remaining quota ##########
							requested_quota_verification = true
							########## Applied Leave Quota Total Deducted ##########
							LeaveRequestDetail.create(:leave_request_id => self.id, :leave_type_id => single_leave_type.id, :allocated_quota => allocated_leave.allocated_quota, :used_quota => allocated_leave.used_quota, :remaining_quota => allocated_leave.remaining_quota, :quota_transaction => requested_quota)
							LeaveAllocation.deducted_leave_qouta(allocated_leave, requested_quota, requested_employee, single_leave_type, self, "Leave deducted becasue leave applied")
						elsif requested_quota < allocated_leave.remaining_quota
							########## Applied Quota is less than remaining quota ##########
							requested_quota_verification = true
							########## Applied Leave Quota Total Deducted ##########
							LeaveRequestDetail.create(:leave_request_id => self.id, :leave_type_id => single_leave_type.id, :allocated_quota => allocated_leave.allocated_quota, :used_quota => allocated_leave.used_quota, :remaining_quota => allocated_leave.remaining_quota, :quota_transaction => requested_quota)
							LeaveAllocation.deducted_leave_qouta(allocated_leave, requested_quota, requested_employee, single_leave_type, self, "Leave deducted becasue leave applied")
						elsif requested_quota > allocated_leave.remaining_quota
							########## Applied Quota is less than remaining quota ##########
							deducted_quota 	= allocated_leave.remaining_quota
							requested_quota = requested_quota - allocated_leave.remaining_quota
							requested_quota_verification = false
							########## Applied Leave Quota not Total Deducted ##########
							LeaveRequestDetail.create(:leave_request_id => self.id, :leave_type_id => single_leave_type.id, :allocated_quota => allocated_leave.allocated_quota, :used_quota => allocated_leave.used_quota, :remaining_quota => allocated_leave.remaining_quota, :quota_transaction => deducted_quota)
							LeaveAllocation.deducted_leave_qouta(allocated_leave, deducted_quota, requested_employee, single_leave_type, self, "Leave deducted becasue leave applied")
						end
					else
						requested_quota_verification = false
					end
				end
			end
		end
		return requested_quota_verification
	end

	########## Leave Impact on Employee Attendance ##########
	def self.employee_wise_leave_impact(employee_attendance)
		LeaveRequest.where(:employee_id => employee_attendance.employee_id, :request_status => "Availed").where("Date(start_date) <= ? AND Date(end_date) >= ?", employee_attendance.attendance_date.to_date, employee_attendance.attendance_date.to_date).each do |leave_request|
			employee_attendance.attendance_status = "On Leave (#{leave_request.leave_type_name})"	    
	    employee_attendance.early_left_status = ""
	    employee_attendance.remarks						= ""
	    employee_attendance.other_remarks			= ""
	    employee_attendance.encashable_quota 					= 0.0
	    employee_attendance.checkout_deduction 				= 0.0
			employee_attendance.checkin_deduction 				= 0.0
			if employee_attendance.is_ot_approved == false
				employee_attendance.approved_overtime 				= 0.0
				employee_attendance.approved_overtime_hours 	= 0.0
				employee_attendance.approved_overtime_minutes = 0.0
				employee_attendance.actual_overtime_hours 		= 0.0
				employee_attendance.actual_overtime_minutes 	= 0.0
				employee_attendance.is_ot_approved						= false
				employee_attendance.over_time_hours 					= 0.0
				employee_attendance.over_time_minutes 				= 0.0
				employee_attendance.over_time_seconds 				= 0.0
			end
			employee_attendance.off_days_payment_days 		= 0.0
			employee_attendance.no_of_cpl 								= 0.0
			employee_attendance.pay_deduction							= 0.0
			employee_attendance.minute_deducted						= 0.0
			employee_attendance.minute_earned							= 0.0
			employee_attendance.incentive_verified 				= false
			employee_attendance.is_on_leave 							= true
			employee_attendance.is_official_duty 					= false
			employee_attendance.is_relaxation 						= false
			employee_attendance.deduction_from_quota			= false
			employee_attendance.deduction_from_salary			= false
			unless ENV['APP_URL'].include? 'attendancebe.cressettech.com'
				employee_attendance.in_time										= nil
				employee_attendance.out_time									= nil
			end
			if leave_request.leave_type.is_leave_without_pay == true
				employee_attendance.is_leave_without_pay 		= true
				employee_attendance.deduction_from_salary		= true
				employee_attendance.pay_deduction						= leave_request.request_count > 1 ? 1.0 : leave_request.request_count
			end
	    employee_attendance.save
		end
	end

	########## Revert Leave Impact on Employee Attendance ##########
	def self.remove_impact_on_attendance_of_request(start_date, end_date, employee)
		date_range = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
		date_range.each do |single_date|
			if EmployeeAttendance.where(:employee_id => employee.id, :attendance_date => single_date).empty?
				if employee.joining_date.to_date <= single_date
					EmployeeAttendance.create_empty_attenance_record(single_date, employee)
				end
			end
		end

		########## Update Attendance Information with Employee Roster ##########
		EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_on_leave => true).order('attendance_date ASC').each do |employee_attendance|
			EmployeeRoster.update_employee_roster(employee_attendance.attendance_date.to_date, employee_attendance)
		end

		########## Update Attendance Information with Employee Roster ##########
		EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_on_leave => true).order('attendance_date ASC').each do |employee_attendance|
			EmployeeAttendance.update_employee_detail(employee_attendance, employee)
		end

		########## Revert Leave Impact on Attendance ##########
		EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_on_leave => true).each do |employee_attendance|
			EmployeeAttendance.clear_attendance_record_for_request_impact(employee_attendance)
		end

		########## Process Employee Attendance Information ##########
		EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_on_leave => false).order('attendance_date ASC').each do |employee_attendance|
			EmployeeAttendance.single_employee_process_attendance(employee_attendance)
		end
	end

	########## Arrear Entry ##########
	def record_arrear
		system_setting = SystemSetting.find_by(:company_id => self.company_id)
		if not system_setting.nil?
			if system_setting.auto_arrear == true
				if self.request_status == "Availed"
					if self.start_date.present? and self.end_date.present?
						employee_attendances = EmployeeAttendance.where(employee_id: self.employee_id, is_finalized: true, attendance_date: self.start_date.to_date..self.end_date.to_date)
						if employee_attendances.count > 0
							if EmployeeArrear.where(:leave_request_id => self.id).count == 0
								employee_arrear = EmployeeArrear.new
								employee_arrear.company_id				= self.company_id
								employee_arrear.employee_id 			= self.employee_id
								employee_arrear.leave_request_id 	= self.id
								employee_arrear.arrear_days	 			= self.request_count
								employee_arrear.arrear_type 			= "LeaveRequest"
								employee_arrear.start_date 				= self.start_date
								employee_arrear.end_date 					= self.end_date
								employee_arrear.arrears_month 		= Time.now
								employee_arrear.save
							end
						end
					end
				end
			end
		end
	end

	def leave_type_name
		if self.leave_type.nil?
			return "-"
		else
			self.leave_type.name
		end
	end

	def employee_name
		if self.employee.nil?
			return "-"
		else
			self.employee.full_name
		end
	end

	def employee_code
		if self.employee.nil?
			return "-"
		else
			self.employee.employee_code
		end
	end

	def employee_id
		if self.employee.nil?
			return "-"
		else
			self.employee.id
		end
	end

	def calculate_combine_leave_balance(employee, leave_type)
		allocated_leave = LeaveAllocation.find_by(:company_id => employee.company_id, :is_active => true, :leave_type_id => leave_type.id, :employee_id => self.employee_id)
	end

end
