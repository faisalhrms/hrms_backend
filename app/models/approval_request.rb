class ApprovalRequest < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:requestable, polymorphic: true
	belongs_to 	:company
	belongs_to 	:request_flow
	belongs_to	:request_sender, 					foreign_key: :request_sender_id, 		:class_name => 'Employee'
	belongs_to	:request_receiver, 				foreign_key: :request_receiver_id, 	:class_name => 'Employee'

	validate :restrict_approval_days

	scope :get_leave_requests, -> { where(:requestable_type => 'LeaveRequest') }
	scope :get_od_requests, -> { where(:requestable_type => 'OfficialDuty') }
	scope :get_fa_requests, -> { where(:requestable_type => 'CplEarning') }

	def restrict_approval_days
		allowed_days = RestrictLeave.allowed_approval_days
		if allowed_days and !RestrictLeave.admin.include?(User.current) and created_at and (created_at + allowed_days.days).to_date < Date.today
			status = self.approval_request_status.downcase.include?('approve') ? 'approve' : 'reject'
			self.errors.add(:base, "You can only #{status} #{self.requestable_type.split(/(?=[A-Z])/).join(' ')} within #{allowed_days} days of #{self.requestable_type.split(/(?=[A-Z])/).join(' ')} applied.")
		end
	end

	def self.generate_approval_request(company_id, sender_id, receiver_id, request_flow_id, request_status, request_id, request_type)
		approval_request = ApprovalRequest.new
		approval_request.company_id 							= company_id
		approval_request.request_sender_id 				= sender_id
		approval_request.request_receiver_id 			= receiver_id
		approval_request.request_flow_id 					= request_flow_id
		approval_request.approval_request_status 	= request_status
		approval_request.is_approved 							= false
		approval_request.requestable_id 					= request_id
		approval_request.requestable_type 				= request_type
		approval_request.save
    approval_request.update_column(:token, approval_request.get_token(approval_request.id))
  end

	def approval_status
		if self.is_approved == true && self.approval_request_status == "Approved"
			if self.requestable_type == "LeaveRequest"
				leave_request = LeaveRequest.find(approval_request.requestable_id)
				leave_request.request_status = "Availed"
				leave_request.save
			end
		elsif	self.is_approved == false && self.approval_request_status == "Cancelled"
			if self.requestable_type == "LeaveRequest"
				leave_request = LeaveRequest.find(approval_request.requestable_id)
				leave_request.request_status 	= "Cancelled"
				leave_request.is_cancelled 		= true
				leave_request.save
			end
		end
	end

	def self.revert_leave_request(leave_request)
		approval_request = ApprovalRequest.find_by(:requestable_id => leave_request.id, :requestable_type => leave_request.class.name)
		if not approval_request.nil?
			approval_request.approval_request_status = "Cancelled"
			approval_request.save
			#############################################
			########## Notification Generation ##########
			#############################################
			leave_type = leave_request.leave_type
			request_by_user = approval_request.request_sender.user
			request_to_user = approval_request.request_receiver.user
			if not request_by_user.nil?
				Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "You Cancelled your #{leave_type.name} of #{leave_request.request_count} Quota")
			end
			if not request_to_user.nil?
				Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "#{approval_request.request_sender.full_name} Cancelled #{leave_type.name} Request")
			end
			if not (request_by_user.nil? or request_to_user.nil?)
				email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Leave Cancelled")
				if not email_template.nil?
					EmailOutbound.initiate_email_notification(email_template, request_to_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user)
				end
			end
			#############################################
			########## Notification Generation ##########
			#############################################
		end
	end

	def add_impact_in_leave_request(current_user)
		if self.requestable_type == "LeaveRequest"
			if self.approval_request_status == "Approved"
				leave_request = LeaveRequest.find(self.requestable_id)
				leave_request.request_status 	= "Availed"
				request_user_full_name 				= ReportFormat.request_user_full_name(current_user)
				leave_request.approval_name 	= request_user_full_name
				leave_request.approval_datetime = Time.now
				leave_request.save(validate: false)
				#############################################
				########## Notification Generation ##########
				#############################################
				leave_type = leave_request.leave_type
				request_by_user = self.request_sender.user
				request_to_user = self.request_receiver.user
				if not request_by_user.nil?
					Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "Your #{leave_type.name} of #{leave_request.request_count} Quota Request Approved by #{self.request_receiver.full_name}")
				end
				if not request_to_user.nil?
					Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "You Approved Leave Request of #{self.request_sender.full_name}")
				end
				if not (request_by_user.nil? or request_to_user.nil?)
					email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Leave Approved")
					if not email_template.nil?
						EmailOutbound.initiate_email_notification(email_template, request_by_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user)
					end
				end
				#############################################
				########## Notification Generation ##########
				#############################################
			elsif self.approval_request_status == "Rejected"
				leave_request = LeaveRequest.find(self.requestable_id)
				leave_request.is_cancelled = true
		    leave_request.request_status = "Rejected"
		    leave_request.save(validate: false)
		    #############################################
				########## Notification Generation ##########
				#############################################
				leave_type = leave_request.leave_type
				request_by_user = self.request_sender.user
				request_to_user = self.request_receiver.user
				if not request_by_user.nil?
					Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "Your #{leave_type.name} of #{leave_request.request_count} Quota Request Rejected by #{self.request_receiver.full_name}")
				end
				if not request_to_user.nil?
					Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "You Rejected Leave Request of #{self.request_sender.full_name}")
				end
				if not (request_by_user.nil? or request_to_user.nil?)
					email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Leave Rejected")
					if not email_template.nil?
						EmailOutbound.initiate_email_notification(email_template, request_by_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user)
					end
				end
				#############################################
				########## Notification Generation ##########
				#############################################
			end
		end
	end

	def self.revert_official_duty_request(official_duty)
		approval_request = ApprovalRequest.find_by(:requestable_id => official_duty.id, :requestable_type => official_duty.class.name)
		approval_request.approval_request_status = "Cancelled"
		approval_request.save
		#############################################
		########## Notification Generation ##########
		#############################################
		request_by_user = approval_request.request_sender.user
		request_to_user = approval_request.request_receiver.user
		if not request_by_user.nil?
			Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "You Cancelled your Official Duty")
		end
		if not request_to_user.nil?
			Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "#{approval_request.request_sender.full_name} Cancelled Official Duty Request")
		end
		if not (request_by_user.nil? or request_to_user.nil?)
			email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Official Duty Cancelled")
			if not email_template.nil?
				EmailOutbound.initiate_email_notification(email_template, request_to_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user)
			end
		end
		#############################################
		########## Notification Generation ##########
		#############################################
	end

  def self.revert_cpl_earning_request(cpl_earning)
    approval_request = ApprovalRequest.find_by(:requestable_id => cpl_earning.id, :requestable_type => cpl_earning.class.name)
    if not approval_request.nil?
      approval_request.approval_request_status = "Cancelled"
      approval_request.save
      #############################################
      ########## Notification Generation ##########
      #############################################
      request_by_user = approval_request.request_sender.user
      request_to_user = approval_request.request_receiver.user
      if not request_by_user.nil?
        Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "You Cancelled your Cpl Earning")
      end
      if not request_to_user.nil?
        Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "#{approval_request.request_sender.full_name} Cancelled Cpl Earning Request")
      end
      if not (request_by_user.nil? or request_to_user.nil?)
        email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Cpl Earning Cancelled")
        if not email_template.nil?
          EmailOutbound.initiate_email_notification(email_template, request_to_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user)
        end
      end
      #############################################
      ########## Notification Generation ##########
      #############################################
    end
  end

  def add_impact_in_official_duty_request(current_user)
		if self.requestable_type == "OfficialDuty"
			if self.approval_request_status == "Approved"
				official_duty = OfficialDuty.find(self.requestable_id)
				official_duty.request_status 	= "Availed"
				request_user_full_name 				= ReportFormat.request_user_full_name(current_user)
				official_duty.approval_name 	= request_user_full_name
				official_duty.approval_datetime = Time.now
				official_duty.save(validate: false)
				#############################################
				########## Notification Generation ##########
				#############################################
				request_by_user = self.request_sender.user
				request_to_user = self.request_receiver.user
				if not request_by_user.nil?
					Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "Your Official Duty Request Approved by #{self.request_receiver.full_name}")
				end
				if not request_to_user.nil?
					Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "You Approved Official Duty Request of #{self.request_sender.full_name}")
				end
				if not (request_by_user.nil? or request_to_user.nil?)
					email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Official Duty Approved")
					if not email_template.nil?
						EmailOutbound.initiate_email_notification(email_template, request_by_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user)
					end
				end
				#############################################
				########## Notification Generation ##########
				#############################################
			elsif self.approval_request_status == "Rejected"
				official_duty = OfficialDuty.find(self.requestable_id)
				official_duty.is_cancelled = true
		    official_duty.request_status = "Rejected"
				official_duty.save(validate: false)
		    #############################################
				########## Notification Generation ##########
				#############################################
				request_by_user = self.request_sender.user
				request_to_user = self.request_receiver.user
				if not request_by_user.nil?
					Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "Your Official Duty Request Rejected by #{self.request_receiver.full_name}")
				end
				if not request_to_user.nil?
					Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "You Rejected Official Duty Request of #{self.request_sender.full_name}")
				end
				if not (request_by_user.nil? or request_to_user.nil?)
					email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Official Duty Rejected")
					if not email_template.nil?
						EmailOutbound.initiate_email_notification(email_template, request_by_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user)
					end
				end
				#############################################
				########## Notification Generation ##########
				#############################################
			end
		end
	end

	def add_impact_in_cpl_earning(current_user)
		if self.requestable_type == 'CplEarning'
			if self.approval_request_status == 'Approved'
				cpl_earning = CplEarning.find(self.requestable_id)
				request_user_full_name = ReportFormat.request_user_full_name(current_user)
    		cpl_earning.approval_name = request_user_full_name
				cpl_earning.status = "Availed"
				cpl_earning.save(validate: false)
				EmployeeAttendance.auto_impact_on_attendance_of_request('cpl_request', cpl_earning.employee_attendance.attendance_date, cpl_earning.employee_attendance.attendance_date, cpl_earning.employee)
				#############################################
				########## Notification Generation ##########
				#############################################
				request_by_user = self.request_sender.user
				request_to_user = self.request_receiver.user
				if not request_by_user.nil?
					Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "Your Cpl Earning Request Approved by #{self.request_receiver.full_name}")
				end
				if not request_to_user.nil?
					Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "You Approved Cpl Earning Request of #{self.request_sender.full_name}")
				end
				if not (request_by_user.nil? or request_to_user.nil?)
					email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => 'Cpl Earning Approved')
					if not email_template.nil?
            EmailOutbound.initiate_email_notification(email_template, request_by_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user)
					end
				end
				#############################################
				########## Notification Generation ##########
				#############################################
			elsif self.approval_request_status == "Rejected"
				cpl_earning = CplEarning.find(self.requestable_id)
		    cpl_earning.status = "Rejected"
				cpl_earning.save(validate: false)
		    #############################################
				########## Notification Generation ##########
				#############################################
				request_by_user = self.request_sender.user
				request_to_user = self.request_receiver.user
				if not request_by_user.nil?
					Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "Your Cpl Earning Request Rejected by #{self.request_receiver.full_name}")
				end
				if not request_to_user.nil?
					Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "You Rejected Cpl Earning Request of #{self.request_sender.full_name}")
				end
				if not (request_by_user.nil? or request_to_user.nil?)
					email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Cpl Earning Rejected")
					if not email_template.nil?
            EmailOutbound.initiate_email_notification(email_template, request_by_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user)
					end
				end
				#############################################
				########## Notification Generation ##########
				#############################################
			end
		end
	end

	def self.revert_relaxation_request(relaxation)
		approval_request = ApprovalRequest.find_by(:requestable_id => relaxation.id, :requestable_type => relaxation.class.name)
		approval_request.approval_request_status = "Cancelled"
		approval_request.save
		#############################################
		########## Notification Generation ##########
		#############################################
		request_by_user = approval_request.request_sender.user
		request_to_user = approval_request.request_receiver.user
		if not request_by_user.nil?
			Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "You Cancelled your Relaxation")
		end
		if not request_to_user.nil?
			Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "#{approval_request.request_sender.full_name} Cancelled Relaxation Request")
		end
		if not (request_by_user.nil? or request_to_user.nil?)
			email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Relaxation Cancelled")
			if not email_template.nil?
				EmailOutbound.initiate_email_notification(email_template, request_to_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user)
			end
		end
		#############################################
		########## Notification Generation ##########
		#############################################
	end

	def add_impact_in_relaxation_request(current_user)
		if self.requestable_type == "RelaxationRequest"
			if self.approval_request_status == "Approved"
				relaxation = RelaxationRequest.find(self.requestable_id)
				relaxation.request_status = "Availed"
				request_user_full_name 		= ReportFormat.request_user_full_name(current_user)
				relaxation.approval_name 	= request_user_full_name
				relaxation.approval_datetime = Time.now
				relaxation.save
				#############################################
				########## Notification Generation ##########
				#############################################
				request_by_user = self.request_sender.user
				request_to_user = self.request_receiver.user
				if not request_by_user.nil?
					Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "Your Relaxation Request Approved by #{self.request_receiver.full_name}")
				end
				if not request_to_user.nil?
					Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "You Approved Relaxation Request of #{self.request_sender.full_name}")
				end
				if not (request_by_user.nil? or request_to_user.nil?)
					email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Relaxation Approved")
					if not email_template.nil?
						EmailOutbound.initiate_email_notification(email_template, request_by_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user)
					end
				end
				#############################################
				########## Notification Generation ##########
				#############################################
			elsif self.approval_request_status == "Rejected"
				relaxation = RelaxationRequest.find(self.requestable_id)
				relaxation.is_cancelled = true
		    relaxation.request_status = "Rejected"
		    relaxation.save
		    #############################################
				########## Notification Generation ##########
				#############################################
				request_by_user = self.request_sender.user
				request_to_user = self.request_receiver.user
				if not request_by_user.nil?
					Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "Your Relaxation Request Rejected by #{self.request_receiver.full_name}")
				end
				if not request_to_user.nil?
					Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "You Rejected Relaxation Request of #{self.request_sender.full_name}")
				end
				if not (request_by_user.nil? or request_to_user.nil?)
					email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Relaxation Rejected")
					if not email_template.nil?
						EmailOutbound.initiate_email_notification(email_template, request_by_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user)
					end
				end
				#############################################
				########## Notification Generation ##########
				#############################################
			end
		end
	end

  def get_token(item_id)
    str = [('a'..'z'), (0..9), ('A'..'Z')].map { |i| i.to_a }.flatten
    "#{item_id}-#{(0...50).map { str[rand(str.length)] }.join}"
  end
end

