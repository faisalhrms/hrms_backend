class RelaxationRequest < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:employee
	belongs_to 	:attendance_type

	has_one    	:approval_request, class_name: 'ApprovalRequest', as: :requestable

	########## Validation ############
  validate 		:validate_the_apply_date, :limit_requests

  ########## Call Back ############
  after_save 	:relaxation_approval_request
  # after_save 	:record_arrear

  ########## Validation of Relaxation Application ##########
	def validate_the_apply_date
		applied_status = false
		if self.request_status == "Waiting For Approval"
			if self.id.present?
				RelaxationRequest.where.not(id:self.id).where(employee_id: self.employee_id, is_cancelled: false, request_status: ["Waiting For Approval","Availed","System Deducted"]).each do |single_request|
					if self.id != single_request.id
						if single_request.start_date.present? and single_request.end_date.present?
							if (single_request.start_date <= self.start_date and single_request.end_date >= self.start_date) or (single_request.end_date >= self.end_date and single_request.start_date <= self.end_date)
								applied_status = true
								self.errors.add(:base, "Relaxation Request Already Applied! from #{single_request.start_date.to_date.strftime("%d-%b-%Y")} to #{single_request.end_date.to_date.strftime("%d-%b-%Y")}")
							end
						end
					end
				end
			else
				RelaxationRequest.where(employee_id: self.employee_id, is_cancelled: false, request_status: ["Waiting For Approval","Availed","System Deducted"]).each do |single_request|
					if self.id != single_request.id
						if single_request.start_date.present? and single_request.end_date.present?
							if (single_request.start_date <= self.start_date and single_request.end_date >= self.start_date) or (single_request.end_date >= self.end_date and single_request.start_date <= self.end_date)
								applied_status = true
								self.errors.add(:base, "Relaxation Request Already Applied! from #{single_request.start_date.to_date.strftime("%d-%b-%Y")} to #{single_request.end_date.to_date.strftime("%d-%b-%Y")}")
							end
						end
					end
				end
			end
		end

		if self.request_status == "Availed"
			if self.id.present?
				RelaxationRequest.where.not(id:self.id).where(employee_id: self.employee_id, is_cancelled: false, request_status: ["Waiting For Approval","Availed","System Deducted"]).each do |single_request|
					if self.id != single_request.id
						if single_request.start_date.present? and single_request.end_date.present?
							if (single_request.start_date <= self.start_date and single_request.end_date >= self.start_date) or (single_request.end_date >= self.end_date and single_request.start_date <= self.end_date)
								applied_status = true
								self.errors.add(:base, "Relaxation Request Already Applied! from #{single_request.start_date.to_date.strftime("%d-%b-%Y")} to #{single_request.end_date.to_date.strftime("%d-%b-%Y")}")
							end
						end
					end
				end
			else
				RelaxationRequest.where(employee_id: self.employee_id, is_cancelled: false, request_status: ["Waiting For Approval","Availed","System Deducted"]).each do |single_request|
					if self.id != single_request.id
						if single_request.start_date.present? and single_request.end_date.present?
							if (single_request.start_date <= self.start_date and single_request.end_date >= self.start_date) or (single_request.end_date >= self.end_date and single_request.start_date <= self.end_date)
								applied_status = true
								self.errors.add(:base, "Relaxation Request Already Applied! from #{single_request.start_date.to_date.strftime("%d-%b-%Y")} to #{single_request.end_date.to_date.strftime("%d-%b-%Y")}")
							end
						end
					end
				end
			end
		end
		
		logger.info "#{self.errors}"
	end

	########## Calculation of Relaxation that requested to Applied ##########
	def self.calculate_relaxation(employee, relaxation_start_date , relaxation_end_date ,start_date, end_date)
		message = "No issue in Relaxation Request. You are allowed to apply Relaxation. Relaxation Request will not be created for Rest Day and Public Holiday."
		date_range = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
		request_count  = date_range.count

		relaxation_range = (relaxation_start_date.to_date..relaxation_end_date.to_date).to_a.map{|x| x.to_date}
		relaxation_count  = relaxation_range.count

		relaxtion_limit = RequestFlow.last.back_date_limit

		sandwich_count = 0
		################ Roster Rest Day Count in Leaves ###############
		EmployeeRoster.where(:employee_id => employee.id, :roster_date => start_date.to_date..end_date.to_date).each do |employee_roster|
			if employee_roster.is_rest_day == true
				sandwich_count = sandwich_count + 1
			end
		end

		sandwich_count = sandwich_count + Holiday.calculate_holidays(start_date, end_date, employee)

		if sandwich_count > 0
			request_count = 0
		end

		############## Verification of Relaxation Request	##############
		request_flow_status = RequestFlow.verification_of_request_flow(employee, "Relaxation Request")

		if request_flow_status[0] == false
			request_count 	= 0
			message					= request_flow_status[1]
		end

		if message != request_flow_status[1]
			message = "#{message} #{request_flow_status[1]}."
		end

		if request_count > 1
			message = "More Than One Day Relaxation Request are not allowed."
			request_count = 0
		end


			employee_start_date = EmployeeAttendance.find_by(:employee_code => employee.employee_code,:attendance_date => relaxation_start_date.to_date)
			employee_end_date = EmployeeAttendance.find_by(:employee_code => employee.employee_code,:attendance_date => relaxation_end_date.to_date)


		if relaxation_count == 1
			if ENV.fetch("APP_URL").include?('hrmsbe.sapphirepakistan.pk')

				if employee_start_date.try(:in_time).present? and employee_end_date.try(:out_time).present? and relaxation_count == 1
								working_hours = TimeDifference.between(employee_start_date.try(:in_time), employee_end_date.try(:out_time)).in_hours
							 end
				end
  		criteria = RequestFlow.pluck(:criteria).map!{|e| e.to_i}.uniq.sum

		if working_hours.present? and criteria.present?
			if working_hours < criteria
			message = "Your Working Hours (#{working_hours}) Less Than Our Criteria."
				request_count = 0
		  end

		if request_count == 1

			attendance_logs = AttendanceMachineLog.where(:employee_code => employee.employee_code, :attendance_date => start_date.to_date..end_date.to_date).order('attendance_datetime ASC').map{|x| x.actual_attendance_date.split(' ')[1]}.join(' - ')

			if attendance_logs.blank? and working_hours.present?
				attendance_logs = AttendanceMachineLog.where(:employee_code => employee.employee_code, :attendance_date => start_date.to_date..end_date.to_date).order('attendance_datetime ASC').map{|x| x.actual_attendance_date.split('T')[1]}.join(' - ')
				if attendance_logs.blank?
					message = "No Attendance Log Found. You are not allowed to send Relaxation Request."
					request_count = 0
				else
					message = "#{message} Your Attendance Logs are #{attendance_logs}"
				end
			else
				message = "#{message} Your Attendance Logs are #{attendance_logs} and working hours (#{working_hours})"
			end
		end
		else
			if ENV.fetch("APP_URL").include?('hrmsbe.sapphirepakistan.pk')
				message = "Your Working Hours is 0"
			request_count = 0
			else
				request_count = 1
			end
		end
		else
			message = "More Than One Day Relaxation Request are not allowed."
			request_count = 0
		end

		return request_count ,message
	end

	########## Relaxation Approval Request ##########
	def relaxation_approval_request
		requested_employee 				= self.employee
		requested_quota 					= self.request_count
		if self.request_status == "Waiting For Approval"
			request_flow = RequestFlow.find_by(:company_id => requested_employee.company_id, :request_flow_type => "Relaxation Request")
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
						Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "Your Relaxation has forward to #{approval_employee.full_name} for Approval")
					end
					if not request_to_user.nil?
						Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "#{requested_employee.full_name} submitted a Relaxation Request")
					end
					if not (request_by_user.nil? or request_to_user.nil?)
						email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Relaxation Request")
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
							Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "Your Relaxation has forward to #{approval_employee.full_name} for Approval")
						end
						if not request_to_user.nil?
							Notification.create_custom_notification(request_to_user, request_to_user, request_to_user, "#{requested_employee.full_name} submitted a Relaxation Request")
						end
						if not (request_by_user.nil? or request_to_user.nil?)
							email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Relaxation Request")
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
							Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "You Availed Relaxation")
						end
						if not (request_by_user.nil? or request_to_user.nil?)
							email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Relaxation Approved")
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
						Notification.create_custom_notification(request_by_user, request_by_user, request_by_user, "You Availed Relaxation")
					end
					if not request_by_user.nil?
						email_template = EmailTemplate.find_by(:company_id => request_by_user.company_id, :trigger => "Relaxation Approved")
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
			ApprovalRequest.revert_relaxation_request(self)
		elsif self.request_status == "Availed"
			########## Add Impact on Attendance ##########
			EmployeeAttendance.auto_impact_on_attendance_of_request("relaxation_request", self.start_date, self.end_date, self.employee)
		end
	end

	########## Relaxation Impact on Employee Attendance ##########
	def self.employee_wise_relaxation_impact(employee_attendance)
		RelaxationRequest.where(:employee_id => employee_attendance.employee_id, :request_status => "Availed").where("Date(start_date) <= ? AND Date(end_date) >= ?", employee_attendance.attendance_date.to_date, employee_attendance.attendance_date.to_date).each do |relaxation_request|
			employee_attendance.attendance_status = "#{relaxation_request.attendance_type_name} Relaxation"	    
	    employee_attendance.early_left_status = ""
	    employee_attendance.other_remarks			= ""
	    employee_attendance.in_time 					= Time.new(employee_attendance.office_in_time.to_datetime.year, employee_attendance.office_in_time.to_datetime.month, employee_attendance.office_in_time.to_datetime.day, employee_attendance.office_in_time.to_datetime.to_time.strftime('%H'), employee_attendance.office_in_time.to_datetime.to_time.strftime('%M'), employee_attendance.office_in_time.to_datetime.to_time.strftime('%S'))
	    employee_attendance.remarks						= "#{relaxation_request.start_time.to_datetime.strftime("%-l:%M %P")} - #{relaxation_request.end_time.to_datetime.strftime("%-l:%M %P")} Relaxation"
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
			employee_attendance.is_relaxation 						= true
			employee_attendance.is_on_leave 							= false
			employee_attendance.is_official_duty 					= false
			employee_attendance.deduction_from_quota			= false
			employee_attendance.deduction_from_salary			= false
			employee_attendance.is_leave_without_pay 			= false
	    employee_attendance.save
		end
	end

	def add_impact_to_approval_request(current_user)
		approval_request = self.approval_request
		approval_request.approval_request_status  = "Approved"
    approval_request.is_approved              = true
    approval_request.save
    approval_request.add_impact_in_relaxation_request(current_user)
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
									employee_arrear.arrear_type 		= "RelaxationRequest"
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

	def limit_requests
		if dtl_instance?
			request_count = self.employee.relaxation_requests.where("start_date >= ? and end_date <= ?", start_date.beginning_of_month.to_date, end_date.end_of_month.to_date).where.not(id: self.id).where(request_status: ['Waiting For Approval', 'Availed']).sum(:request_count)
			if request_count.to_i >= 2
				self.errors.add(:base, 'Relaxation Request quota limit reached')
			end
			elsif srl_instance?
				request_count = self.employee.relaxation_requests.where("start_date >= ? and end_date <= ?", start_date.beginning_of_month.to_date, end_date.end_of_month.to_date).where.not(id: self.id).where(request_status: ['Waiting For Approval', 'Availed']).sum(:request_count)
				if request_count.to_i >= 100
					self.errors.add(:base, 'Relaxation Request quota limit reached')
				end
			end
		end


	def attendance_type_name
		if self.attendance_type.nil?
			return "-"
		else
			self.attendance_type.name
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

	def srl_instance?
		ENV['APP_URL'].include?('hrmsbe.sapphirepakistan.pk')
	end

	def dtl_instance?
		ENV.fetch("APP_URL").include?('dtlbe.srl.com.pk')
	end
end
