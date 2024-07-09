class EmployeeAttendance < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:location
	belongs_to 	:branch
	belongs_to 	:department
	belongs_to 	:sub_department
	belongs_to 	:grade
	belongs_to 	:designation
	belongs_to 	:job_title
	belongs_to 	:salary_unit
	belongs_to 	:cost_center
	belongs_to 	:employee
  belongs_to :cpl_earning
	belongs_to 	:sub_time_slot
	belongs_to	:employee_roster, foreign_key: :roster_id, 	:class_name => "EmployeeRoster"
	TOTAL_LEVERAGE_MIN = 250
	validate :restrict_back_dates

	scope :get_by_attendance_date, -> (date){where(attendance_date: date)}
	scope :get_by_employee_id, -> (id){where(employee_id: id)}
	scope :get_by_remarks, -> (remarks){where(remarks: remarks)}
	scope :get_by_in_over_strength, -> (in_strength, over_strength, gazetted) {where(in_strength: in_strength, over_strength: over_strength, gazetted: gazetted)}

	def restrict_back_dates
		allowed_days = RestrictLeave.allowed_leave_days

		if allowed_days and !RestrictLeave.admin.include?(User.current) and is_ot_approved and created_at.to_date < allowed_days.days.ago.to_date
			self.errors.add(:base, "You can only approve Over Time for last #{allowed_days} days of attendance fetched. Failed for ")
		end
	end

	def roster_transfer_impact
		if self.employee_roster.nil?
			return false
		else
			if self.employee_roster.is_transfer == false
				return false
			else
				return true
			end
		end
	end

	def sub_time_slot_name
		if self.sub_time_slot.nil?
  		return "-"
  	else
  		return self.sub_time_slot.name
  	end	
	end

	def company_code
  	if self.company.nil?
  		return "-"
  	else
  		return self.company.code
  	end
  end

	########## Filter Employee Attendance using Location ##########
	def self.location_related_employee_attendance(employee_attendance_list, location_id)
		employee_attendances = employee_attendance_list.where(:location_id => location_id)
		return employee_attendances
	end

	########## Filter Employee Attendance using Branch ##########
	def self.branch_related_employee_attendance(employee_attendance_list, branch_id)
		employee_attendances = employee_attendance_list.where(:branch_id => branch_id)
		return employee_attendances
	end

	def self.department_related_employee_attendance(employee_attendance_list, department_id)
		employee_attendances = employee_attendance_list.where(:department_id => department_id)
		return employee_attendances
	end

	def self.sub_department_related_employee_attendance(employee_attendance_list, sub_department_id)
		employee_attendances = employee_attendance_list.where(:sub_department_id => sub_department_id)
		return employee_attendances
	end

	def self.designation_related_employee_attendance(employee_attendance_list, designation_id)
		employee_attendances = employee_attendance_list.where(:designation_id => designation_id)
		return employee_attendances
	end

	def self.job_title_related_employee_attendance(employee_attendance_list, job_title_id)
		employee_attendances = employee_attendance_list.where(:job_title_id => job_title_id)
		return employee_attendances
	end

	def self.grade_related_employee_attendance(employee_attendance_list, grade_id)
		employee_attendances = employee_attendance_list.where(:grade_id => grade_id)
		return employee_attendances
	end

	def self.multi_grade_related_employee_attendance(employee_attendance_list, grade_ids)
		employee_attendances = employee_attendance_list.where(:grade_id => grade_ids)
		return employee_attendances
	end

	def self.salary_unit_related_employee_attendance(employee_attendance_list, salary_unit_id)
		employee_attendances = employee_attendance_list.where(:salary_unit_id => salary_unit_id)
		return employee_attendances
	end
	
	def self.cost_center_related_employee_attendance(employee_attendance_list, cost_center_id)
		employee_attendances = employee_attendance_list.where(:cost_center_id => cost_center_id)
		return employee_attendances
	end

	def self.employee_related_employee_attendance(employee_attendance_list, employee_id)
		employee_attendances = employee_attendance_list.where(:employee_id => employee_id)
		return employee_attendances
	end

	def self.exclude_employees(employee_attendance_list, exclude)
		employee_attendance_list.includes(:employee).where(employees: {excluded_from_reports: exclude})
	end

	def self.payment_method_related_attendances(employee_attendance_list, payment_method)
		employee_attendance_list.includes(:employee).where(employees: {payment_method: payment_method})
	end

	def self.on_roll_employees(employee_attendance_list, on_roll)
		employee_attendance_list.includes(:employee).where(employees: {is_active: on_roll})
	end

	def self.struck_off_employees(employee_attendance_list, struck_off)
		employee_attendance_list.includes(:employee).where(employees: {is_struck_off: struck_off})
	end

	########## Empty Row Creation for Attendance ##########
	def self.create_empty_attenance_record(single_date, employee)
    if not EmployeeAttendance.exists?(:attendance_date => single_date,:employee_id => employee.id)
      employee_attendance = EmployeeAttendance.new(:attendance_date => single_date, :in_time => nil, :out_time => nil)
			employee_attendance.employee_id 				= employee.id
			employee_attendance.company_id 					= employee.company_id
			employee_attendance.location_id 				= employee.location_id
			employee_attendance.branch_id 					= employee.branch_id
			employee_attendance.department_id 			= employee.department_id
			employee_attendance.sub_department_id 	= employee.sub_department_id
			employee_attendance.grade_id 						= employee.grade_id
			employee_attendance.job_title_id 				= employee.job_title_id
			employee_attendance.designation_id 			= employee.designation_id
			employee_attendance.salary_unit_id 			= employee.salary_unit_id
			employee_attendance.cost_center_id   		= employee.cost_center_id
			employee_attendance.employee_full_name 	= employee.full_name
			employee_attendance.employee_code				= employee.employee_code
			employee_attendance.company_name				= employee.company_name
			employee_attendance.location_name				= employee.location_name
			employee_attendance.branch_name					= employee.branch_name
			employee_attendance.department_name			= employee.department_name
			employee_attendance.sub_department_name	= employee.sub_department_name
			employee_attendance.grade_name					= employee.grade_name
			employee_attendance.job_title_name			= employee.job_title_name
			employee_attendance.designation_name		= employee.designation_name
			employee_attendance.salary_unit_name		= employee.salary_unit_name
			employee_attendance.cost_center_name		= employee.cost_center_name
			employee_attendance.attendance_date   	= single_date 
			employee_attendance.is_overtime					= employee.is_overtime
			employee_attendance.is_off_day_working	= employee.is_off_day_working
			employee_attendance.is_cpl							= employee.is_cpl
			employee_attendance.attendance_exempted = employee.attendance_exempted
			employee_attendance.regular_quota_encashment = employee.regular_quota_encashment
			employee_attendance.holiday_quota_encashment = employee.holiday_quota_encashment
			employee_attendance.is_regular_cpl 					 = employee.is_regular_cpl
			employee_attendance.is_holiday_overtime 		 = employee.is_holiday_overtime
			employee_attendance.approval_base_overtime	= employee.approval_base_overtime
			employee_attendance.save
    end
  end

  ########## Update Employee Information for Attendance ##########
  def self.update_employee_detail(employee_attendance, employee)
  	employee_attendance.is_overtime								= employee.is_overtime
		employee_attendance.is_off_day_working				= employee.is_off_day_working
		employee_attendance.is_cpl										= employee.is_cpl
		employee_attendance.regular_quota_encashment	= employee.regular_quota_encashment
		employee_attendance.holiday_quota_encashment	= employee.holiday_quota_encashment
		employee_attendance.is_regular_cpl 					 	= employee.is_regular_cpl
		employee_attendance.is_holiday_overtime 			= employee.is_holiday_overtime
		employee_attendance.attendance_exempted 			= employee.attendance_exempted
		employee_attendance.late_exempted							= employee.late_exempted
		employee_attendance.employee_id 							= employee.id
		employee_attendance.employee_full_name 				= employee.full_name
		employee_attendance.employee_code							= employee.employee_code
		employee_attendance.gross_salary							= employee.gross_salary
		employee_attendance.approval_base_overtime		= employee.approval_base_overtime
  	transfer_status = employee_attendance.roster_transfer_impact
  	if transfer_status == false
			employee_attendance.company_id 							= employee.company_id
			employee_attendance.location_id 						= employee.location_id
			employee_attendance.branch_id 							= employee.branch_id
			employee_attendance.department_id 					= employee.department_id
			employee_attendance.sub_department_id 			= employee.sub_department_id
			employee_attendance.grade_id 								= employee.grade_id
			employee_attendance.job_title_id 						= employee.job_title_id
			employee_attendance.designation_id 					= employee.designation_id
			employee_attendance.salary_unit_id 					= employee.salary_unit_id
			employee_attendance.cost_center_id   				= employee.cost_center_id
			employee_attendance.company_name						= employee.company_name
			employee_attendance.location_name						= employee.location_name
			employee_attendance.branch_name							= employee.branch_name
			employee_attendance.department_name					= employee.department_name
			employee_attendance.sub_department_name			= employee.sub_department_name
			employee_attendance.grade_name							= employee.grade_name
			employee_attendance.job_title_name					= employee.job_title_name
			employee_attendance.designation_name				= employee.designation_name
			employee_attendance.salary_unit_name				= employee.salary_unit_name
			employee_attendance.cost_center_name				= employee.cost_center_name
		else
			employee_roster = employee_attendance.employee_roster
			if not employee_roster.nil?
				employee_attendance.location_id 					= employee_roster.location_id
				employee_attendance.branch_id 						= employee_roster.branch_id
				employee_attendance.location_name					= employee_roster.location_name
				employee_attendance.branch_name						= employee_roster.branch_name
			end
		end
		employee_attendance.save
  end

  ########## Clear Attendance Record ##########
  def self.clear_attendance_record(employee_attendance)
  	employee_attendance.attendance_status = ""
    employee_attendance.early_left_status = ""
    employee_attendance.remarks						= ""
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
		employee_attendance.incentive_verified 				= false
		employee_attendance.is_official_duty 					= false
		employee_attendance.is_on_leave 							= false
		employee_attendance.is_relaxation 						= false
		employee_attendance.deduction_from_quota			= false
		employee_attendance.deduction_from_salary			= false
		employee_attendance.is_leave_without_pay 			= false
		employee_attendance.is_public_holiday 			= false
		employee_attendance.save
  end

  ########## Clear Attendance Record ##########
  def self.clear_attendance_record_for_request_impact(employee_attendance)
  	employee_attendance.in_time = nil
    employee_attendance.out_time = nil
  	employee_attendance.attendance_status = ""
    employee_attendance.early_left_status = ""
    employee_attendance.remarks						= ""
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
		employee_attendance.incentive_verified 				= false
		employee_attendance.is_official_duty 					= false
		employee_attendance.is_on_leave 							= false
		employee_attendance.is_relaxation 						= false
		employee_attendance.deduction_from_quota			= false
		employee_attendance.deduction_from_salary			= false
		employee_attendance.is_leave_without_pay 			= false
		employee_attendance.save
  end

  def self.request_clear_attendance_record(employee_attendance)
  	employee_attendance.attendance_status = ""
    employee_attendance.early_left_status = ""
    employee_attendance.remarks						= ""
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
		employee_attendance.incentive_verified 				= false
		employee_attendance.is_official_duty 					= false
		employee_attendance.is_on_leave 							= false
		employee_attendance.is_relaxation 						= false
		employee_attendance.deduction_from_quota			= false
		employee_attendance.deduction_from_salary			= false
		employee_attendance.is_leave_without_pay 			= false
		employee_attendance.save
  end

  ########## Single Employee Process Attendance ##########
	def self.single_employee_process_attendance(employee_attendance)
		if employee_attendance.roster_exist == true
			if employee_attendance.attendance_exempted == true
				employee_attendance.attendance_status = "Present"
				employee_attendance.incentive_verified = true
				employee_attendance.remarks = "Attendance Exempted"
				public_holiday = Holiday.verify_public_holiday(employee_attendance, employee_attendance.attendance_date.to_date)
				if employee_attendance.is_rest_day == true
					employee_attendance.attendance_status = "Rest Day"
					employee_attendance.remarks = ""
				elsif public_holiday
					employee_attendance.attendance_status = "Public Holiday"
					employee_attendance.remarks = ""
					employee_attendance.is_public_holiday  = true
				end
				employee_attendance.save
			else
				public_holiday = Holiday.verify_public_holiday(employee_attendance, employee_attendance.attendance_date.to_date)
				if employee_attendance.is_rest_day == true
					if employee_attendance.is_official_duty == false and employee_attendance.is_relaxation == false
						employee_attendance.attendance_status = "Rest Day"	
					end
					if not employee_attendance.in_time.nil?
						employee_attendance.incentive_verified = true
					end
					employee_attendance.save
					attendance_structure = employee_attendance.attendance_master_policy(employee_attendance)
					if not attendance_structure.nil?
						attendance_overtime = attendance_structure.attendance_overtime
						if not attendance_overtime.nil?
							if not employee_attendance.in_time.nil?
								if not employee_attendance.out_time.nil?
									if not employee_attendance.office_in_time.nil?
										if not employee_attendance.office_out_time.nil?
											employee_attendance.apply_overtime_policy(employee_attendance, attendance_overtime, attendance_structure)
										end
									end
								end
							end
						end
					end
				elsif public_holiday
					if employee_attendance.is_official_duty == false and employee_attendance.is_relaxation == false
						employee_attendance.attendance_status = "Public Holiday"
					end
					employee_attendance.is_public_holiday  = true
					if not employee_attendance.in_time.nil?
						employee_attendance.incentive_verified = true
					end
					employee_attendance.save
					attendance_structure = employee_attendance.attendance_master_policy(employee_attendance)
					if not attendance_structure.nil?
						attendance_overtime = attendance_structure.attendance_overtime
						if not attendance_overtime.nil?
							if not employee_attendance.in_time.nil?
								if not employee_attendance.out_time.nil?
									if not employee_attendance.office_in_time.nil?
										if not employee_attendance.office_out_time.nil?
											employee_attendance.apply_overtime_policy(employee_attendance, attendance_overtime, attendance_structure)
										end
									end
								end
							end
						end
					end
				else
					attendance_structure = employee_attendance.attendance_master_policy(employee_attendance)
					if attendance_structure.nil?
						employee_attendance.remarks = "Attendance Structure Not Found"
						employee_attendance.attendance_status = "Absent"
						employee_attendance.incentive_verified = false
						employee_attendance.save
					else
						cut_off_date_range = AttendanceCutoff.get_attendance_cutoff_date_range(employee_attendance)
						absent_policy 				= attendance_structure.absent_policy
						attendance_relaxation = attendance_structure.attendance_relaxation
						attendance_overtime 	= attendance_structure.attendance_overtime
						missing_punch 				= attendance_structure.missing_punch
						early_left 						= attendance_structure.early_left
						if employee_attendance.in_time.nil? and employee_attendance.is_relaxation == false and employee_attendance.is_official_duty == false
							if not absent_policy.nil?
								absent_deduction = absent_policy.attendance_deduction
								employee_attendance.attendance_status = "Absent"
								employee_attendance.incentive_verified = false
								employee_attendance.save
								if not cut_off_date_range.nil?
									if absent_deduction.exempted_in_month <= EmployeeAttendance.where(:employee_id => employee_attendance.employee_id, :attendance_date => cut_off_date_range, :attendance_status => "Absent").count
										if employee_attendance.out_time.nil?
											employee_attendance.deduction_impact(employee_attendance, absent_deduction, "CheckIn", 1.0)
										else
											system_setting = SystemSetting.find_by(:company_id => employee_attendance.company_id)
  										if not system_setting.nil?
  											if system_setting.pay_deduction_on_missing_in == true
  												employee_attendance.deduction_impact(employee_attendance, absent_deduction, "CheckIn", 1.0)
  											else
													employee_attendance.checkin_deduction 		= 1
										  		employee_attendance.deduction_from_quota 	= true
										  		employee_attendance.save
										  	end
										  else
										  	employee_attendance.checkin_deduction 		= 1
									  		employee_attendance.deduction_from_quota 	= true
									  		employee_attendance.save
									  	end
										end
									else
										if employee_attendance.remarks != "No Roster"
											employee_attendance.remarks = "Exempted"
											employee_attendance.save	
										end
									end
								else
									if employee_attendance.out_time.nil?
										employee_attendance.deduction_impact(employee_attendance, absent_deduction, "CheckIn", 1.0)
									else
										system_setting = SystemSetting.find_by(:company_id => employee_attendance.company_id)
  									if not system_setting.nil?
											if system_setting.pay_deduction_on_missing_in == true
												employee_attendance.deduction_impact(employee_attendance, absent_deduction, "CheckIn", 1.0)
											else
												employee_attendance.checkin_deduction 		= 1
									  		employee_attendance.deduction_from_quota 	= true
									  		employee_attendance.save
									  	end
									  else
									  	employee_attendance.checkin_deduction 		= 1
								  		employee_attendance.deduction_from_quota 	= true
								  		employee_attendance.save
								  	end
									end
								end
							end
						else
							employee_attendance.incentive_verified = true
							employee_attendance.save
							if not attendance_relaxation.nil?
								if employee_attendance.is_official_duty == false and employee_attendance.is_relaxation == false
									if employee_attendance.late_exempted == true
										if not employee_attendance.in_time.nil?
											employee_attendance.attendance_status = "Present"
											employee_attendance.incentive_verified = true
											employee_attendance.remarks = "Late Exempted"
										else
											employee_attendance.apply_relaxation_policy(employee_attendance, attendance_relaxation, cut_off_date_range, attendance_structure)	
										end
									else
										employee_attendance.apply_relaxation_policy(employee_attendance, attendance_relaxation, cut_off_date_range, attendance_structure)	
									end
								end
							end
							if not missing_punch.nil?
								if employee_attendance.out_time.nil?
									if employee_attendance.is_official_duty == false
										if employee_attendance.late_exempted == false
											employee_attendance.apply_missing_punch_policy(employee_attendance, missing_punch, cut_off_date_range)
										end
									end
								end
							end
							if not early_left.nil?
								if not employee_attendance.out_time.nil?
									if employee_attendance.is_official_duty == false
										if employee_attendance.late_exempted == false
											employee_attendance.apply_early_left_policy(employee_attendance, early_left, cut_off_date_range, attendance_structure)	
										end
									end
								end
							end
							if not attendance_overtime.nil?
								if not employee_attendance.in_time.nil?
									if not employee_attendance.out_time.nil?
										if not employee_attendance.office_in_time.nil?
											if not employee_attendance.office_out_time.nil?
												employee_attendance.apply_overtime_policy(employee_attendance, attendance_overtime, attendance_structure)
											end
										end
									end
								end
							end
						end
					end
				end
			end
	    employee_attendance.save
	  else
	  	employee_attendance.remarks 							= "No Roster"
	  	employee_attendance.attendance_status 		= "Absent"
	  	employee_attendance.incentive_verified 		= false
	  	employee_attendance.checkin_deduction 		= 1.0
			employee_attendance.pay_deduction 				= 1.0
  		employee_attendance.deduction_from_salary = true
  		employee_attendance.save
			employee_attendance.save
		end
  end

  ########## Clear Attendance Exception ##########
  def check_attendance_exception(employee_attendance, exception_value)
    grace_time = 0
    ##### Checking Attendance Exception #####
		
		###################################################
    #################### Old Logic ####################
    ###################################################

    # attendance_exceptions = AttendanceException.where(:company_id => employee_attendance.company_id, :location_id => employee_attendance.location_id, :branch_id => employee_attendance.branch_id, :attendance_exception_type => exception_value).where("Date(start_date) <= ? AND Date(end_date) >= ?", employee_attendance.attendance_date.to_date, employee_attendance.attendance_date.to_date)
    # grace_time = attendance_exceptions.sum(:grace_time)
    # if grace_time > 0
    # 	employee_attendance.other_remarks = attendance_exceptions.collect(&:name).join(',')
    # 	employee_attendance.save
    # end
    # return grace_time

    ###################################################
    #################### Old Logic ####################
    ###################################################


    ###################################################
    #################### New Logic ####################
    ###################################################

    attendance_exceptions = AttendanceException.where(:company_id => employee_attendance.company_id, :salary_unit_id => employee_attendance.salary_unit_id, :salary_unit_wise => true, :attendance_exception_type => exception_value).where("Date(start_date) <= ? AND Date(end_date) >= ?", employee_attendance.attendance_date.to_date, employee_attendance.attendance_date.to_date)
    if attendance_exceptions.count > 0
    	grace_time = attendance_exceptions.sum(:grace_time)
	    if grace_time > 0
	    	employee_attendance.other_remarks = attendance_exceptions.collect(&:name).join(',')
	    	employee_attendance.save
	    end
	    return grace_time
	  else
	  	attendance_exceptions = AttendanceException.where(:company_id => employee_attendance.company_id, :salary_unit_wise => false, :location_id => employee_attendance.location_id, :branch_id => employee_attendance.branch_id, :attendance_exception_type => exception_value).where("Date(start_date) <= ? AND Date(end_date) >= ?", employee_attendance.attendance_date.to_date, employee_attendance.attendance_date.to_date)
	    grace_time = attendance_exceptions.sum(:grace_time)
	    if grace_time > 0
	    	employee_attendance.other_remarks = attendance_exceptions.collect(&:name).join(',')
	    	employee_attendance.save
	    end
	    return grace_time
    end

    ###################################################
    #################### New Logic ####################
    ###################################################

  end

  ########## Attendance Structure ##########
	def attendance_master_policy(employee_attendance)
		if (srl_instance?) and !(Department.where(name: ['Audit', 'Retail Stores']).ids.include?(employee_attendance.department_id)) and employee_attendance.department_id and employee_attendance.try(:employee).try(:gross_salary).to_i <= 28000
			return AttendanceStructure.find_by_name('Less than 28000')
		end
		attendance_structures = AttendanceStructure.where(:is_active => true, :company_id => employee_attendance.company_id, :location_id => employee_attendance.location_id, :grade_id => employee_attendance.grade_id).where("Date(start_date) <= ? AND Date(end_date) >= ?", employee_attendance.attendance_date.to_date, employee_attendance.attendance_date.to_date)
		if attendance_structures.count > 0
			if attendance_structures.where(:branch_id => employee_attendance.branch_id).present?
				attendance_structures = attendance_structures.where(:branch_id => employee_attendance.branch_id)
			end
			if attendance_structures.present?
				attendance_structures_temp = []
				attendance_structures_temp << attendance_structures.select{|s| s.department_ids.split(',').map(&:to_i).include?(employee_attendance.department_id.to_i)}.map(&:id)
				attendance_structures_temp = attendance_structures_temp.flatten.uniq
				attendance_structures = attendance_structures.where(id:attendance_structures_temp.flatten.uniq)
			end
			if (srl_instance? or dtl_instance?) and attendance_structures.count > 1
				attendance_structures = attendance_structures.where.not(id: AttendanceStructure.find_by_name('Less than 28000').try(:id))
			end
			if attendance_structures.count == 1
				return attendance_structures.first
			else
				return nil
			end
		else
			return nil
		end
	end

  def verification_of_special_rule_in_attendance_structure(attendance_structure)
  	if attendance_structure.special_rule == true
  		if attendance_structure.is_flexi == true
  			return attendance_structure.serve_minutes
  		else
  			return 0
  		end
  	else
  		return 0
  	end
  end

  def attendance_structure_total_working_minutes(attendance_structure)
  	if attendance_structure.special_rule == true
  		if attendance_structure.is_flexi == true
  			return attendance_structure.total_working_minutes
  		else
  			return 0
  		end
  	else
  		return 0
  	end
  end

  ########## Attendance Deduction ##########
  def deduction_impact(employee_attendance, attendance_deduction, deduction_status, minute_wise_deduction)
  	# if not attendance_deduction.nil?
		if attendance_deduction.deduction_from == "Quota"
  		if attendance_deduction.deduction_type == "Flat"
  			employee_attendance.flat_deduction(employee_attendance, deduction_status, attendance_deduction.deduction_value, attendance_deduction.deduction_from)
  		elsif attendance_deduction.deduction_type == "As Per Actual"
  			employee_attendance.actual_deduction(employee_attendance, deduction_status, minute_wise_deduction, attendance_deduction.deduction_from)
  		end
  	elsif attendance_deduction.deduction_from == "Salary"
			if attendance_deduction.deduction_type == "Flat"
				employee_attendance.flat_deduction(employee_attendance, deduction_status, attendance_deduction.deduction_value, attendance_deduction.deduction_from)
  		elsif attendance_deduction.deduction_type == "As Per Actual"
  			employee_attendance.actual_deduction(employee_attendance, deduction_status, minute_wise_deduction, attendance_deduction.deduction_from)
  		end
  	end
  	# end
  end

  ########## Flat Deduction ##########
  def flat_deduction(employee_attendance, deduction_status, deduction_value, deduction_from)
  	if deduction_from == "Quota"
  		if deduction_status == "CheckIn"
  			employee_attendance.checkin_deduction 		= deduction_value
	  		employee_attendance.deduction_from_quota 	= true
	  		employee_attendance.save
	  	elsif deduction_status == "Checkout"
	  		employee_attendance.checkout_deduction 		= deduction_value
	  		employee_attendance.deduction_from_quota 	= true
	  		employee_attendance.save
  		end
  	elsif deduction_from == "Salary"
  		if deduction_status == "CheckIn"
  			employee_attendance.checkin_deduction 		= deduction_value
  			employee_attendance.pay_deduction 				= deduction_value
	  		employee_attendance.deduction_from_salary = true
	  		employee_attendance.save
	  	elsif deduction_status == "Checkout"
	  		employee_attendance.checkout_deduction 		= deduction_value
	  		employee_attendance.pay_deduction 				= deduction_value
	  		employee_attendance.deduction_from_salary = true
	  		employee_attendance.save
  		end
  	end	
  end

  ########## Actual Deduction ##########
  def actual_deduction(employee_attendance, deduction_status, deduction_value, deduction_from)
  	if deduction_from == "Quota"
  		if deduction_status == "CheckIn"
  			employee_attendance.checkin_deduction 		= deduction_value
  			employee_attendance.minute_deducted 			= employee_attendance.minute_deducted + deduction_value
	  		employee_attendance.deduction_from_quota 	= true
	  		employee_attendance.save
	  	elsif deduction_status == "Checkout"
	  		employee_attendance.minute_deducted 			= deduction_value
	  		employee_attendance.checkout_deduction 		= employee_attendance.minute_deducted + deduction_value
	  		employee_attendance.deduction_from_quota 	= true
	  		employee_attendance.save
  		end
  	elsif deduction_from == "Salary"
  		if deduction_status == "CheckIn"
  			employee_attendance.minute_deducted 			= employee_attendance.minute_deducted + deduction_value
  			employee_attendance.checkin_deduction 		= deduction_value
  			employee_attendance.pay_deduction 				= deduction_value
	  		employee_attendance.deduction_from_salary = true
	  		employee_attendance.save
	  	elsif deduction_status == "Checkout"
	  		employee_attendance.minute_deducted 			= employee_attendance.minute_deducted + deduction_value
	  		employee_attendance.checkout_deduction 		= deduction_value
	  		employee_attendance.pay_deduction 				= deduction_value
	  		employee_attendance.deduction_from_salary = true
	  		employee_attendance.save
  		end
  	end	
  end

  ########## As Per Actual Deduction ##########
  def as_per_actual_deduction_value(employee_attendance, checkin_checkout_time_difference)
		excluded_break_hours = 0.0
  	working_hours = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.office_out_time).in_hours
  	time_slot 		= employee_attendance.employee_roster.time_slot
  	no_of_hours 	= time_slot.break_times.where(:excluded => true).map {|detail| {:no_of_hours => TimeDifference.between(detail.start_time, detail.end_time).in_hours }}
  	no_of_hours.each do |single_item|
  		excluded_break_hours = excluded_break_hours + single_item[:no_of_hours].to_f
  	end
  	working_hours = working_hours - excluded_break_hours
  	total_working_minutes = working_hours * 60
		deduction_factor = (checkin_checkout_time_difference.to_f/total_working_minutes.to_f).round(3)
		return deduction_factor
	end

  ########## Relaxation Policy ##########
  def apply_relaxation_policy(employee_attendance, attendance_relaxation, cut_off_date_range, attendance_structure)
  	in_time_difference = 0
  	temp_time_difference = 0

  	special_relaxation_minute = employee_attendance.verification_of_special_rule_in_attendance_structure(attendance_structure)
  	if not (employee_attendance.office_in_time.nil? and employee_attendance.in_time.nil?)
  		temp_time_difference = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.in_time).in_minutes
  	else
  		temp_time_difference = 0
  	end
  	if special_relaxation_minute > 0 and temp_time_difference < special_relaxation_minute
  		if not employee_attendance.in_time.nil?
				if not employee_attendance.out_time.nil?
					served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
					total_working_minutes = employee_attendance.attendance_structure_total_working_minutes(attendance_structure)
					total_working_hours = (total_working_minutes.to_f/60.0)
					if served_hours < total_working_hours
						served_hours_time = Time.at(served_hours * 60 * 60)
						remaining_working_hour_time = Time.at(total_working_minutes * 60)
						current_time =  employee_attendance.attendance_date
						office_in_time = Time.new(current_time.year, current_time.month, current_time.day, served_hours_time.to_time.strftime('%H'), served_hours_time.to_time.strftime('%M'), served_hours_time.to_time.strftime('%S'))
						office_out_time = Time.new(current_time.year, current_time.month, current_time.day, remaining_working_hour_time.to_time.strftime('%H'), remaining_working_hour_time.to_time.strftime('%M'), remaining_working_hour_time.to_time.strftime('%S'))
						time_difference = TimeDifference.between(office_in_time, office_out_time).in_minutes
						grace_time = employee_attendance.check_attendance_exception(employee_attendance, "Arrival")
						in_time_difference = time_difference - grace_time
					end
				end
			end	
  	else
	  	if employee_attendance.is_flexi == false
		  	if employee_attendance.in_time <= employee_attendance.office_in_time
		      in_time_difference = 0
		    else
		      in_time_difference = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.in_time).in_minutes    
		      grace_time = employee_attendance.check_attendance_exception(employee_attendance, "Arrival")
		      in_time_difference = in_time_difference - grace_time
		    end
		  elsif employee_attendance.is_flexi == true and employee_attendance.sub_time_slot_id != nil
		  	if employee_attendance.in_time <= employee_attendance.office_in_time
		      in_time_difference = 0
		    end
		  else
				if not employee_attendance.in_time.nil?
					if not employee_attendance.out_time.nil?
						served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
						puts "================#{employee_attendance.employee_roster.id}================"
						puts "================#{employee_attendance.employee_roster.id}================"
						total_working_minutes = 	employee_attendance.employee_roster.time_slot.total_working_minutes
						total_working_hours = (total_working_minutes.to_f/60.0)
						if served_hours < total_working_hours
							served_hours_time = Time.at(served_hours * 60 * 60)
							remaining_working_hour_time = Time.at(total_working_minutes * 60)
							current_time =  employee_attendance.attendance_date
							office_in_time = Time.new(current_time.year, current_time.month, current_time.day, served_hours_time.to_time.strftime('%H'), served_hours_time.to_time.strftime('%M'), served_hours_time.to_time.strftime('%S'))
							office_out_time = Time.new(current_time.year, current_time.month, current_time.day, remaining_working_hour_time.to_time.strftime('%H'), remaining_working_hour_time.to_time.strftime('%M'), remaining_working_hour_time.to_time.strftime('%S'))
							time_difference = TimeDifference.between(office_in_time, office_out_time).in_minutes
							grace_time = employee_attendance.check_attendance_exception(employee_attendance, "Arrival")
							in_time_difference = time_difference - grace_time
						end
					end
				end
			end
		end
		in_time_difference = in_time_difference.to_i

		if in_time_difference < 0
			in_time_difference = 0
		end
    minute_wise_deduction = employee_attendance.as_per_actual_deduction_value(employee_attendance, in_time_difference)
    attendance_relaxation_slabs = attendance_relaxation.attendance_relaxation_slabs.where("start_minute <= ? AND end_minute >= ?", in_time_difference, in_time_difference)
		minute_policy = SystemSetting.find_by(:company_id => employee_attendance.company_id).try(:leverage_minutes)
		minute_policy = (mill_instance? and employee_attendance.grade_id == 4) if mill_instance?
		if minute_policy
			# if an employee consumed all leverage minutes then add salary deduction
			current_time =  employee_attendance.attendance_date
			if employee_attendance.employee_roster.time_slot.is_flexi and employee_attendance.sub_time_slot_id and mill_instance?
				expected_in_time = Time.new(current_time.year, current_time.month, current_time.day, employee_attendance.sub_time_slot.actual_start_time.to_datetime.hour, employee_attendance.sub_time_slot.actual_start_time.to_datetime.minute, '0')
			elsif mill_instance?
				expected_in_time = Time.new(current_time.year, current_time.month, current_time.day, employee_attendance.office_start_hour, employee_attendance.office_start_min, '0')
			else
				expected_in_time = Time.new(current_time.year, current_time.month, current_time.day, '9', '0', '0')
			end
			if employee_attendance.in_time and employee_attendance.in_time > expected_in_time
				in_time_difference = TimeDifference.between(employee_attendance.in_time, expected_in_time).in_minutes.to_i
			else
				in_time_difference = 0
			end
			leverage_minutes = 0
			if attendance_relaxation_slabs.last && attendance_relaxation_slabs.last.attendance_deduction.deduction_value == 0
				leverage_minutes = get_leverage_minutes
			end
			if (leverage_minutes + in_time_difference) > TOTAL_LEVERAGE_MIN
				deduction_id = AttendanceDeduction.where(deduction_value: 0.25, deduction_from: 'Salary').last.try(:id)
				attendance_relaxation_slabs = attendance_relaxation.attendance_relaxation_slabs.where(attendance_deduction_id: deduction_id)
			end
		end
		# todo add proper message if no slabs found
    attendance_relaxation_slabs.each do |attendance_relaxation_slab|
    	relaxation_deduction = attendance_relaxation_slab.attendance_deduction
    	attendance_type_name = relaxation_deduction.attendance_type_name
    	if not cut_off_date_range.nil?
				attendance_count = EmployeeAttendance.where(:employee_id => employee_attendance.employee_id, :attendance_date => cut_off_date_range, :attendance_status => attendance_type_name).count
				if relaxation_deduction.exempted_in_month <= attendance_count
					employee_attendance.attendance_status = attendance_type_name
					unless cresset_instance? and relaxation_deduction.try(:name) == 'Late' and attendance_count.odd?
						employee_attendance.deduction_impact(employee_attendance, relaxation_deduction, "CheckIn", minute_wise_deduction)
					end
				else
					employee_attendance.attendance_status = attendance_type_name
					employee_attendance.remarks = "Exempted"
					employee_attendance.save
				end
			else
				employee_attendance.attendance_status = attendance_type_name
				employee_attendance.deduction_impact(employee_attendance, relaxation_deduction, "CheckIn", minute_wise_deduction)
			end
    end
  end

  ########## Missing Punch Policy ##########
	def apply_missing_punch_policy(employee_attendance, missing_punch, cut_off_date_range)    
    missing_punch_deduction = missing_punch.attendance_deduction
  	attendance_type_name = missing_punch_deduction.attendance_type_name
  	if not cut_off_date_range.nil?
			if missing_punch_deduction.exempted_in_month <= EmployeeAttendance.where(:employee_id => employee_attendance.employee_id, :attendance_date => cut_off_date_range, :early_left_status => attendance_type_name).count
				employee_attendance.early_left_status = attendance_type_name
				employee_attendance.deduction_impact(employee_attendance, missing_punch_deduction, "Checkout", 0.0)
			else
				employee_attendance.early_left_status = attendance_type_name
				employee_attendance.remarks = "Exempted"
				employee_attendance.save
			end
		else
			employee_attendance.early_left_status = attendance_type_name
			employee_attendance.deduction_impact(employee_attendance, missing_punch_deduction, "Checkout", 0.0)
		end
	end

	########## Early Left Policy ##########
	def apply_early_left_policy(employee_attendance, early_left, cut_off_date_range, attendance_structure)
		out_time_difference = 0
		temp_time_difference = 0

		special_relaxation_minute = employee_attendance.verification_of_special_rule_in_attendance_structure(attendance_structure)
  	if not (employee_attendance.office_in_time.nil? and employee_attendance.in_time.nil?)
  		temp_time_difference = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.in_time).in_minutes
  	else
  		temp_time_difference = 0
  	end
  	
  	if employee_attendance.is_flexi == false
  		if attendance_structure.is_flexi_in_early_gone == true
  			if not employee_attendance.in_time.nil?
					if not employee_attendance.out_time.nil?
						served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
						total_working_minutes = attendance_structure.early_gone_total_working_minute
						total_working_hours = (total_working_minutes.to_f/60.0)
						if served_hours < total_working_hours
							served_hours_time = Time.at(served_hours * 60 * 60)
							remaining_working_hour_time = Time.at(total_working_minutes * 60)
							current_time =  employee_attendance.attendance_date
							office_in_time = Time.new(current_time.year, current_time.month, current_time.day, served_hours_time.to_time.strftime('%H'), served_hours_time.to_time.strftime('%M'), served_hours_time.to_time.strftime('%S'))
							office_out_time = Time.new(current_time.year, current_time.month, current_time.day, remaining_working_hour_time.to_time.strftime('%H'), remaining_working_hour_time.to_time.strftime('%M'), remaining_working_hour_time.to_time.strftime('%S'))
							time_difference = TimeDifference.between(office_in_time, office_out_time).in_minutes
							grace_time = employee_attendance.check_attendance_exception(employee_attendance, "Departure")
							out_time_difference = time_difference - grace_time
						end
					end
				end
  		else
	  		if special_relaxation_minute > 0 and temp_time_difference > special_relaxation_minute
		  		new_office_out_time = employee_attendance.office_out_time + attendance_structure.addional_minutes.minute
		  		if new_office_out_time <= employee_attendance.out_time
			      out_time_difference = 0
			    else
			      out_time_difference = TimeDifference.between(new_office_out_time, employee_attendance.out_time).in_minutes    
			      grace_time = employee_attendance.check_attendance_exception(employee_attendance, "Departure")
			      out_time_difference = out_time_difference - grace_time
			    end
		  	else
		  		if special_relaxation_minute > 0 and temp_time_difference < special_relaxation_minute
		  			########## Auto Flexi Deduction Already Done ##########
		  		else
				  	if employee_attendance.office_out_time <= employee_attendance.out_time
				      out_time_difference = 0
				    else
				      out_time_difference = TimeDifference.between(employee_attendance.office_out_time, employee_attendance.out_time).in_minutes    
				      grace_time = employee_attendance.check_attendance_exception(employee_attendance, "Departure")
				      out_time_difference = out_time_difference - grace_time
				    end
				  end
			  end
			end
		elsif employee_attendance.is_flexi == true and employee_attendance.sub_time_slot_id != nil
			if attendance_structure.is_flexi_in_early_gone == true
  			if not employee_attendance.in_time.nil?
					if not employee_attendance.out_time.nil?
						served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
						total_working_minutes = attendance_structure.early_gone_total_working_minute
						total_working_hours = (total_working_minutes.to_f/60.0)
						if served_hours < total_working_hours
							served_hours_time = Time.at(served_hours * 60 * 60)
							remaining_working_hour_time = Time.at(total_working_minutes * 60)
							current_time =  employee_attendance.attendance_date
							office_in_time = Time.new(current_time.year, current_time.month, current_time.day, served_hours_time.to_time.strftime('%H'), served_hours_time.to_time.strftime('%M'), served_hours_time.to_time.strftime('%S'))
							office_out_time = Time.new(current_time.year, current_time.month, current_time.day, remaining_working_hour_time.to_time.strftime('%H'), remaining_working_hour_time.to_time.strftime('%M'), remaining_working_hour_time.to_time.strftime('%S'))
							time_difference = TimeDifference.between(office_in_time, office_out_time).in_minutes
							grace_time = employee_attendance.check_attendance_exception(employee_attendance, "Departure")
							out_time_difference = time_difference - grace_time
						end
					end
				end
  		else
	  		if special_relaxation_minute > 0 and temp_time_difference > special_relaxation_minute
		  		new_office_out_time = employee_attendance.office_out_time + attendance_structure.addional_minutes.minute
		  		if new_office_out_time <= employee_attendance.out_time
			      out_time_difference = 0
			    else
			      out_time_difference = TimeDifference.between(new_office_out_time, employee_attendance.out_time).in_minutes    
			      grace_time = employee_attendance.check_attendance_exception(employee_attendance, "Departure")
			      out_time_difference = out_time_difference - grace_time
			    end
		  	else
		  		if special_relaxation_minute > 0 and temp_time_difference < special_relaxation_minute
		  			########## Auto Flexi Deduction Already Done ##########
		  		else
				  	if employee_attendance.office_out_time <= employee_attendance.out_time
				      out_time_difference = 0
				    else
				      out_time_difference = TimeDifference.between(employee_attendance.office_out_time, employee_attendance.out_time).in_minutes    
				      grace_time = employee_attendance.check_attendance_exception(employee_attendance, "Departure")
				      out_time_difference = out_time_difference - grace_time
				    end
				  end
			  end
			end
  	end

  	if out_time_difference > 0
    	out_time_difference = out_time_difference.to_i
    	minute_wise_deduction = as_per_actual_deduction_value(employee_attendance, out_time_difference)
	    
	    early_left_slabs = early_left.early_left_slabs.where("start_minute <= ? AND end_minute >= ?", out_time_difference, out_time_difference)
	    early_left_slabs.each do |early_left_slab|
	    	early_left_deduction = early_left_slab.attendance_deduction
	    	attendance_type_name = early_left_deduction.attendance_type_name
	    	if not cut_off_date_range.nil?
					if early_left_deduction.exempted_in_month <= EmployeeAttendance.where(:employee_id => employee_attendance.employee_id, :attendance_date => cut_off_date_range, :early_left_status => attendance_type_name).count
						employee_attendance.early_left_status = attendance_type_name
						employee_attendance.deduction_impact(employee_attendance, early_left_deduction, "Checkout", minute_wise_deduction)
					else
						employee_attendance.early_left_status = attendance_type_name
						employee_attendance.remarks = "Exempted"
						employee_attendance.save
					end
				else
					employee_attendance.early_left_status = attendance_type_name
					employee_attendance.deduction_impact(employee_attendance, early_left_deduction, "Checkout", minute_wise_deduction)
				end
	    end
    end
	end

	########## Overtime Policy ##########
	def apply_overtime_policy(employee_attendance, attendance_overtime, attendance_structure)


		########### New Overtime Policy Regular Working Day ###########
		if employee_attendance.is_rest_day == false and employee_attendance.is_public_holiday == false
			overtime_working_day = false
			
			if employee_attendance.regular_quota_encashment == true
				if employee_attendance.gross_salary >= attendance_structure.regular_min_salary and employee_attendance.gross_salary <= attendance_structure.regular_max_salary
					overtime_working_day = true
					if not employee_attendance.in_time.nil?
		        if not employee_attendance.out_time.nil?
		        	served_hours = 0
		        	working_hours = 0
					  	
					  	temp_time_difference = 0
					  	special_relaxation_minute = employee_attendance.verification_of_special_rule_in_attendance_structure(attendance_structure)
					  	if not (employee_attendance.office_in_time.nil? and employee_attendance.in_time.nil?)
					  		temp_time_difference = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.in_time).in_minutes
					  	else
					  		temp_time_difference = 0
					  	end
					  	if special_relaxation_minute > 0 and temp_time_difference < special_relaxation_minute
					  		served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
								total_working_minutes = employee_attendance.attendance_structure_total_working_minutes(attendance_structure)
								working_hours = (total_working_minutes.to_f/60.0)
					  	else
						  	if employee_attendance.is_flexi == false
						  		excluded_break_hours = 0.0
							  	working_hours = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.office_out_time).in_hours
							  	time_slot 		= employee_attendance.employee_roster.time_slot
							  	no_of_hours 	= time_slot.break_times.where(:excluded => true).map {|detail| {:no_of_hours => TimeDifference.between(detail.start_time, detail.end_time).in_hours }}
							  	no_of_hours.each do |single_item|
							  		excluded_break_hours = excluded_break_hours + single_item[:no_of_hours].to_f
							  	end
							  	working_hours = working_hours - excluded_break_hours
							  	total_working_minutes = working_hours * 60
							  	served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
						  	elsif employee_attendance.is_flexi == true and employee_attendance.sub_time_slot_id != nil
						  		excluded_break_hours = 0.0
							  	working_hours = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.office_out_time).in_hours
							  	excluded_break_hours = 0
							  	working_hours = working_hours - excluded_break_hours
							  	total_working_minutes = working_hours * 60
							  	served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
						  	else
						  		served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
									total_working_minutes = employee_attendance.employee_roster.time_slot.total_working_minutes
									working_hours = (total_working_minutes.to_f/60.0)
						  	end	
						  end

							if served_hours > working_hours
								over_time_hours = (served_hours - working_hours).round(2)
								if over_time_hours > 0
									over_time_minutes = over_time_hours * 60
									regular_overtime = attendance_structure.regular_overtime
									if not regular_overtime.nil?
										attendance_overtime_slabs = regular_overtime.attendance_overtime_slabs.where("min_minute <= ? AND max_minute >= ?", over_time_minutes, over_time_minutes)
					    			attendance_overtime_slabs.each do |attendance_overtime_slab|
					    				attendance_earning = attendance_overtime_slab.attendance_earning
					    				employee_attendance.overtime_impact(employee_attendance, attendance_earning, over_time_hours, working_hours)
					    			end	
									end
								end
			    		end
		    		end
		    	end
	    	end
			end
			
			if employee_attendance.is_overtime == true
				if overtime_working_day == false
					overtime_working_day = true
					if not employee_attendance.in_time.nil?
		        if not employee_attendance.out_time.nil?
		        	served_hours = 0
		        	working_hours = 0
					  	
							temp_time_difference = 0
							special_relaxation_minute = employee_attendance.verification_of_special_rule_in_attendance_structure(attendance_structure)
							if not (employee_attendance.office_in_time.nil? and employee_attendance.in_time.nil?)
								temp_time_difference = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.in_time).in_minutes
							else
								temp_time_difference = 0
							end
					  	if special_relaxation_minute > 0 and temp_time_difference < special_relaxation_minute
					  		served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
								total_working_minutes = employee_attendance.attendance_structure_total_working_minutes(attendance_structure)
								working_hours = (total_working_minutes.to_f/60.0)
					  	else
						  	if employee_attendance.is_flexi == false
						  		excluded_break_hours = 0.0
							  	working_hours = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.office_out_time).in_hours
							  	time_slot 		= employee_attendance.employee_roster.time_slot
							  	no_of_hours 	= time_slot.break_times.where(:excluded => true).map {|detail| {:no_of_hours => TimeDifference.between(detail.start_time, detail.end_time).in_hours }}
							  	no_of_hours.each do |single_item|
							  		excluded_break_hours = excluded_break_hours + single_item[:no_of_hours].to_f
							  	end
							  	working_hours = working_hours - excluded_break_hours
							  	total_working_minutes = working_hours * 60
							  	served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
						  	elsif employee_attendance.is_flexi == true and employee_attendance.sub_time_slot_id != nil
						  		excluded_break_hours = 0.0
							  	working_hours = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.office_out_time).in_hours
							  	excluded_break_hours = 0
							  	working_hours = working_hours - excluded_break_hours
							  	total_working_minutes = working_hours * 60
							  	served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
						  	else
						  		served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
									total_working_minutes = employee_attendance.employee_roster.time_slot.total_working_minutes
									working_hours = (total_working_minutes.to_f/60.0)
						  	end	
						  end

						  if attendance_overtime.overtime_after_office_end == false
								if served_hours > working_hours
									over_time_hours = (served_hours - working_hours).round(2)
									if over_time_hours > 0
										over_time_minutes = over_time_hours * 60
										attendance_overtime_slabs = attendance_overtime.attendance_overtime_slabs.where("min_minute <= ? AND max_minute >= ?", over_time_minutes, over_time_minutes)
										# todo add proper message if no slabs found
					    			attendance_overtime_slabs.each do |attendance_overtime_slab|
					    				attendance_earning = attendance_overtime_slab.attendance_earning
					    				employee_attendance.overtime_impact(employee_attendance, attendance_earning, over_time_hours, working_hours)
					    			end
									end
				    		end
				    	else
				    		if not employee_attendance.out_time.nil?
									if not employee_attendance.office_out_time.nil?
										if employee_attendance.out_time > employee_attendance.office_out_time
											over_time_hours = TimeDifference.between(employee_attendance.out_time, employee_attendance.office_out_time).in_hours
											over_time_minutes = TimeDifference.between(employee_attendance.out_time, employee_attendance.office_out_time).in_minutes
											if over_time_minutes > 0
												attendance_overtime_slabs = attendance_overtime.attendance_overtime_slabs.where("min_minute <= ? AND max_minute >= ?", over_time_minutes, over_time_minutes)
							    			attendance_overtime_slabs.each do |attendance_overtime_slab|
							    				attendance_earning = attendance_overtime_slab.attendance_earning
							    				employee_attendance.overtime_impact(employee_attendance, attendance_earning, over_time_hours, working_hours)
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

			##### Hamza Working #########
			# if employee_attendance.is_overtime == false
			# 	if overtime_working_day == false
			# 		overtime_working_day = true
			# 		if not employee_attendance.in_time.nil?
			# 			if not employee_attendance.out_time.nil?
			# 				served_hours = 0
			# 				working_hours = 0
			#
			# 				temp_time_difference = 0
			# 				special_relaxation_minute = employee_attendance.verification_of_special_rule_in_attendance_structure(attendance_structure)
			# 				if not (employee_attendance.office_in_time.nil? and employee_attendance.in_time.nil?)
			# 					temp_time_difference = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.in_time).in_minutes
			# 				else
			# 					temp_time_difference = 0
			# 				end
			# 				if special_relaxation_minute > 0 and temp_time_difference < special_relaxation_minute
			# 					served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
			# 					total_working_minutes = employee_attendance.attendance_structure_total_working_minutes(attendance_structure)
			# 					working_hours = (total_working_minutes.to_f/60.0)
			# 				else
			# 					if employee_attendance.is_flexi == false
			# 						excluded_break_hours = 0.0
			# 						working_hours = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.office_out_time).in_hours
			# 						time_slot 		= employee_attendance.employee_roster.time_slot
			# 						no_of_hours 	= time_slot.break_times.where(:excluded => true).map {|detail| {:no_of_hours => TimeDifference.between(detail.start_time, detail.end_time).in_hours }}
			# 						no_of_hours.each do |single_item|
			# 							excluded_break_hours = excluded_break_hours + single_item[:no_of_hours].to_f
			# 						end
			# 						working_hours = working_hours - excluded_break_hours
			# 						total_working_minutes = working_hours * 60
			# 						served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
			# 					elsif employee_attendance.is_flexi == true and employee_attendance.sub_time_slot_id != nil
			# 						excluded_break_hours = 0.0
			# 						working_hours = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.office_out_time).in_hours
			# 						excluded_break_hours = 0
			# 						working_hours = working_hours - excluded_break_hours
			# 						total_working_minutes = working_hours * 60
			# 						served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
			# 					else
			# 						served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
			# 						total_working_minutes = employee_attendance.employee_roster.time_slot.total_working_minutes
			# 						working_hours = (total_working_minutes.to_f/60.0)
			# 					end
			# 				end
			#
			# 				if attendance_overtime.overtime_after_office_end == true
			# 					if served_hours > working_hours
			# 						over_time_hours = (served_hours - working_hours).round(2)
			# 						if over_time_hours > 0
			# 							over_time_minutes = over_time_hours * 60
			# 							attendance_overtime_slabs = attendance_overtime.attendance_overtime_slabs.where("min_minute <= ? AND max_minute >= ?", over_time_minutes, over_time_minutes)
			# 							# todo add proper message if no slabs found
			# 							attendance_overtime_slabs.each do |attendance_overtime_slab|
			# 								attendance_earning = attendance_overtime_slab.attendance_earning
			# 								employee_attendance.overtime_impact(employee_attendance, attendance_earning, over_time_hours, working_hours)
			# 							end
			# 						end
			# 					end
			# 				else
			# 					if not employee_attendance.out_time.nil?
			# 						if not employee_attendance.office_out_time.nil?
			# 							if employee_attendance.out_time > employee_attendance.office_out_time
			# 								over_time_hours = TimeDifference.between(employee_attendance.out_time, employee_attendance.office_out_time).in_hours
			# 								over_time_minutes = TimeDifference.between(employee_attendance.out_time, employee_attendance.office_out_time).in_minutes
			# 								if over_time_minutes > 0
			# 									attendance_overtime_slabs = attendance_overtime.attendance_overtime_slabs.where("min_minute <= ? AND max_minute >= ?", over_time_minutes, over_time_minutes)
			# 									attendance_overtime_slabs.each do |attendance_overtime_slab|
			# 										attendance_earning = attendance_overtime_slab.attendance_earning
			# 										employee_attendance.overtime_impact(employee_attendance, attendance_earning, over_time_hours, working_hours)
			# 									end
			# 								end
			# 							end
			# 						end
			# 					end
			# 				end
			# 			end
			# 		end
			# 	end
			# end
			##### ///Hamza Working #########
			
			if employee_attendance.is_regular_cpl == true
				if overtime_working_day == false
					overtime_working_day = true
					if not employee_attendance.in_time.nil?
				    if not employee_attendance.out_time.nil?
		        	served_hours = 0
		        	working_hours = 0
					  	
					  	temp_time_difference = 0
					  	special_relaxation_minute = employee_attendance.verification_of_special_rule_in_attendance_structure(attendance_structure)
					  	if not (employee_attendance.office_in_time.nil? and employee_attendance.in_time.nil?)
					  		temp_time_difference = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.in_time).in_minutes
					  	else
					  		temp_time_difference = 0
					  	end
					  	if special_relaxation_minute > 0 and temp_time_difference < special_relaxation_minute
					  		served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
								total_working_minutes = employee_attendance.attendance_structure_total_working_minutes(attendance_structure)
								working_hours = (total_working_minutes.to_f/60.0)
					  	else
						  	if employee_attendance.is_flexi == false
						  		excluded_break_hours = 0.0
							  	working_hours = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.office_out_time).in_hours
							  	time_slot 		= employee_attendance.employee_roster.time_slot
							  	no_of_hours 	= time_slot.break_times.where(:excluded => true).map {|detail| {:no_of_hours => TimeDifference.between(detail.start_time, detail.end_time).in_hours }}
							  	no_of_hours.each do |single_item|
							  		excluded_break_hours = excluded_break_hours + single_item[:no_of_hours].to_f
							  	end
							  	working_hours = working_hours - excluded_break_hours
							  	total_working_minutes = working_hours * 60
							  	served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
						  	elsif employee_attendance.is_flexi == true and employee_attendance.sub_time_slot_id != nil
						  		excluded_break_hours = 0.0
							  	working_hours = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.office_out_time).in_hours
							  	excluded_break_hours = 0
							  	working_hours = working_hours - excluded_break_hours
							  	total_working_minutes = working_hours * 60
							  	served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
						  	else
						  		served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
									total_working_minutes = employee_attendance.employee_roster.time_slot.total_working_minutes
									working_hours = (total_working_minutes.to_f/60.0)
						  	end	
						  end

							if served_hours > working_hours
								over_time_hours = (served_hours - working_hours).round(2)
								if over_time_hours > 0
									over_time_minutes = over_time_hours * 60
									attendance_overtime_slabs = attendance_overtime.attendance_overtime_slabs.where("min_minute <= ? AND max_minute >= ?", over_time_minutes, over_time_minutes)
				    			attendance_overtime_slabs.each do |attendance_overtime_slab|
				    				attendance_earning = attendance_overtime_slab.attendance_earning
				    				employee_attendance.overtime_impact(employee_attendance, attendance_earning, over_time_hours, working_hours)
				    			end
								end
			    		end
						end
					end
				end
			end

		end
		
		########### New Overtime Policy Rest and Public Holiday ###########
		if employee_attendance.is_rest_day == true or employee_attendance.is_public_holiday == true
			overtime_holiday_day = false
			
			if employee_attendance.holiday_quota_encashment == true
				if employee_attendance.gross_salary >= attendance_structure.holiday_min_salary and employee_attendance.gross_salary <= attendance_structure.holiday_max_salary
					overtime_holiday_day = true
					if not employee_attendance.in_time.nil?
		        if not employee_attendance.out_time.nil?
		        	excluded_break_hours = 0.0
					  	working_hours = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.office_out_time).in_hours
					  	time_slot 		= employee_attendance.employee_roster.time_slot
					  	no_of_hours 	= time_slot.break_times.where(:excluded => true).map {|detail| {:no_of_hours => TimeDifference.between(detail.start_time, detail.end_time).in_hours }}
					  	no_of_hours.each do |single_item|
					  		excluded_break_hours = excluded_break_hours + single_item[:no_of_hours].to_f
					  	end
					  	working_hours = working_hours - excluded_break_hours
					  	total_working_minutes = working_hours * 60
					  	served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
							if served_hours > 0
								total_served_minutes = served_hours * 60
								holiday_overtime = attendance_structure.holiday_overtime
								if not holiday_overtime.nil?
									attendance_overtime_slabs = holiday_overtime.attendance_overtime_slabs.where("min_minute <= ? AND max_minute >= ?", total_served_minutes, total_served_minutes)
				    			attendance_overtime_slabs.each do |attendance_overtime_slab|
				    				attendance_earning = attendance_overtime_slab.attendance_earning
				    				employee_attendance.overtime_impact(employee_attendance, attendance_earning, served_hours, working_hours)
				    			end
				    		end
			    		end
		    		end
		    	end
		    end
			end
			
			if employee_attendance.is_holiday_overtime == true
				if overtime_holiday_day == false
					overtime_holiday_day = true
					if not employee_attendance.in_time.nil?
		        if not employee_attendance.out_time.nil?
		        	served_hours = 0
		        	working_hours = 0
					  	
					  	temp_time_difference = 0
					  	special_relaxation_minute = employee_attendance.verification_of_special_rule_in_attendance_structure(attendance_structure)
					  	if not (employee_attendance.office_in_time.nil? and employee_attendance.in_time.nil?)
					  		temp_time_difference = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_minutes
					  	else
					  		temp_time_difference = 0
					  	end
					  	if special_relaxation_minute > 0 and temp_time_difference < special_relaxation_minute
					  		served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
								total_working_minutes = employee_attendance.attendance_structure_total_working_minutes(attendance_structure)
								working_hours = (total_working_minutes.to_f/60.0)
					  	else
						  	if employee_attendance.is_flexi == false
						  		excluded_break_hours = 0.0
							  	working_hours = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.office_out_time).in_hours
							  	time_slot 		= employee_attendance.employee_roster.time_slot
							  	no_of_hours 	= time_slot.break_times.where(:excluded => true).map {|detail| {:no_of_hours => TimeDifference.between(detail.start_time, detail.end_time).in_hours }}
							  	no_of_hours.each do |single_item|
							  		excluded_break_hours = excluded_break_hours + single_item[:no_of_hours].to_f
							  	end
							  	working_hours = working_hours - excluded_break_hours
							  	total_working_minutes = working_hours * 60
							  	served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
						  	elsif employee_attendance.is_flexi == true and employee_attendance.sub_time_slot_id != nil
						  		excluded_break_hours = 0.0
							  	working_hours = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.office_out_time).in_hours
							  	excluded_break_hours = 0
							  	working_hours = working_hours - excluded_break_hours
							  	total_working_minutes = working_hours * 60
							  	served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
						  	else
						  		served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
									total_working_minutes = employee_attendance.employee_roster.time_slot.total_working_minutes
									working_hours = (total_working_minutes.to_f/60.0)
						  	end	
						  end

						 	# if attendance_overtime.overtime_after_office_end == false
							over_time_hours = served_hours.round(2)
							if over_time_hours > 0
								over_time_minutes = over_time_hours * 60
								attendance_overtime_slabs = attendance_overtime.attendance_overtime_slabs.where("min_minute <= ? AND max_minute >= ?", over_time_minutes, over_time_minutes)
			    			attendance_overtime_slabs.each do |attendance_overtime_slab|
			    				attendance_earning = attendance_overtime_slab.attendance_earning
			    				employee_attendance.overtime_impact(employee_attendance, attendance_earning, over_time_hours, working_hours)
			    			end
							end
							# else
							# 	if not employee_attendance.out_time.nil?
							# 		if not employee_attendance.office_out_time.nil?
							# 			if employee_attendance.out_time > employee_attendance.office_out_time
							# 				over_time_hours = TimeDifference.between(employee_attendance.out_time, employee_attendance.office_out_time).in_hours
							# 				over_time_minutes = TimeDifference.between(employee_attendance.out_time, employee_attendance.office_out_time).in_minutes
							# 				if over_time_minutes > 0
							# 					attendance_overtime_slabs = attendance_overtime.attendance_overtime_slabs.where("min_minute <= ? AND max_minute >= ?", over_time_minutes, over_time_minutes)
							#     			attendance_overtime_slabs.each do |attendance_overtime_slab|
							#     				attendance_earning = attendance_overtime_slab.attendance_earning
							#     				employee_attendance.overtime_impact(employee_attendance, attendance_earning, over_time_hours, working_hours)
							#     			end
							# 				end
							# 			end
							# 		end
							# 	end
							# end

		    		end
		    	end
		    end
			end
			
			if employee_attendance.is_cpl == true
				if overtime_holiday_day == false
					overtime_holiday_day = true
					if not employee_attendance.in_time.nil?
		        if not employee_attendance.out_time.nil?
		        	excluded_break_hours = 0.0
					  	working_hours = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.office_out_time).in_hours
					  	time_slot 		= employee_attendance.employee_roster.time_slot
					  	no_of_hours 	= time_slot.break_times.where(:excluded => true).map {|detail| {:no_of_hours => TimeDifference.between(detail.start_time, detail.end_time).in_hours }}
					  	no_of_hours.each do |single_item|
					  		excluded_break_hours = excluded_break_hours + single_item[:no_of_hours].to_f
					  	end
					  	working_hours = working_hours - excluded_break_hours
					  	total_working_minutes = working_hours * 60
					  	served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
							if served_hours > 0
								total_served_minutes = served_hours * 60
								attendance_overtime_slabs = attendance_overtime.attendance_overtime_slabs.where("min_minute <= ? AND max_minute >= ?", total_served_minutes, total_served_minutes)
			    			attendance_overtime_slabs.each do |attendance_overtime_slab|
			    				attendance_earning = attendance_overtime_slab.attendance_earning
			    				employee_attendance.overtime_impact(employee_attendance, attendance_earning, served_hours, working_hours)
			    			end
			    		end
		    		end
		    	end
		    end
			end

			if employee_attendance.is_off_day_working == true
				if overtime_holiday_day == false
					overtime_holiday_day = true
					if not employee_attendance.in_time.nil?
		        if not employee_attendance.out_time.nil?
		        	excluded_break_hours = 0.0
					  	working_hours = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.office_out_time).in_hours
					  	time_slot 		= employee_attendance.employee_roster.time_slot
					  	no_of_hours 	= time_slot.break_times.where(:excluded => true).map {|detail| {:no_of_hours => TimeDifference.between(detail.start_time, detail.end_time).in_hours }}
					  	no_of_hours.each do |single_item|
					  		excluded_break_hours = excluded_break_hours + single_item[:no_of_hours].to_f
					  	end
					  	working_hours = working_hours - excluded_break_hours
					  	total_working_minutes = working_hours * 60
					  	served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
							if served_hours > 0
								total_served_minutes = served_hours * 60
								attendance_overtime_slabs = attendance_overtime.attendance_overtime_slabs.where("min_minute <= ? AND max_minute >= ?", total_served_minutes, total_served_minutes)
			    			attendance_overtime_slabs.each do |attendance_overtime_slab|
			    				attendance_earning = attendance_overtime_slab.attendance_earning
			    				employee_attendance.overtime_impact(employee_attendance, attendance_earning, served_hours, working_hours)
			    			end
			    		end
		    		end
		    	end
		    end
			end

		end
	end

	########## Overtime ##########
  def overtime_impact(employee_attendance, attendance_earning, over_time_hours, working_hours)
  	if attendance_earning.earning_from == "Quota"
  		if attendance_earning.earning_type == "Flat"
  			if attendance_earning.multiplex_allowed == true
  				multiplex_verification = Holiday.verify_public_holiday_for_overtime(employee_attendance, employee_attendance.attendance_date.to_date, attendance_earning.holiday_ids)
  				if multiplex_verification == true
  					employee_attendance.flat_overtime(employee_attendance, (attendance_earning.earning_value * attendance_earning.multiplex), attendance_earning.earning_from)	
  				else
  					employee_attendance.flat_overtime(employee_attendance, attendance_earning.earning_value, attendance_earning.earning_from)		
  				end
  			else
  				employee_attendance.flat_overtime(employee_attendance, attendance_earning.earning_value, attendance_earning.earning_from)		
  			end
  		elsif attendance_earning.earning_type == "As Per Actual"
  			if attendance_earning.upper_cap == true
	  			if over_time_hours > attendance_earning.upper_cap_limit
	  				over_time_hours = attendance_earning.upper_cap_limit
					end
				end
				if dtl_instance?
					if employee_attendance.employee.gross_salary <= 28000.0
						if employee_attendance.employee.sub_department_id.present?
							if not employee_attendance.employee.sub_department_id.to_s == "78" or employee_attendance.employee.sub_department_id.to_s == "75" or employee_attendance.location_id.to_s == "10"
								if employee_attendance.attendance_status == "Rest Day" or employee_attendance.attendance_status == "Public Holiday"
									if attendance_earning.rest_upper_cap == true
										if over_time_hours > attendance_earning.rest_upper_cap_limit
											over_time_hours = attendance_earning.rest_upper_cap_limit
										end
									end
								elsif employee_attendance.attendance_status == "Present" or employee_attendance.attendance_status == "Half Day" or employee_attendance.attendance_status == "Late"
									if attendance_earning.regular_upper_cap == true
										if over_time_hours > attendance_earning.regular_upper_cap_limit
											over_time_hours = attendance_earning.regular_upper_cap_limit
										end
									end
								end
							end
						end
					else
						over_time_hours = 0.0
					end
				end
  			if attendance_earning.multiplex_allowed == true
  				multiplex_verification = Holiday.verify_public_holiday_for_overtime(employee_attendance, employee_attendance.attendance_date.to_date, attendance_earning.holiday_ids)
  				if multiplex_verification == true
  					employee_attendance.actual_overtime(employee_attendance, ((attendance_earning.multiplex * over_time_hours).to_f/working_hours).to_f.round(2), attendance_earning.earning_from)
  				else
  					employee_attendance.actual_overtime(employee_attendance, (over_time_hours.to_f/working_hours.to_f).to_f.round(2), attendance_earning.earning_from)
  				end
  			else
  				employee_attendance.actual_overtime(employee_attendance, (over_time_hours.to_f/working_hours.to_f).to_f.round(2), attendance_earning.earning_from)
  			end
  		end
		elsif attendance_earning.earning_from == "Salary"
			if attendance_earning.earning_type == "Flat"
				if attendance_earning.multiplex_allowed == true
  				multiplex_verification = Holiday.verify_public_holiday_for_overtime(employee_attendance, employee_attendance.attendance_date.to_date, attendance_earning.holiday_ids)
  				if multiplex_verification == true
						employee_attendance.flat_overtime(employee_attendance, (attendance_earning.earning_value * attendance_earning.multiplex), attendance_earning.earning_from)
					else
						employee_attendance.flat_overtime(employee_attendance, attendance_earning.multiplex, attendance_earning.earning_from)
					end
				else
					employee_attendance.flat_overtime(employee_attendance, attendance_earning.multiplex, attendance_earning.earning_from)
				end
			elsif attendance_earning.earning_type == "As Per Actual"
				if attendance_earning.upper_cap == true
					if over_time_hours > attendance_earning.upper_cap_limit
						over_time_hours = attendance_earning.upper_cap_limit
					end
				end
				if dtl_instance?
					if employee_attendance.employee.gross_salary <= 28000.0
						if employee_attendance.employee.sub_department_id.present?
							if not employee_attendance.employee.sub_department_id.to_s == "78" or employee_attendance.employee.sub_department_id.to_s == "75"
								if employee_attendance.attendance_status == "Rest Day" or employee_attendance.attendance_status == "Public Holiday"
									if attendance_earning.rest_upper_cap == true
										if over_time_hours > attendance_earning.rest_upper_cap_limit
											over_time_hours = attendance_earning.rest_upper_cap_limit
										end
									end
								elsif employee_attendance.attendance_status == "Present" or employee_attendance.attendance_status == "Half Day" or employee_attendance.attendance_status == "Late"
									if attendance_earning.regular_upper_cap == true
										if over_time_hours > attendance_earning.regular_upper_cap_limit
											over_time_hours = attendance_earning.regular_upper_cap_limit
										end
									end
								end
							end
						end
					else
						over_time_hours = 0.0
					end
				end
  			if attendance_earning.multiplex_allowed == true
  				multiplex_verification = Holiday.verify_public_holiday_for_overtime(employee_attendance, employee_attendance.attendance_date.to_date, attendance_earning.holiday_ids)
  				if multiplex_verification == true
  					employee_attendance.actual_overtime(employee_attendance, (attendance_earning.multiplex * over_time_hours), attendance_earning.earning_from)
  				else
  					employee_attendance.actual_overtime(employee_attendance, over_time_hours, attendance_earning.earning_from)
  				end
  			else
  				employee_attendance.actual_overtime(employee_attendance, over_time_hours, attendance_earning.earning_from)
  			end
  		end
  	elsif attendance_earning.earning_from == "Encashable Quota"
			if attendance_earning.earning_type == "Flat"
				if attendance_earning.multiplex_allowed == true
  				multiplex_verification = Holiday.verify_public_holiday_for_overtime(employee_attendance, employee_attendance.attendance_date.to_date, attendance_earning.holiday_ids)
  				if multiplex_verification == true
						employee_attendance.flat_overtime(employee_attendance, (attendance_earning.earning_value * attendance_earning.multiplex), attendance_earning.earning_from)
					else
						employee_attendance.flat_overtime(employee_attendance, attendance_earning.multiplex, attendance_earning.earning_from)
					end
				else
					employee_attendance.flat_overtime(employee_attendance, attendance_earning.multiplex, attendance_earning.earning_from)
				end
  		elsif attendance_earning.earning_type == "As Per Actual"
				if attendance_earning.upper_cap == true
					if over_time_hours > attendance_earning.upper_cap_limit
						over_time_hours = attendance_earning.upper_cap_limit
					end
				end
				if dtl_instance?
					if employee_attendance.employee.gross_salary <= 28000.0
						if employee_attendance.employee.sub_department_id.present?
							if not employee_attendance.employee.sub_department_id.to_s == "78" or employee_attendance.employee.sub_department_id.to_s == "75"
								if employee_attendance.attendance_status == "Rest Day" or employee_attendance.attendance_status == "Public Holiday"
									if attendance_earning.rest_upper_cap == true
										if over_time_hours > attendance_earning.rest_upper_cap_limit
											over_time_hours = attendance_earning.rest_upper_cap_limit
										end
									end
								elsif employee_attendance.attendance_status == "Present" or employee_attendance.attendance_status == "Half Day" or employee_attendance.attendance_status == "Late"
									if attendance_earning.regular_upper_cap == true
										if over_time_hours > attendance_earning.regular_upper_cap_limit
											over_time_hours = attendance_earning.regular_upper_cap_limit
										end
									end
								end
							end
						end
					else
						over_time_hours = 0.0
					end
				end
  			if attendance_earning.multiplex_allowed == true
  				multiplex_verification = Holiday.verify_public_holiday_for_overtime(employee_attendance, employee_attendance.attendance_date.to_date, attendance_earning.holiday_ids)
  				if multiplex_verification == true
  					employee_attendance.actual_overtime(employee_attendance, (attendance_earning.multiplex * over_time_hours), attendance_earning.earning_from)
  				else
  					employee_attendance.actual_overtime(employee_attendance, over_time_hours, attendance_earning.earning_from)
  				end
  			else
  				employee_attendance.actual_overtime(employee_attendance, over_time_hours, attendance_earning.earning_from)
  			end
  		end
  	end
  end

  ########## Overtime Flat Deduction ##########
	def flat_overtime(employee_attendance, earning_value, earning_from)
		if earning_from == "Quota"
			employee_attendance.no_of_cpl = earning_value
			employee_attendance.remarks = "CPL Earned"
			employee_attendance.save
			employee_attendance.add_earned_quota_to_employee(employee_attendance)
		elsif earning_from == "Salary"
			employee_attendance.off_days_payment_days = earning_value
			employee_attendance.remarks = "Off Day Working"
			employee_attendance.save
		elsif earning_from == "Encashable Quota"
			employee_attendance.encashable_quota = earning_value
			employee_attendance.remarks = "Monthly Encashable CPL #{earning_value} Flat"
			employee_attendance.save
		end
	end

	def actual_overtime(employee_attendance, earning_value, earning_from)
		if earning_from == "Quota"
			over_time_minutes = (earning_value * 60).round(2)
			over_time_seconds = (earning_value * 60 * 60).round(2)
			employee_attendance.no_of_cpl 				= earning_value
			employee_attendance.remarks = "CPL Earned #{earning_value}"
			employee_attendance.save
			employee_attendance.add_earned_quota_to_employee(employee_attendance)
		elsif earning_from == "Salary"
			if employee_attendance.is_ot_approved == false
				# attendance_month = employee_attendance.attendance_date.to_date.strftime("%B %Y")
				# if employee_attendance.attendance_status == "Rest Day"
				# 	total_rest_days_overtime = EmployeeAttendance.where(:employee_id => employee_attendance.employee_id, :attendance_date => attendance_month.to_date.beginning_of_month..attendance_month.to_date.end_of_month, :attendance_status => "Rest Day").sum(:over_time_hours)
				# 	if total_rest_days_overtime < 32.0
				# 		rest_day_diff = 32.0 - total_rest_days_overtime
				# 		if rest_day_diff < 8.0
				# 			earning_value = rest_day_diff
				# 		else
				# 			earning_value = 8.0
				# 		end
				# 	else
				# 		earning_value = 0.0
				# 	end
				# elsif employee_attendance.attendance_status == "Present" or employee_attendance.attendance_status == "Late" or employee_attendance.attendance_status == "Half Day"
				# 	total_regular_days_overtime = EmployeeAttendance.where(:employee_id => employee_attendance.employee_id, :attendance_date => attendance_month.to_date.beginning_of_month..attendance_month.to_date.end_of_month, :attendance_status => ["Present", "Late", "Half Day"]).sum(:over_time_hours)
				# 	if total_regular_days_overtime < 28.0
				# 		regular_day_diff = 28.0 - total_regular_days_overtime
				# 		if regular_day_diff < 4.0
				# 			earning_value = regular_day_diff
				# 		else
				# 			earning_value = 4.0
				# 		end
				# 	else
				# 		earning_value = 0.0
				# 	end
				# end
					over_time_minutes = (earning_value * 60).round(2)
					over_time_seconds = (earning_value * 60 * 60).round(2)
					employee_attendance.actual_overtime_hours 	= earning_value
					employee_attendance.actual_overtime_minutes = over_time_minutes
					employee_attendance.over_time_minutes = over_time_minutes
					employee_attendance.over_time_seconds = over_time_seconds
					employee_attendance.minute_earned 		= over_time_minutes
				if dtl_instance?
					if employee_attendance.employee.gross_salary <= 28000.0
						##### For Security Dept Rest Day #####
						if employee_attendance.attendance_status == "Rest Day" or employee_attendance.attendance_status == "Public Holiday" and employee_attendance.sub_department_id.to_s == "78"
							if employee_attendance.in_time.present? and employee_attendance.out_time.present?
								if employee_attendance.in_time < employee_attendance.office_in_time
									earning_value = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.out_time).in_hours
								else
									earning_value = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
								end
							else
								earning_value = 0.0
							end
							if earning_value > 0
								if earning_value >= 24
									first_value = earning_value.to_s.split('.')[0].to_i
									last_value 	= (earning_value.to_s.split('.')[1].to_f/2.0).to_i
									ot = "#{first_value}:#{last_value}"
								else
									ot = Time.at(earning_value * 60 * 60).utc.strftime("%H:%M")
								end
								hours = ot.to_s.split(":")
								if hours.count > 1
									if hours.last.to_i >= 45
										employee_attendance.over_time_hours 	= hours.first.to_f + 1.0
									else
										employee_attendance.over_time_hours		=	hours.first.to_f
									end
								else
									employee_attendance.over_time_hours 	= earning_value
								end
							else
								employee_attendance.over_time_hours 	= 0.0
							end
							##### For All Rest Day #####
						elsif employee_attendance.attendance_status == "Rest Day"
							if employee_attendance.in_time.present? and employee_attendance.out_time.present?
								served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
							else
								served_hours = 0
							end
							working_hours = TimeDifference.between(employee_attendance.office_in_time, employee_attendance.office_out_time).in_hours
							earning_value = served_hours - working_hours
							if earning_value > 0
								if earning_value >= 24
									first_value = earning_value.to_s.split('.')[0].to_i
									if first_value > 8
										first_value = 8
									end
									last_value 	= (earning_value.to_s.split('.')[1].to_f/2.0).to_i
									ot = "#{first_value}:#{last_value}"
								else
									first_value = earning_value.to_s.split('.')[0].to_i
									if first_value > 8
										first_value = 8
									end
									last_value 	= (earning_value.to_s.split('.')[1]).to_i
									earning_value = "#{first_value}.#{last_value}".to_f
									ot = Time.at(earning_value * 60 * 60).utc.strftime("%H:%M")
								end
								hours = ot.to_s.split(":")
								if hours.count > 1
									if hours.last.to_i >= 45
										employee_attendance.over_time_hours 	= hours.first.to_f + 1.0
									else
										employee_attendance.over_time_hours		=	hours.first.to_f
									end
								else
									employee_attendance.over_time_hours 	= earning_value
								end
							else
								employee_attendance.over_time_hours 	= 0.0
							end
						else
							if employee_attendance.out_time > employee_attendance.office_out_time
								earning_value = (TimeDifference.between(employee_attendance.office_out_time.to_s, employee_attendance.out_time.to_s).in_hours + 0.01).round(2)
								ot = ""
								if earning_value > 0
									if earning_value >= 24
										first_value = earning_value.to_s.split('.')[0].to_i
										if first_value > 4
											first_value = 4
										end
										last_value 	= (earning_value.to_s.split('.')[1].to_f/2.0).to_i
										ot = "#{first_value}:#{last_value}"
									else
										first_value = earning_value.to_s.split('.')[0].to_i
										if first_value > 4
											first_value = 4
										end
										last_value 	= (earning_value.to_s.split('.')[1]).to_i
										earning_value = "#{first_value}.#{last_value}".to_f
										ot = Time.at(earning_value * 60 * 60).utc.strftime("%H:%M")
									end
									hours = ot.to_s.split(":")
									if hours.count > 1
										if hours.last.to_i >= 45
											employee_attendance.over_time_hours 	= hours.first.to_f + 1.0
										else
											employee_attendance.over_time_hours		=	hours.first.to_f
										end
									else
										employee_attendance.over_time_hours 	= earning_value
									end
								else
									employee_attendance.over_time_hours 	= earning_value
								end
							else
								employee_attendance.over_time_hours = "-"
							end
						end
					else
						employee_attendance.over_time_hours 	= 0.0
					end
					employee_attendance.remarks = " "
				else
					employee_attendance.over_time_hours 	= earning_value
					employee_attendance.remarks = "Normal OverTime"
				end
					employee_attendance.save
			end
		elsif earning_from == "Encashable Quota"
			over_time_minutes = (earning_value * 60).round(2)
			employee_attendance.encashable_quota 	= earning_value
			employee_attendance.remarks = "Monthly Encashable CPL #{earning_value} Hours"
			employee_attendance.save
		end
	end

  ########## Add CPL Quota In Employee Leave Ledger ##########
  def add_earned_quota_to_employee(employee_attendance)  	
  	if employee_attendance.quota_earned == false
  		if employee_attendance.no_of_cpl > 0
  			system_setting = SystemSetting.find_by(:company_id => employee_attendance.company_id)
  			if not system_setting.nil?
  				if system_setting.live_leave_earning == true
  					leave_type = LeaveType.find_by(:company_id => employee_attendance.employee.company_id, :location_id => employee_attendance.employee.location_id, :is_active => true, :auto_allocation => true, :earned_quota => true)
				  	if not leave_type.nil?	
				  		leave_allocation = LeaveAllocation.find_by(:employee_id => employee_attendance.employee_id, :is_active => true, :leave_type_id => leave_type.id)
				  		if not leave_allocation.nil?
				  			if leave_allocation.allocated_quota < leave_type.earned_quota_max_limit
				  				leave_allocation.add_earned_quota_to_employee(employee_attendance.no_of_cpl, leave_type.id, employee_attendance.employee_id, leave_allocation.leave_year_id)		
				  				employee_attendance.quota_earned = true
		  						employee_attendance.save
				  			end

				  			# if leave_allocation.allocated_quota < leave_type.earned_quota_max_limit
				  			# 	if (leave_allocation.allocated_quota + employee_attendance.no_of_cpl) < leave_type.earned_quota_max_limit
				  			# 		leave_allocation.add_earned_quota_to_employee(employee_attendance.no_of_cpl, leave_type.id, employee_attendance.employee_id, leave_allocation.leave_year_id)		
					  		# 		employee_attendance.quota_earned = true
			  				# 		employee_attendance.save
			  				# 	else
			  				# 		no_of_cpl = leave_type.earned_quota_max_limit - leave_allocation.allocated_quota
			  				# 		leave_allocation.add_earned_quota_to_employee(no_of_cpl, leave_type.id, employee_attendance.employee_id, leave_allocation.leave_year_id)		
					  		# 		employee_attendance.quota_earned = true
			  				# 		employee_attendance.save
				  			# 	end
				  			# end
				  			
				  		end
				  	end
  				end
  			end
  		end
  	end
  end

  ########## Leave Deduction Revision ##########
  def self.revision_of_leave_deducted(employee_attendance)
  	system_setting = SystemSetting.find_by(:company_id => employee_attendance.company_id)
		if not system_setting.nil?
			if system_setting.live_leave_deduction == true
		  	leave_requests = LeaveRequest.where("start_date >= ? AND end_date <= ?", employee_attendance.attendance_date.to_date, employee_attendance.attendance_date.to_date).where(:is_cancelled => false, :request_status => "System Deducted", :employee_id => employee_attendance.employee_id).order('id ASC')  
		    leave_requests.each do |leave_request|
		    	leave_request.is_cancelled = true
		    	leave_request.request_status = "Cancelled"
		    	leave_request.save
		    end
		  end
		end
	end

	########## Employee Attendance Leaves wrt Cutoff ##########
  def self.employee_leaves(pay_invoices)
		cl_status = []
		LeaveType.where(short_name: "CL").each do |leave_type|
			cl_status << "On Leave (#{leave_type.name})"
		end
		ml_status = []
		LeaveType.where(short_name: "SL").each do |leave_type|
			ml_status << "On Leave (#{leave_type.name})"
		end
		al_status = []
		LeaveType.where(short_name: "AL").each do |leave_type|
			al_status << "On Leave (#{leave_type.name})"
		end
		leave_data = {}
		pay_invoices.each do |pay_invoice|
			employee_attendances = FinalizeAttendance.includes(:employee_attendance).where(employee_id: pay_invoice.employee_id, attendance_cutoff_id: pay_invoice.pay_execution.attendance_cutoff_ids.split(',').map(&:to_i)).map(&:employee_attendance)
			emp_leave_details = {}
			emp_leave_details["ml"] = 0
			emp_leave_details["al"] = 0
			emp_leave_details["lwp"] = 0
			emp_leave_details["cl"] = 0
			emp_leave_details["rest"] = 0
			emp_leave_details["absent"] = 0
			employee_attendances.each do |emp_attendance|
				emp_leave_details["ml"] += 1 if ml_status.include?(emp_attendance&.attendance_status)
				emp_leave_details["al"] += 1 if al_status.include?(emp_attendance&.attendance_status)
				emp_leave_details["cl"] += 1 if cl_status.include?(emp_attendance&.attendance_status)
				emp_leave_details["lwp"] += 1 if emp_attendance.try(:is_leave_without_pay)
				emp_leave_details["rest"] += 1 if emp_attendance.try(:is_rest_day)
				emp_leave_details["absent"] += 1 if emp_attendance&.attendance_status == "Absent"
			end
			leave_data[pay_invoice.id] = emp_leave_details
		end
		leave_data
  end
  
  ########## Finalize Deduction ##########
  def self.finalize_deuction(employee_attendance)
  	system_setting = SystemSetting.find_by(:company_id => employee_attendance.company_id)
		if not system_setting.nil?
			if system_setting.live_leave_deduction == true 	  	
		  	if employee_attendance.deduction_from_quota == true
		  		deduction_value = (employee_attendance.checkout_deduction.to_f + employee_attendance.checkin_deduction.to_f).round(2)
		  		if deduction_value > 0
			  		if deduction_value > 1
			  			deduction_value = 1.0
			  		end
			  		deduction_completed = false
			  		leave_types = LeaveType.where(:is_active => true, :is_deductible => true, :is_composite => false, :special_leave => false).order('sort_order ASC')
			  		leave_types.each do |leave_type|
			  			if deduction_completed == false
			  				leave_allocation = LeaveAllocation.find_by(:employee_id => employee_attendance.employee_id, :is_active => true, :leave_type_id => leave_type.id)	
			  				if not leave_allocation.nil?
			  					if leave_allocation.remaining_quota > 0
										if deduction_value <= leave_allocation.remaining_quota
											puts "\n\n #{employee_attendance.attendance_date} \n\n"
											puts "\n\n #{deduction_value} \n\n"
											puts "\n\n #{leave_allocation.remaining_quota} \n\n"
											puts "\n\n #{leave_type.name} \n\n"
											deduction_completed = true
											employee_attendance.generate_deduction_request(employee_attendance, deduction_value, leave_allocation, leave_type)
										else
											deduction_value = (deduction_value - leave_allocation.remaining_quota).round(2)
											puts "\n\n #{employee_attendance.attendance_date} \n\n"
											puts "\n\n #{deduction_value} \n\n"
											puts "\n\n #{leave_allocation.remaining_quota} \n\n"
											puts "\n\n #{leave_type.name} \n\n"
											deduction_completed = false
											employee_attendance.generate_deduction_request(employee_attendance, leave_allocation.remaining_quota, leave_allocation, leave_type)
										end
									end
			  				end
			  			end
			  		end
			  		if deduction_value > 0 && deduction_completed == false
			  			employee_attendance.deduction_from_salary = true
			  			employee_attendance.pay_deduction = deduction_value
			  			employee_attendance.save
			  		end
			  	end
		  	end
		  end
		end
  end

  ########## Leave Deduction Request Generation ##########
  def generate_deduction_request(employee_attendance, deducted_quota, leave_allocation, leave_type)
  	leave_request = LeaveRequest.new
    leave_request.company_id       = employee_attendance.company_id
    leave_request.employee_id      = employee_attendance.employee_id
    leave_request.leave_type_id    = leave_type.id
    leave_request.allocated_quota  = leave_allocation.allocated_quota.to_f
    leave_request.used_quota       = leave_allocation.used_quota.to_f
    leave_request.remaining_quota  = leave_allocation.remaining_quota.to_f
    leave_request.request_count    = deducted_quota.to_f
    leave_request.sandwich_count   = 0.0
    leave_request.min_apply_date   = employee_attendance.attendance_date.to_date - leave_type.back_date_limit.day
    leave_request.start_date       = employee_attendance.attendance_date.to_date
    leave_request.end_date         = employee_attendance.attendance_date.to_date
    leave_request.reason           = "Attendance Deduction"
    leave_request.leave_category   = "Full Day"
    leave_request.request_status   = "System Deducted"
    leave_request.is_composite   	 = false
    leave_request.apply_status     = "System"
    leave_request.is_cancelled     = false
    leave_request.save
  end

  ########## Auto Impact on Attendance of Request Availed ##########
  def self.auto_impact_on_attendance_of_request(request_type, start_date, end_date, employee)
  	date_range = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
  	########## Empty Row Creation for Attendance ##########
		date_range.each do |single_date|
			if EmployeeAttendance.where(:employee_id => employee.id, :attendance_date => single_date).empty?
				if employee.joining_date.to_date <= single_date
					EmployeeAttendance.create_empty_attenance_record(single_date, employee)
				end
			end
		end

		########## Update Attendance Information with Employee Roster ##########
		EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range).order('attendance_date ASC').each do |employee_attendance|
			EmployeeRoster.update_employee_roster(employee_attendance.attendance_date.to_date, employee_attendance)
		end

		EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range).order('attendance_date ASC').each do |employee_attendance|
			EmployeeAttendance.update_employee_detail(employee_attendance, employee)
		end
		
		########## Leave Impact on Attendance ##########
		if request_type == "leave_request"
			EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_on_leave => true).each do |employee_attendance|
				EmployeeAttendance.clear_attendance_record_for_request_impact(employee_attendance)
			end
			EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range).order('attendance_date ASC').each do |employee_attendance|
				LeaveRequest.employee_wise_leave_impact(employee_attendance)
			end
		end

		########## Official Duty Impact on Attendance ##########
		if request_type == "official_duty_request"
			EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_official_duty => true).each do |employee_attendance|
				EmployeeAttendance.clear_attendance_record_for_request_impact(employee_attendance)
			end
			EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range).order('attendance_date ASC').each do |employee_attendance|
				OfficialDuty.employee_wise_official_duty_impact(employee_attendance)
			end
			EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_on_leave => false, :is_official_duty => true, :is_relaxation => false).order('attendance_date ASC').each do |employee_attendance|
				EmployeeAttendance.single_employee_process_attendance(employee_attendance)
			end
		end

		########## Relaxation Impact on Attendance ##########
		if request_type == "relaxation_request"
			EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_relaxation => true).each do |employee_attendance|
				EmployeeAttendance.clear_attendance_record_for_request_impact(employee_attendance)
			end
			EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :mark_as_manual => false, :is_relaxation => true).order('attendance_date ASC').each do |employee_attendance|
				AttendanceMachineLog.update_employee_checkin_checkout(employee_attendance)
			end
			EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range).order('attendance_date ASC').each do |employee_attendance|
				RelaxationRequest.employee_wise_relaxation_impact(employee_attendance)
			end
			EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :is_on_leave => false, :is_official_duty => false, :is_relaxation => true).order('attendance_date ASC').each do |employee_attendance|
				EmployeeAttendance.single_employee_process_attendance(employee_attendance)
			end
		end

		if request_type == "cpl_request"
			EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, mark_as_manual: false).each do |employee_attendance|
				EmployeeAttendance.clear_attendance_record_for_request_impact(employee_attendance)
			end
			EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range, :mark_as_manual => false).order('attendance_date ASC').each do |employee_attendance|
				AttendanceMachineLog.update_employee_checkin_checkout(employee_attendance)
			end
			EmployeeAttendance.where(:is_finalized => false, :employee_id => employee.id, :attendance_date => date_range).order('attendance_date ASC').each do |employee_attendance|
				EmployeeAttendance.single_employee_process_attendance(employee_attendance)
			end
		end

  end

	def get_leverage_minutes
		leverage_minutes = 0
		cut_off = AttendanceCutoff.last.location_id.nil? ? AttendanceCutoff.where(salary_unit_id: self.salary_unit_id).last : AttendanceCutoff.where(location_id: self.location_id).last
		leverage_end_date = self.attendance_date.to_date >= cut_off.end_date.to_date ? cut_off.end_date.to_date : self.attendance_date.to_date
		date_range = (cut_off.start_date.to_date..leverage_end_date).to_a.map{|x| x.to_date}
		present_attendances = EmployeeAttendance.where(employee_id: employee_id, attendance_date: date_range, attendance_status: 'Present')
		present_attendances.each do |attendace|
			current_time = attendace.attendance_date
			if mill_instance? and attendace.employee_roster.time_slot.is_flexi and attendace.sub_time_slot_id
				expected_in_time = Time.new(current_time.year, current_time.month, current_time.day, attendace.sub_time_slot.actual_start_time.to_datetime.hour, attendace.sub_time_slot.actual_start_time.to_datetime.minute, '0')
			elsif mill_instance?
				expected_in_time = Time.new(current_time.year, current_time.month, current_time.day, attendace.office_start_hour, attendace.office_start_min, '0')
			elsif attendace.employee_roster.start_time.to_datetime.strftime("%I:%M") == "09:30"
				expected_in_time = Time.new(current_time.year, current_time.month, current_time.day, '9', '30', '0')
			else
				expected_in_time = Time.new(current_time.year, current_time.month, current_time.day, '9', '0', '0')
			end
			leverage_minutes += TimeDifference.between(attendace.in_time, expected_in_time).in_minutes.to_i if (attendace.in_time and attendace.in_time > expected_in_time)
		end
		leverage_minutes
	end

	def self.auto_daily_attendance_report_overall
		begin
			if Date.today.day > 27
				start_date = Date.today.year.to_s + "-" + Date.today.month.to_s + "-27"
			else
				start_date = (Date.today - 1.month).year.to_s + "-" + (Date.today - 1.month).month.to_s + "-27"
			end
			end_date = Date.today - 1.day
			start_time = Time.now
			date_range = (start_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}

			@employees = Employee.where(:company_id => 1, :is_active => true, :is_struck_off => false).order('id DESC')
			@employee_attendances = EmployeeAttendance.where(:employee_id => @employees.collect(&:id).uniq, :company_id => 1, :attendance_date => start_date.to_date..end_date.to_date).order('attendance_date ASC')

			time = Time.now
			book = Axlsx::Package.new
			wb = book.workbook
			sheet = wb.add_worksheet(name: 'Daily Attendance')
			book.use_autowidth = false
			sheet.sheet_view do |view|
				view.show_outline_symbols = true
			end
			book.use_autowidth = true

			cell_style = sheet.styles.add_style :sz => 10, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma'
			sheet.add_row ["Extraction Date :","#{DateTime.now.strftime("%d-%b-%Y %I:%M %P")}"], :style => cell_style
			sheet.add_row ['']
			sheet.add_row ['']
			sheet.add_row ['']
			sheet.add_row ['']

			header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
			bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 10,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
			sheet.add_row ["SR NO.", "Emp Code", "Name", "Branch","Grade", "Designation", "Job Title", "Employee Type", "Department", "Sub Department", "Date", "Rest Day", "Hiring Shift", "Shift", "Shift Timing", "In Time", "Out Time", "Attendance Mark", "Arrival Status", "Left Status", "Worked Hours", "Actual OT", "Approved OT", "OT Action", 'Request Status', 'Approval Authority'],:style => header_style
			old_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
			even_row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
			count = 0
			employee_ids = @employee_attendances.collect(&:employee_id).uniq
			employees = Employee.where(:id => employee_ids).order('employee_code ASC')
			employees.each do |employee|
				employee_total_wh = 0.0
				@employee_attendances.where(:employee_id => employee.id).order('attendance_date ASC').each do |employee_attendance|
					count = count + 1
					row_format = old_row_format

					if count.even? == true
						row_format = even_row_format
					else
						row_format = old_row_format
					end

					current_row_value = []
					current_row_style = []
					current_row_type = []

					current_row_value << count
					current_row_style << row_format
					current_row_type << :integer

					current_row_value << employee_attendance.employee.employee_code
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee_attendance.employee.full_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee_attendance.employee.branch_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee_attendance.employee.grade_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee_attendance.employee.designation_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee_attendance.employee.job_title_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee_attendance.employee.employee_type_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee_attendance.employee.department_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee_attendance.employee.sub_department_name
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.date_format(employee_attendance.attendance_date)
					current_row_style << row_format
					current_row_type << :string

					current_row_value << ReportFormat.rest_day_name(employee_attendance)
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee_attendance.employee.hiring_shift
					current_row_style << row_format
					current_row_type << :string

					if employee_attendance.employee_roster.nil?
						current_row_value << "No Roster Assinged"
						current_row_style << row_format
						current_row_type << :string

						current_row_value << "No Roster Assinged"
						current_row_style << row_format
						current_row_type << :string
					else
						current_row_value << ReportFormat.shift_name(employee_attendance)
						current_row_style << row_format
						current_row_type << :string

						current_row_value << ReportFormat.shift_timing(employee_attendance)
						current_row_style << row_format
						current_row_type << :string
					end

					if employee_attendance.in_time.nil?
						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string
					else
						current_row_value << employee_attendance.in_time.to_datetime.strftime("%-l:%M %P")
						current_row_style << row_format
						current_row_type << :string
					end

					if employee_attendance.out_time.nil?
						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string
					else
						current_row_value << employee_attendance.out_time.to_datetime.strftime("%-l:%M %P")
						current_row_style << row_format
						current_row_type << :string
					end

					if employee_attendance.mark_as_manual == true
						current_row_value << "Manual"
						current_row_style << row_format
						current_row_type << :string
					else
						current_row_value << "Automatic"
						current_row_style << row_format
						current_row_type << :string
					end

					current_row_value << employee_attendance.attendance_status
					current_row_style << row_format
					current_row_type << :string

					current_row_value << employee_attendance.early_left_status
					current_row_style << row_format
					current_row_type << :string

					served_hours = 0
					if not employee_attendance.in_time.nil?
						if not employee_attendance.out_time.nil?
							served_hours = TimeDifference.between(employee_attendance.in_time, employee_attendance.out_time).in_hours
							current_row_value << Time.at(served_hours * 60 * 60).utc.strftime("%H:%M")
							current_row_style << row_format
							current_row_type << :string
						else
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					else
						current_row_value << "-"
						current_row_style << row_format
						current_row_type << :string
					end

					employee_total_wh = employee_total_wh + (served_hours * 60 * 60)

					####### Above Code ########
					if employee_attendance.approval_base_overtime == false
						if employee_attendance.over_time_hours > 0
							current_row_value << ReportFormat.overtime_value_into_overtime_hours(employee_attendance.over_time_hours * 60 * 60)
							current_row_style << row_format
							current_row_type << :string

							current_row_value << ReportFormat.overtime_value_into_overtime_hours(employee_attendance.over_time_hours * 60 * 60)
							current_row_style << row_format
							current_row_type << :string
						else
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string

							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					else
						if employee_attendance.over_time_hours > 0
							current_row_value << ReportFormat.overtime_value_into_overtime_hours(employee_attendance.over_time_hours * 60 * 60)
							current_row_style << row_format
							current_row_type << :string
						else
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
						if employee_attendance.approved_overtime > 0
							first_value = employee_attendance.approved_overtime.to_s.split('.')[0]
							last_value 	= (employee_attendance.approved_overtime.to_s.split('.')[1].to_f/2.0).to_i
							current_row_value << "#{first_value}:#{last_value}"
							# current_row_value << ReportFormat.overtime_value_into_overtime_hours(employee_attendance.approved_overtime * 60 * 60)
							current_row_style << row_format
							current_row_type << :string
						else
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					if employee_attendance.approval_base_overtime == false
						if employee_attendance.over_time_hours > 0
							current_row_value << ReportFormat.overtime_value_into_overtime_hours(employee_attendance.over_time_hours * 60 * 60)
							current_row_style << row_format
							current_row_type << :string

							current_row_value << ReportFormat.overtime_value_into_overtime_hours(employee_attendance.over_time_hours * 60 * 60)
							current_row_style << row_format
							current_row_type << :string
						else
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string

							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					else
						if employee_attendance.over_time_hours > 0
							current_row_value << ReportFormat.overtime_value_into_overtime_hours(employee_attendance.over_time_hours * 60 * 60)
							current_row_style << row_format
							current_row_type << :string
						else
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
						if employee_attendance.approved_overtime > 0
							first_value = employee_attendance.approved_overtime.to_s.split('.')[0]
							last_value 	= (employee_attendance.approved_overtime.to_s.split('.')[1].to_f/2.0).to_i
							current_row_value << "#{first_value}:#{last_value}"
							# current_row_value << ReportFormat.overtime_value_into_overtime_hours(employee_attendance.approved_overtime * 60 * 60)
							current_row_style << row_format
							current_row_type << :string
						else
							current_row_value << "-"
							current_row_style << row_format
							current_row_type << :string
						end
					end

					current_row_value << ReportFormat.boolean_in_text(employee_attendance.is_ot_approved)
					current_row_style << row_format
					current_row_type << :string

					request_status = 'Request Not Applied'
					if employee.leave_requests.where(':date BETWEEN leave_requests.start_date AND leave_requests.end_date', date: employee_attendance.attendance_date).count >= 1
						request_status = 'Leave Requested'
					end
					if employee.official_duties.where(':date BETWEEN official_duties.start_date AND official_duties.end_date', date: employee_attendance.attendance_date).count >= 1
						request_status = 'OfficialDuty Requested'
					end
					if employee.relaxation_requests.where(':date BETWEEN relaxation_requests.start_date AND relaxation_requests.end_date', date: employee_attendance.attendance_date).count >= 1
						request_status = 'Relaxation Requested'
					end

					current_row_value << request_status
					current_row_style << row_format
					current_row_type << :string

					current_row_value << (employee.line_manager.try(:full_name) || '-')
					current_row_style << row_format
					current_row_type << :string

					sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
					puts "row added"
				end
			end
			file_name = "auto_daily_attendance_#{Time.now.strftime("%d-%m-%Y")}"
			file_path = "/excel/#{file_name}.xlsx"
			book.serialize "#{Rails.public_path.to_s + file_path}"
			end_time = Time.now
			UserMailer.send_report_xlsx2(["zeshan.haider@sapphire.com.pk", "imran.hameed@sapphire.com.pk"], "Auto Daily Attendance Overall Report", "", "", file_name, start_time, end_time, "dev.team@sapphiretextiles.com.pk", "").deliver_now
		rescue StandardError => error
			puts '====Unable to process attendance==============='
			UserMailer.send_email_notification('hrms@sapphiretextiles.com.pk', 'dev.team@sapphiretextiles.com.pk', 'Unable to send auto daily attendance report', error, nil).deliver_later
			puts error
		end
	end

	def srl_instance?
		ENV['APP_URL'].include?('hrmsbe.sapphirepakistan.pk')
	end

	def dtl_instance?
		ENV['APP_URL'].include?('dtlbe.srl.com.pk')
	end

	def mill_instance?
		ENV['APP_URL'].include?('millshrmsbe.dfl.com.pk')
	end

	def cresset_instance?
		ENV['APP_URL'].include?('attendancebe.cressettech.com')
	end
end
