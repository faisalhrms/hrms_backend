class EmployeeRoster < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:location
	belongs_to 	:branch
	belongs_to 	:department
	belongs_to 	:grade
	belongs_to 	:time_slot
	belongs_to 	:employee

	validates :roster_date, :uniqueness => { scope: :employee_id }

	def time_slot_name
  	if self.time_slot.nil?
  		return "-"
  	else
  		return self.time_slot.name
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

	def department_name
		if self.department.nil?
  		return "-"
  	else
  		return self.department.name
  	end
	end

	def grade_name
		if self.grade.nil?
  		return "-"
  	else
  		return self.grade.name
  	end
	end

	def self.location_related_employee_roster(employee_roster_list, location_id)
		employee_rosters = employee_roster_list.where(:location_id => location_id)
		return employee_rosters
	end

	def self.branch_related_employee_roster(employee_roster_list, branch_id)
		employee_rosters = employee_roster_list.where(:branch_id => branch_id)
		return employee_rosters
	end

	def self.department_related_employee_roster(employee_roster_list, department_id)
		employee_rosters = employee_roster_list.where(:department_id => department_id)
		return employee_rosters
	end

	def self.sub_department_related_employee_roster(employee_roster_list, sub_department_id)
		employee_roster_list.where(:sub_department_id => sub_department_id)
	end

	def self.grade_related_employee_roster(employee_roster_list, grade_id)
		employee_rosters = employee_roster_list.where(:grade_id => grade_id)
		return employee_rosters
	end

	def self.repeat_every_week(selected_day, selected_day_dates)
		date_range = []
		if selected_day == "true"
      date_range = date_range + selected_day_dates
    end
    return date_range
	end

	def self.selected_day_verification(selected_day, selected_date)
		if selected_day[:monday] == "true" && selected_date.strftime("%A") == "Monday"
			return selected_date
		end
		if selected_day[:tuesday] == "true" && selected_date.strftime("%A") == "Tuesday"
			return selected_date
		end
		if selected_day[:wednesday] == "true" && selected_date.strftime("%A") == "Wednesday"
			return selected_date
		end
		if selected_day[:thursday] == "true" && selected_date.strftime("%A") == "Thursday"
			return selected_date
		end
		if selected_day[:friday] == "true" && selected_date.strftime("%A") == "Friday"
			return selected_date
		end
		if selected_day[:saturday] == "true" && selected_date.strftime("%A") == "Saturday"
			return selected_date
		end
		if selected_day[:sunday] == "true" && selected_date.strftime("%A") == "Sunday"
			return selected_date
		end
	end

	########## Update Attendance Information with Employee Roster ##########
	def self.update_employee_roster(single_date, employee_attendance)
  	employee_roster = EmployeeRoster.find_by(:employee_id => employee_attendance.employee_id, :roster_date => single_date)
  	if employee_roster.nil?
  		employee_attendance.roster_exist = false
  		employee_attendance.save
  	else	
  		current_time = employee_attendance.attendance_date.to_date
  		new_current_time = employee_attendance.attendance_date.to_date + 1.day
      office_in_time = Time.new(current_time.year, current_time.month, current_time.day, employee_roster.start_time.to_time.strftime('%H'), employee_roster.start_time.to_time.strftime('%M'), employee_roster.start_time.to_time.strftime('%S'))
      office_out_time = Time.new(current_time.year, current_time.month, current_time.day, employee_roster.end_time.to_time.strftime('%H'), employee_roster.end_time.to_time.strftime('%M'), employee_roster.end_time.to_time.strftime('%S'))

      if office_in_time > office_out_time 
      	office_out_time = Time.new(new_current_time.year, new_current_time.month, new_current_time.day, employee_roster.end_time.to_time.strftime('%H'), employee_roster.end_time.to_time.strftime('%M'), employee_roster.end_time.to_time.strftime('%S'))		
      end

  		employee_attendance.roster_exist 				= true
  		employee_attendance.roster_id 					= employee_roster.id
  		employee_attendance.time_slot_id 				= employee_roster.time_slot_id
  		employee_attendance.is_rest_day 				= employee_roster.is_rest_day
  		employee_attendance.is_flexi 						= employee_roster.is_flexi
  		employee_attendance.office_start_time		= employee_roster.start_time
			employee_attendance.office_end_time			= employee_roster.end_time
      
      employee_attendance.office_in_time			= office_in_time
			employee_attendance.office_out_time			= office_out_time
			employee_attendance.start_buffer				= employee_roster.start_buffer
 			employee_attendance.end_buffer					= employee_roster.end_buffer

 			employee_attendance.buffer_office_in_time		= office_in_time - employee_roster.start_buffer.minute
			employee_attendance.buffer_office_out_time	= office_out_time + employee_roster.end_buffer.minute

 			employee_attendance.office_start_hour = employee_roster.start_time.to_time.strftime('%H').to_i
 			employee_attendance.office_start_min  = employee_roster.start_time.to_time.strftime('%M').to_i

 			employee_attendance.office_end_hour 	= employee_roster.end_time.to_time.strftime('%H').to_i
 			employee_attendance.office_end_min  	= employee_roster.end_time.to_time.strftime('%M').to_i

			employee_attendance.buffer_office_start_hour = employee_attendance.buffer_office_in_time.to_time.strftime('%H').to_i
 			employee_attendance.buffer_office_start_min  = employee_attendance.buffer_office_in_time.to_time.strftime('%M').to_i

 			employee_attendance.buffer_office_end_hour 	 = employee_attendance.buffer_office_out_time.to_time.strftime('%H').to_i
 			employee_attendance.buffer_office_end_min 	 = employee_attendance.buffer_office_out_time.to_time.strftime('%M').to_i

  		employee_attendance.save
  	end
  end

  def self.transfer_impact_on_roster(employee, employee_transaction)
		emp_rosters = EmployeeRoster.where(:employee_id => employee.id, :is_transfer => false)
		emp_rosters.where('roster_date < ?', employee_transaction.transaction_date.to_date).update_all(is_transfer: true)
		emp_rosters.where('roster_date >= ?', employee_transaction.transaction_date.to_date).update_all(location_id: employee_transaction.new_location_id, branch_id: employee_transaction.new_branch_id)
  end

	def self.group_by_employee(date_range, employee_ids)
		employee_roster_data = {}
		EmployeeRoster.where(roster_date: date_range, employee_id: employee_ids).group_by(&:employee_id).each do |employee_id, data|
			employee_roster_data[employee_id] = data
		end
		employee_roster_data
	end
end
