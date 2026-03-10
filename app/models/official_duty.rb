class OfficialDuty < ApplicationRecord
	include RestrictRequest

	OFFICE_DUTY_MODE = "Office Duty".freeze
	WORK_FROM_HOME_MODE = "Work From Home (WFH)".freeze
	LEGACY_ON_OFFICIAL_DUTY_STATUS = "On Official Duty".freeze
	OFFICIAL_DUTY_MODES = [OFFICE_DUTY_MODE, WORK_FROM_HOME_MODE].freeze

	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:employee

	has_one    	:approval_request, class_name: 'ApprovalRequest', as: :requestable

	########## Validation ############
  before_validation :set_default_official_duty_mode
  validate 		:validate_the_apply_date

  ########## Call Back ############
  after_save 	:official_duty_approval_request
  after_save 	:record_arrear

  ########## Validation of Official Duty Application ##########
	def validate_the_apply_date
		applied_status = false
		if self.request_status == "Waiting For Approval"
			if self.id.present?
				OfficialDuty.where.not(id:self.id).where(employee_id: self.employee_id, is_cancelled: false, request_status: ["Waiting For 2nd Approval", "Waiting For Approval", "Availed", "System Deducted"]).each do |official_duty|
					if self.id != official_duty.id
						if official_duty.start_date.present? and official_duty.end_date.present?
							if (official_duty.start_date <= self.start_date and official_duty.end_date >= self.start_date) or (official_duty.end_date >= self.end_date and official_duty.start_date <= self.end_date)
								applied_status = true
								self.errors.add(:base, "Official Duty Request Already Applied! from #{official_duty.start_date.to_date.strftime("%d-%b-%Y")} to #{official_duty.end_date.to_date.strftime("%d-%b-%Y")}")
							end
						end
					end
				end
			else
				OfficialDuty.where(employee_id: self.employee_id, is_cancelled: false, request_status: ["Waiting For 2nd Approval", "Waiting For Approval", "Availed", "System Deducted"]).each do |official_duty|
					if self.id != official_duty.id
						if official_duty.start_date.present? and official_duty.end_date.present?
							if (official_duty.start_date <= self.start_date and official_duty.end_date >= self.start_date) or (official_duty.end_date >= self.end_date and official_duty.start_date <= self.end_date)
								applied_status = true
								self.errors.add(:base, "Official Duty Request Already Applied! from #{official_duty.start_date.to_date.strftime("%d-%b-%Y")} to #{official_duty.end_date.to_date.strftime("%d-%b-%Y")}")
							end
						end
					end
				end
			end
		end

		if self.request_status == "Waiting For 2nd Approval"
			if self.id.present?
				OfficialDuty.where.not(id:self.id).where(employee_id: self.employee_id, is_cancelled: false, request_status: ["Waiting For 2nd Approval", "Waiting For Approval", "Availed", "System Deducted"]).each do |official_duty|
					if self.id != official_duty.id
						if official_duty.start_date.present? and official_duty.end_date.present?
							if (official_duty.start_date <= self.start_date and official_duty.end_date >= self.start_date) or (official_duty.end_date >= self.end_date and official_duty.start_date <= self.end_date)
								applied_status = true
								self.errors.add(:base, "Official Duty Request Already Applied! from #{official_duty.start_date.to_date.strftime("%d-%b-%Y")} to #{official_duty.end_date.to_date.strftime("%d-%b-%Y")}")
							end
						end
					end
				end
			else
				OfficialDuty.where(employee_id: self.employee_id, is_cancelled: false, request_status: ["Waiting For 2nd Approval", "Waiting For Approval", "Availed", "System Deducted"]).each do |official_duty|
					if self.id != official_duty.id
						if official_duty.start_date.present? and official_duty.end_date.present?
							if (official_duty.start_date <= self.start_date and official_duty.end_date >= self.start_date) or (official_duty.end_date >= self.end_date and official_duty.start_date <= self.end_date)
								applied_status = true
								self.errors.add(:base, "Official Duty Request Already Applied! from #{official_duty.start_date.to_date.strftime("%d-%b-%Y")} to #{official_duty.end_date.to_date.strftime("%d-%b-%Y")}")
							end
						end
					end
				end
			end
		end

		logger.info "#{self.errors}"
	end

	########## Calculation of Official Duty that requested to Applied ##########
	def self.calculate_official_duty(employee, start_date, end_date)
		message = "No issue in Official Duty Request. You are allowed to apply Official Duty."
		date_range = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
		request_count  = date_range.count

		############## Verification of Official Duty Request	##############
		request_flow_status = RequestFlow.verification_of_request_flow(employee, "Official Duty Request")

		if request_flow_status[0] == false
			request_count 	= 0
			message					= request_flow_status[1]
		end

		if message != request_flow_status[1]
			message = "#{message} #{request_flow_status[1]}"
		end

		od_upper_limit_cap = SystemSetting.get_od_upper_limit(employee.company_id)
		if od_upper_limit_cap > 0
			if od_upper_limit_cap < request_count
				request_count 	= 0
				message					= "You are not allowed to send Official Duty request more than #{od_upper_limit_cap.to_i} days"
			end
		end

		return request_count, message
	end

	########## Calculation of Bulk Official Duty that requested to Applied ##########
	def self.calculate_bulk_official_duty(employee)
		message = "No issue in Official Duty Request. You are allowed to apply Official Duty."
		
		############## Verification of Official Duty Request	##############
		request_flow_status = RequestFlow.verification_of_request_flow(employee, "Official Duty Request")

		if request_flow_status[0] == false
			message					= request_flow_status[1]
		end

		if message != request_flow_status[1]
			message = "#{message} #{request_flow_status[1]}"
		end

		return message
	end

	def self.validate_od_restriction(employee, start_date, end_date)
		od_restriction_validation = false
		message = ""
		get_od_restriction 	= SystemSetting.get_od_restriction(employee.company_id)

		if get_od_restriction == true
			get_od_message = SystemSetting.get_od_message(employee.company_id)
			od_restriction_validation = SystemSetting.od_restriction_validation(employee.company_id, start_date, end_date)	
			if od_restriction_validation == true
				message = get_od_message 	
			end
		end
		return od_restriction_validation, message
	end

	########## Official Duty Approval Request ##########
	def official_duty_approval_request
		requested_employee 				= self.employee
		requested_quota 					= self.request_count
		if self.request_status == "Waiting For Approval"
			request_flow = RequestFlow.find_by(:company_id => requested_employee.company_id, :request_flow_type => "Official Duty Request")
			if request_flow.nil?
				self.request_status = "Availed"
				self.save
			else
				if request_flow.request_node == "Line Manager"
					approval_employee = self.employee.line_manager
					########## Send Approval Request ##########
					ApprovalRequest.generate_approval_request(requested_employee.company_id, requested_employee.id, approval_employee.id, request_flow.id, "Waiting For Approval", self.id, self.class.name)
					#############################################
					########## Notification Generation ##########
					#############################################
					request_by_user = requested_employee.user
					request_to_user = approval_employee.user
					if not request_by_user.nil?
						Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "Your Official Duty has forward to #{approval_employee.full_name} for Approval")
					end
					if not request_to_user.nil?
						Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "#{requested_employee.full_name} submitted a Official Duty Request")
					end
					if not (request_by_user.nil? or request_to_user.nil?)
						email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Official Duty Request")
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
						########## Send Approval Request ##########
						ApprovalRequest.generate_approval_request(requested_employee.company_id, requested_employee.id, approval_employee.id, request_flow.id, "Waiting For Approval", self.id, self.class.name)
						#############################################
						########## Notification Generation ##########
						#############################################
						request_by_user = requested_employee.user
						request_to_user = approval_employee.user
						if not request_by_user.nil?
							Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "Your Official Duty has forward to #{approval_employee.full_name} for Approval")
						end
						if not request_to_user.nil?
							Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "#{requested_employee.full_name} submitted a Official Duty Request")
						end
						if not (request_by_user.nil? or request_to_user.nil?)
							email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Official Duty Request")
							if not email_template.nil?
								EmailOutbound.initiate_email_notification(email_template, request_to_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user, self.approval_request)
							end
						end
						#############################################
						########## Notification Generation ##########
						#############################################
					else
						#############################################
						########## Notification Generation ##########
						#############################################
						request_by_user = requested_employee.user
						request_to_user = approval_employee.user
						if not request_by_user.nil?
							Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "You Availed Official Duty")
						end
						if not (request_by_user.nil? or request_to_user.nil?)
							email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Official Duty Approved")
							if not email_template.nil?
								EmailOutbound.initiate_email_notification(email_template, request_by_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user, self.approval_request)
							end
						end
						#############################################
						########## Notification Generation ##########
						#############################################
					end
				else
					self.request_status = "Availed"
					self.save
					#############################################
					########## Notification Generation ##########
					#############################################
					request_by_user = requested_employee.user
					request_to_user = approval_employee.user
					if not request_by_user.nil?
						Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "You Availed Official Duty")
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
		elsif self.request_status == "Waiting For 2nd Approval"
			request_flow = RequestFlow.find_by(:company_id => requested_employee.company_id, :request_flow_type => "Official Duty Request")
			if request_flow.nil?
				self.request_status = "Availed"
				self.save
			else
				if request_flow.request_flow_details.where(:specific_condition => true,:branch_id => requested_employee.branch_id ,:department_id => requested_employee.department_id).count == 1
					approval_employee = request_flow.request_flow_details.where(:specific_condition => true,:branch_id => requested_employee.branch_id ,:department_id => requested_employee.department_id).first.employee
					########## Send Approval Request ##########
					ApprovalRequest.generate_approval_request(requested_employee.company_id, requested_employee.id, approval_employee.id, request_flow.id, "Waiting For 2nd Approval", self.id, self.class.name)
					#############################################
					########## Notification Generation ##########
					#############################################
					request_by_user = requested_employee.user
					request_to_user = approval_employee.user
					if not request_by_user.nil?
						Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "Your Official Duty has Approved by #{self.request_sender_name} and forward to #{approval_employee.full_name} for 2nd Approval")
					end
					if not request_to_user.nil?
						Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "#{requested_employee.full_name} submitted a Official Duty Request")
					end
					if not (request_by_user.nil? or request_to_user.nil?)
						email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Official Duty 2nd Request")
						if not email_template.nil?
							EmailOutbound.initiate_2nd_email_notification(email_template, request_to_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user, self.request_sender_name)
						end
					end
					if not request_by_user.nil?
						email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Official Duty 2nd Approval Request")
						if not email_template.nil?
							EmailOutbound.initiate_2nd_email_notification(email_template, request_by_user.email, request_by_user.full_name, request_to_user.full_name, request_by_user, request_to_user, self.request_sender_name)
						end
					end
					#############################################
					########## Notification Generation ##########
					#############################################
				else
					self.request_status = "Availed"
					self.save
					#############################################
					########## Notification Generation ##########
					#############################################
					request_by_user = requested_employee.user
					request_to_user = approval_employee.user
					if not request_by_user.nil?
						Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "You Availed Official Duty")
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
			########## Revert Approval Request ##########
			ApprovalRequest.revert_official_duty_request(self)
		elsif self.request_status == "Availed"
			########## Add Impact on Attendance ##########
			EmployeeAttendance.auto_impact_on_attendance_of_request("official_duty_request", self.start_date, self.end_date, self.employee)
		elsif self.request_status == "Revert"
			########## Remove Impact on Attendance ##########
			OfficialDuty.remove_impact_on_attendance_of_request(self.start_date, self.end_date, self.employee)
		end
	end

	########## Revert Official Duty Impact on Employee Attendance ##########
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
		EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_official_duty => true).order('attendance_date ASC').each do |employee_attendance|
			EmployeeRoster.update_employee_roster(employee_attendance.attendance_date.to_date, employee_attendance)
		end

		########## Update Attendance Information with Employee Roster ##########
		EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_official_duty => true).order('attendance_date ASC').each do |employee_attendance|
			EmployeeAttendance.update_employee_detail(employee_attendance, employee)
		end

		########## Revert Official Duty Impact on Attendance ##########
		EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_official_duty => true).each do |employee_attendance|
			EmployeeAttendance.clear_attendance_record_for_request_impact(employee_attendance)
		end

		########## Process Employee Attendance Information ##########
		EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_official_duty => false).order('attendance_date ASC').each do |employee_attendance|
			EmployeeAttendance.single_employee_process_attendance(employee_attendance)
		end
	end

	########## Official Duty Impact on Employee Attendance ##########
	def self.employee_wise_official_duty_impact(employee_attendance)
		OfficialDuty.where(:employee_id => employee_attendance.employee_id, :request_status => "Availed").where("Date(start_date) <= ? AND Date(end_date) >= ?", employee_attendance.attendance_date.to_date, employee_attendance.attendance_date.to_date).each do |official_duty|
			employee_attendance.attendance_status = official_duty.attendance_status_label
	    employee_attendance.early_left_status = ""
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
			employee_attendance.incentive_verified 				= true
			employee_attendance.is_official_duty 					= true
			employee_attendance.is_on_leave 							= false
			employee_attendance.is_relaxation 						= false
			employee_attendance.deduction_from_quota			= false
			employee_attendance.deduction_from_salary			= false
			employee_attendance.is_leave_without_pay 			= false
			if not employee_attendance.office_in_time.nil?
				if not employee_attendance.in_time.nil?
					start_time = Time.new(employee_attendance.attendance_date.to_datetime.year, employee_attendance.attendance_date.to_datetime.month, employee_attendance.attendance_date.to_datetime.day, official_duty.start_time.to_datetime.to_time.strftime('%H'), official_duty.start_time.to_datetime.to_time.strftime('%M'), official_duty.start_time.to_datetime.to_time.strftime('%S'))
					if start_time.to_datetime < employee_attendance.in_time.to_datetime
						employee_attendance.in_time = Time.new(employee_attendance.office_in_time.to_datetime.year, employee_attendance.office_in_time.to_datetime.month, employee_attendance.office_in_time.to_datetime.day, official_duty.start_time.to_datetime.to_time.strftime('%H'), official_duty.start_time.to_datetime.to_time.strftime('%M'), official_duty.start_time.to_datetime.to_time.strftime('%S'))			
					end
				else
					employee_attendance.in_time = Time.new(employee_attendance.office_in_time.to_datetime.year, employee_attendance.office_in_time.to_datetime.month, employee_attendance.office_in_time.to_datetime.day, official_duty.start_time.to_datetime.to_time.strftime('%H'), official_duty.start_time.to_datetime.to_time.strftime('%M'), official_duty.start_time.to_datetime.to_time.strftime('%S'))
				end
			end
			if not employee_attendance.office_out_time.nil?
				if not employee_attendance.out_time.nil?
					end_time = Time.new(employee_attendance.attendance_date.to_datetime.year, employee_attendance.attendance_date.to_datetime.month, employee_attendance.attendance_date.to_datetime.day, official_duty.end_time.to_datetime.to_time.strftime('%H'), official_duty.end_time.to_datetime.to_time.strftime('%M'), official_duty.end_time.to_datetime.to_time.strftime('%S'))
					if end_time.to_datetime > employee_attendance.out_time.to_datetime
						employee_attendance.out_time = Time.new(employee_attendance.office_out_time.to_datetime.year, employee_attendance.office_out_time.to_datetime.month, employee_attendance.office_out_time.to_datetime.day, official_duty.end_time.to_datetime.to_time.strftime('%H'), official_duty.end_time.to_datetime.to_time.strftime('%M'), official_duty.end_time.to_datetime.to_time.strftime('%S'))			
					end
				else
					employee_attendance.out_time = Time.new(employee_attendance.office_out_time.to_datetime.year, employee_attendance.office_out_time.to_datetime.month, employee_attendance.office_out_time.to_datetime.day, official_duty.end_time.to_datetime.to_time.strftime('%H'), official_duty.end_time.to_datetime.to_time.strftime('%M'), official_duty.end_time.to_datetime.to_time.strftime('%S'))
				end
			end
			if official_duty.is_full_day == true
				employee_attendance.remarks		= "Full Day #{official_duty.normalized_official_duty_mode}"
			else
				employee_attendance.remarks		= "#{official_duty.start_time.to_datetime.strftime("%-l:%M %P")} - #{official_duty.end_time.to_datetime.strftime("%-l:%M %P")} #{official_duty.normalized_official_duty_mode}"
	    end
	    employee_attendance.save
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
						employee_attendances.each do |employee_attendance|
							if employee_attendance.pay_deduction > 0
								if EmployeeArrear.where(:offical_duty_id => self.id, :start_date => employee_attendance.attendance_date.to_date, :end_date => employee_attendance.attendance_date).count == 0
									employee_arrear = EmployeeArrear.new
									employee_arrear.company_id			= self.company_id
									employee_arrear.employee_id 		= self.employee_id
									employee_arrear.offical_duty_id = self.id
									employee_arrear.arrear_days 		= employee_attendance.pay_deduction
									employee_arrear.arrear_type 		= "OfficalDuty"
									employee_arrear.start_date 			= employee_attendance.attendance_date
									employee_arrear.end_date 				= employee_attendance.attendance_date
									employee_arrear.arrears_month 	= Time.now
									employee_arrear.save
								end
							end
							if employee_attendance.deduction_from_quota == true
								system_setting = SystemSetting.find_by(:company_id => employee_attendance.company_id)
								if not system_setting.nil?
									if system_setting.revision_of_leave_after_cutoff == true
										if employee_attendance.is_on_leave == false and employee_attendance.is_relaxation == false and employee_attendance.is_finalized == true
											EmployeeAttendance.revision_of_leave_deducted(employee_attendance)
										end
									end
								end
							end
						end
					end
				end
			end
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

	def company_name
  	if self.company.nil?
  		return "-"
  	else
  		return self.company.name
  	end
  end

  def location_name
  	if self.employee.nil?
  		return "-"
  	else
  		return self.employee.location_name
  	end
  end

	def branch_name
		if self.employee.nil?
  		return "-"
  	else
  		return self.employee.branch_name
  	end
	end

	def department_name
		if self.employee.nil?
  		return "-"
  	else
  		return self.employee.department_name
  	end
	end

	def job_title_name
		if self.employee.nil?
  		return "-"
  	else
  		return self.employee.job_title_name
  	end
	end
		
	def grade_name
		if self.employee.nil?
  		return "-"
  	else
  		return self.employee.grade_name
  	end
	end
		
	def designation_name
	  	if self.employee.nil?
	  		return "-"
	  	else
	  		return self.employee.designation_name
	  	end
	  end

	def self.attendance_statuses
		OFFICIAL_DUTY_MODES
	end

	def self.attendance_statuses_with_legacy
		[LEGACY_ON_OFFICIAL_DUTY_STATUS] + OFFICIAL_DUTY_MODES
	end

	def normalized_official_duty_mode
		if OFFICIAL_DUTY_MODES.include?(self.official_duty_mode)
			self.official_duty_mode
		else
			OFFICE_DUTY_MODE
		end
	end

	def attendance_status_label
		normalized_official_duty_mode
	end

	def set_default_official_duty_mode
		self.official_duty_mode = normalized_official_duty_mode
	end

end
