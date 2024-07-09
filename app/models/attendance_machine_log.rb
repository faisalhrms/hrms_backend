class AttendanceMachineLog < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:employee

	def company_name
  	if self.company.nil?
  		return "-"
  	else
  		return self.company.name
  	end
  end

  def employee_name
  	if self.employee.nil?
  		return "-"
  	else
  		return self.employee.full_name
  	end
  end

  def employee_code
  	if self.employee.nil?
  		return "-"
  	else
  		return self.employee.employee_code
  	end
  end

  ########## Fetch Attendance from Machine ##########

  def self.fetch_attendance_machine_data(attendance_device, start_date, end_date)
    if attendance_device.device_type == "DDS"
			if attendance_device.description == 'ho_attendance'
				device_url = attendance_device.device_url.to_s + '/api/employee_daily_attendances/fetch_employee_attendance?access_token=' + 'cG0un0uRaCYtj-KlLmOoeA' + "&start_date=" + start_date.to_s + "&machine_name=" + attendance_device.device_id.to_s + "&end_date=" + end_date.to_s
				self.insert_masked_data(device_url, attendance_device)
			else
				device_url = attendance_device.device_url.to_s + '/api/employee_daily_attendances/fetch_employee_attendance?access_token=' + 'cG0un0uRaCYtj-KlLmOoeA' + "&machine_name=" + attendance_device.device_id.to_s + "&start_date=" + start_date.to_s + "&end_date=" + end_date.to_s
				log_id = 'daily_attendance'
				machine_name = 'machine_name'
				self.att_machine_data_insertion(device_url, attendance_device, log_id, machine_name, 'log_id')
			end
    elsif attendance_device.device_type == "D-Finger Tech"
      device_url = attendance_device.device_url.to_s + '/api/employee_daily_attendances/dfl_machine_wise_attendance?access_token=' + 'cG0un0uRaCYtj-KlLmOoeA' + "&start_date=" + start_date.to_s + "&machine_name=" + attendance_device.description.to_s + "&end_date=" + end_date.to_s
      log_id = 'daily_attendance'
      machine_name = 'ip_address'
      self.att_machine_data_insertion(device_url, attendance_device, log_id, machine_name, 'log_id')
    elsif attendance_device.device_type == "DM-Finger Tech"
      device_url = attendance_device.device_url.to_s + '/api/employee_daily_attendances/dfl_mill_machine_wise_attendance?access_token=' + 'cG0un0uRaCYtj-KlLmOoeA' + "&start_date=" + start_date.to_s + "&machine_name=" + attendance_device.description.to_s + "&end_date=" + end_date.to_s
      log_id = 'daily_attendance'
      machine_name = 'ip_address'
      self.att_machine_data_insertion(device_url, attendance_device, log_id, machine_name, 'attendance_date_time')
		elsif attendance_device.device_type == "DH-Zktecho"
			if ENV['APP_URL'].include? 'attendancebe.cressettech.com'
				daily_attendance_url = attendance_device.device_url.to_s + '/api/employee_daily_attendances/daily_attendances?access_token=' + 'cG0un0uRaCYtj-KlLmOoeA' + "&start_date=" + start_date.to_s + "&machine_name=" + attendance_device.device_id.to_s + "&end_date=" + end_date.to_s
				self.insert_masked_data(daily_attendance_url, attendance_device)
			else
				device_url = attendance_device.device_url.to_s + '/api/employee_daily_attendances/daily_attendances?access_token=' + 'cG0un0uRaCYtj-KlLmOoeA' + "&start_date=" + start_date.to_s + "&machine_name=" + attendance_device.device_id.to_s + "&end_date=" + end_date.to_s
				log_id = 'DFL-HOME-'
				machine_name = 'ip_address'
				self.att_machine_data_insertion(device_url, attendance_device, log_id, machine_name, 'attendance_date_time')
			end
		elsif attendance_device.device_type == "DHM-Zktecho"
      device_url = attendance_device.device_url.to_s + '/api/employee_daily_attendances/mill_employee_daily_attendances?access_token=' + 'cG0un0uRaCYtj-KlLmOoeA' + "&start_date=" + start_date.to_s + "&end_date=" + end_date.to_s
      log_id = 'DFL-HOME-'
      machine_name = 'ip_address'
      self.att_machine_data_insertion(device_url, attendance_device, log_id, machine_name, 'attendance_date_time')
    elsif attendance_device.device_type == "SL-Finger Tech"
      device_url = attendance_device.device_url.to_s + '/api/employee_daily_attendances/srl_machine_wise_attendance?access_token=' + 'cG0un0uRaCYtj-KlLmOoeA' + "&start_date=" + start_date.to_s + "&machine_name=" + attendance_device.description.to_s + "&end_date=" + end_date.to_s
      log_id = 'daily_attendance'
      machine_name = 'ip_address'
      self.att_machine_data_insertion(device_url, attendance_device, log_id, machine_name, 'attendance_date_time')
    elsif attendance_device.device_type == "SD-Finger Tech"
      salary_unit = SalaryUnit.find_by(name: 'SDL')
      if salary_unit.present?
        employee_codes_salary_unit = Employee.where(:company_id => attendance_device.company_id, :is_active => true, :salary_unit_id => salary_unit.id).collect(&:employee_code)
        device_url = attendance_device.device_url.to_s + '/api/employee_daily_attendances/sdl_ho_machine_wise_attendance?access_token=' + 'cG0un0uRaCYtj-KlLmOoeA' + "&start_date=" + start_date.to_s + "&machine_name=" + attendance_device.description.to_s + "&employee_codes=" + employee_codes_salary_unit.join(',').to_s + "&end_date=" + end_date.to_s
        log_id = 'daily_attendance'
        machine_name = 'ip_address'
        self.att_machine_data_insertion(device_url, attendance_device, log_id, machine_name, 'log_id')
      end
    elsif attendance_device.device_type == "S7-Finger Tech"
      device_url = attendance_device.device_url.to_s + '/api/employee_daily_attendances/fetch_employee_code_wise_attendance?access_token=' + 'cG0un0uRaCYtj-KlLmOoeA' + "&start_date=" + start_date.to_s + "&machine_name=" + attendance_device.description.to_s + "&end_date=" + end_date.to_s
      log_id = 'daily_attendance'
      machine_name = 'ip_address'
      self.att_machine_data_insertion(device_url, attendance_device, log_id, machine_name, 'log_id')
    elsif attendance_device.device_type == "IDL-Zktecho"
      device_url = attendance_device.device_url.to_s + '/api/employee_daily_attendances/daily_attendances?access_token=' + 'cG0un0uRaCYtj-KlLmOoeA' + "&start_date=" + start_date.to_s + "&end_date=" + end_date.to_s
      log_id = 'IDL-'
      machine_name = 'ip_address'
      self.att_machine_data_insertion(device_url, attendance_device, log_id, machine_name, 'attendance_date_time')
    elsif attendance_device.device_type == "CS-Zktecho"
      device_url = attendance_device.device_url.to_s + '/api/employee_daily_attendances/daily_attendances?access_token=' + 'cG0un0uRaCYtj-KlLmOoeA' + "&start_date=" + start_date.to_s + "&end_date=" + end_date.to_s
      log_id = 'Cresset-'
      machine_name = 'ip_address'
      self.att_machine_data_insertion(device_url, attendance_device, log_id, machine_name, 'attendance_date_time')
    elsif attendance_device.device_type == "DM-Zktecho"
      device_url = attendance_device.device_url.to_s + '/api/employee_daily_attendances/daily_attendances?access_token=' + 'cG0un0uRaCYtj-KlLmOoeA' + "&start_date=" + start_date.to_s + "&machine_name=" + attendance_device.device_id.to_s + "&end_date=" + end_date.to_s
      log_id = 'DM-Zktecho-'
      machine_name = 'ip_address'
      self.att_machine_data_insertion(device_url, attendance_device, log_id, machine_name, 'log_id')
    elsif attendance_device.device_type == "MKT-Tricon"
      device_url = attendance_device.device_url.to_s + '/api/employee_daily_attendances/daily_attendances?access_token=' + 'cG0un0uRaCYtj-KlLmOoeA' + "&start_date=" + start_date.to_s + "&machine_name=" + attendance_device.device_id.to_s + "&end_date=" + end_date.to_s
      log_id = 'MKT-Tricon-'
      machine_name = 'ip_address'
      self.att_machine_data_insertion(device_url, attendance_device, log_id, machine_name, 'attendance_date_time')
    elsif attendance_device.device_type == "STM"
      device_url = attendance_device.device_url.to_s + '/api/employee_daily_attendances/fetch_employee_code_wise_attendance?access_token=' + 'cG0un0uRaCYtj-KlLmOoeA' + "&machine_name=" + attendance_device.device_id.to_s + "&start_date=" + start_date.to_s + "&end_date=" + end_date.to_s
      log_id = '1020-'
      machine_name = 'machine_name'
      self.att_machine_data_insertion(device_url, attendance_device, log_id, machine_name, 'log_id')
    end
  end

	########## Update Employee CheckIn and CheckOut ##########
	def self.update_employee_checkin_checkout(employee_attendance)
		if employee_attendance.roster_exist == true
			date_range = []
	  	date_range << employee_attendance.attendance_date.to_date
	  	if employee_attendance.buffer_office_out_time.to_date > employee_attendance.attendance_date.to_date
	  		date_range << (employee_attendance.attendance_date.to_date	+ 1.day)
	  	end
	  	
	  	actual_attendance_date_check_in  = nil
	  	actual_attendance_date_check_out = nil
	  	check_in 	= nil
	  	check_out = nil
	  	buffer_office_in_time 	= Time.new(employee_attendance.buffer_office_in_time.to_datetime.year, employee_attendance.buffer_office_in_time.to_datetime.month, employee_attendance.buffer_office_in_time.to_datetime.day, employee_attendance.buffer_office_in_time.to_datetime.to_time.strftime('%H'), employee_attendance.buffer_office_in_time.to_datetime.to_time.strftime('%M'), employee_attendance.buffer_office_in_time.to_datetime.to_time.strftime('%S'))
	    buffer_office_out_time 	= Time.new(employee_attendance.buffer_office_out_time.to_datetime.year, employee_attendance.buffer_office_out_time.to_datetime.month, employee_attendance.buffer_office_out_time.to_datetime.day, employee_attendance.buffer_office_out_time.to_datetime.to_time.strftime('%H'), employee_attendance.buffer_office_out_time.to_datetime.to_time.strftime('%M'), employee_attendance.buffer_office_out_time.to_datetime.to_time.strftime('%S'))

	  	if employee_attendance.is_flexi == true and ["DFL - Mill", 'Interloop Dairies Ltd.'].include?(employee_attendance.company_code)
	  		machine_logs = []

	  		# actual_attendance_date_array = []
		    # (buffer_office_in_time.to_datetime.to_i .. buffer_office_out_time.to_datetime.to_i).step(1.second) do |datetime|
				# 	actual_attendance_date_array << Time.at(datetime).strftime("%d/%m/%Y %-l:%M:%S %p")
				# end
	  		# machine_logs = AttendanceMachineLog.where(:employee_id => employee_attendance.employee_id, :actual_attendance_date => actual_attendance_date_array).order('attendance_datetime ASC')

				employee_attendance.sub_time_slot_id = nil
				sub_time_slot_found = false
	  		if employee_attendance.employee_roster.time_slot.sub_time_slots.count > 0
	  			employee_attendance.employee_roster.time_slot.sub_time_slots.order('description ASC').each do |sub_time_slot|
	  				if sub_time_slot_found == false

	  					current_time = employee_attendance.attendance_date.to_date
				  		new_current_time = employee_attendance.attendance_date.to_date + 1.day
				      office_in_time = Time.new(current_time.year, current_time.month, current_time.day, sub_time_slot.start_time.to_time.strftime('%H'), sub_time_slot.start_time.to_time.strftime('%M'), sub_time_slot.start_time.to_time.strftime('%S'))
				      office_out_time = Time.new(current_time.year, current_time.month, current_time.day, sub_time_slot.end_time.to_time.strftime('%H'), sub_time_slot.end_time.to_time.strftime('%M'), sub_time_slot.end_time.to_time.strftime('%S'))

				      if office_in_time > office_out_time 
				      	office_out_time = Time.new(new_current_time.year, new_current_time.month, new_current_time.day, sub_time_slot.end_time.to_time.strftime('%H'), sub_time_slot.end_time.to_time.strftime('%M'), sub_time_slot.end_time.to_time.strftime('%S'))		
				      end

      				buffer_office_in_time		= office_in_time - sub_time_slot.start_buffer.minute
							buffer_office_out_time	= office_out_time + sub_time_slot.end_buffer.minute

	  					prev_out_time = nil
					  	prev_date = (employee_attendance.attendance_date - 1.day).to_date
				  		prev_employee_attendance = EmployeeAttendance.find_by(:attendance_date => prev_date, :employee_id => employee_attendance.employee_id)
				  		if not prev_employee_attendance.nil?
				  			if not prev_employee_attendance.out_time.nil?
				  				prev_out_time = prev_employee_attendance.out_time
				  			end
				  		end

	  					machine_logs = AttendanceMachineLog.where(:employee_id => employee_attendance.employee_id, :attendance_date => date_range).order('attendance_datetime ASC')
				  		if not prev_out_time.nil?
				  			in_attendance_time_details = machine_logs.order('log_id ASC').select{|c| c.actual_attendance_date.to_datetime.strftime("%d/%m/%Y %-l:%M:%S %p") != prev_out_time.to_datetime.strftime("%d/%m/%Y %-l:%M:%S %p")}.map {|detail| {:id => detail.id, :attendance_datetime => detail.actual_attendance_date.to_datetime, :formatted_hour => detail.formatted_hour, :formatted_minute => detail.formatted_minute, :formatted_second => detail.formatted_second}}
				  		else
				  			in_attendance_time_details = machine_logs.order('log_id ASC').map {|detail| {:id => detail.id, :attendance_datetime => detail.actual_attendance_date.to_datetime, :formatted_hour => detail.formatted_hour, :formatted_minute => detail.formatted_minute, :formatted_second => detail.formatted_second}}
				  		end
				  		out_attendance_time_details = machine_logs.order('log_id ASC').map {|detail| {:id => detail.id, :attendance_datetime => detail.actual_attendance_date.to_datetime, :formatted_hour => detail.formatted_hour, :formatted_minute => detail.formatted_minute, :formatted_second => detail.formatted_second}}.reverse

							buffer_office_in_time = buffer_office_in_time.strftime("%d-%m-%Y %H:%M:%S").to_datetime
							buffer_office_out_time = buffer_office_out_time.strftime("%d-%m-%Y %H:%M:%S").to_datetime
							# temp_time_array = in_attendance_time_details & out_attendance_time_details

							temp_time_array = in_attendance_time_details + out_attendance_time_details
							temp_time_array = temp_time_array.uniq
							filter_temp_time_array = temp_time_array.select { |hash| hash[:attendance_datetime] >= buffer_office_in_time and hash[:attendance_datetime] <= buffer_office_out_time }

					  	uniq_filter_temp_time_array = []
					  	uniq_filter_temp_time_array << filter_temp_time_array.first
					  	filter_temp_time_array.each_index do |index|
					  		new_index = index + 1
					  		if not filter_temp_time_array[new_index].nil?
					  			if filter_temp_time_array.first[:attendance_datetime] != filter_temp_time_array[new_index][:attendance_datetime]
						  			if TimeDifference.between(filter_temp_time_array.first[:attendance_datetime], filter_temp_time_array[new_index][:attendance_datetime]).in_minutes > 15
						  				uniq_filter_temp_time_array << filter_temp_time_array[new_index]
						  			end
						  		end
					  		end
					  	end
					  	
					  	# if uniq_filter_temp_time_array.count == 2
					  	# 	if uniq_filter_temp_time_array.first[:attendance_datetime] != uniq_filter_temp_time_array.last[:attendance_datetime]
					  	# 		if TimeDifference.between(uniq_filter_temp_time_array.first[:attendance_datetime], uniq_filter_temp_time_array.last[:attendance_datetime]).in_minutes > 15
					  	# 			check_in = uniq_filter_temp_time_array.first[:attendance_datetime]
								# 		check_out = uniq_filter_temp_time_array.last[:attendance_datetime]
					  	# 		end
					  	# 	end
					  	# end

					  	if uniq_filter_temp_time_array.count == 2
					  		if uniq_filter_temp_time_array.first[:attendance_datetime] != uniq_filter_temp_time_array.last[:attendance_datetime]
					  			if uniq_filter_temp_time_array.first[:attendance_datetime] < uniq_filter_temp_time_array.last[:attendance_datetime]
					  				if TimeDifference.between(uniq_filter_temp_time_array.first[:attendance_datetime], uniq_filter_temp_time_array.last[:attendance_datetime]).in_minutes > 15
						  				check_in = uniq_filter_temp_time_array.first[:attendance_datetime]
											check_out = uniq_filter_temp_time_array.last[:attendance_datetime]
						  			end
						  		else
						  			if TimeDifference.between(uniq_filter_temp_time_array.last[:attendance_datetime], uniq_filter_temp_time_array.first[:attendance_datetime]).in_minutes > 15
						  				check_in = uniq_filter_temp_time_array.last[:attendance_datetime]
											check_out = uniq_filter_temp_time_array.first[:attendance_datetime]
						  			end
					  			end
					  		end
					  	end

					  	if not check_in.nil?
					  		if not check_out.nil?
					  			employee_attendance.sub_time_slot_id = sub_time_slot.id
					  			sub_time_slot_found = true
					  			employee_attendance.office_in_time = office_in_time
					  			employee_attendance.office_out_time = office_out_time
					  		else
					  			employee_attendance.sub_time_slot_id = nil
					  		end
					  	else
					  		employee_attendance.sub_time_slot_id
					  	end
	  				end
	  			end
	  		end

	  		if employee_attendance.employee_roster.time_slot.sub_time_slots.count > 0
	  			if check_in.nil? and check_out.nil?
						machine_logs = AttendanceMachineLog.where(:employee_id => employee_attendance.employee_id, :attendance_date => date_range).order('attendance_datetime ASC')
						FlexiLog.where(:employee_id => employee_attendance.employee_id, :attendance_date => date_range).delete_all
						machine_logs.each do |log|
							flexi_log = FlexiLog.new
							flexi_log.employee_full_name = log.employee_full_name
							flexi_log.employee_code = log.employee_code
							flexi_log.machine_name = log.machine_name
							flexi_log.attendance_datetime = log.attendance_datetime
							flexi_log.attendance_date = log.attendance_date
							flexi_log.actual_attendance_date = log.actual_attendance_date
							flexi_log.formatted_hour = log.formatted_hour
							flexi_log.formatted_minute = log.formatted_minute
							flexi_log.formatted_second = log.formatted_second
							flexi_log.log_id = log.log_id
							flexi_log.company_id = log.company_id
							flexi_log.employee_id = log.employee_id
							flexi_log.save
						end
					end
	  		end
				# buffer_office_in_time = buffer_office_in_time + 5.hours
				# buffer_office_out_time = buffer_office_out_time + 5.hours
	  		# machine_logs = AttendanceMachineLog.where(:employee_id => employee_attendance.employee_id).where(['attendance_datetime >= ? AND attendance_datetime <= ?', buffer_office_in_time, buffer_office_out_time]).order('attendance_datetime ASC')
	  	else
	  		machine_logs = AttendanceMachineLog.where(:employee_id => employee_attendance.employee_id, :attendance_date => date_range).order('attendance_datetime ASC')
	  		if ["DFL - Mill", 'Interloop Dairies Ltd.'].include? employee_attendance.company_code
	  			if machine_logs.count > 0
			  		uniq_machine_logs = []
				  	uniq_machine_logs << machine_logs.first
				  	new_index = 0
				  	# binding.pry
				  	machine_logs.each do |single_log|
				  		new_index = new_index + 1
				  		# binding.pry
				  		if not machine_logs[new_index].nil?
				  			# binding.pry
				  			if machine_logs.first[:attendance_datetime] != machine_logs[new_index][:attendance_datetime]
				  				# binding.pry
					  			if TimeDifference.between(machine_logs.first[:attendance_datetime], machine_logs[new_index][:attendance_datetime]).in_minutes > 15
					  				# binding.pry
					  				uniq_machine_logs << machine_logs[new_index]
					  			end
					  		end
				  		end
				  	end
						
			  		# in_attendance_time_details = machine_logs.order('log_id ASC').map {|detail| {:actual_attendance_date => detail.actual_attendance_date, :id => detail.id, :attendance_datetime => detail.actual_attendance_date.to_datetime, :formatted_hour => detail.formatted_hour, :formatted_minute => detail.formatted_minute, :formatted_second => detail.formatted_second, :minute_difference => TimeDifference.between(employee_attendance.office_in_time, (Time.new(detail.actual_attendance_date.to_datetime.year, detail.actual_attendance_date.to_datetime.month, detail.actual_attendance_date.to_datetime.day, detail.actual_attendance_date.to_datetime.to_time.strftime('%H'), detail.actual_attendance_date.to_datetime.to_time.strftime('%M'), detail.actual_attendance_date.to_datetime.to_time.strftime('%S')))).in_minutes}}
			  		in_attendance_time_details = uniq_machine_logs.map {|detail| {:actual_attendance_date => detail.actual_attendance_date, :id => detail.id, :attendance_datetime => detail.actual_attendance_date.to_datetime, :formatted_hour => detail.formatted_hour, :formatted_minute => detail.formatted_minute, :formatted_second => detail.formatted_second, :minute_difference => TimeDifference.between(employee_attendance.office_in_time, (Time.new(detail.actual_attendance_date.to_datetime.year, detail.actual_attendance_date.to_datetime.month, detail.actual_attendance_date.to_datetime.day, detail.actual_attendance_date.to_datetime.to_time.strftime('%H'), detail.actual_attendance_date.to_datetime.to_time.strftime('%M'), detail.actual_attendance_date.to_datetime.to_time.strftime('%S')))).in_minutes}}
				  	
			  		in_attendance_time_details.each do |attendance_time_detail|
				  		if check_in.nil?
					  		if attendance_time_detail[:attendance_datetime].to_date == buffer_office_in_time.to_date
					  			if attendance_time_detail[:minute_difference] <= employee_attendance.start_buffer
					  				check_in = attendance_time_detail[:attendance_datetime]
					  				actual_attendance_date_check_in = attendance_time_detail[:actual_attendance_date]
					  			end
					  		end
					  	end
				  	end

				  	# out_attendance_time_details = machine_logs.order('log_id ASC').select{|c| c.attendance_datetime != check_in}.map {|detail| {:actual_attendance_date => detail.actual_attendance_date, :id => detail.id, :attendance_datetime => detail.actual_attendance_date.to_datetime, :formatted_hour => detail.formatted_hour, :formatted_minute => detail.formatted_minute, :formatted_second => detail.formatted_second, :minute_difference => TimeDifference.between(employee_attendance.office_out_time, (Time.new(detail.actual_attendance_date.to_datetime.year, detail.actual_attendance_date.to_datetime.month, detail.actual_attendance_date.to_datetime.day, detail.actual_attendance_date.to_datetime.to_time.strftime('%H'), detail.actual_attendance_date.to_datetime.to_time.strftime('%M'), detail.actual_attendance_date.to_datetime.to_time.strftime('%S')))).in_minutes}}.reverse
				  	out_attendance_time_details = uniq_machine_logs.select{|c| c.attendance_datetime != check_in}.map {|detail| {:actual_attendance_date => detail.actual_attendance_date, :id => detail.id, :attendance_datetime => detail.actual_attendance_date.to_datetime, :formatted_hour => detail.formatted_hour, :formatted_minute => detail.formatted_minute, :formatted_second => detail.formatted_second, :minute_difference => TimeDifference.between(employee_attendance.office_out_time, (Time.new(detail.actual_attendance_date.to_datetime.year, detail.actual_attendance_date.to_datetime.month, detail.actual_attendance_date.to_datetime.day, detail.actual_attendance_date.to_datetime.to_time.strftime('%H'), detail.actual_attendance_date.to_datetime.to_time.strftime('%M'), detail.actual_attendance_date.to_datetime.to_time.strftime('%S')))).in_minutes}}.reverse
				  	out_attendance_time_details.each do |attendance_time_detail|
				  		if check_out.nil?
					  		if attendance_time_detail[:attendance_datetime].to_date <= buffer_office_out_time.to_date
					  			if attendance_time_detail[:minute_difference] <= employee_attendance.end_buffer
					  				check_out = attendance_time_detail[:attendance_datetime]	
					  				actual_attendance_date_check_out = attendance_time_detail[:actual_attendance_date]
					  			end
					  		end
					  	end
				  	end
				  end
				else
					if machine_logs.count > 0
			  		in_attendance_time_details = machine_logs.order('log_id ASC').map {|detail| {:actual_attendance_date => detail.actual_attendance_date, :id => detail.id, :attendance_datetime => detail.actual_attendance_date.to_datetime, :formatted_hour => detail.formatted_hour, :formatted_minute => detail.formatted_minute, :formatted_second => detail.formatted_second, :minute_difference => TimeDifference.between(employee_attendance.office_in_time, (Time.new(detail.actual_attendance_date.to_datetime.year, detail.actual_attendance_date.to_datetime.month, detail.actual_attendance_date.to_datetime.day, detail.actual_attendance_date.to_datetime.to_time.strftime('%H'), detail.actual_attendance_date.to_datetime.to_time.strftime('%M'), detail.actual_attendance_date.to_datetime.to_time.strftime('%S')))).in_minutes}}
			  		
			  		in_attendance_time_details.each do |attendance_time_detail|
				  		if check_in.nil?
					  		if attendance_time_detail[:attendance_datetime].to_date == buffer_office_in_time.to_date
					  			if attendance_time_detail[:minute_difference] <= employee_attendance.start_buffer
					  				check_in = attendance_time_detail[:attendance_datetime]
					  				actual_attendance_date_check_in = attendance_time_detail[:actual_attendance_date]
					  			end
					  		end
					  	end
				  	end

				  	out_attendance_time_details = machine_logs.order('log_id ASC').select{|c| c.attendance_datetime != check_in}.map {|detail| {:actual_attendance_date => detail.actual_attendance_date, :id => detail.id, :attendance_datetime => detail.actual_attendance_date.to_datetime, :formatted_hour => detail.formatted_hour, :formatted_minute => detail.formatted_minute, :formatted_second => detail.formatted_second, :minute_difference => TimeDifference.between(employee_attendance.office_out_time, (Time.new(detail.actual_attendance_date.to_datetime.year, detail.actual_attendance_date.to_datetime.month, detail.actual_attendance_date.to_datetime.day, detail.actual_attendance_date.to_datetime.to_time.strftime('%H'), detail.actual_attendance_date.to_datetime.to_time.strftime('%M'), detail.actual_attendance_date.to_datetime.to_time.strftime('%S')))).in_minutes}}.reverse
				  	out_attendance_time_details.each do |attendance_time_detail|
				  		if check_out.nil?
					  		if attendance_time_detail[:attendance_datetime].to_date <= buffer_office_out_time.to_date
					  			if attendance_time_detail[:minute_difference] <= employee_attendance.end_buffer
					  				check_out = attendance_time_detail[:attendance_datetime]	
					  				actual_attendance_date_check_out = attendance_time_detail[:actual_attendance_date]
					  			end
					  		end
					  	end
				  	end
				  end
	  		end
	  	end

			if employee_attendance.is_flexi == true and employee_attendance.company_name == "Diamond Fabrics Limited"
		  	
				if check_in.nil?
					check_out = nil
				end

				if check_out.nil?
					check_in = nil
				end
      end
	  	if check_in.nil?
				employee_attendance.in_time 	= nil
	  	else
	  		employee_attendance.in_time 	= Time.new(check_in.to_datetime.year, check_in.to_datetime.month, check_in.to_datetime.day, check_in.to_datetime.to_time.strftime('%H'), check_in.to_datetime.to_time.strftime('%M'), check_in.to_datetime.to_time.strftime('%S'))
	  	end

	  	if check_out.nil?
	  		employee_attendance.out_time 	= nil
	  	else
	  		employee_attendance.out_time 	= Time.new(check_out.to_datetime.year, check_out.to_datetime.month, check_out.to_datetime.day, check_out.to_datetime.to_time.strftime('%H'), check_out.to_datetime.to_time.strftime('%M'), check_out.to_datetime.to_time.strftime('%S'))
	  	end
			employee_attendance.save
		else
			employee_attendance.in_time 	= nil
			employee_attendance.out_time 	= nil
			employee_attendance.remarks 	= "No Roster"
			employee_attendance.save
		end
	end

  def self.insert_masked_data(device_url, attendance_device)
		begin
			daily_attendance_url = device_url
			daily_attendance_data = RestClient::Request.execute(:method => :get, :url => daily_attendance_url, :timeout => 90000000, verify_ssl: false)
			daily_attendances = JSON.parse(JSON.parse(daily_attendance_data.body)["daily_attendances"].to_json)
		rescue ActiveRecord::RecordNotFound => e
			daily_attendances = []
		end
		daily_attendances = daily_attendances.select{|a| ENV['MASK_ATTENDANCE'].split(',').to_a.include?(a['employee_code'].to_s)}
		daily_attendances = daily_attendances.sort_by { |hash| hash['employee_code'].to_s }
		employee_codes = daily_attendances.group_by{|b| b["employee_code"]}.collect{|key,value| {"employee_code" =>key}}
		employee_codes_array = []
		employee_codes.each do |single_code|
			employee_codes_array << single_code["employee_code"].to_s
		end
		same_employee_codes = employee_codes_array
		same_employee_codes.each do |single_code|
			actual_employee_code = ENV["MASK_#{single_code.to_s}"]
			employee = Employee.find_by(:employee_code => actual_employee_code.to_s, :company_id => attendance_device.company_id)
			if daily_attendances.count > 0
				daily_attendances.each do |daily_attendance|
					if single_code.to_s == daily_attendance["employee_code"].to_s
						attendance_logs = AttendanceMachineLog.where(:log_id => daily_attendance["log_id"], :employee_code => actual_employee_code.to_s)
						if attendance_logs.count == 0
							if employee
								attendance_data = AttendanceMachineLog.new
								attendance_data.employee_code 					= actual_employee_code.to_s
								attendance_data.machine_name 						= daily_attendance["machine_name"]
								attendance_data.attendance_datetime 		= daily_attendance["attendance_date_time"].to_datetime
								attendance_data.attendance_date 				= daily_attendance["attendance_date_time"].to_date
								attendance_data.actual_attendance_date 	= daily_attendance["attendance_date_time"]
								attendance_data.formatted_hour 					= daily_attendance["attendance_date_time"].to_datetime.hour
								attendance_data.formatted_minute 				= daily_attendance["attendance_date_time"].to_datetime.minute
								attendance_data.formatted_second 				= daily_attendance["attendance_date_time"].to_datetime.second
								attendance_data.log_id 									= daily_attendance["log_id"]
								attendance_data.employee_full_name 			= employee.full_name
								attendance_data.employee_id 						= employee.id
								attendance_data.company_id 							= employee.company_id
								attendance_data.save
							end
						end
					end
				end
			end
		end
	end

  def self.att_machine_data_insertion(device_url, attendance_device, log_id, machine_name, att_variable)
    begin
      daily_attendance_data = RestClient::Request.execute(:method => :get, :url => device_url, :timeout => 90000000)
      daily_attendances = JSON.parse(JSON.parse(daily_attendance_data.body)["daily_attendances"].to_json)
    rescue ActiveRecord::RecordNotFound => e
      daily_attendances = []
    end
    daily_attendances = daily_attendances.sort_by { |hash| hash['employee_code'].to_s }
    employee_codes = daily_attendances.group_by{|b| b["employee_code"]}.collect{|key,value| {'employee_code' =>key}}
    employee_codes_array = []
    employee_codes.each do |single_code|
      employee_codes_array << single_code["employee_code"].to_s
    end
    all_emp_data = Employee.where(:company_id => attendance_device.company_id, :is_active => true).pluck(:employee_code, :id, :first_name, :last_name)
    if log_id == 'daily_attendance'
			begin
				if daily_attendances.last && daily_attendances.last['log_id'].to_datetime.class == DateTime
					att_machine_log_ids  = daily_attendances.map{|att| "#{att['log_id'].to_datetime.to_i}"}
				else
					att_machine_log_ids  = daily_attendances.map{|att| "#{att['log_id']}"}
				end
			rescue
				att_machine_log_ids  = daily_attendances.map{|att| "#{att['log_id']}"}
			end
    else
      machine_code = log_id
			begin
				if daily_attendances.last && daily_attendances.last["#{att_variable}"].to_datetime.class == DateTime
					att_machine_log_ids  = daily_attendances.map{|att| "#{machine_code}#{att[att_variable].to_datetime.to_i}"}
				else
					att_machine_log_ids  = daily_attendances.map{|att| "#{machine_code}#{att[att_variable]}"}
				end
			rescue
				att_machine_log_ids  = daily_attendances.map{|att| "#{machine_code}#{att[att_variable]}"}
			end
    end
		attendance_logs = AttendanceMachineLog.where(log_id: att_machine_log_ids).pluck(:log_id, :employee_code)
    employee_codes_in_system = all_emp_data.map{|a| a.first}
    same_employee_codes = employee_codes_in_system & employee_codes_array
    bulk_insert = []
    same_employee_codes.each do |single_code|
      if daily_attendances.count > 0
        daily_attendances.each do |daily_attendance|
          if single_code.to_s == daily_attendance["employee_code"].to_s
            if attendance_device.device_type == 'S7-Finger Tech'
              case single_code
              when '186'
                single_code = '1423'
              when '188'
                single_code = '1422'
              when '1820'
                single_code = '1461'
              when '1818'
                single_code = '2467'
              when '1819'
                single_code = '2473'
              when '172'
                single_code = '2640'
              end
						end
						if machine_code
							begin
								if daily_attendances.last["#{att_variable}"].to_datetime.class == DateTime
									log_id = "#{machine_code}#{daily_attendance[att_variable].to_datetime.to_i}"
								else
									log_id = "#{machine_code}#{daily_attendance[att_variable]}"
								end
							rescue
								log_id = "#{machine_code}#{daily_attendance[att_variable]}"
							end
						else
							log_id =  daily_attendance['log_id'].to_s
						end
						if !attendance_logs.select{|a| a[0] == log_id and a[1]== single_code.to_s }.present? and employee_codes_in_system.include?(single_code)
							employee = all_emp_data.select{|a| a[0] == single_code.to_s}.flatten
              attendance_data = {}
              attendance_data['employee_code'] 					= daily_attendance["employee_code"]
              attendance_data['machine_name'] 						= machine_name == 'machine_name' ? daily_attendance["machine_name"] : daily_attendance["ip_address"]
              attendance_data['attendance_datetime'] 		= daily_attendance["attendance_date_time"].to_datetime
              attendance_data['attendance_date'] 				= daily_attendance["attendance_date_time"].to_date
              attendance_data['actual_attendance_date'] 	= daily_attendance["attendance_date_time"]
              attendance_data['formatted_hour'] 					= daily_attendance["attendance_date_time"].to_datetime.hour
              attendance_data['formatted_minute'] 				= daily_attendance["attendance_date_time"].to_datetime.minute
              attendance_data['formatted_second'] 				= daily_attendance["attendance_date_time"].to_datetime.second
              attendance_data['log_id'] 									= log_id == 'daily_attendance' ? daily_attendance["log_id"] : log_id
              attendance_data['employee_full_name'] 			= employee.last(2).join(' ').strip
              attendance_data['employee_id'] 						= employee[1]
              attendance_data['company_id'] 							= attendance_device.company_id
              attendance_data['device_id'] 							= attendance_device.device_id
              bulk_insert << attendance_data
            end
          end
        end
      end
    end
    if bulk_insert.present?
      AttendanceMachineLog.import(bulk_insert, batch_size: 500) # callbacks won't work
    end
  end

end