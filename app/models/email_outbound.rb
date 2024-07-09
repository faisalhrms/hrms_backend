class EmailOutbound < ApplicationRecord

	####### Relation Ship #########
	belongs_to :company
	belongs_to :email_configration
	belongs_to :email_template

	after_create :schedule_email

	def schedule_email
    delivery_options = {}
    if ENV["EMAIL_ENV"] == 'production'
      delivery_options[:host] = 'http://hcm.sapphirepakistan.pk'
			delivery_options[:address] = self.server_address
			delivery_options[:domain] = self.server_domain
			delivery_options[:port] = self.server_port
			delivery_options[:user_name] = self.server_user_name
			delivery_options[:password] = self.server_password
			delivery_options[:openssl_verify_mode] = 'none'
			delivery_options[:authentication] = 'login'
			delivery_options[:enable_starttls_auto] = true
    end
    uMailer = UserMailer.send_email_notification(self.from_address, self.to_address, self.subject, self.message, self.cc_address, delivery_options)
    uMailer.deliver_later
	end

	# EmailOutbound.initiate_trigger(email_template, sender_email)
	def self.initiate_trigger(email_template, sender_email)
		if email_template.is_active == true
			email_configration = email_template.email_configration
			if email_configration.is_active == true
				exempted_address = []
				if email_template.is_exempted == true
					exempted_address = email_template.exempted_address.split(',')
				end
				if exempted_address.include?(sender_email) == false
					email_outbound = EmailOutbound.new
					email_outbound.company_id = email_template.company_id
					email_outbound.email_configration_id = email_template.email_configration_id
					email_outbound.email_template_id = email_template.id
					email_outbound.from_address = email_configration.email
					email_outbound.to_address = sender_email
					email_outbound.cc_address = email_template.cc_address
					email_outbound.subject = email_template.subject
					email_outbound.server_user_name = email_configration.user_name
					email_outbound.server_email = email_configration.email
					email_outbound.server_password = email_configration.password
					email_outbound.server_address = email_configration.outgoing_server_address
					email_outbound.server_port = email_configration.outgoing_server_port
					email_outbound.server_domain = email_configration.domain
					email_outbound.is_cc = email_template.is_cc
					email_outbound.message = email_template.message
					email_outbound.save
				end
			end
		end
	end

	# EmailOutbound.initiate_email_notification(email_template, sender_email, sender_name, receiver_name)
	def self.initiate_email_notification(email_template, sender_email, sender_name, receiver_name, sender_employee, receiver_employee, approval_request = nil)
		if email_template.is_active == true
			email_configration = email_template.email_configration
			if email_configration.is_active == true
				exempted_address = []
				if email_template.is_exempted == true
					exempted_address = email_template.exempted_address.split(',')
				end
				if exempted_address.include?(sender_email) == false
					email_outbound = EmailOutbound.new
					email_outbound.company_id = email_template.company_id
					email_outbound.email_configration_id = email_template.email_configration_id
					email_outbound.email_template_id = email_template.id
					email_outbound.from_address = email_configration.email
					email_outbound.to_address = sender_email
					email_outbound.cc_address = email_template.cc_address
					email_outbound.subject = email_template.subject
					email_outbound.server_user_name = email_configration.user_name
					email_outbound.server_email = email_configration.email
					email_outbound.server_password = email_configration.password
					email_outbound.server_address = email_configration.outgoing_server_address
					email_outbound.server_port = email_configration.outgoing_server_port
					email_outbound.server_domain = email_configration.domain
					email_outbound.is_cc = email_template.is_cc
					message = email_template.message
					if approval_request
						message = message.gsub("{ApproveRequestLink}", "<a style='background-color:#4CAF50;border:none;color:white;padding: 12px 20px;text-align:center;text-decoration:none;display:inline-block;font-size:16px;margin:4px 2px;cursor: pointer;' href='#{ENV['APP_URL']}/api/web/approval_requests/approve_by_email?token=#{approval_request.token}'>Approve</a>")
						message = message.gsub("{RejectRequestLink}", "<a style='background-color:#f44336;border:none;color:white;padding: 12px 20px;text-align:center;text-decoration:none;display:inline-block;font-size:16px;margin:4px 2px;cursor: pointer;' href='#{ENV['APP_URL']}/api/web/approval_requests/reject_by_email?token=#{approval_request.token}'>Reject</a>")
						message = message.gsub("{Reason}", "#{approval_request.requestable.reason}")
					end
					message = message.gsub('{salutation}', receiver_employee.employee.try(:salutation))
					message = message.gsub("{SenderName}", "#{sender_name}")
					message = message.gsub("{ReceivedEmployee}", "#{receiver_name}")
					sender_mobile_number = ReportFormat.phone_format(sender_employee.employee.official_mobile_number)
					message = message.gsub("{sender_official_mobile_number}", "#{sender_mobile_number}")
					message = message.gsub("{sender_designation}", "#{sender_employee.employee.designation_name}")
					message = message.gsub("{sender_company}", "#{sender_employee.employee.company_name}")
					email_outbound.message = message
					email_outbound.save
				end
			end
		end
	end

	# EmailOutbound.initiate_2nd_email_notification(email_template, sender_email, sender_name, receiver_name)
	def self.initiate_2nd_email_notification(email_template, sender_email, sender_name, receiver_name, sender_employee, receiver_employee, request_sender_name)
		if email_template.is_active == true
			email_configration = email_template.email_configration
			if email_configration.is_active == true
				exempted_address = []
				if email_template.is_exempted == true
					exempted_address = email_template.exempted_address.split(',')
				end
				if exempted_address.include?(sender_email) == false
					email_outbound = EmailOutbound.new
					email_outbound.company_id = email_template.company_id
					email_outbound.email_configration_id = email_template.email_configration_id
					email_outbound.email_template_id = email_template.id
					email_outbound.from_address = email_configration.email
					email_outbound.to_address = sender_email
					email_outbound.cc_address = email_template.cc_address
					email_outbound.subject = email_template.subject
					email_outbound.server_user_name = email_configration.user_name
					email_outbound.server_email = email_configration.email
					email_outbound.server_password = email_configration.password
					email_outbound.server_address = email_configration.outgoing_server_address
					email_outbound.server_port = email_configration.outgoing_server_port
					email_outbound.server_domain = email_configration.domain
					email_outbound.is_cc = email_template.is_cc
					message = email_template.message
					message = message.gsub("{SenderName}", "#{sender_name}")
					message = message.gsub("{ReceivedEmployee}", "#{receiver_name}")
					message = message.gsub("{FirstApprovalName}", "#{request_sender_name}")
					sender_mobile_number = ReportFormat.phone_format(sender_employee.employee.official_mobile_number)
					message = message.gsub("{sender_official_mobile_number}", "#{sender_mobile_number}")
					message = message.gsub("{sender_designation}", "#{sender_employee.employee.designation_name}")
					message = message.gsub("{sender_company}", "#{sender_employee.employee.company_name}")
					email_outbound.message = message
					email_outbound.save
				end
			end
		end
	end

	# EmailOutbound.send_custom_email(email_template, sender_email, email_message)
	def self.send_custom_email(email_template, sender_email, email_message, email_subject = email_template.subject)
		if email_template.is_active == true
			email_configration = email_template.email_configration
			if email_configration.is_active == true
				if EmailOutbound.where(:to_address => sender_email, :subject => email_template.subject).count == 0
					email_outbound = EmailOutbound.new
					email_outbound.company_id = email_template.company_id
					email_outbound.email_configration_id = email_template.email_configration_id
					email_outbound.email_template_id = email_template.id
					email_outbound.from_address = email_configration.email
					email_outbound.to_address = sender_email
					email_outbound.cc_address = email_template.cc_address
					email_outbound.subject = email_subject
					email_outbound.server_user_name = email_configration.user_name
					email_outbound.server_email = email_configration.email
					email_outbound.server_password = email_configration.password
					email_outbound.server_address = email_configration.outgoing_server_address
					email_outbound.server_port = email_configration.outgoing_server_port
					email_outbound.server_domain = email_configration.domain
					email_outbound.is_cc = email_template.is_cc
					message = email_message
					email_outbound.message = message
					email_outbound.save
				end
			end
		end
	end

end