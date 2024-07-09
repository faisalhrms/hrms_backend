class EmployeeTransactionHistory < ApplicationRecord


	#MONTH_DAYS = ENV.fetch("APP_URL").include?('millshrmsbe.dfl.com.pk') ? 26 : 30.42
	####### Relation Ship #########
	belongs_to 	:employee

	belongs_to	:prev_location, 				foreign_key: :old_location_id, 				:class_name => "Location"
	belongs_to	:prev_branch, 					foreign_key: :old_branch_id, 					:class_name => "Branch"
	belongs_to	:prev_department, 			foreign_key: :old_department_id, 			:class_name => "Department"
	belongs_to	:prev_line_manager, 		foreign_key: :old_line_manager_id, 		:class_name => "Employee"
	belongs_to	:prev_head_of_department, 		foreign_key: :old_hod_id, 		:class_name => "Employee"
	belongs_to	:prev_grade, 						foreign_key: :old_grade_id, 					:class_name => "Grade"
	belongs_to	:prev_designation, 			foreign_key: :old_designation_id, 		:class_name => "Designation"
	belongs_to	:prev_job_title, 				foreign_key: :old_job_title_id, 			:class_name => "JobTitle"
	belongs_to	:prev_salary_unit, 			foreign_key: :old_salary_unit_id, 		:class_name => "SalaryUnit"
	belongs_to	:prev_cost_center, 			foreign_key: :old_cost_center_id, 		:class_name => "CostCenter"
	belongs_to	:prev_employee_type, 		foreign_key: :old_employee_type_id, 	:class_name => "EmployeeType"

	belongs_to	:current_location, 			foreign_key: :new_location_id, 				:class_name => "Location"
	belongs_to	:current_branch, 				foreign_key: :new_branch_id, 					:class_name => "Branch"
	belongs_to	:current_department, 		foreign_key: :new_department_id, 			:class_name => "Department"
	belongs_to	:current_line_manager, 	foreign_key: :new_line_manager_id, 		:class_name => "Employee"
	belongs_to	:current_head_of_department, 	foreign_key: :new_hod_id, 		:class_name => "Employee"
	belongs_to	:current_grade, 				foreign_key: :new_grade_id, 					:class_name => "Grade"
	belongs_to	:current_designation, 	foreign_key: :new_designation_id, 		:class_name => "Designation"
	belongs_to	:current_job_title, 		foreign_key: :new_job_title_id, 			:class_name => "JobTitle"
	belongs_to	:current_salary_unit, 	foreign_key: :new_salary_unit_id, 		:class_name => "SalaryUnit"
	belongs_to	:current_cost_center, 	foreign_key: :new_cost_center_id, 		:class_name => "CostCenter"
	belongs_to	:current_employee_type, foreign_key: :new_employee_type_id, 	:class_name => "EmployeeType"

	scope :get_by_type, -> (type){where(transaction_type: type)}
	scope :get_by_date, -> (start_date, end_date){where(transaction_date: start_date..end_date)}

	after_save :add_impact_in_employee
	TRANSACTION_TYPES = {eoe: 'End of Employment'}
	def add_impact_in_employee
		employee = self.employee
		on_probation = true	
		if self.new_employment_status == "Probation"
			on_probation = true	
		else
			on_probation = false
		end
		is_active = true
		if self.new_employee_status == "Active"
			is_active = true
		else
			is_active = false
		end
		if self.transaction_type == "Employment Status"
			employee.on_probation = on_probation
			if on_probation == true
				employee.confirmation_date = nil
			else
				employee.confirmation_date = self.transaction_date.to_date	
			end
		elsif self.transaction_type == "Employee Status"
			employee.is_active = is_active
		elsif self.transaction_type == "Gross Salary"
			employee.gross_salary = self.new_gross_salary
		elsif self.transaction_type == "Change Joining Date"
			employee.joining_date = self.new_joining_date.to_date
		elsif self.transaction_type == "Line Manager"
			employee.line_manager_id = self.new_line_manager_id
		elsif self.transaction_type == "Head of Department"
			employee.hod_id = self.new_hod_id
		elsif self.transaction_type == "Transfer"
			if self.transfer_type == "Branch"
				employee.location_id = self.new_location_id
				employee.branch_id = self.new_branch_id
			elsif self.transfer_type 	== "Department"
				employee.department_id = self.new_department_id
				employee.sub_department_id = self.new_sub_department_id
			end
		elsif self.transaction_type == "Change Grade" or self.transaction_type == "Change Designation"
			employee.grade_id = self.new_grade_id
			employee.designation_id = self.new_designation_id
		elsif self.transaction_type == "Change Job Title"
			employee.job_title_id = self.new_job_title_id
		elsif self.transaction_type == "Change Employee Type"
			employee.employee_type_id = self.new_employee_type_id
		elsif self.transaction_type == "Change Salary Unit"
			employee.salary_unit_id = self.new_salary_unit_id
			employee.cost_center_id = self.new_cost_center_id
		elsif self.transaction_type == "End of Employment"
			employee.hold_salary = self.hold_salary
			employee.left_type 	= self.left_type
			employee.left_reason = self.left_reason
			employee.is_struck_off = self.is_struck_off
			employee.is_active 	= false if self.left_type != "Struck Off"
			employee.user.update(is_active: false) if employee.user.present?
			employee.leave_allocations.active.update_all(is_active: false)
		elsif self.transaction_type == "Probation Extension"
			employee.confimration_due_date = self.new_confimration_due_date
		end
		employee.save
		if on_probation == false && self.transaction_type == "Employment Status"
			########## Auto Leave Allocation on new employee confimrmation ##########
			LeaveType.where(:company_id => employee.company_id, :is_active => true, :location_id => employee.location_id, :auto_allocation => true, :eligible => "DOC", :is_leave_without_pay => false).each do |leave_type|
				grade_condition = true
				if leave_type.grade_ids.try(:split, ',').try(:map, &:to_i)
					grade_condition = leave_type.grade_ids.try(:split, ',').try(:map, &:to_i).include? employee.grade_id
				end
				if grade_condition
					leave_allocation = LeaveAllocation.create(:location_id => employee.location_id, :is_active => true, :company_id => employee.company_id, :leave_type_id => leave_type.id, :employee_id => employee.id)
					if not leave_allocation.nil?
						leave_transaction = LeaveTransactionHistory.find_by(:employee_id => leave_allocation.employee_id, :leave_type_id => leave_allocation.leave_type_id, :leave_allocation_id => nil)
						if not leave_transaction.nil?
							leave_transaction.leave_allocation_id = leave_allocation.id
							leave_transaction.save
						end
					end
				end
			end
			#########################################################################
			########## Moved CL Probation Balance of Last Year to New Year ##########
			#########################################################################
			leave_type_ids = []
			LeaveType.where(:name => "Casual Leave", :company_id => employee.company_id, :is_active => true, :auto_allocation => true, :eligible => "DOJ", :is_leave_without_pay => false, :transfer_probation_balance => true).each do |leave_type|
				grade_condition = true
				if leave_type.grade_ids.try(:split, ',').try(:map, &:to_i)
					grade_condition = leave_type.grade_ids.try(:split, ',').try(:map, &:to_i).include? employee.grade_id
				end
				leave_type_ids << leave_type.id if grade_condition
			end
			new_leave_allocation = employee.leave_allocations.find_by(:is_active => true, :leave_type_id => leave_type_ids)
			old_leave_allocation = employee.leave_allocations.where(:is_active => false, :leave_type_id => leave_type_ids).last
			if not new_leave_allocation.nil?
				if not old_leave_allocation.nil?
					if LeaveTransactionHistory.where(:transaction_type => "Earned", :remarks => "Moved Last Year Remaining Balance on Confimrmation", :company_id => employee.company_id, :employee_id => employee.id, :leave_type_id => new_leave_allocation.leave_type_id).count == 0
						new_leave_allocation.allocated_quota = new_leave_allocation.allocated_quota + old_leave_allocation.remaining_quota.round(2).to_f
						new_leave_allocation.remaining_quota = new_leave_allocation.remaining_quota + old_leave_allocation.remaining_quota.round(2).to_f
						new_leave_allocation.save(:validate => false)
						LeaveTransactionHistory.create_leave_transaction(employee.company_id, employee.id, new_leave_allocation.leave_type_id, nil, new_leave_allocation.allocated_quota, new_leave_allocation.remaining_quota, new_leave_allocation.used_quota, old_leave_allocation.remaining_quota.round(2).to_f, "Earned", "Moved Last Year Remaining Balance on Confimrmation", new_leave_allocation.leave_year_start_date, new_leave_allocation.leave_year_end_date, new_leave_allocation.id)
					end
				end
			end
			#########################################################################
			########## Moved CL Probation Balance of Last Year to New Year ##########
			#########################################################################
			
			#########################################################################
			########## Moved SL Probation Balance of Last Year to New Year ##########
			#########################################################################
			leave_type_ids = []
			LeaveType.where(:name => "Sick Leave", :company_id => employee.company_id, :is_active => true, :auto_allocation => true, :eligible => "DOJ", :is_leave_without_pay => false, :transfer_probation_balance => true).each do |leave_type|
				grade_condition = true
				if leave_type.grade_ids.try(:split, ',').try(:map, &:to_i)
					grade_condition = leave_type.grade_ids.try(:split, ',').try(:map, &:to_i).include? employee.grade_id
				end
				leave_type_ids << leave_type.id if grade_condition
			end
			new_leave_allocation = employee.leave_allocations.find_by(:is_active => true, :leave_type_id => leave_type_ids)
			old_leave_allocation = employee.leave_allocations.where(:is_active => false, :leave_type_id => leave_type_ids).last
			if not new_leave_allocation.nil?
				if not old_leave_allocation.nil?
					if LeaveTransactionHistory.where(:transaction_type => "Earned", :remarks => "Moved Last Year Remaining Balance on Confimrmation", :company_id => employee.company_id, :employee_id => employee.id, :leave_type_id => new_leave_allocation.leave_type_id).count == 0
						new_leave_allocation.allocated_quota = new_leave_allocation.allocated_quota + old_leave_allocation.remaining_quota.round(2).to_f
						new_leave_allocation.remaining_quota = new_leave_allocation.remaining_quota + old_leave_allocation.remaining_quota.round(2).to_f
						new_leave_allocation.save(:validate => false)
						LeaveTransactionHistory.create_leave_transaction(employee.company_id, employee.id, new_leave_allocation.leave_type_id, nil, new_leave_allocation.allocated_quota, new_leave_allocation.remaining_quota, new_leave_allocation.used_quota, old_leave_allocation.remaining_quota.round(2).to_f, "Earned", "Moved Last Year Remaining Balance on Confimrmation", new_leave_allocation.leave_year_start_date, new_leave_allocation.leave_year_end_date, new_leave_allocation.id)
					end
				end
			end
			#########################################################################
			########## Moved SL Probation Balance of Last Year to New Year ##########
			#########################################################################
		end
		EmployeeTransactionHistory.transaction_history_for_employee_code_on_transfer(employee, self)
	end

	def self.transaction_history_for_employee_code_on_transfer(employee, employee_transaction)
		old_employee_code = employee.employee_code
		if employee_transaction.transaction_type == "Transfer" && employee_transaction.transfer_type == "Branch"
			########## Transfer Impact on Roster ##########
			EmployeeRoster.transfer_impact_on_roster(employee, employee_transaction)
			########## Verification Change of Employee Code ##########
			system_setting = SystemSetting.find_by(:company_id => employee.company_id)
			if not system_setting.nil?
				if system_setting.employee_prefix_code_usage != "Company Level"
					if system_setting.is_employee_code_changeable == true
						new_employee_code = system_setting.get_employee_code_prefix(system_setting, employee.company_id, employee.location_id, employee.branch_id)
						new_employee_transaction = EmployeeTransactionHistory.new
						new_employee_transaction.new_employee_code 	=	new_employee_code.to_s
						new_employee_transaction.old_employee_code 	= old_employee_code.to_s
						new_employee_transaction.transaction_type 	= "Employee Code"
						new_employee_transaction.remarks 						= "Employee Code Due To Transfer"
						new_employee_transaction.transaction_date 	= Time.now.to_date
						new_employee_transaction.employee_id 				= employee.id
						new_employee_transaction.save
						employee.prev_employee_code = employee.employee_code.to_s
						employee.employee_code 			= new_employee_code.to_s
						employee.save
					end
				end
			end
		end
	end

	def prve_location_name
  	if self.prev_location.nil?
  		return "-"
  	else
  		return self.prev_location.name
  	end
  end

	def prve_branch_name
		if self.prev_branch.nil?
  		return "-"
  	else
  		return self.prev_branch.name
  	end
	end

	def prve_department_name
		if self.prev_department.nil?
  		return "-"
  	else
  		return self.prev_department.name
  	end
	end

	def prev_line_manager_name
		if self.prev_line_manager.nil?
  		return "-"
  	else
  		return self.prev_line_manager.full_name
  	end
	end

	def prev_grade_name
		if self.prev_grade.nil?
  		return "-"
  	else
  		return self.prev_grade.name
  	end
	end

	def prev_designation_name
		if self.prev_designation.nil?
  		return "-"
  	else
  		return self.prev_designation.name
  	end
	end

	def prev_job_title_name
		if self.prev_job_title.nil?
  		return "-"
  	else
  		return self.prev_job_title.name
  	end
	end

	def prev_salary_unit_name
		if self.prev_salary_unit.nil?
  		return "-"
  	else
  		return self.prev_salary_unit.name
  	end
	end

	def prev_cost_center_name
		if self.prev_cost_center.nil?
  		return "-"
  	else
  		return self.prev_cost_center.name
  	end
	end

	def prev_employee_type_name
		if self.prev_employee_type.nil?
  		return "-"
  	else
  		return self.prev_employee_type.name
  	end
	end

	def current_location_name
  	if self.current_location.nil?
  		return "-"
  	else
  		return self.current_location.name
  	end
  end

	def current_branch_name
		if self.current_branch.nil?
  		return "-"
  	else
  		return self.current_branch.name
  	end
	end

	def current_department_name
		if self.current_department.nil?
  		return "-"
  	else
  		return self.current_department.name
  	end
	end

	def current_line_manager_name
		if self.current_line_manager.nil?
  		return "-"
  	else
  		return self.current_line_manager.full_name
  	end
	end

	def current_grade_name
		if self.current_grade.nil?
  		return "-"
  	else
  		return self.current_grade.name
  	end
	end

	def current_designation_name
		if self.current_designation.nil?
  		return "-"
  	else
  		return self.current_designation.name
  	end
	end

	def current_job_title_name
		if self.current_job_title.nil?
  		return "-"
  	else
  		return self.current_job_title.name
  	end
	end

	def current_salary_unit_name
		if self.current_salary_unit.nil?
  		return "-"
  	else
  		return self.current_salary_unit.name
  	end
	end

	def current_cost_center_name
		if self.current_cost_center.nil?
  		return "-"
  	else
  		return self.current_cost_center.name
  	end
	end

	def current_employee_type_name
		if self.current_employee_type.nil?
  		return "-"
  	else
  		return self.current_employee_type.name
  	end
	end

	def employee_gross_salary
		if self.employee.nil?
  		return 0
  	else
  		return self.employee.gross_salary
  	end
	end
	
end
