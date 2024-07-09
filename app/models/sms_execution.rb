class SmsExecution < ApplicationRecord

	########## Validation ############
	validates :name, :uniqueness => { scope: :company_id }
	
	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:location
	belongs_to 	:branch
	belongs_to 	:grade
	belongs_to 	:sms_template

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
	
	def send_sms
		attendance_date = Time.now
		sms_template = self.sms_template
		if not sms_template.nil?
			if sms_template.is_active == true
				sms_configration = sms_template.sms_configration	
				if not sms_configration.nil?
					if sms_configration.is_active == true
						employee_list = Employee.where(:company_id => self.company_id, :location_id => self.location_id, :branch_id => self.branch_id, :is_active => true, :attendance_exempted => false).order('id ASC')
						if not self.grade_id.nil?
							employee_list = employee_list.where(:grade_id => self.grade_id).order('id ASC')
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
				          sms_message = sms_template.message
				          offical_mobile_number = employee.official_mobile_number.to_s.gsub('-','')
				          personal_mobile_number = employee.personal_number.to_s.gsub('-','')
				      
				          sms_message = sms_message.gsub('{salutation}', employee.salutation)
				          sms_message = sms_message.gsub('{employee_name}', employee.full_name)
				          sms_message = sms_message.gsub('{attendance_date}', employee_attendance_date)

				          if not offical_mobile_number.to_s.blank?
				          	exempted_verification = self.verify_exempted_number(sms_template, offical_mobile_number)
			          		if exempted_verification == false
					            if employee_attendance.is_on_leave == true
					            	leave_message = "You are on Leave today"
					              sms_message = sms_message.gsub('You marked your attendance at: {attendance_time}', leave_message)
					            elsif employee_attendance.is_official_duty == true
					            	od_message = "You are on Official Duty today"
					              sms_message = sms_message.gsub('You marked your attendance at: {attendance_time}', od_message)
					            else
					              if employee_in_time.blank?
						              absent_message = "You are absent today"
						              sms_message = sms_message.gsub('You marked your attendance at: {attendance_time}', absent_message)
						            else
						              sms_message = sms_message.gsub('{attendance_time}', employee_in_time)
						            end
					            end
					            logger.debug "\n\n Salutation: #{employee.salutation} Name: #{employee.full_name} Official Number: #{offical_mobile_number} Date: #{employee_attendance_date} Time: #{employee_in_time} \n\n"
					            logger.debug "\n\n #{sms_message} \n\n"
					            self.post_message(sms_configration, offical_mobile_number, sms_message)		            
					          end
				          elsif not personal_mobile_number.to_s.blank?
				          	exempted_verification = self.verify_exempted_number(sms_template, personal_mobile_number)
			          		if exempted_verification == false
					            if employee_attendance.is_on_leave == true
					            	leave_message = "You are on Leave today"
					              sms_message = sms_message.gsub('You marked your attendance at: {attendance_time}', leave_message)
					            elsif employee_attendance.is_official_duty == true
					            	od_message = "You are on Official Duty today"
					              sms_message = sms_message.gsub('You marked your attendance at: {attendance_time}', od_message)
					            else
					              if employee_in_time.blank?
						              absent_message = "You are absent today"
						              sms_message = sms_message.gsub('You marked your attendance at: {attendance_time}', absent_message)
						            else
						              sms_message = sms_message.gsub('{attendance_time}', employee_in_time)
						            end
					            end
					            logger.debug "\n\n Salutation: #{employee.salutation} Name: #{employee.full_name} Phone Number: #{personal_mobile_number} Date: #{employee_attendance_date} Time: #{employee_in_time} \n\n"
					            logger.debug "\n\n #{sms_message} \n\n"
					            self.post_message(sms_configration, personal_mobile_number, sms_message)		            
					          end
				          end
				        end	
				      else
				      	sms_message = sms_template.message
			          offical_mobile_number = employee.official_mobile_number.to_s.gsub('-','')
			          personal_mobile_number = employee.personal_number.to_s.gsub('-','')
			          sms_message = sms_message.gsub('{salutation}', employee.salutation)
			          sms_message = sms_message.gsub('{employee_name}', employee.full_name)
			          if not offical_mobile_number.to_s.blank?
			          	exempted_verification = self.verify_exempted_number(sms_template, offical_mobile_number)
			          	if exempted_verification == false
			          		logger.debug "\n\n Salutation: #{employee.salutation} Name: #{employee.full_name} Official Number: #{offical_mobile_number} \n\n"
				            logger.debug "\n\n #{sms_message} \n\n"
				            self.post_message(sms_configration, offical_mobile_number, sms_message)		            
			          	end
			          elsif not personal_mobile_number.to_s.blank?
			          	exempted_verification = self.verify_exempted_number(sms_template, personal_mobile_number)
			          	if exempted_verification == false
			            	logger.debug "\n\n Salutation: #{employee.salutation} Name: #{employee.full_name} Phone Number: #{personal_mobile_number} \n\n"
			            	logger.debug "\n\n #{sms_message} \n\n"
			            	self.post_message(sms_configration, personal_mobile_number, sms_message)		            
			            end
			          end
							end
						end
					end
				end
			end
		end	
	end

	def post_message(sms_configration, mobile_number, sms_message)
		# request_url = "https://sendpk.com/api/sms.php?username=923360020555&password=UMYT6EBfd8z@HSK&sender=03000041619&mobile=03484327675&message=Hello"
		# request = Unirest.post "#{request_url}"
		request_url = "#{sms_configration.url}?Username=#{sms_configration.user_name}&Password=#{sms_configration.password}&From=#{sms_configration.masking}&To=#{mobile_number}&Message=#{sms_message}"
		begin
	    request = Unirest.get "#{request_url}"  
	  rescue Exception => e
	    logger.debug "\n\n SMS Not Send \n\n"
	  end
	end

	def verify_exempted_number(sms_template, mobile_number)
		if sms_template.is_exempted == true
  		if sms_template.exempted_numbers.split(',').include?(mobile_number) == true
  			return true
  		else
  			return false
  		end
  	else
  		return false
  	end
	end

end
