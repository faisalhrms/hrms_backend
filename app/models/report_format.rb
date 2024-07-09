class ReportFormat

	def self.cnic_format(cnic_data)
		if cnic_data.present?
			if not cnic_data.nil?
				if cnic_data.size == 13
					cnic_data.from(0).to(4) +"-"+ cnic_data.from(5).to(6) +"-"+ cnic_data.from(12).to(1)
				else
					cnic_data
				end
			else
				cnic_data
			end
		end
	end

	# ReportFormat.request_user_full_name(current_user)
	def self.request_user_full_name(current_user)
		if current_user.nil?
			return "-"
		else
			if current_user.employee.nil?
				return current_user.full_name
			else
				return current_user.employee.full_name
			end	
		end
	end

	# ReportFormat.phone_format
	def self.phone_format(number_data)
		if number_data.present?
			if number_data.size == 11
				number_data.from(0).to(3) +"-"+ number_data.from(4).to(7)
			else
				number_data
			end
		end
	end

	# ReportFormat.complete_datetime_format
	def self.complete_datetime_format(current_date)
		if current_date.nil?
			return "-"
		else
			return (current_date.to_datetime - 5.hour).to_datetime.strftime("%Y-%m-%d %H:%M:%S")
		end
	end

	def self.date_format(current_date)
		if current_date.nil?
			return "-"
		else
			return current_date.to_date
		end
	end

	def self.twelve_hours_time_format(current_date)
		if current_date.nil?
			return "-"
		else
			return current_date.strftime("%I:%M:%S %P")
		end
	end

	def self.twenty_four_hour_time_format(current_date)
		if current_date.nil?
			return "-"
		else
			return current_date.strftime("%d/%m/%Y %H:%M")
		end
	end

	def self.date_only_year(current_date)
		if current_date.nil?
			return "-"
		else
			return current_date.to_date.strftime("%Y")
		end
	end

	def self.date_format1(current_date)
		if current_date.nil?
			return "-"
		else
			return current_date.to_date.strftime("%A, %B %-d, %Y")
		end
	end

	def self.date_format2(current_date)
		if current_date.nil?
			return "-"
		else
			return current_date.to_date.strftime("%a %d-%m-%Y")
		end
	end

	def self.date_format3(current_date)
		if current_date.nil?
			return "-"
		else
			return current_date.to_date.strftime("%d-%m-%Y")
		end
	end

	def self.time_card_date_format(current_date)
		if current_date.nil?
			return "-"
		else
			return current_date.to_date.strftime("%d-%m-%y (%a)")
		end
	end

	def self.salary_sheet_date_format(current_date)
		if current_date.nil?
			return "-"
		else
			return current_date.to_date.strftime("%d/%m/%Y")
		end
	end
	
	def self.date_in_human_readable(current_date, end_date = nil)
		if current_date.nil?
			return "-"
		else
			formated_date = TimeDifference.between(current_date.to_date,Date.today).in_days
			formated_date = TimeDifference.between(current_date.to_date, end_date.to_date).in_days if end_date.present?
			formated_date = "#{(formated_date/365).to_i} years, #{((formated_date%365)/30).to_i} months, #{(((formated_date%365)%30)/7).to_i} weeks, #{(((formated_date%365)%30)%7).to_i} days"
			return formated_date
		end
	end

	def self.formatted_duration_clock_format(total_seconds)
    hours = total_seconds / (60 * 60)
    minutes = (total_seconds / 60) % 60
    seconds = total_seconds % 60
    return "#{  sprintf('%02d',hours) }:#{  sprintf('%02d',minutes) }"
  end

	def self.boolean_in_text(current_value)
		if current_value == true
			return "Yes"
		elsif current_value == false
			return "No"
		else
			return "-"
		end
	end

	def self.boolean_in_text_as_active(current_value)
		if current_value == true
			return "Active"
		elsif current_value == false
			return "In-Active"
		else
			return "-"
		end
	end

	def self.boolean_in_text_as_confirmed(current_value)
		if current_value == true
			return "Probation"
		elsif current_value == false
			return "Confirmed"
		else
			return "-"
		end
	end

	def self.boolean_in_text_as_allowed(current_value)
		if current_value == true
			return "Allowed"
		elsif current_value == false
			return "Not Allowed"
		else
			return "-"
		end
	end

	def self.overtime_hours(in_time, out_time, working_hours)
		if not in_time.nil?
			if not out_time.nil?
				served_hours = TimeDifference.between(in_time, out_time).in_hours
				over_time_hours = (served_hours - working_hours).round(2)
				return over_time_hours
			else
				return 0
			end
		else
			return 0
		end
	end

	def self.employee_age(current_date)
		if current_date.nil?
			return 0
		else
			age_in_years = TimeDifference.between(current_date.to_date,Date.today).in_years
			return age_in_years
		end
	end

	def self.employee_age_in_human(employee)
		if employee.date_of_birth.nil?
			return "0.0 years, 0.0 months, 0.0 weeks, 0.0 days"
		else
			experience = TimeDifference.between(employee.date_of_birth.to_date,Date.today).in_days
			return "#{(experience/365).to_i} years, #{((experience%365)/30).to_i} months, #{(((experience%365)%30)/7).to_i} weeks, #{(((experience%365)%30)%7).to_i} days"	
		end
	end

	def self.employee_experince(current_date)
		experience = 0
		if current_date.present?
			experience = TimeDifference.between(current_date.to_date,Date.today).in_days
		else
			experience = 0
		end
		if experience == 0
			experience = 0
		else
			experience = (experience.to_f/365.to_f).round(2).to_s + "Years"
		end
		return experience
	end

	def self.employee_previous_experince(employee)
		if employee.employee_experiences.count > 0
			temp_days = ReportFormat.get_date_difference(employee.employee_experiences.map(&:start_date),employee.employee_experiences.map(&:end_date))
			experience = TimeDifference.between(Date.today + temp_days ,Date.today).in_days
			return "#{(experience/365).to_i} years, #{((experience%365)/30).to_i} months, #{(((experience%365)%30)/7).to_i} weeks, #{(((experience%365)%30)%7).to_i} days"
		else
			return "0.0 years, 0.0 months, 0.0 weeks, 0.0 days"
		end
	end

	def self.employee_current_experince(employee)
		if employee.joining_date.nil?
			return "0.0 years, 0.0 months, 0.0 weeks, 0.0 days"
		else
			experience = TimeDifference.between(employee.joining_date.to_date,Date.today).in_days
			return "#{(experience/365).to_i} years, #{((experience%365)/30).to_i} months, #{(((experience%365)%30)/7).to_i} weeks, #{(((experience%365)%30)%7).to_i} days"	
		end
	end

	def self.employee_previous_experince_in_years(employee)
		if employee.employee_experiences.count > 0
			temp_days = ReportFormat.get_date_difference(employee.employee_experiences.map(&:start_date),employee.employee_experiences.map(&:end_date))
			experience = TimeDifference.between(Date.today + temp_days ,Date.today).in_years
			return experience.to_s + " Years"
		else
			return "0.0"
		end
	end

	def self.employee_current_experince_in_years(employee)
		if employee.joining_date.nil?
			return "0.0"
		else
			experience = TimeDifference.between(employee.joining_date.to_date,Date.today).in_years
			return experience
		end
	end

	def self.month_difference(start_date, end_date)
		experience_in_months = 0
		if not start_date.nil?
			if not end_date.nil?
				experience_in_months = TimeDifference.between(start_date.to_date,end_date.to_date).in_months.round
			end
		end
		return experience_in_months
	end

	def self.get_date_difference(start_date_array,end_date_array)
    employee_duration = 0.0
    start_date_array.zip(end_date_array).each do |start_date,end_date|
    	if start_date.present? and end_date.present?
			employee_duration = employee_duration + TimeDifference.between(start_date,end_date).in_days
    	end
    end
		return employee_duration
	end

	def self.non_text_to_dash(current_value)
		if not current_value.nil?
			if not current_value.blank?
				if current_value.to_s.length == 0
					return '-'
				else
					return current_value
				end
			else
				return '-'	
			end
		else
			return '-'
		end
	end

	def self.non_float_to_dash(current_value)
		if not current_value.nil?
			if not current_value.blank?
				if current_value.to_f == 0
					return '-'
				else
					return current_value
				end
			else
				return '-'	
			end
		else
			return '-'
		end
	end

	# ReportFormat.zero_to_dash
  def self.zero_to_dash(selected_value)
  	if selected_value.to_f > 0
  		return selected_value
  	else
  		return "-"
  	end
  end

  def self.rest_day_name(employee_attendance)
		if employee_attendance.is_rest_day == true
			return employee_attendance.attendance_date.to_date.strftime("%A")
		else
			return "-"	
		end
	end

	def self.roster_rest_day_name(employee_roster)
		if employee_roster.is_rest_day == true
			return employee_roster.roster_date.to_date.strftime("%A")
		else
			return "-"	
		end
	end

	# ReportFormatlast_rest_day_name(employee_attendances)
	def self.last_rest_day_name(employee_attendances)
		employee_attendance = employee_attendances.where(:is_rest_day => true).last
		if not employee_attendance.nil?
			return employee_attendance.attendance_date.to_date.strftime("%A")
		else
			return "-"	
		end
	end

	# ReportFormat.verification_of_nan(selected_value)
	def self.verification_of_nan(selected_value)
		return (selected_value.is_a?(Float) && selected_value.nan?) ? 0 : selected_value
	end

	# ReportFormat.insurance_report_date_format
	def self.insurance_report_date_format(current_date)
		if current_date.nil?	
			return "-"
		else
			return current_date.to_date.strftime("%d/%m/%Y")
		end
	end

	# ReportFormat.date_of_birth_in_years
	def self.date_of_birth_in_years(current_date)
		if current_date.nil?
			return 0.0
		else
			difference_in_years = TimeDifference.between(current_date.to_date,Date.today).in_years
			return difference_in_years
		end
	end

	# ReportFormat.bonus_eligibility
	def self.bonus_eligibility(employee, bonus_type)
    item_eligible_date = nil
    if bonus_type == "Eid Ul Fitr Bonus"
      if employee.bonus1_allowed == true
        if employee.bonus1_eligibility == "Date of Joining"
          item_eligible_date = employee.joining_date
        elsif employee.bonus1_eligibility == "Date of Confirmation"
          item_eligible_date = employee.confirmation_date
        elsif employee.bonus1_eligibility == "Completion of 1 Year"
          item_eligible_date = employee.joining_date + 1.year
        end
      end
    elsif bonus_type == "Eid Ul Adha Bouns"
      if employee.bonus2_allowed == true
        if employee.bonus2_eligibility == "Date of Joining"
          item_eligible_date = employee.joining_date
        elsif employee.bonus2_eligibility == "Date of Confirmation"
          item_eligible_date = employee.confirmation_date
        elsif employee.bonus2_eligibility == "Completion of 1 Year"
          item_eligible_date = employee.joining_date + 1.year
        end
      end
    elsif bonus_type == "Annual Bonus"
      if employee.bonus3_allowed == true
        if employee.bonus3_eligibility == "Date of Joining"
          item_eligible_date = employee.joining_date
        elsif employee.bonus3_eligibility == "Date of Confirmation"
          item_eligible_date = employee.confirmation_date
        elsif employee.bonus3_eligibility == "Completion of 1 Year"
          item_eligible_date = employee.joining_date + 1.year
        end
      end
    end
    return item_eligible_date
  end

  def self.shift_name(employee_attendance)
  	selected_name = "-"
  	if not employee_attendance.employee_roster.nil?
  		if not employee_attendance.employee_roster.time_slot.nil?
  			if employee_attendance.employee_roster.time_slot.is_flexi == true and employee_attendance.sub_time_slot_id != nil
  				selected_name = employee_attendance.sub_time_slot_name
  			else
  				selected_name = employee_attendance.employee_roster.time_slot_name
  			end
  		else
  			selected_name = employee_attendance.employee_roster.time_slot_name
  		end
  	else
  		selected_name = employee_attendance.employee_roster.time_slot_name
  	end
  	return selected_name
  end

  def self.shift_timing(employee_attendance)
  	selected_timing = "-"
  	if not employee_attendance.employee_roster.nil?
  		if not employee_attendance.employee_roster.time_slot.nil?
  			if employee_attendance.employee_roster.time_slot.is_flexi == true and employee_attendance.sub_time_slot_id != nil
  				selected_timing = "#{employee_attendance.sub_time_slot.actual_start_time} #{employee_attendance.sub_time_slot.actual_end_time}"
  			else
  				selected_timing = "#{employee_attendance.employee_roster.formated_start_time} #{employee_attendance.employee_roster.formated_end_time}"
  			end
  		else
  			selected_timing = "#{employee_attendance.employee_roster.formated_start_time} #{employee_attendance.employee_roster.formated_end_time}"
  		end
  	else
  		selected_timing = "#{employee_attendance.employee_roster.formated_start_time} #{employee_attendance.employee_roster.formated_end_time}"
  	end
  	return selected_timing
  end

  # ReportFormat.overtime_value_into_overtime_hours(seconds)
	def self.overtime_value_into_overtime_hours(seconds, decimals = 0)
	  int   = seconds.floor
	  decs  = [decimals, 8].min
	  frac  = seconds - int
	  hms   = [int / 3600, (int / 60) % 60, int % 60].map { |t| t.to_s.rjust(2,'0') }.join(':')
	  if decs > 0
	    fp = (frac == 0) ? '.00' : "#{(frac).round(decs)}"[1..-1]
	    hms  << fp
	  end
	  hm_data = hms.split(':')
	  return "#{hm_data[0]}:#{hm_data[1]}"
	end

	# ReportFormat.employee_qualification_program_name(employee)
	def self.employee_qualification_program_name(employee)
		employee_qualification = employee.employee_qualifications.last
		if not employee_qualification.nil?
			return employee_qualification.program_name
		else
			return "-"
		end
	end
	
	# ReportFormat.employee_qualification_year(employee)
	def self.employee_qualification_year(employee)
		employee_qualification = employee.employee_qualifications.last
		if not employee_qualification.nil?
			if employee_qualification.end_date.nil?
				return "-"
			else
				return employee_qualification.end_date.to_date.strftime("%Y")
			end
		else
			return "-"
		end
	end
	
	# ReportFormat.employee_qualification_institute_name(employee)
	def self.employee_qualification_institute_name(employee)
		employee_qualification = employee.employee_qualifications.last
		if not employee_qualification.nil?
			return employee_qualification.institute_name
		else
			return "-"
		end
	end

end