class FinalizeAttendance < ApplicationRecord

	####### Relation Ship #########
	belongs_to 	:employee_attendance
	belongs_to 	:attendance_cutoff
	belongs_to 	:employee
	belongs_to 	:company
	belongs_to 	:location
	belongs_to 	:branch
	belongs_to 	:salary_unit

	########## Attendance Cuf Off Process ##########
	def self.finalize_attendance(cut_off, start_date, end_date)
		if cut_off.salary_unit_wise == false
			#######################################################################
			##### Get Employee Attendance on cut off filter and not finalize ######
			#######################################################################
	  	employee_attendances = EmployeeAttendance.where(:company_id => cut_off.company_id, :location_id => cut_off.location_id, :branch_id => cut_off.branch_id, :is_finalized => false, :prev_finalized => false)
	  	#######################################################################
	  	##### Get Employee Attendance on cut off filter and not finalize ######
	  	#######################################################################

	  	#############################################
	  	####### Archive Old Attendance Data #########
	  	#############################################
	  	EmployeeAttendance.where(:company_id => cut_off.company_id, :location_id => cut_off.location_id, :branch_id => cut_off.branch_id, :is_finalized => true).where('attendance_date < ?', start_date.to_date).update_all(prev_finalized: true)
	  	FinalizeAttendance.where(:company_id => cut_off.company_id, :location_id => cut_off.location_id, :branch_id => cut_off.branch_id, :is_finalize => false).where('attendance_date < ?', start_date.to_date).update_all(is_finalize: true)
	  	#############################################
	  	####### Archive Old Attendance Data #########
	  	#############################################
	  else
	  	#######################################################################
	  	##### Get Employee Attendance on cut off filter and not finalize ######
	  	#######################################################################
	  	employee_attendances = EmployeeAttendance.where(:company_id => cut_off.company_id, :salary_unit_id => cut_off.salary_unit_id, :is_finalized => false, :prev_finalized => false)
	  	#######################################################################
	  	##### Get Employee Attendance on cut off filter and not finalize ######
	  	#######################################################################

	  	#############################################
	  	####### Archive Old Attendance Data #########
	  	#############################################
	  	EmployeeAttendance.where(:company_id => cut_off.company_id, :salary_unit_id => cut_off.salary_unit_id, :is_finalized => true).where('attendance_date < ?', start_date.to_date).each do |employee_attendance|
	  		employee_attendance.prev_finalized = true
	  		employee_attendance.save
	  	end
	  	FinalizeAttendance.where(:company_id => cut_off.company_id, :salary_unit_id => cut_off.salary_unit_id, :is_finalize => false).where('attendance_date < ?', start_date.to_date).each do |record_attendance|
	  		record_attendance.is_finalize = true
	  		record_attendance.save
	  	end
	  	#############################################
	  	####### Archive Old Attendance Data #########
	  	#############################################
		end
			

  	##### Get Employee Attendance less then equal to cut_off_date ######
  	employee_attendances = employee_attendances.where(:attendance_date => start_date.to_date..end_date.to_date)
  	employee_ids = employee_attendances.collect(&:employee_id).uniq.sort
  	Array.new(employee_ids.count).each_index do |index|
	  	attendances = employee_attendances.where(:employee_id => employee_ids[index])
	  	######## Loop on Single Employee Attendance ########
	  	attendances.each do |single_attendance|
	  		single_attendance.is_finalized = true
	  		single_attendance.save
	  		final_attendance = FinalizeAttendance.new
				final_attendance.employee_attendance_id = single_attendance.id
				final_attendance.attendance_cutoff_id 	= cut_off.id
				final_attendance.employee_id 						= single_attendance.employee_id
				final_attendance.company_id 						= single_attendance.company_id
				final_attendance.location_id 						= single_attendance.location_id
				final_attendance.branch_id 							= single_attendance.branch_id
				final_attendance.attendance_date 				= single_attendance.attendance_date
				final_attendance.encashable_quota				= single_attendance.encashable_quota

				######## Updating Employee Arrears ########
				arrear_days = EmployeeArrear.where(:status => false, :employee_id => single_attendance.employee_id).where("arrears_month >= ? AND arrears_month <= ?", start_date.to_date, end_date.to_date).sum(:arrear_days)
				deduction_days = EmployeeDeduction.where(:status => false, :employee_id => single_attendance.employee_id).where("deductions_month >= ? AND deductions_month <= ?", start_date.to_date, end_date.to_date).sum(:deduction_days)
				final_attendance.arrear_days 				= arrear_days
        final_attendance.off_day_payment 		= single_attendance.off_days_payment_days
				if single_attendance.approval_base_overtime == true
					final_attendance.over_time_hours 		= single_attendance.approved_overtime
				else
					final_attendance.over_time_hours 		= single_attendance.over_time_hours
				end
    		final_attendance.over_time_minutes 	= single_attendance.over_time_minutes
    		final_attendance.over_time_seconds 	= single_attendance.over_time_seconds
        EmployeeArrear.where(:status => false, :employee_id => single_attendance.employee_id).where("arrears_month >= ? AND arrears_month <= ?", start_date.to_date, end_date.to_date).each do |arrear|
          arrear.status = true
          arrear.save
        end

        EmployeeDeduction.where(:status => false, :employee_id => single_attendance.employee_id).where("deductions_month >= ? AND deductions_month <= ?", start_date.to_date, end_date.to_date).each do |deduction|
          deduction.status = true
          deduction.save
        end
				
        if single_attendance.deduction_from_salary == true
					final_attendance.pay_deduction	= single_attendance.pay_deduction
					final_attendance.save
				end
				
				final_attendance.pay_deduction = final_attendance.pay_deduction + deduction_days
				final_attendance.save
	  	end
	  end

	end

end
