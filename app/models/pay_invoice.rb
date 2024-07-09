class PayInvoice < ApplicationRecord

	OVERTIME_CHECK_VALUE = 2
	####### Relation Ship #########
	belongs_to 	:employee
	belongs_to 	:pay_execution
	belongs_to 	:fiscal_year
	belongs_to 	:provident_fund
	belongs_to 	:eobi
	belongs_to 	:tax_slab
	belongs_to 	:company
	belongs_to 	:location
	belongs_to 	:branch
	belongs_to 	:department
  belongs_to	:sub_department
	belongs_to 	:designation
	belongs_to 	:job_title
	belongs_to 	:grade
	belongs_to 	:salary_unit
	belongs_to 	:cost_center
	belongs_to 	:employee_type

	has_many 		:pay_invoice_details, 			:dependent => :destroy
	has_one 		:employee_taxable_income

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

  def sub_department_name
    if self.sub_department.nil?
      return "-"
    else
      return self.sub_department.name
    end
  end

	def job_title_name
		if self.job_title.nil?
  		return "-"
  	else
  		return self.job_title.name
  	end
	end
		
	def grade_name
		if self.grade.nil?
  		return "-"
  	else
  		return self.grade.name
  	end
	end
		
  def designation_name
  	if self.designation.nil?
  		return "-"
  	else
  		return self.designation.name
  	end
  end

  def salary_unit_name
  	if self.salary_unit.nil?
  		return "-"
  	else
  		return self.salary_unit.name
  	end
  end

  def cost_center_name
  	if self.cost_center.nil?
  		return "-"
  	else
  		return self.cost_center.name
  	end
  end

  def employee_type_name
  	if self.employee_type.nil?
  		return "-"
  	else
  		return self.employee_type.name
  	end
  end

  def no_of_pay_days
  	if self.pay_execution.nil?
  		return 0.0
  	else
  		return self.pay_execution.no_of_pay_days.to_f
  	end
  end

  def urdu_allowed
  	if self.pay_execution.nil?
  		return false
  	else
  		self.pay_execution.allowed_urdu
  	end
  end

	def self.location_related_invoices(pay_invoice_list, location_id)
		pay_invoices = pay_invoice_list.where(:location_id => location_id)
		return pay_invoices
	end

	def self.branch_related_invoices(pay_invoice_list, branch_id)
		pay_invoices = pay_invoice_list.where(:branch_id => branch_id)
		return pay_invoices
	end

	def self.department_related_invoices(pay_invoice_list, department_id)
		pay_invoices = pay_invoice_list.where(:department_id => department_id)
		return pay_invoices
	end

	def self.sub_department_related_invoices(pay_invoice_list, sub_department_id)
		pay_invoice_list.where(sub_department_id: sub_department_id)
	end

	def self.designation_related_invoices(pay_invoice_list, designation_id)
		pay_invoices = pay_invoice_list.where(:designation_id => designation_id)
		return pay_invoices
	end

	def self.job_title_related_invoices(pay_invoice_list, job_title_id)
		pay_invoices = pay_invoice_list.where(:job_title_id => job_title_id)
		return pay_invoices
	end

	def self.grade_related_invoices(pay_invoice_list, grade_id)
		pay_invoices = pay_invoice_list.where(:grade_id => grade_id)
		return pay_invoices
	end

	def self.salary_unit_related_invoices(pay_invoice_list, salary_unit_id)
		pay_invoices = pay_invoice_list.where(:salary_unit_id => salary_unit_id)
		return pay_invoices
	end

	def self.cost_center_related_invoices(pay_invoice_list, cost_center_id)
		pay_invoices = pay_invoice_list.where(:cost_center_id => cost_center_id)
		return pay_invoices
	end

	def self.employee_type_related_invoices(pay_invoice_list, employee_type_id)
		pay_invoices = pay_invoice_list.where(:employee_type_id => employee_type_id)
		return pay_invoices
	end

	def self.payment_method_related_invoices(pay_invoice_list, payment_method)
		 pay_invoice_list.includes(:employee).where(employees: {payment_method: payment_method})
	end

	def self.exclude_employees(pay_invoice_list, exclude)
		 pay_invoice_list.includes(:employee).where(employees: {excluded_from_reports: exclude})
	end

	def self.on_roll_employees(pay_invoice_list, on_roll)
		pay_invoice_list.includes(:employee).where(employees: {is_active: on_roll})
	end

	def self.struck_off_employees(pay_invoice_list, struck_off)
		pay_invoice_list.includes(:employee).where(employees: {is_struck_off: struck_off})
	end

	def self.hiring_shifts(pay_invoice_list, hiring)
		pay_invoice_list.includes(:employee).where(employees: {hiring_shift_id: hiring})
	end

	def self.taxable_employees(pay_invoice)
		pay_invoice.where("monthly_tax > 0")
	end

	def self.non_taxable_employees(pay_invoice)
		pay_invoice.where("monthly_tax = 0")
	end

	def self.invoice_worked_days(pay_invoice)
		pay_invoice.no_of_pay_days - pay_invoice.deduction_days
	end

	def self.regenerate_slip(employee, pay_invoice, pay_execution)
		pay_invoice.status = false
		pay_invoice.save
		EmployeeTaxableIncome.where(:status => true, :pay_invoice_id => pay_invoice.id).each do |item|
			item.status = false
			item.save
		end
		if employee.joining_date.to_date <= pay_execution.end_date.to_date
			PayInvoice.generate_single_employee_invoice(employee, pay_execution)
		end
	end

	def self.generate_single_employee_invoice(employee, pay_execution)
		time = Time.now
		if PayInvoice.count == 0
      pay_invoice_count = 1
    else
      pay_invoice_count = PayInvoice.last.id + 1
    end
    invoice_number = "PaySlip-#{time.to_date.year.to_s[2..4].to_i}-%.9d" % pay_invoice_count
    fiscal_year = pay_execution.fiscal_year
    
    pay_invoice = PayInvoice.new
    pay_invoice.employee_id 					= employee.id
    pay_invoice.pay_month							= pay_execution.formated_pay_month
    pay_invoice.actual_pay_month			= pay_execution.end_date.to_date
		pay_invoice.pay_execution_id			= pay_execution.id
		pay_invoice.fiscal_year_id				= pay_execution.fiscal_year_id
		pay_invoice.provident_fund_id			= pay_execution.provident_fund_id
		pay_invoice.eobi_id								= pay_execution.eobi_id
		pay_invoice.tax_slab_id						= pay_execution.tax_slab_id
		pay_invoice.company_id						= employee.company_id
		pay_invoice.location_id						= employee.location_id
		pay_invoice.branch_id							= employee.branch_id
		pay_invoice.department_id 				= employee.department_id
		pay_invoice.sub_department_id 		= employee.sub_department_id
		pay_invoice.designation_id 				= employee.designation_id
		pay_invoice.job_title_id 					= employee.job_title_id
		pay_invoice.grade_id 							= employee.grade_id
		pay_invoice.salary_unit_id 				= employee.salary_unit_id
		pay_invoice.cost_center_id 				= employee.cost_center_id
		pay_invoice.employee_type_id 			= employee.employee_type_id
		pay_invoice.joining_date 					= employee.joining_date
		pay_invoice.customize_tax 				= employee.customize_tax
		pay_invoice.tax_criteria 					= employee.tax_criteria
		pay_invoice.fixed_tax_rate 				= employee.fixed_tax_rate
		pay_invoice.is_medical_allowance	= employee.is_medical_allowance
		pay_invoice.quota_encashment 			= LeaveAllocation.encashable_quota_non_probation(employee)
		if employee.confirmation_date.nil?
			pay_invoice.on_probation 					= true
			pay_invoice.confirmation_date 		= nil
		else
			if employee.confirmation_date.to_date > pay_execution.end_date.to_date
				pay_invoice.on_probation 					= true
				pay_invoice.confirmation_date 		= nil
			else
				pay_invoice.on_probation 					= employee.on_probation
				pay_invoice.confirmation_date 		= employee.confirmation_date
			end	
		end
		pay_invoice.invoice_number				= invoice_number

		###################################################################################
		#################### Restriction of Payroll base on Attendance ####################
		###################################################################################
		if pay_execution.attendance_cutoff_ids
			cutoff_start_date = AttendanceCutoff.find(pay_execution.attendance_cutoff_ids.split(',').map(&:to_i)).map{|a| a.start_date}.min
			cutoff_end_date = AttendanceCutoff.find(pay_execution.attendance_cutoff_ids.split(',').map(&:to_i)).map{|a| a.end_date}.min
			pay_invoice.encashable_quota			= FinalizeAttendance.where(:attendance_cutoff_id => pay_execution.attendance_cutoff_ids.split(',').map(&:to_i), :is_finalize => false, :employee_id => employee.id).sum(&:encashable_quota)
			pay_invoice.deduction_days				= FinalizeAttendance.where(:attendance_cutoff_id => pay_execution.attendance_cutoff_ids.split(',').map(&:to_i), :is_finalize => false, :employee_id => employee.id).sum(&:pay_deduction)
			employee_attendance_ids = FinalizeAttendance.where(:attendance_cutoff_id => pay_execution.attendance_cutoff_ids.split(',').map(&:to_i), :is_finalize => false, :employee_id => employee.id).pluck(:employee_attendance_id)
			if pay_invoice.joining_date > cutoff_start_date and ENV['APP_URL'].include?('millshrmsbe.dfl.com.pk')
				pay_invoice.deduction_days += TimeDifference.between(cutoff_start_date, pay_invoice.joining_date).in_days
				pay_invoice.deduction_days += EmployeeAttendance.find(employee_attendance_ids).pluck(:is_rest_day).count(true)
				total_pay_days = (Time.days_in_month(cutoff_start_date.month, cutoff_start_date.year) - cutoff_start_date.day + 1) + cutoff_end_date.day
				pay_invoice.deduction_days = pay_invoice.deduction_days - (total_pay_days - pay_execution.no_of_pay_days)
			end
			if mill_instance? and employee.is_struck_off
				present_count = EmployeeAttendance.where(id: employee_attendance_ids, attendance_status: ['Present', 'Late'], roster_exist: true).count + EmployeeAttendance.where(id: employee_attendance_ids, is_on_leave: true, is_leave_without_pay: false, roster_exist: true).count  + EmployeeAttendance.where(id: employee_attendance_ids, is_public_holiday: true, roster_exist: true, attendance_status: 'Public Holiday').count
				pay_invoice.deduction_days = 26 - present_count
				pay_invoice.deduction_days += FinalizeAttendance.where(:attendance_cutoff_id => pay_execution.attendance_cutoff_ids.split(',').map(&:to_i), :is_finalize => false, :employee_id => employee.id).sum(&:off_day_payment)
			end
			if cresset_instance?
				if pay_invoice.joining_date > cutoff_start_date
					pay_invoice.deduction_days += TimeDifference.between(cutoff_start_date, pay_invoice.joining_date).in_days
				end
				unless employee.is_active
					resign_date = employee.employee_transaction_histories.where(transaction_type: EmployeeTransactionHistory::TRANSACTION_TYPES[:eoe]).first.try(:transaction_date)
					if resign_date and resign_date >= cutoff_start_date.to_date and resign_date <= cutoff_end_date.to_date
						pay_invoice.deduction_days += TimeDifference.between(cutoff_end_date, resign_date).in_days
					end
				end
			end
			over_time_hours = 0
			if ENV['APP_URL'] && ENV['APP_URL'].include?('millshrmsbe.dfl.com.pk')
				FinalizeAttendance.where(:attendance_cutoff_id => pay_execution.attendance_cutoff_ids.split(',').map(&:to_i), :is_finalize => false, :employee_id => employee.id).each do |attendance|
					over_time_hours += attendance.over_time_hours <= OVERTIME_CHECK_VALUE ? attendance.over_time_hours : 0.0
				end
			else
				over_time_hours = FinalizeAttendance.where(:attendance_cutoff_id => pay_execution.attendance_cutoff_ids.split(',').map(&:to_i), :is_finalize => false, :employee_id => employee.id).sum(&:over_time_hours)
			end
			pay_invoice.over_time_hours				= over_time_hours
			pay_invoice.off_day_payment				= FinalizeAttendance.where(:attendance_cutoff_id => pay_execution.attendance_cutoff_ids.split(',').map(&:to_i), :is_finalize => false, :employee_id => employee.id).sum(&:off_day_payment)
			pay_invoice.arrears_days					= FinalizeAttendance.where(:attendance_cutoff_id => pay_execution.attendance_cutoff_ids.split(',').map(&:to_i), :is_finalize => false, :employee_id => employee.id).sum(&:arrear_days)
		end
		###################################################################################
		#################### Restriction of Payroll base on Attendance ####################
		###################################################################################
    # todo Need to disable this logic for sdl farm short joining days
		if not pay_invoice.joining_date.nil?
			start_time = Time.new(pay_invoice.joining_date.to_date.year,pay_invoice.joining_date.to_date.month, pay_invoice.joining_date.to_date.day)
			short_joining_days = ((TimeDifference.between(start_time, (pay_execution.end_date.to_date)).in_days) + 1)
			if pay_execution.allowed_extra_days == false
				if short_joining_days <= pay_execution.no_of_pay_days
					pay_invoice.short_joining_days = pay_execution.total_pay_days(employee).to_f - (short_joining_days - pay_execution.exclude_sunday_count(employee).to_f)
				elsif pay_execution.exclude_sunday == true
					if pay_execution.start_date.to_date < pay_invoice.joining_date.to_date and pay_execution.end_date.to_date > pay_invoice.joining_date.to_date
						pay_invoice.short_joining_days = pay_execution.total_pay_days(employee).to_f - (short_joining_days - pay_execution.exclude_sunday_count(employee).to_f)
					end
				end
			else
				pay_generate_date_range_days = ((TimeDifference.between(pay_execution.start_date.to_date, pay_execution.end_date.to_date).in_days) + 1)
				if short_joining_days <= pay_generate_date_range_days
					pay_invoice.short_joining_days = pay_generate_date_range_days.to_f - (short_joining_days - pay_execution.exclude_sunday_count(employee).to_f)
				end
			end
			
			no_of_days_till_joining = TimeDifference.between(pay_execution.start_date.beginning_of_year.to_date, pay_execution.end_date.end_of_year.to_date).in_days + 1
			if short_joining_days <= no_of_days_till_joining
				pay_invoice.no_of_days_till_joining = pay_execution.total_pay_days(employee).to_f - (short_joining_days - pay_execution.exclude_sunday_count(employee).to_f)
			else
				pay_invoice.no_of_days_till_joining = 365
			end 
			
			eobi_short_joining_days = ((TimeDifference.between(start_time, (pay_execution.end_date.end_of_month.to_date)).in_days) + 1)
			if eobi_short_joining_days < pay_execution.end_date.end_of_month.to_date.day
				pay_invoice.eobi_short_joining_days = pay_execution.end_date.end_of_month.to_date.day.to_f - eobi_short_joining_days
			end
			eobi_no_of_days_till_joining = TimeDifference.between(pay_execution.start_date.beginning_of_year.to_date, pay_execution.end_date.end_of_year.to_date).in_days + 1
			if eobi_short_joining_days <= eobi_no_of_days_till_joining
				pay_invoice.eobi_no_of_days_till_joining = pay_execution.total_pay_days(employee).to_f - eobi_short_joining_days
			else
				pay_invoice.eobi_no_of_days_till_joining = 365
			end 
		end
		
		if pay_invoice.on_probation == false
			if not pay_invoice.confirmation_date.nil?
				start_time = Time.new(pay_invoice.confirmation_date.to_date.year,pay_invoice.confirmation_date.to_date.month, pay_invoice.confirmation_date.to_date.day)
				no_of_days_till_confirmation = ((TimeDifference.between(start_time, (pay_execution.end_date.to_date)).in_days) + 1)
				if no_of_days_till_confirmation < pay_execution.total_pay_days(employee)
					pay_invoice.short_confirmation_days = no_of_days_till_confirmation
				end
			end
		end
		
		if employee.velicle_allowed == true
			if not employee.vehicle_assignment_date.nil?
				if pay_execution.vehicle_monthly_prorated == false
					start_time = Time.new(employee.vehicle_assignment_date.to_date.year,employee.vehicle_assignment_date.to_date.month, employee.vehicle_assignment_date.to_date.day)
			    pay_invoice.vehicle_months = (TimeDifference.between(start_time, fiscal_year.end_date).in_months)
			    if pay_invoice.vehicle_months > 12
			      pay_invoice.vehicle_months = 12
			    end
			  else
			  	start_time = Time.new(employee.vehicle_assignment_date.to_date.year,employee.vehicle_assignment_date.to_date.month, (employee.vehicle_assignment_date.to_date).beginning_of_month.day)
			    pay_invoice.vehicle_months = (TimeDifference.between(start_time, fiscal_year.end_date).in_months)
			    if pay_invoice.vehicle_months > 12
			      pay_invoice.vehicle_months = 12
			    end
				end
			end
		end
		
		if not pay_invoice.confirmation_date.nil?
			pf_start_time = Time.new(pay_invoice.confirmation_date.to_date.year,pay_invoice.confirmation_date.to_date.month, pay_invoice.confirmation_date.to_date.day)
	    pf_end_time = Time.new(fiscal_year.end_date.to_date.year,fiscal_year.end_date.to_date.month, fiscal_year.end_date.to_date.day)
	    pay_invoice.total_pf_months = (TimeDifference.between(pf_start_time, pf_end_time).in_months)
	    if pay_invoice.total_pf_months > 12
	      pay_invoice.total_pf_months = 12
	    end
	  end
	  
	  if pay_execution.end_date.to_date.end_of_month.to_date == fiscal_year.end_date.to_date.end_of_month.to_date
	  	remaining_tax_year_month = 0
	  else
    	remaining_tax_year_month = (TimeDifference.between((pay_execution.end_date.to_date + 1.month).beginning_of_month.to_date, fiscal_year.end_date.to_date.end_of_month.to_date).in_months)
    end

    if pay_execution.allowed_extra_days == true
    	pay_invoice.allowed_extra_days = true
    	pay_invoice.extra_pay_days = (TimeDifference.between(pay_execution.start_date.to_date, pay_execution.start_date.to_date.end_of_month.to_date).in_days) + 1
    else
    	pay_invoice.allowed_extra_days = false
    	pay_invoice.extra_pay_days = 0.0
    end
    
    pay_invoice.remaining_tax_year_month 	= remaining_tax_year_month.round
    if pay_execution.allowed_extra_days == false
    	pay_invoice.payable_gross 						= ((employee.gross_salary.to_f/pay_execution.total_pay_days(employee).to_f)*((pay_execution.total_pay_days(employee).to_f - pay_invoice.short_joining_days.to_f) - pay_invoice.deduction_days.to_f))
    else
    	pay_invoice.payable_gross 						= ((employee.gross_salary.to_f/pay_execution.total_pay_days(employee).to_f)*(((pay_execution.total_pay_days(employee).to_f + pay_invoice.extra_pay_days) - pay_invoice.short_joining_days.to_f) - pay_invoice.deduction_days.to_f))
    end
		pay_invoice.save
		pay_invoice.update(actual_salary: Employee.effective_gross_salary(employee, pay_invoice).to_f)
		pay_invoice.calculate_pay_item(pay_invoice)

		if not pay_invoice.confirmation_date.nil?
			if pay_invoice.arrears_days > 0 and employee.back_date_pf_impact == false
				if pay_invoice.short_confirmation_days == 0
					pay_invoice.arrear_on_provident_fund(pay_invoice, employee, pay_execution)
				end
			end
		end

		if pay_execution.opd_impact_on_arrear == true
    	pay_invoice.calculate_medical_allowance_on_arrear(pay_invoice, employee)
    end

    pay_invoice.back_date_provident_fund(pay_invoice, employee, pay_execution)
    pay_invoice.back_date_eobi(pay_invoice, employee, pay_execution)

		total_deduction 	= PayInvoiceDetail.where(:pay_invoice_id => pay_invoice.id, :item_type => "Deduction").sum(:amount)
    total_earning 		= PayInvoiceDetail.where(:pay_invoice_id => pay_invoice.id, :item_type => "Earning").sum(:amount)
    pay_invoice.total_deduction 	= total_deduction - PayInvoiceDetail.where(:pay_invoice_id => pay_invoice.id, :item_name => "Attendance Deduction").sum(:amount)
    pay_invoice.total_earning 		= total_earning
    pay_invoice.save
    pay_invoice.calculate_employee_taxable_income(pay_invoice, pay_execution, employee)
	end

	def calculate_pay_item(pay_invoice)
		pay_execution = pay_invoice.pay_execution
		if pay_invoice.employee.employee_type_name == "Contractual"
			pay_execution.item_execution_details.where(:status => "Allowed").order('pay_item_id ASC').each do |item_detail|
				pay_item = PayItem.find(item_detail.pay_item_id)
				if pay_item.name == "Medical Allowance (OPD)"
					if ENV.fetch("APP_URL").include?('dtlbe.srl.com.pk')
						if [15,16,17,18,19,21,22,23].include?employee.grade_id
							item_value = pay_invoice.employee.gross_salary * 0.02
						elsif [4,5,6,7,8,9,10,11,12,13,14].include?employee.grade.id
							item_value = (pay_invoice.employee.gross_salary * 0.67) * 0.02
						end
						taxable_amount = 0
					else
						item_value = 0
						taxable_amount = 0
					end
					PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => item_value, :pay_invoice_id => pay_invoice.id, :taxable_amount => taxable_amount, :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
				else
					item_value = PayItem.calculate_formula(pay_invoice.employee, pay_item, pay_invoice)
					taxable_amount = PayItem.calculate_item_tax(pay_item, item_value)
					PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => item_value, :pay_invoice_id => pay_invoice.id, :taxable_amount => taxable_amount, :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
				end
			end
		else
			pay_execution.item_execution_details.where(:status => "Allowed").order('pay_item_id ASC').each do |item_detail|
				pay_item = PayItem.find(item_detail.pay_item_id)
				if pay_item.name == "Medical Allowance (OPD)" && pay_invoice.is_medical_allowance == true
					item_value = 0
					taxable_amount = 0
					PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => item_value, :pay_invoice_id => pay_invoice.id, :taxable_amount => taxable_amount, :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
				elsif pay_item.name == "Annual Bonus"
					item_value = PayItem.calculate_formula(pay_invoice.employee, pay_item, pay_invoice)
					taxable_amount = PayItem.calculate_item_tax(pay_item, item_value)
					PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => item_value, :pay_invoice_id => pay_invoice.id, :taxable_amount => taxable_amount, :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
				elsif pay_item.name == "Salary Arrears"
					pay_item = PayItem.find(item_detail.pay_item_id)
					item_value = PayItem.calculate_formula(pay_invoice.employee, pay_item, pay_invoice)
					taxable_amount = PayItem.calculate_item_tax(pay_item, item_value)
					non_taxable_amount = 0
					if item_value > 0
						non_taxable_amount = ((((item_value.to_f/100.0)*67)/100.0)*8)	
					end
					taxable_amount = taxable_amount - non_taxable_amount
					PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => item_value, :pay_invoice_id => pay_invoice.id, :taxable_amount => taxable_amount, :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
				else
					pay_item = PayItem.find(item_detail.pay_item_id)
					# if pay_item.name == "Provident Fund"
					# 	binding.pry
					# end
					item_value = PayItem.calculate_formula(pay_invoice.employee, pay_item, pay_invoice)
					taxable_amount = PayItem.calculate_item_tax(pay_item, item_value)
					PayInvoiceDetail.create(:item_id => pay_item.id, :item_type => pay_item.item_type, :amount => item_value, :pay_invoice_id => pay_invoice.id, :taxable_amount => taxable_amount, :item_name => pay_item.name, :show_in_slip => pay_item.show_in_slip, :part_of_other => pay_item.part_of_other, :part_of_gross_salary => pay_item.part_of_gross_salary, :sort_order => pay_item.sort_order)
				end
			end
		end
	end

	def calculate_employee_taxable_income(pay_invoice, pay_execution, employee)
		prev_vehicle_tax 					= EmployeeTaxableIncome.where(:status => true, :fiscal_year_id => pay_invoice.fiscal_year_id, :employee_id => pay_invoice.employee_id).sum(:current_month_vehicle_tax)
		current_month_vehicle_tax = 0
		predicted_vehicle_tax 		= 0
		if pay_execution.vehicle_impact_on_tax == true
  		if pay_execution.vehicle_tax_percentage > 0
				current_month_vehicle_tax = pay_invoice.calculate_vehicle_monthly_tax_value(pay_invoice, employee, pay_execution)
				predicted_vehicle_tax 		= pay_invoice.predicted_calculate_vehicle_tax_value(pay_invoice, employee, pay_execution)
			end
		end

		employeer_pf_value 		= pay_invoice.calculate_employyer_provident_fund(pay_invoice, employee, pay_execution)
		pf_tax_value 					= pay_invoice.calculate_predicted_employyer_provident_fund(pay_invoice, employee, pay_execution, "PF TAX")
		predicted_pf_value 		= pay_invoice.calculate_predicted_employyer_provident_fund(pay_invoice, employee, pay_execution, "Predicted PF")

		employeer_eobi_value 	= employyer_eobi_contribution(pay_invoice, employee, pay_execution)

		transaction_month 				= (pay_execution.start_date.to_date.beginning_of_month).to_date.strftime("%B %Y")
		
		if pay_execution.vehicle_monthly_prorated == true
			current_taxable_amount 		= PayInvoiceDetail.where(:pay_invoice_id => pay_invoice.id).sum(:taxable_amount) - pay_invoice.pay_invoice_details.where(:item_name => ["LWP", "Attendance Deduction", "Salary Deduction", "Allowance Deduction"]).sum(:amount).round
		else
			current_taxable_amount= PayInvoiceDetail.where(:pay_invoice_id => pay_invoice.id).sum(:taxable_amount)
		end

    if EmployeeTaxableIncome.where(:status => true, :fiscal_year_id => pay_invoice.fiscal_year_id, :employee_id => pay_invoice.employee_id).last.nil?
    	prev_taxable_amount = 0
    else
    	prev_taxable_amount = EmployeeTaxableIncome.where(:status => true, :fiscal_year_id => pay_invoice.fiscal_year_id, :employee_id => pay_invoice.employee_id).last.taxable_amount_to_date
    end
    
    if pay_execution.vehicle_monthly_prorated == true
    	medical_exempted = ((((pay_invoice.actual_salary/100.0)*67.0)/100.0)*8.0).round
			actual_salary = pay_invoice.actual_salary - medical_exempted
    	predicated_taxable_amount = actual_salary * pay_invoice.remaining_tax_year_month
    else
    	predicated_taxable_amount = pay_invoice.actual_salary * pay_invoice.remaining_tax_year_month
    end
    taxable_amount_to_date 		= current_taxable_amount + prev_taxable_amount
    prev_incentive_amount 		= EmployeeTaxableIncome.where(:status => true, :fiscal_year_id => pay_invoice.fiscal_year_id, :employee_id => pay_invoice.employee_id).sum(:current_incentive_amount)
    total_paid_tax 						= EmployeeTaxableIncome.where(:status => true, :employee_id => pay_invoice.employee_id, :fiscal_year_id => pay_invoice.fiscal_year_id).sum(:monthly_tax_amount)

    # if pay_invoice.employee.employee_code == "771656"
    # 	taxable_amount_to_date = taxable_amount_to_date - 26800.0
    # end

    #####################################################################################################################
		############################################# Annualize Pay Item Amount #############################################
		#####################################################################################################################
		
		annualize_predicated_taxable_amount = 0
		all_pay_item_ids = pay_execution.item_execution_details.where(:status => "Allowed").collect(&:pay_item_id)
		annualize_pay_items = PayItem.where(:id => all_pay_item_ids, :is_active => true, :annualize => true, :is_taxable => true)
		annualize_pay_item_ids = annualize_pay_items.collect(&:id)
		monthly_annualize_item_amount = PayInvoiceDetail.where(:item_id => annualize_pay_item_ids, :pay_invoice_id => pay_invoice.id).sum(:taxable_amount)
		annualize_predicated_taxable_amount = (monthly_annualize_item_amount * pay_invoice.remaining_tax_year_month).to_f

		#####################################################################################################################
		############################################# Annualize Pay Item Amount #############################################
		#####################################################################################################################
		
    employee_taxable_income = EmployeeTaxableIncome.new(:company_id => pay_invoice.company_id, :employee_id => pay_invoice.employee_id, :pay_invoice_id => pay_invoice.id, :fiscal_year_id => pay_invoice.fiscal_year_id, :pay_execution_id => pay_execution.id)
    employee_taxable_income.loan_interest_amount 				= EmployeeLoan.employee_loan_tax_amount_yearly(employee, pay_execution.fiscal_year)
		employee_taxable_income.current_taxable_amount 			= current_taxable_amount
		employee_taxable_income.prev_taxable_amount 				= prev_taxable_amount
		employee_taxable_income.predicated_taxable_amount 	= predicated_taxable_amount
		employee_taxable_income.taxable_amount_to_date 			= taxable_amount_to_date
		employee_taxable_income.prev_incentive_amount     	= prev_incentive_amount
		employee_taxable_income.gross_salary 								= pay_invoice.actual_salary
		employee_taxable_income.prev_vehicle_tax 						= prev_vehicle_tax
		employee_taxable_income.current_month_vehicle_tax 	= current_month_vehicle_tax
		employee_taxable_income.predicted_vehicle_tax 			= predicted_vehicle_tax
		employee_taxable_income.employeer_pf_value 					= employeer_pf_value
		employee_taxable_income.pf_tax_value 								= pf_tax_value
		employee_taxable_income.predicted_pf_value 					= predicted_pf_value
		employee_taxable_income.employeer_eobi_value 				= employeer_eobi_value
		employee_taxable_income.annualize_predicated_taxable_amount = annualize_predicated_taxable_amount

    # if pay_execution.incentive_impact_on_tax == true
    # 	incentive_amount = EmployeeSaleIncentive.where(:employee_id => pay_invoice.employee_id, :incentive_date => pay_execution.incentive_month.to_date).sum(:incentive_amount)
    #  	employee_taxable_income.current_incentive_amount = incentive_amount
    # else
    #   employee_taxable_income.current_incentive_amount = 0
    # end

    if pay_execution.incentive_impact_on_tax == true
	  	sale_incentive_data = SmarterCSV.process("#{Rails.public_path}/srl_data/feb_store_incentive.csv")
			sale_incentive_data.each_with_index do |sale_incentive,index|
				if employee.employee_code.to_s == sale_incentive[:employee_code].to_s
					employee_taxable_income.current_incentive_amount = sale_incentive[:amount].to_f
				end
			end
		end
	    
    if pay_execution.prediction_tax_impact == true
			predition_amount 				= 0
			predition_item_ids 			= []
			predition_item_names 		= []
			predition_item_amounts 	= []
			PayItem.where(:is_active => true, :prediction_tax_impact => true).order('id ASC').each do |single_item|
				if single_item.name == "Eid Reward 1" and pay_invoice.employee.bonus1_allowed == true
					item_value 							= PayItem.prediction_calculate_formula(employee, single_item, pay_invoice)
					predition_item_amounts 	<< item_value.to_f
					predition_item_ids 			<< single_item.id
					predition_item_names 		<< single_item.name
					predition_amount 				= predition_amount + item_value.round
				end
				if single_item.name == "Eid Reward 2" and pay_invoice.employee.bonus2_allowed == true
					item_value 							= PayItem.prediction_calculate_formula(employee, single_item, pay_invoice)
					predition_item_amounts 	<< item_value.to_f
					predition_item_ids 			<< single_item.id
					predition_item_names 		<< single_item.name
					predition_amount 				= predition_amount + item_value.round
				end
				if single_item.name == "Annual Bonus" and pay_invoice.employee.bonus3_allowed == true
					item_value 							= PayItem.prediction_calculate_formula(employee, single_item, pay_invoice)
					predition_item_amounts 	<< item_value.to_f
					predition_item_ids 			<< single_item.id
					predition_item_names 		<< single_item.name
					predition_amount 				= predition_amount + item_value.round
				end
				if single_item.name == "Leave Encashment"
					item_value 							= PayItem.prediction_calculate_formula(employee, single_item, pay_invoice)
					predition_item_amounts 	<< item_value.to_f
					predition_item_ids 			<< single_item.id
					predition_item_names 		<< single_item.name
					predition_amount 				= predition_amount + item_value.round
				end
			end
    	employee_taxable_income.encashable_quota 				= LeaveAllocation.encashable_quota(employee)
    	employee_taxable_income.predition_amount 				= predition_amount
    	employee_taxable_income.predition_item_amounts	= predition_item_amounts.join(',')
    	employee_taxable_income.predition_item_ids			= predition_item_ids.join(',')
    	employee_taxable_income.predition_item_names		= predition_item_names.join(',')
		end
		employee_taxable_income.total_taxable_amount = (employee_taxable_income.taxable_amount_to_date + employee_taxable_income.predicated_taxable_amount + employee_taxable_income.loan_interest_amount + employee_taxable_income.prev_incentive_amount + employee_taxable_income.current_incentive_amount + employee_taxable_income.predition_amount + employee_taxable_income.prev_vehicle_tax + employee_taxable_income.current_month_vehicle_tax + employee_taxable_income.predicted_vehicle_tax + employee_taxable_income.pf_tax_value + employee_taxable_income.annualize_predicated_taxable_amount)
		employee_taxable_income.total_taxable_amount = employee_taxable_income.total_taxable_amount - (PayInvoiceDetail.where(:pay_invoice_id => pay_invoice.id).where(item_name: 'Medical').sum(:taxable_amount) * 12)
    employee_taxable_income.save
    
    if employee.tax_exempted == false
    	if pay_invoice.customize_tax == false
    		###############################################################
    		###################### Normal Tax Working #####################
    		###############################################################
    		tax_credit_amount = EmployeeTaxCredit.where(:employee_id => pay_invoice.employee_id, :fiscal_year_id => pay_invoice.fiscal_year_id).sum(:tax_credit_amount)
	    	yearly_salary 		= employee_taxable_income.total_taxable_amount
	      tax_slab_details 	= pay_execution.tax_slab.tax_slab_details
	    	fixed_amount 			= tax_slab_details.where("lower_limit <= ? AND upper_limit >= ?", yearly_salary, yearly_salary).sum(:fixed_amount)
	    	tax_percentage 		= tax_slab_details.where("lower_limit <= ? AND upper_limit >= ?", yearly_salary, yearly_salary).sum(:tax_percentage)
	    	lower_limit 			= tax_slab_details.where("lower_limit <= ? AND upper_limit >= ?", yearly_salary, yearly_salary).sum(:lower_limit)

	      yearly_fixed_tax = fixed_amount
	      yearly_variable_pay_amount = yearly_salary - lower_limit
	      yearly_variable_tax = 0
	      if tax_percentage > 0
	        yearly_variable_tax = (tax_percentage * yearly_variable_pay_amount).to_f / 100.0 
	      end
	      yearly_total_tax = yearly_variable_tax + yearly_fixed_tax
	      remaing_tax_to_be_paid = yearly_total_tax - total_paid_tax
	      remaing_tax_to_be_paid = remaing_tax_to_be_paid - tax_credit_amount
	      monthly_tax = (remaing_tax_to_be_paid.to_f/(pay_invoice.remaining_tax_year_month + 1))
	      employee_taxable_income.yearly_total_tax 				= yearly_total_tax
	      if monthly_tax < 0
	      	employee_taxable_income.monthly_tax_amount 			= 0
	      	employee_taxable_income.total_paid_tax					= 0
					employee_taxable_income.remaing_tax_to_be_paid	= 0
	      else	
	      	employee_taxable_income.monthly_tax_amount 			= monthly_tax.to_f.round
	      	employee_taxable_income.total_paid_tax 					= total_paid_tax
	      	employee_taxable_income.remaing_tax_to_be_paid 	= remaing_tax_to_be_paid
	      end
		    tax_adjustment_amount = EmployeeTaxAdjustment.where(:employee_id => pay_invoice.employee_id, :tax_adjustment_formatted_month => pay_invoice.pay_month, is_active: true).sum(:amount)
		    if tax_adjustment_amount.to_f > 0
		    	employee_taxable_income.monthly_tax_amount = tax_adjustment_amount
		    end
		    
	      pay_invoice.monthly_tax = employee_taxable_income.monthly_tax_amount	
	      employee_taxable_income.save
	      pay_invoice.save
	      ###############################################################
	      ###################### Normal Tax Working #####################
	      ###############################################################
	    else
	    	###############################################################
	    	#################### Customize Tax Working ####################
	    	###############################################################
	    	if pay_invoice.tax_criteria == "Fixed Tax"
	    		###############################################################
	    		###################### Fixed Tax Working ######################
	    		###############################################################
	    		tax_credit_amount = EmployeeTaxCredit.where(:employee_id => pay_invoice.employee_id, :fiscal_year_id => pay_invoice.fiscal_year_id).sum(:tax_credit_amount)
		    	yearly_salary 		= employee_taxable_income.total_taxable_amount
		      tax_slab_details 	= pay_execution.tax_slab.tax_slab_details
		    	fixed_amount 			= tax_slab_details.where("lower_limit <= ? AND upper_limit >= ?", yearly_salary, yearly_salary).sum(:fixed_amount)
		    	tax_percentage 		= tax_slab_details.where("lower_limit <= ? AND upper_limit >= ?", yearly_salary, yearly_salary).sum(:tax_percentage)
		    	lower_limit 			= tax_slab_details.where("lower_limit <= ? AND upper_limit >= ?", yearly_salary, yearly_salary).sum(:lower_limit)

		      yearly_fixed_tax = fixed_amount
		      yearly_variable_pay_amount = yearly_salary - lower_limit
		      yearly_variable_tax = 0
		      if tax_percentage > 0
		        yearly_variable_tax = (tax_percentage * yearly_variable_pay_amount).to_f / 100.0 
		      end
		      yearly_total_tax = yearly_variable_tax + yearly_fixed_tax
		      if yearly_variable_tax > pay_invoice.fixed_tax_rate
		      	yearly_variable_tax = pay_invoice.fixed_tax_rate
		      end
		      remaing_tax_to_be_paid = yearly_total_tax - total_paid_tax
		      remaing_tax_to_be_paid = remaing_tax_to_be_paid - tax_credit_amount
		      monthly_tax = (remaing_tax_to_be_paid.to_f/(pay_invoice.remaining_tax_year_month + 1))
		      employee_taxable_income.yearly_total_tax 				= yearly_total_tax
		      if monthly_tax < 0
		      	employee_taxable_income.monthly_tax_amount 			= 0
		      	employee_taxable_income.total_paid_tax					= 0
						employee_taxable_income.remaing_tax_to_be_paid	= 0
		      else	
		      	employee_taxable_income.monthly_tax_amount 			= monthly_tax
		      	employee_taxable_income.total_paid_tax 					= total_paid_tax
		      	employee_taxable_income.remaing_tax_to_be_paid 	= remaing_tax_to_be_paid
		      end
		      employee_taxable_income.save
		      pay_invoice.monthly_tax 													= employee_taxable_income.monthly_tax_amount
		      pay_invoice.save
	    		###############################################################
	    		###################### Fixed Tax Working ######################
	    		###############################################################
	    	elsif pay_invoice.tax_criteria == "Custom Tax Slab"
	    		###############################################################
	    		##################### Custom Tax Working ######################
	    		###############################################################
	    		remaining_tax_amount = true
	    		yearly_salary = employee_taxable_income.total_taxable_amount
					employer_yearly_contribution = yearly_salary
					employer_tax_differences = []
					yearly_fixed_tax_amount = 0
					old_tax_diff = 0
					temp_total_taxable_amount = yearly_salary
					monthly_taxable_amount = 0
					yearly_total_tax = 0
					total_paid_tax = 0
					remaing_tax_to_be_paid = 0

					employee_monthly_fixed_tax_amount = 0
					employee_yearly_fixed_tax_amount 	= 0

					custom_tax_slab = CustomTaxSlab.find_by(:is_active => true)
					if not custom_tax_slab.nil?
						custom_tax_slab_details = custom_tax_slab.custom_tax_slab_details
						employee_monthly_fixed_tax_amount = custom_tax_slab_details.where("lower_limit <= ? AND upper_limit >= ?", pay_invoice.actual_salary, pay_invoice.actual_salary).sum(:fixed_amount)
						employee_yearly_fixed_tax_amount = employee_monthly_fixed_tax_amount * 12
					else
						employee_monthly_fixed_tax_amount = 0
						employee_yearly_fixed_tax_amount 	= 0
					end

					tax_credit_amount = EmployeeTaxCredit.where(:employee_id => pay_invoice.employee_id, :fiscal_year_id => pay_invoice.fiscal_year_id).sum(:tax_credit_amount)    
					tax_slab_details 	= pay_execution.tax_slab.tax_slab_details
					fixed_amount 			= tax_slab_details.where("lower_limit <= ? AND upper_limit >= ?", yearly_salary, yearly_salary).sum(:fixed_amount)
					tax_percentage 		= tax_slab_details.where("lower_limit <= ? AND upper_limit >= ?", yearly_salary, yearly_salary).sum(:tax_percentage)
					lower_limit 			= tax_slab_details.where("lower_limit <= ? AND upper_limit >= ?", yearly_salary, yearly_salary).sum(:lower_limit)
					
					yearly_fixed_tax = fixed_amount
		      yearly_variable_pay_amount = yearly_salary - lower_limit
		      yearly_variable_tax = 0
		      if tax_percentage > 0
		        yearly_variable_tax = (tax_percentage * yearly_variable_pay_amount).to_f / 100.0 
		      end
		      yearly_total_tax = yearly_variable_tax + yearly_fixed_tax
		      remaing_tax_to_be_paid = yearly_total_tax - total_paid_tax
		      remaing_tax_to_be_paid = remaing_tax_to_be_paid - tax_credit_amount
		      monthly_tax = (remaing_tax_to_be_paid.to_f/(pay_invoice.remaining_tax_year_month + 1))
		      
		      if monthly_tax < employee_monthly_fixed_tax_amount
		      	employee_taxable_income.yearly_total_tax 				= yearly_total_tax
			      if monthly_tax < 0
			      	employee_taxable_income.monthly_tax_amount 			= 0
			      	employee_taxable_income.total_paid_tax					= 0
							employee_taxable_income.remaing_tax_to_be_paid	= 0
			      else	
			      	employee_taxable_income.monthly_tax_amount 			= monthly_tax
			      	employee_taxable_income.total_paid_tax 					= total_paid_tax
			      	employee_taxable_income.remaing_tax_to_be_paid 	= remaing_tax_to_be_paid
			      end
			      employee_taxable_income.save
			      pay_invoice.monthly_tax 													= employee_taxable_income.monthly_tax_amount
			      pay_invoice.save
		      else
						while remaining_tax_amount == true
							tax_credit_amount = EmployeeTaxCredit.where(:employee_id => pay_invoice.employee_id, :fiscal_year_id => pay_invoice.fiscal_year_id).sum(:tax_credit_amount)    
							tax_slab_details 	= pay_execution.tax_slab.tax_slab_details
							fixed_amount 			= tax_slab_details.where("lower_limit <= ? AND upper_limit >= ?", yearly_salary, yearly_salary).sum(:fixed_amount)
							tax_percentage 		= tax_slab_details.where("lower_limit <= ? AND upper_limit >= ?", yearly_salary, yearly_salary).sum(:tax_percentage)
							lower_limit 			= tax_slab_details.where("lower_limit <= ? AND upper_limit >= ?", yearly_salary, yearly_salary).sum(:lower_limit)

							yearly_fixed_tax = fixed_amount
							yearly_variable_pay_amount = yearly_salary - lower_limit
							yearly_variable_tax = 0
							if tax_percentage > 0
							  yearly_variable_tax = (tax_percentage * yearly_variable_pay_amount).to_f / 100.0 
							end

							yearly_total_tax = yearly_variable_tax + yearly_fixed_tax
							remaing_tax_to_be_paid = yearly_total_tax - total_paid_tax
							remaing_tax_to_be_paid = remaing_tax_to_be_paid - tax_credit_amount
							monthly_tax = (remaing_tax_to_be_paid.to_f/(pay_invoice.remaining_tax_year_month + 1))

							yearly_fixed_tax_amount = employee_yearly_fixed_tax_amount
						  tax_diff = (yearly_total_tax - employee_yearly_fixed_tax_amount).to_f.round
						  puts "\n tax_diff => #{tax_diff} \n"
						  tax_diff = (tax_diff - old_tax_diff).to_f.round
						  puts "\n old_tax_diff => #{old_tax_diff} \n"
						  puts "\n new_tax_diff => #{tax_diff} \n"
						  old_tax_diff = (yearly_total_tax - employee_yearly_fixed_tax_amount).to_f.round
						  employer_yearly_contribution = (employer_yearly_contribution + tax_diff).to_f.round
						  puts "\n employer_yearly_contribution => #{employer_yearly_contribution} \n"
						  employer_tax_differences << tax_diff
						  if tax_diff.to_f.round > 0
						    temp_total_taxable_amount = temp_total_taxable_amount + tax_diff
						    yearly_salary = temp_total_taxable_amount
						  else
						    remaining_tax_amount = false
						  end

						  yearly_total_tax = yearly_total_tax
						  monthly_taxable_amount = employee_monthly_fixed_tax_amount
						  total_paid_tax = total_paid_tax
						  remaing_tax_to_be_paid = remaing_tax_to_be_paid
						end

						employee_taxable_income.yearly_total_tax = yearly_total_tax
						if monthly_taxable_amount < 0
							employee_taxable_income.monthly_tax_amount 			= 0
							employee_taxable_income.total_paid_tax					= 0
							employee_taxable_income.remaing_tax_to_be_paid	= 0
						else	
							employee_taxable_income.monthly_tax_amount 			= monthly_taxable_amount
							employee_taxable_income.total_paid_tax 					= total_paid_tax
							employee_taxable_income.remaing_tax_to_be_paid 	= remaing_tax_to_be_paid
						end
						employee_taxable_income.save
						pay_invoice.monthly_tax = employee_taxable_income.monthly_tax_amount
						pay_invoice.save

						employer_contribution_before_tax_on_tax = employer_tax_differences.first
						tax_on_tax = 0
						employer_tax_differences.each do |single_value|
						  tax_on_tax = tax_on_tax + single_value
						end
						tax_on_tax = tax_on_tax - employer_contribution_before_tax_on_tax
						total_tax_on_tax = tax_on_tax + employer_contribution_before_tax_on_tax

						employee_taxable_income.employer_yearly_contribution = employer_yearly_contribution
						employee_taxable_income.employer_contribution_before_tax_on_tax = employer_contribution_before_tax_on_tax
						employee_taxable_income.tax_on_tax = tax_on_tax
						employee_taxable_income.total_tax_on_tax = total_tax_on_tax
						employee_taxable_income.save
					end
	    		###############################################################
	    		##################### Custom Tax Working ######################
	    		###############################################################
	    	else
	    		###############################################################
	    		###################### Normal Tax Working #####################
	    		###############################################################
	    		tax_credit_amount = EmployeeTaxCredit.where(:employee_id => pay_invoice.employee_id, :fiscal_year_id => pay_invoice.fiscal_year_id).sum(:tax_credit_amount)    
		    	yearly_salary 		= employee_taxable_income.total_taxable_amount
		      tax_slab_details 	= pay_execution.tax_slab.tax_slab_details
		    	fixed_amount 			= tax_slab_details.where("lower_limit <= ? AND upper_limit >= ?", yearly_salary, yearly_salary).sum(:fixed_amount)
		    	tax_percentage 		= tax_slab_details.where("lower_limit <= ? AND upper_limit >= ?", yearly_salary, yearly_salary).sum(:tax_percentage)
		    	lower_limit 			= tax_slab_details.where("lower_limit <= ? AND upper_limit >= ?", yearly_salary, yearly_salary).sum(:lower_limit)

		      yearly_fixed_tax = fixed_amount
		      yearly_variable_pay_amount = yearly_salary - lower_limit
		      yearly_variable_tax = 0
		      if tax_percentage > 0
		        yearly_variable_tax = (tax_percentage * yearly_variable_pay_amount).to_f / 100.0 
		      end
		      yearly_total_tax = yearly_variable_tax + yearly_fixed_tax
		      remaing_tax_to_be_paid = yearly_total_tax - total_paid_tax
		      remaing_tax_to_be_paid = remaing_tax_to_be_paid - tax_credit_amount
		      monthly_tax = (remaing_tax_to_be_paid.to_f/(pay_invoice.remaining_tax_year_month + 1))
		      employee_taxable_income.yearly_total_tax 				= yearly_total_tax
		      if monthly_tax < 0
		      	employee_taxable_income.monthly_tax_amount 			= 0
		      	employee_taxable_income.total_paid_tax					= 0
						employee_taxable_income.remaing_tax_to_be_paid	= 0
		      else	
		      	employee_taxable_income.monthly_tax_amount 			= monthly_tax.to_f.round
		      	employee_taxable_income.total_paid_tax 					= total_paid_tax
		      	employee_taxable_income.remaing_tax_to_be_paid 	= remaing_tax_to_be_paid
		      end
		      employee_taxable_income.save
		      pay_invoice.monthly_tax 													= employee_taxable_income.monthly_tax_amount
		      pay_invoice.save
		      ###############################################################
		      ###################### Normal Tax Working #####################
		      ###############################################################
	    	end
	    	###############################################################
	    	#################### Customize Tax Working ####################
	    	###############################################################
    	end
    end
  end

  def calculate_medical_allowance_on_arrear(pay_invoice, employee)
  	medical_allowance_amount 	= 0
  	employee_per_day_salary 	= 0
  	per_day_medical_allowance = 0
    arrears_medical_allowance = 0

    last_month = (pay_invoice.actual_pay_month - 1.month).to_date.strftime("%B %Y")
		old_pay_execution = PayExecution.last_pay_execution(last_month, pay_invoice.company_id, pay_invoice.location_id, pay_invoice.grade_id)
    if old_pay_execution.nil?
      arrears_month 						= pay_invoice.pay_execution.total_pay_days(employee)
      medical_allowance_amount 	= ((((pay_invoice.actual_salary.to_f / 100.0) * 67.0).to_f/100.0)*2)
      employee_per_day_salary 	= (pay_invoice.actual_salary/arrears_month.to_f)
    else  
      arrears_month 						= old_pay_execution.total_pay_days(employee)
      medical_allowance_amount 	= ((((pay_invoice.actual_salary.to_f / 100.0) * 67.0).to_f/100.0)*2)
      employee_per_day_salary 	= (pay_invoice.actual_salary/arrears_month.to_f)
    end
      
    per_day_medical_allowance = (medical_allowance_amount.to_f/arrears_month.to_f)
    arrears_medical_allowance = (per_day_medical_allowance * pay_invoice.arrears_days)
    invoice_detail = PayInvoiceDetail.find_by(:pay_invoice_id => pay_invoice.id, :item_type => "Earning", :item_name => "Arrears")
    if not invoice_detail.nil?
    	invoice_detail.amount = invoice_detail.amount + arrears_medical_allowance
    	invoice_detail.save
    end
  end

  def calculate_vehicle_monthly_tax_value(pay_invoice, employee, pay_execution)
  	vehicle_current_month_value = 0
  	if pay_execution.vehicle_impact_on_tax == true
  		if pay_execution.vehicle_tax_percentage > 0
  			if employee.velicle_allowed == true
		  		vehicle_value = employee.vehicle_value
		  		# if vehicle_value > 0
		  			vehicle_taxable_value = ((vehicle_value.to_f/100.0)*pay_execution.vehicle_tax_percentage.to_f)
		  			total_payable_vehicle_tax = ((vehicle_taxable_value.to_f/12.0) * pay_invoice.vehicle_months.to_f)
		  			vehicle_current_month = (pay_invoice.vehicle_months.to_f - pay_invoice.remaining_tax_year_month.to_f)
		  			if vehicle_current_month >= 1
		  				vehicle_current_month_value = (total_payable_vehicle_tax.to_f/pay_invoice.vehicle_months.to_f) * 1
		  			elsif pay_invoice.vehicle_months > 0
		  				vehicle_current_month_value = (total_payable_vehicle_tax.to_f/pay_invoice.vehicle_months.to_f) * vehicle_current_month.to_f
		  			end
		  		# end
	  		end
  		end
		end
  	return vehicle_current_month_value
  end

  def predicted_calculate_vehicle_tax_value(pay_invoice, employee, pay_execution)
  	predicted_vehicle_value = 0
  	if pay_execution.vehicle_impact_on_tax == true
  		if pay_execution.vehicle_tax_percentage > 0
  			if employee.velicle_allowed == true
  				vehicle_value = employee.vehicle_value
  				# if vehicle_value > 0
		  			vehicle_taxable_value = ((vehicle_value.to_f/100.0)*pay_execution.vehicle_tax_percentage.to_f)
		  			total_payable_vehicle_tax = ((vehicle_taxable_value.to_f/12.0) * pay_invoice.vehicle_months.to_f)
					if pay_invoice.vehicle_months > 0
		  			predicted_vehicle_value = (total_payable_vehicle_tax.to_f/pay_invoice.vehicle_months) * pay_invoice.remaining_tax_year_month.to_f
					end
  				# end
  			end
  		end
  	end
  	return predicted_vehicle_value
  end

  def calculate_employyer_provident_fund(pay_invoice, employee, pay_execution)
  	current_provident_value = PayInvoiceDetail.where(:pay_invoice_id => pay_invoice.id, :item_type => "Deduction", :item_name => "Provident Fund").sum(:amount)
  	return current_provident_value
  end

  def calculate_predicted_employyer_provident_fund(pay_invoice, employee, pay_execution, return_value)
  	prev_provident_fund_value 	= EmployeeTaxableIncome.where(:status => true, :fiscal_year_id => pay_invoice.fiscal_year_id, :employee_id => pay_invoice.employee_id).sum(:employeer_pf_value)
  	pf_tax_value 								= 0
  	predicted_pf_value 					= 0
  	back_date_pf_value 					= 0
  	arrear_pf_value 						= 0
  	current_provident_value 		= PayInvoiceDetail.where(:pay_invoice_id => pay_invoice.id, :item_type => "Deduction", :item_name => "Provident Fund").sum(:amount) + PayInvoiceDetail.where(:pay_invoice_id => pay_invoice.id, :item_type => "Deduction", :item_name => "Arrears Provident Fund").sum(:amount)
  	if employee.back_date_pf_impact == true
  		back_date_pf_value = pay_invoice.tax_value_back_date_provident_fund(pay_invoice, employee, pay_execution)
  	end
		if not pay_invoice.confirmation_date.nil?
			if pay_invoice.arrears_days > 0 and employee.back_date_pf_impact == false
  			arrear_pf_value = pay_invoice.tax_value_arrear_on_provident_fund(pay_invoice, employee, pay_execution)
  		end
  	end
  	actual_current_provident_value = (current_provident_value - (back_date_pf_value + arrear_pf_value))
  	provident_fund = pay_execution.provident_fund
  	if not provident_fund.nil?
  		if provident_fund.is_active == true
	  		if provident_fund.employer_taxable == true
	  			if current_provident_value > 0
	  				employer_amount_exceed 		 = provident_fund.employer_amount_exceed
						total_provident_fund_value = (current_provident_value.to_f * pay_invoice.total_pf_months.to_f)
						predicted_pf_value 				 = (total_provident_fund_value.to_f/pay_invoice.total_pf_months) * pay_invoice.remaining_tax_year_month.to_f
						pf_tax_value 		= (predicted_pf_value + current_provident_value + prev_provident_fund_value)
						if pf_tax_value > employer_amount_exceed
							pf_tax_value 	= (pf_tax_value - employer_amount_exceed)
						else
							pf_tax_value = 0
						end
	  			end
	  		end
	  	end
  	end
  	if return_value == "PF TAX"
  		return pf_tax_value
  	else
  		return predicted_pf_value
  	end
  end

  def employyer_eobi_contribution(pay_invoice, employee, pay_execution)
  	current_eobi_value = PayInvoiceDetail.where(:pay_invoice_id => pay_invoice.id, :item_type => "Deduction", :item_name => "EOBI").sum(:amount)
  	employeer_eobi_value = 0
  	eobi = pay_execution.eobi
  	if not eobi.nil?
  		if eobi.is_active == true
  			employeer_eobi_value = current_eobi_value * eobi.employer_percentage.to_f
  		end
  	end
  	return employeer_eobi_value
  end

  def back_date_provident_fund(pay_invoice, employee, pay_execution)
  	extra_pf_days 	= 0
  	extra_pf_value	= 0
  	if employee.back_date_pf_impact == true
	  	if pay_invoice.on_probation == false
				if not pay_invoice.confirmation_date.nil?
					start_time = Time.new(pay_invoice.confirmation_date.to_date.year,pay_invoice.confirmation_date.to_date.month, pay_invoice.confirmation_date.to_date.day)
					no_of_days_till_confirmation = ((TimeDifference.between(start_time, (pay_execution.end_date.to_date)).in_days) + 1)
					if no_of_days_till_confirmation > pay_execution.total_pay_days(employee)
						extra_pf_days = no_of_days_till_confirmation - pay_execution.total_pay_days(employee)
					end
				end
			end
			pay_item = PayItem.find_by(:name => "Back Date Provident Fund", :is_active => true)
			if not pay_item.nil?
				item_value = PayItem.calculate_formula(pay_invoice.employee, pay_item, pay_invoice)
				last_month = (pay_invoice.actual_pay_month - 1.month).to_date.strftime("%B %Y")
				old_pay_execution = PayExecution.last_pay_execution(last_month, pay_invoice.company_id, pay_invoice.location_id, pay_invoice.grade_id)
		    if old_pay_execution.nil?
		      no_of_pay_days = pay_invoice.pay_execution.total_pay_days(employee)
		      extra_pf_value = (item_value.to_f/30.42) * extra_pf_days.to_f
		    else  
		      no_of_pay_days = old_pay_execution.total_pay_days(employee)
		      extra_pf_value = (item_value.to_f/30.42) * extra_pf_days.to_f
		    end
			end
			invoice_detail = PayInvoiceDetail.find_by(:pay_invoice_id => pay_invoice.id, :item_type => "Deduction", :item_name => "Provident Fund")
	    if not invoice_detail.nil?
	    	invoice_detail.amount = invoice_detail.amount + extra_pf_value
	    	invoice_detail.save
	    end
	  end
  end

  def back_date_eobi(pay_invoice, employee, pay_execution)
  	extra_eobi_days 	= 0
  	extra_eobi_value	= 0
  	if employee.back_date_eobi_impact == true
  		if not pay_invoice.joining_date.nil?
				start_time = Time.new(pay_invoice.joining_date.to_date.year,pay_invoice.joining_date.to_date.month, pay_invoice.joining_date.to_date.day)
				no_of_days_till_joining = ((TimeDifference.between(start_time, (pay_execution.end_date.to_date)).in_days) + 1)
				extra_eobi_days = no_of_days_till_joining - pay_execution.end_date.to_date.day
			end
			pay_item_ids = pay_execution.item_execution_details.where(:status => "Allowed").collect(&:pay_item_id)
			pay_items = PayItem.where(:id => pay_item_ids, :name => "EOBI")
			if pay_items.count == 1
				pay_item = pay_items.first
				item_value = PayItem.calculate_formula(pay_invoice.employee, pay_item, pay_invoice)
				
				last_month = (pay_invoice.actual_pay_month - 1.month).to_date.strftime("%B %Y")
				old_pay_execution = PayExecution.last_pay_execution(last_month, pay_invoice.company_id, pay_invoice.location_id, pay_invoice.grade_id)
				if old_pay_execution.nil?
		      no_of_pay_days 		= pay_invoice.pay_execution.end_date.end_of_month.day
		      extra_eobi_value 	= (item_value.to_f/no_of_pay_days.to_f) * extra_eobi_days.to_f
		    else  
		      no_of_pay_days 		= old_pay_execution.end_date.end_of_month.day
		      extra_eobi_value 	= (item_value.to_f/no_of_pay_days.to_f) * extra_eobi_days.to_f
		    end
			end
			invoice_detail = PayInvoiceDetail.find_by(:pay_invoice_id => pay_invoice.id, :item_type => "Deduction", :item_name => "EOBI")
	    if not invoice_detail.nil?
	    	invoice_detail.amount = invoice_detail.amount + extra_eobi_value
	    	invoice_detail.save
	    end
  	end

  	if employee.back_date_allowance_impact == true
	  	if employee.fuel_allowed == true
	  		if employee.fuel_eligibility == "Date of Joining"
			  	extra_fuel_days 	= 0
			  	extra_fuel_value	= 0
			  	extra_fuel_tax_value	= 0
		  		if not pay_invoice.joining_date.nil?
						start_time = Time.new(pay_invoice.joining_date.to_date.year,pay_invoice.joining_date.to_date.month, pay_invoice.joining_date.to_date.day)
						no_of_days_till_joining = TimeDifference.between(pay_execution.start_date.beginning_of_year.to_date, pay_execution.end_date.end_of_year.to_date).in_days + 1
						if no_of_days_till_joining > pay_execution.total_pay_days(employee)
							extra_fuel_days = no_of_days_till_joining - pay_execution.total_pay_days(employee)
						end 
					end
					pay_item_ids = pay_execution.item_execution_details.where(:status => "Allowed").collect(&:pay_item_id)
					pay_items = PayItem.where(:id => pay_item_ids, :name => "Fuel")
					if pay_items.count == 1
						pay_item = pay_items.first
						item_value = PayItem.calculate_formula(pay_invoice.employee, pay_item, pay_invoice)
						taxable_amount = PayItem.calculate_item_tax(pay_item, item_value)
						
						last_month = (pay_invoice.actual_pay_month - 1.month).to_date.strftime("%B %Y")
						old_pay_execution = PayExecution.last_pay_execution(last_month, pay_invoice.company_id, pay_invoice.location_id, pay_invoice.grade_id)
						if old_pay_execution.nil?
				      no_of_pay_days 		= pay_invoice.pay_execution.total_pay_days(employee)
				      extra_fuel_value 	= (item_value.to_f/no_of_pay_days.to_f) * extra_fuel_days.to_f
				      extra_fuel_tax_value 	= (taxable_amount.to_f/no_of_pay_days.to_f) * extra_fuel_days.to_f
				    else  
				      no_of_pay_days 		= old_pay_execution.total_pay_days(employee)
				      extra_fuel_value 	= (item_value.to_f/no_of_pay_days.to_f) * extra_fuel_days.to_f
				      extra_fuel_tax_value 	= (taxable_amount.to_f/no_of_pay_days.to_f) * extra_fuel_days.to_f
				    end
					end
					invoice_detail = PayInvoiceDetail.find_by(:pay_invoice_id => pay_invoice.id, :item_type => "Earning", :item_name => "Fuel")
			    if not invoice_detail.nil?
			    	invoice_detail.amount = invoice_detail.amount + extra_fuel_value
			    	invoice_detail.taxable_amount = invoice_detail.taxable_amount + extra_fuel_tax_value
			    	invoice_detail.save
			    end
			  elsif employee.fuel_eligibility == "Date of Confirmation"
			  	extra_fuel_days 	= 0
			  	extra_fuel_value	= 0
			  	extra_fuel_tax_value	= 0
		  		if not pay_invoice.joining_date.nil?
						start_time = Time.new(pay_invoice.confirmation_date.to_date.year,pay_invoice.confirmation_date.to_date.month, pay_invoice.confirmation_date.to_date.day)
						no_of_days_till_confirmation = ((TimeDifference.between(start_time, (pay_execution.end_date.to_date)).in_days) + 1)
						if no_of_days_till_confirmation > pay_execution.total_pay_days(employee)
							extra_fuel_days = no_of_days_till_confirmation - pay_execution.total_pay_days(employee)
						end
					end
					pay_item_ids = pay_execution.item_execution_details.where(:status => "Allowed").collect(&:pay_item_id)
					pay_items = PayItem.where(:id => pay_item_ids, :name => "Fuel")
					if pay_items.count == 1
						pay_item = pay_items.first
						item_value = PayItem.calculate_formula(pay_invoice.employee, pay_item, pay_invoice)
						taxable_amount = PayItem.calculate_item_tax(pay_item, item_value)
						
						last_month = (pay_invoice.actual_pay_month - 1.month).to_date.strftime("%B %Y")
						old_pay_execution = PayExecution.last_pay_execution(last_month, pay_invoice.company_id, pay_invoice.location_id, pay_invoice.grade_id)
						if old_pay_execution.nil?
				      no_of_pay_days 		= pay_invoice.pay_execution.total_pay_days(employee)
				      extra_fuel_value 	= (item_value.to_f/no_of_pay_days.to_f) * extra_fuel_days.to_f
				      extra_fuel_tax_value 	= (taxable_amount.to_f/no_of_pay_days.to_f) * extra_fuel_days.to_f
				    else  
				      no_of_pay_days 		= old_pay_execution.total_pay_days(employee)
				      extra_fuel_value 	= (item_value.to_f/no_of_pay_days.to_f) * extra_fuel_days.to_f
				      extra_fuel_tax_value 	= (taxable_amount.to_f/no_of_pay_days.to_f) * extra_fuel_days.to_f
				    end
					end
					invoice_detail = PayInvoiceDetail.find_by(:pay_invoice_id => pay_invoice.id, :item_type => "Earning", :item_name => "Fuel")
			    if not invoice_detail.nil?
			    	invoice_detail.amount = invoice_detail.amount + extra_fuel_value
			    	invoice_detail.taxable_amount = invoice_detail.taxable_amount + extra_fuel_tax_value
			    	invoice_detail.save
			    end
			  end
		  end

		  if employee.vehicle_allowance_allowed == true
			  if employee.vehicle_allowance_eligibility == "Date of Joining"
			  	extra_vehicle_allowance_days 	= 0
			  	extra_vehicle_allowance_value	= 0
			  	extra_vehicle_allowance_tax_value = 0
			  	if not pay_invoice.joining_date.nil?
						start_time = Time.new(pay_invoice.joining_date.to_date.year,pay_invoice.joining_date.to_date.month, pay_invoice.joining_date.to_date.day)
						no_of_days_till_joining = TimeDifference.between(pay_execution.start_date.beginning_of_year.to_date, pay_execution.end_date.end_of_year.to_date).in_days + 1
						if no_of_days_till_joining > pay_execution.total_pay_days(employee)
							extra_vehicle_allowance_days = no_of_days_till_joining - pay_execution.total_pay_days(employee)
						end 
					end
					pay_item_ids = pay_execution.item_execution_details.where(:status => "Allowed").collect(&:pay_item_id)
					pay_items = PayItem.where(:id => pay_item_ids, :name => "Vehicle Allowance")
					if pay_items.count == 1
						pay_item = pay_items.first
						item_value = PayItem.calculate_formula(pay_invoice.employee, pay_item, pay_invoice)
						taxable_amount = PayItem.calculate_item_tax(pay_item, item_value)
						
						last_month = (pay_invoice.actual_pay_month - 1.month).to_date.strftime("%B %Y")
						old_pay_execution = PayExecution.last_pay_execution(last_month, pay_invoice.company_id, pay_invoice.location_id, pay_invoice.grade_id)
						if old_pay_execution.nil?
				      no_of_pay_days = pay_invoice.pay_execution.total_pay_days(employee)
				      extra_vehicle_allowance_value = (item_value.to_f/no_of_pay_days.to_f) * extra_vehicle_allowance_days.to_f
				      extra_vehicle_allowance_tax_value = (taxable_amount.to_f/no_of_pay_days.to_f) * extra_vehicle_allowance_days.to_f
				    else  
				      no_of_pay_days = old_pay_execution.total_pay_days(employee)
				      extra_vehicle_allowance_value = (item_value.to_f/no_of_pay_days.to_f) * extra_vehicle_allowance_days.to_f
				      extra_vehicle_allowance_tax_value = (taxable_amount.to_f/no_of_pay_days.to_f) * extra_vehicle_allowance_days.to_f
				    end
					end
					invoice_detail = PayInvoiceDetail.find_by(:pay_invoice_id => pay_invoice.id, :item_type => "Earning", :item_name => "Vehicle Allowance")
			    if not invoice_detail.nil?
			    	invoice_detail.amount = invoice_detail.amount + extra_vehicle_allowance_value
			    	invoice_detail.taxable_amount = invoice_detail.taxable_amount + extra_vehicle_allowance_tax_value
			    	invoice_detail.save
			    end
			  elsif employee.vehicle_allowance_eligibility == "Date of Confirmation"
			  	extra_vehicle_allowance_days 	= 0
			  	extra_vehicle_allowance_value	= 0
			  	extra_vehicle_allowance_tax_value = 0
			  	if not pay_invoice.joining_date.nil?
						start_time = Time.new(pay_invoice.confirmation_date.to_date.year,pay_invoice.confirmation_date.to_date.month, pay_invoice.confirmation_date.to_date.day)
						no_of_days_till_confirmation = ((TimeDifference.between(start_time, (pay_execution.end_date.to_date)).in_days) + 1)
						if no_of_days_till_confirmation > pay_execution.total_pay_days(employee)
							extra_vehicle_allowance_days = no_of_days_till_confirmation - pay_execution.total_pay_days(employee)
						end
					end
					pay_item_ids = pay_execution.item_execution_details.where(:status => "Allowed").collect(&:pay_item_id)
					pay_items = PayItem.where(:id => pay_item_ids, :name => "Vehicle Allowance")
					if pay_items.count == 1
						pay_item = pay_items.first
						item_value = PayItem.calculate_formula(pay_invoice.employee, pay_item, pay_invoice)
						taxable_amount = PayItem.calculate_item_tax(pay_item, item_value)
						
						last_month = (pay_invoice.actual_pay_month - 1.month).to_date.strftime("%B %Y")
						old_pay_execution = PayExecution.last_pay_execution(last_month, pay_invoice.company_id, pay_invoice.location_id, pay_invoice.grade_id)
						if old_pay_execution.nil?
				      no_of_pay_days = pay_invoice.pay_execution.total_pay_days(employee)
				      extra_vehicle_allowance_value = (item_value.to_f/no_of_pay_days.to_f) * extra_vehicle_allowance_days.to_f
				      extra_vehicle_allowance_tax_value = (taxable_amount.to_f/no_of_pay_days.to_f) * extra_vehicle_allowance_days.to_f
				    else  
				      no_of_pay_days = old_pay_execution.total_pay_days(employee)
				      extra_vehicle_allowance_value = (item_value.to_f/no_of_pay_days.to_f) * extra_vehicle_allowance_days.to_f
				      extra_vehicle_allowance_tax_value = (taxable_amount.to_f/no_of_pay_days.to_f) * extra_vehicle_allowance_days.to_f
				    end
					end
					invoice_detail = PayInvoiceDetail.find_by(:pay_invoice_id => pay_invoice.id, :item_type => "Earning", :item_name => "Vehicle Allowance")
			    if not invoice_detail.nil?
			    	invoice_detail.amount = invoice_detail.amount + extra_vehicle_allowance_value
			    	invoice_detail.taxable_amount = invoice_detail.taxable_amount + extra_vehicle_allowance_tax_value
			    	invoice_detail.save
			    end
			  end
			end
		end
  end

  def arrear_on_provident_fund(pay_invoice, employee, pay_execution)
  	if pay_execution.vehicle_monthly_prorated == false
	  	pay_item = PayItem.find_by(:name => "Provident Fund Arrear")
	  	item_value = PayItem.calculate_formula(pay_invoice.employee, pay_item, pay_invoice)
	  	if not pay_item.nil?
	  		invoice_detail = PayInvoiceDetail.find_by(:pay_invoice_id => pay_invoice.id, :item_type => "Deduction", :item_name => "Provident Fund")
		    if not invoice_detail.nil?
		    	invoice_detail.amount = invoice_detail.amount + item_value
		    	invoice_detail.save
		    end
	  	end
	  end
  end

  def tax_value_back_date_provident_fund(pay_invoice, employee, pay_execution)
  	extra_pf_days 	= 0
  	extra_pf_value	= 0
  	if employee.back_date_pf_impact == true
	  	if pay_invoice.on_probation == false
				if not pay_invoice.confirmation_date.nil?
					start_time = Time.new(pay_invoice.confirmation_date.to_date.year,pay_invoice.confirmation_date.to_date.month, pay_invoice.confirmation_date.to_date.day)
					no_of_days_till_confirmation = ((TimeDifference.between(start_time, (pay_execution.end_date.to_date)).in_days) + 1)
					if no_of_days_till_confirmation > pay_execution.total_pay_days(employee)
						extra_pf_days = no_of_days_till_confirmation - pay_execution.total_pay_days(employee)
					end
				end
			end
			pay_item = PayItem.find_by(:name => "Back Date Provident Fund", :is_active => true)
			if not pay_item.nil?
				item_value = PayItem.calculate_formula(pay_invoice.employee, pay_item, pay_invoice)
				last_month = (pay_invoice.actual_pay_month - 1.month).to_date.strftime("%B %Y")
				old_pay_execution = PayExecution.find_by(:formated_pay_month => last_month, :company_id => pay_invoice.company_id, :location_id => pay_invoice.location_id)
		    if old_pay_execution.nil?
		      no_of_pay_days = pay_invoice.pay_execution.total_pay_days(employee)
		      extra_pf_value = (item_value.to_f/30.42) * extra_pf_days.to_f
		    else  
		      no_of_pay_days = old_pay_execution.total_pay_days(employee)
		      extra_pf_value = (item_value.to_f/30.42) * extra_pf_days.to_f
		    end
			end
	  end
	  return extra_pf_value
  end

  def tax_value_arrear_on_provident_fund(pay_invoice, employee, pay_execution)
  	if pay_execution.vehicle_monthly_prorated == false
	  	pay_item = PayItem.find_by(:name => "Provident Fund Arrear")
	  	item_value = PayItem.calculate_formula(pay_invoice.employee, pay_item, pay_invoice)
	  	return item_value
	  else
	  	return 0.0
	  end
	end

	def self.mill_instance?
		ENV.fetch("APP_URL").include?('millshrmsbe.dfl.com.pk')
	end

	def self.dtl_instance?
		ENV.fetch("APP_URL").include?('dtlbe.srl.com.pk')
	end

	def self.srl_instance?
		ENV.fetch("APP_URL").include?('hrmsbe.sapphirepakistan.pk')
	end

	def self.cresset_instance?
		ENV.fetch("APP_URL").include?('attendancebe.cressettech.com')
	end
end

