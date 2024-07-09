class SystemSetting < ApplicationRecord

	########## Validation ############
	validates :name, 				:uniqueness => { scope: :company_id }
	
	belongs_to 	:company

	########## Validation ############
  validate 		:validate_multiple_setting

  ########## Validation of Multiple Setting ##########
	def validate_multiple_setting
		if self.id.present?
			if SystemSetting.where.not(id:self.id).where(company_id:self.company_id).count > 0
				self.errors.add(:base, "Setting Already Exist for this Company")
			end
		else
			if SystemSetting.where(company_id:self.company_id).count > 0
				self.errors.add(:base, "Setting Already Exist for this Company")
			end
		end
	end

	########## Fetch Employee Code Prefix ##########
	def get_employee_code_prefix(setting_obj, company_id, location_id, branch_id)
		employee_code_prefix = 0
		if setting_obj.nil?
      employee_code_prefix = 0
    else
      if setting_obj.employee_prefix_code_usage == "Company Level"
        company = Company.find(company_id)
        employee_code_prefix = 0
        if Employee.where(:company_id => company_id).count == 0
        	employee_code_prefix = company.employee_code_prefix + Employee.where(:company_id => company_id).count
        else
        	employee_code_prefix = Employee.where(:company_id => company_id).last.employee_code.to_i + 1
        end
      elsif setting_obj.employee_prefix_code_usage == "Location Level"
        location = Location.find(location_id)
        employee_code_prefix = 0
        if Employee.where(:company_id => company_id).count == 0
        	employee_code_prefix = location.employee_code_prefix + Employee.where(:location_id => location_id).count
        else
        	employee_code_prefix = Employee.where(:location_id => location_id).last.employee_code.to_i + 1
        end
      elsif setting_obj.employee_prefix_code_usage == "Branch Level"  
        branch = Branch.find(branch_id)
        employee_code_prefix = 0
        if Employee.where(:company_id => company_id).count == 0
        	employee_code_prefix = branch.employee_code_prefix + Employee.where(:branch_id => branch_id).count
        else
        	employee_code_prefix = Employee.where(:branch_id => branch_id).last.employee_code.to_i + 1
        end
      else
        employee_code_prefix = 0
      end
    end
    return employee_code_prefix.to_i
	end

	def self.get_od_upper_limit(company_id)
		if company_id.nil?
			return 0
		else
			system_setting = SystemSetting.find_by(:company_id => company_id)
			if system_setting.nil?
				return 0
			else
				if system_setting.od_upper_cap_allowed == true
					return system_setting.od_upper_cap_limit
				else
					return 0
				end
			end
		end
	end

	def self.get_od_restriction(company_id)
		if company_id.nil?
			return false
		else
			system_setting = SystemSetting.find_by(:company_id => company_id)
			if system_setting.nil?
				return false
			else
				return system_setting.od_restriction
			end
		end
	end

	def self.get_od_message(company_id)
		if company_id.nil?
			return ""
		else
			system_setting = SystemSetting.find_by(:company_id => company_id)
			if system_setting.nil?
				return ""
			else
				return system_setting.od_message
			end
		end
	end

	def self.od_restriction_validation(company_id, start_date, end_date)
		if company_id.nil?
			return false
		else
			system_setting = SystemSetting.find_by(:company_id => company_id)
			if system_setting.nil?
				return false
			else
				if start_date.to_date >= system_setting.od_start_date.to_date and end_date.to_date <= system_setting.od_end_date.to_date
					return true
				else
					return false
				end
			end
		end
	end

	def self.get_back_date_calculation(company_id)
		if company_id.nil?
			return false
		else
			system_setting = SystemSetting.find_by(:company_id => company_id)
			if system_setting.nil?
				return false
			else
				if system_setting.back_date_calculation == true
					return true
				else
					return false
				end
			end	
		end
	end

	def self.get_hide_religion(company_id)
		if company_id.nil?
			return false
		else
			system_setting = SystemSetting.find_by(:company_id => company_id)
			if system_setting.nil?
				return false
			else
				if system_setting.hide_religion == true
					return true
				else
					return false
				end
			end	
		end
	end

	def self.get_hide_religion_sect(company_id)
		if company_id.nil?
			return false
		else
			system_setting = SystemSetting.find_by(:company_id => company_id)
			if system_setting.nil?
				return false
			else
				if system_setting.hide_religion_sect == true
					return true
				else
					return false
				end
			end	
		end
	end

	def self.overtime_execption(company_id)
		if company_id.nil?
			return false
		else
			system_setting = SystemSetting.find_by(:company_id => company_id)
			if system_setting.nil?
				return false
			else
				if system_setting.overtime_execption == true
					return true
				else
					return false
				end
			end	
		end
	end	

	def self.advance_leave_allowed(company_id)
		if company_id.nil?
			return false
		else
			system_setting = SystemSetting.find_by(:company_id => company_id)
			if system_setting.nil?
				return false
			else
				if system_setting.advance_leave_allowed == true
					return true
				else
					return false
				end
			end	
		end
	end

	def self.advance_leave_limit(company_id)
		if company_id.nil?
			return 0
		else
			system_setting = SystemSetting.find_by(:company_id => company_id)
			if system_setting.nil?
				return 0
			else
				if system_setting.advance_leave_allowed == true
					return system_setting.advance_leave_limit
				else
					return 0
				end
			end
		end
	end

	# SystemSetting.auto_confirmation_process
	def self.auto_confirmation_process
		system_setting = SystemSetting.find_by(:company_id => Company.find_by_is_active(true).try(:id))
		if system_setting.confirmation_days > 0 and system_setting.confirmation_type == 'Day'
			puts "=========Count: #{Employee.where(:is_active => true, :company_id => system_setting.company_id, :location_id => Location.mill_location.ids, :on_probation => true).count}"
			Employee.where(:is_active => true, :company_id => system_setting.company_id, :location_id => Location.mill_location.ids, :on_probation => true).each do |employee|
				puts "==========#{employee.employee_code}==================="
				if employee.joining_date
					days_diff = TimeDifference.between(employee.joining_date, Time.now.to_date).in_days
					if days_diff >= system_setting.confirmation_days
						puts "=======Auto Confirm ==========#{employee.employee_code}==================="
						employee_transaction = EmployeeTransactionHistory.new
						employee_transaction.transaction_date = (employee.confimration_due_date || (employee.joining_date + system_setting.confirmation_days.days))
						employee_transaction.old_employment_status = "Probation"
						employee_transaction.new_employment_status = "Confirmed"
						employee_transaction.transaction_type = "Employment Status"
						employee_transaction.employee_id = employee.id
						employee_transaction.action_performed = "Auto Confirmed By System"
						employee_transaction.save
					end
				end
			end
		end
	end

	# SystemSetting.in-active_piece_rate_employees
	def self.auto_in_active_employees
		if not dtl_instance?
			Employee.where(:location_id => 9, :is_active => true).each do|employee|
				ten_days = ((Date.today)..(Date.today - 10.days))
				check_attendance = EmployeeAttendance.where(:employee_id => employee.id, :attendance_date => ten_days)
				if not check_attendance.present?
					employee.update(:is_active => false)
					if employee.leave_allocations.present?
						employee.leave_allocations.update_all(:is_active => false )
					end
					puts "Employee De-activated #{employee.full_name}"
				end
			end
		end
	end

	def self.dtl_instance?
		ENV.fetch("APP_URL").include?('dtlbe.srl.com.pk')
	end

end
