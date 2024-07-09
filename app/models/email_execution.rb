class EmailExecution < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :company_id }
	
	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:location
	belongs_to 	:branch
	belongs_to 	:grade
	belongs_to 	:email_template

	def company_name
  	if self.company.nil?
  		return "-"
  	else
  		return self.company.name
  	end
  end

  def location_name
  	if self.location.nil?
  		return "-"
  	else
  		return self.location.name
  	end
  end

	def branch_name
		if self.branch.nil?
  		return "-"
  	else
  		return self.branch.name
  	end
	end
	
	def send_email
		attendance_date = Time.now
		email_template = self.email_template
		if not email_template.nil?
			email_configration = email_template.email_configration	
			if not email_configration.nil?
				employee_list = Employee.get_by_company(self.company_id).where(:location_id => self.location_id, :attendance_exempted => false).active.order('id ASC')
				employee_list = employee_list.where(branch_id: self.branch_id) if self.branch_id.present?
				employee_list = employee_list.where(:grade_id => self.grade_id).order('id ASC') if self.grade_id.present?
				line_manager = nil
				if employee_list.where(:is_active => true, :is_line_manager => true).count == 1
					line_manager = employee_list.where(:is_active => true, :is_line_manager => true).first
				end
				employee_list.each do |employee|
					if self.trigger == "Attendance"
						EmployeeAttendance.where(:attendance_date => attendance_date.to_date, :employee_id => employee.id).each do |employee_attendance|
							employee_attendance_date = employee_attendance.attendance_date.strftime("%b %d, %Y")
		          employee_in_time = ""
		          if employee_attendance.in_time.nil?
		            employee_in_time = ""
		          else
		            employee_in_time = employee_attendance.in_time.localtime.strftime("%I:%M %p")  
		          end
		          email_message = email_template.message
		          official_email = employee.official_email
		          personal_email = employee.personal_email
		      
		          email_message = email_message.gsub('{salutation}', employee.salutation)
		          email_message = email_message.gsub('{employee_name}', employee.full_name)
		          email_message = email_message.gsub('{attendance_date}', employee_attendance_date)

							email_subject = email_template.subject
							email_subject = email_subject.gsub('{attendance_date}', employee_attendance_date)

		          if not official_email.to_s.blank?
		          	exempted_verification = self.verify_exempted_number(email_template, official_email)
	          		if exempted_verification == false
			            if employee_attendance.is_on_leave == true
			            	leave_message = "You are on Leave today"
			              email_message = email_message.gsub('You marked your attendance at: {attendance_time}', leave_message)
			            elsif employee_attendance.is_official_duty == true
			            	od_message = "You are on Official Duty today"
			              email_message = email_message.gsub('You marked your attendance at: {attendance_time}', od_message)
			            else
				            if employee_in_time.blank?
				              absent_message = "You are absent today"
				              email_message = email_message.gsub('You marked your attendance at: {attendance_time}', absent_message)
				            else
				              email_message = email_message.gsub('{attendance_time}', employee_in_time)
				            end
				          end
			            logger.debug "\n\n Salutation: #{employee.salutation} Name: #{employee.full_name} Official Email: #{official_email} Date: #{employee_attendance_date} Time: #{employee_in_time} \n\n"
			            logger.debug "\n\n #{email_message} \n\n"
			            self.post_message(email_template, official_email, email_message, email_subject)
			          end
		          elsif not personal_email.to_s.blank?
		          	exempted_verification = self.verify_exempted_number(email_template, personal_email)
	          		if exempted_verification == false
			            if employee_attendance.is_on_leave == true
			            	leave_message = "You are on Leave today"
			              email_message = email_message.gsub('You marked your attendance at: {attendance_time}', leave_message)
			            elsif employee_attendance.is_official_duty == true
			            	od_message = "You are on Official Duty today"
			              email_message = email_message.gsub('You marked your attendance at: {attendance_time}', od_message)
			            else
				            if employee_in_time.blank?
				              absent_message = "You are absent today"
				              email_message = email_message.gsub('You marked your attendance at: {attendance_time}', absent_message)
				            else
				              email_message = email_message.gsub('{attendance_time}', employee_in_time)
				            end
				          end
			            logger.debug "\n\n Salutation: #{employee.salutation} Name: #{employee.full_name} Phone Email: #{personal_email} Date: #{employee_attendance_date} Time: #{employee_in_time} \n\n"
			            logger.debug "\n\n #{email_message} \n\n"
			            self.post_message(email_template, personal_email, email_message, email_subject)
			          end
		          end
		        end
		      elsif self.trigger == "Consistent Absent"		      	
		      	if not employee.line_manager.nil?
		      		line_manager = employee.line_manager
		      		if line_manager.id != employee.id
				      	absent_days = (self.no_of_days + 1)
				      	start_date = Time.now - absent_days.days
				      	end_date = Time.now - 1.day
				      	employee_rest_day_count = EmployeeRoster.where(:employee_id => employee.id, :roster_date => start_date.to_date..end_date.to_date, :is_rest_day => true).count
				      	public_holiday_count = 0
								date_range = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
								date_range.each do |single_date|
									public_holiday = Holiday.verify_public_holiday(employee, single_date)	
									if public_holiday == true
										public_holiday_count = public_holiday_count + 1
									end
								end
				      	if EmployeeAttendance.where(:employee_id => employee.id, :attendance_date => start_date.to_date..end_date.to_date, :attendance_status => "Absent").count >= self.no_of_days
				      		if LeaveRequest.where(:employee_id => employee.id, :request_status => "Availed").where("Date(start_date) <= ? AND Date(end_date) >= ?", start_date.to_date, end_date.to_date).count == 0
				      			if OfficialDuty.where(:employee_id => employee.id, :request_status => "Availed").where("Date(start_date) <= ? AND Date(end_date) >= ?", start_date.to_date, end_date.to_date).count == 0
				      				if RelaxationRequest.where(:employee_id => employee.id, :request_status => "Availed").where("Date(start_date) <= ? AND Date(end_date) >= ?", start_date.to_date, end_date.to_date).count == 0
				      					email_message = email_template.message
							          official_email = line_manager.official_email
							          email_message = email_message.gsub('{employee_name}', employee.full_name)
							          email_message = email_message.gsub('{LineManager}', line_manager.full_name)
												email_subject = email_template.subject
												if not official_email.to_s.blank?
							          	exempted_verification = self.verify_exempted_number(email_template, official_email)
						          		if exempted_verification == false
						          			logger.debug "\n\n employee_name => #{employee.full_name} \n\n"
						          			logger.debug "\n\n LineManager => #{line_manager.full_name} \n\n"
						          			logger.debug "\n\n official_email => #{official_email} \n\n"
							          		self.post_message(email_template, official_email, email_message, email_subject)
							          	end
							          end
				      				end
				      			end
				      		end
				      	end
				      end
			      end
		      else
		      	email_message = email_template.message
	          official_email = employee.official_email
		        personal_email = employee.personal_email
	          email_message = email_message.gsub('{salutation}', employee.salutation)
	          email_message = email_message.gsub('{employee_name}', employee.full_name)

						email_subject = email_template.subject
						email_subject = email_subject.gsub('{attendance_date}', employee_attendance_date)
						if not official_email.to_s.blank?
	          	exempted_verification = self.verify_exempted_number(email_template, official_email)
	          	if exempted_verification == false
	          		logger.debug "\n\n Salutation: #{employee.salutation} Name: #{employee.full_name} Official Email: #{official_email} \n\n"
		            logger.debug "\n\n #{email_message} \n\n"
		            self.post_message(email_template, official_email, email_message, email_subject)
	          	end
	          elsif not personal_email.to_s.blank?
	          	exempted_verification = self.verify_exempted_number(email_template, personal_email)
	          	if exempted_verification == false
	            	logger.debug "\n\n Salutation: #{employee.salutation} Name: #{employee.full_name} Phone Email: #{personal_email} \n\n"
	            	logger.debug "\n\n #{email_message} \n\n"
	            	self.post_message(email_template, personal_email, email_message, email_subject)
	            end
	          end
					end
				end
			end
		end	
	end

	def post_message(email_template, email_address, email_message, email_subject = self.email_template.subject)
		EmailOutbound.send_custom_email(email_template, email_address, email_message, email_subject)
	end

	def verify_exempted_number(email_template, email_address)
		if email_template.is_exempted == true
  		if email_template.exempted_address.split(',').include?(email_address) == true
  			return true
  		else
  			return false
  		end
  	else
  		return false
  	end
	end
	
end
