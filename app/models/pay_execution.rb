class PayExecution < ApplicationRecord

	########## Validation ############
	validates :name, 										:uniqueness => { scope: :company_id }
	
	####### Relation Ship #########
	belongs_to 	:company
	belongs_to 	:location
	belongs_to 	:provident_fund
	belongs_to 	:eobi
	belongs_to 	:tax_slab
	belongs_to 	:fiscal_year

  has_many    :item_execution_details,  :dependent => :destroy
  has_many    :pay_invoices,            :dependent => :restrict_with_error

  ########## Validation ############
  validate   :validate_pay_month

  ########## Validation of Pay Execution ##########
  def validate_pay_month
    if self.id.present?
      PayExecution.where.not(id:self.id).where(company_id: self.company_id, location_id: self.location_id, :grade_ids => self.grade_ids).each do |pay_execution|
        if self.id != pay_execution.id
          if pay_execution.formated_pay_month.present?
            if pay_execution.formated_pay_month == self.formated_pay_month
              self.errors.add(:base, "Pay Execution Already Exist! for #{pay_execution.formated_pay_month}")
            end
          end
        end
      end
    else
      PayExecution.where(company_id: self.company_id, location_id: self.location_id, :grade_ids => self.grade_ids).each do |pay_execution|
        if self.id != pay_execution.id
          if pay_execution.formated_pay_month.present?
            if pay_execution.formated_pay_month == self.formated_pay_month
              self.errors.add(:base, "Pay Execution Already Exist! for #{pay_execution.formated_pay_month}")
            end
          end
        end
      end
    end
    logger.info "#{self.errors}"
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

  def self.generate_payroll(pay_execution)
    if not pay_execution.grade_ids.nil?
      cutoff_start_date = AttendanceCutoff.find(pay_execution.attendance_cutoff_ids.split(',').map(&:to_i)).map(&:start_date).min
      struck_off_employees = Employee.where(id: EmployeeTransactionHistory.get_by_type('End of Employment').where('is_struck_off = ? AND transaction_date > ?', true, cutoff_start_date).pluck(:employee_id))
      employee_list = Employee.where(:company_id => pay_execution.company_id, :location_id => pay_execution.location_id, :grade_id => pay_execution.grade_ids.split(',').map(&:to_i), :salary_exempted => false, :hold_salary => false, is_struck_off: false)
      (struck_off_employees + employee_list).each do |employee|
        salary_slip_employees = (employee.joining_date.to_date <= pay_execution.end_date.to_date and employee.is_active)
        if cresset_instance?
          resign_date = employee.employee_transaction_histories.where(transaction_type: EmployeeTransactionHistory::TRANSACTION_TYPES[:eoe]).first.try(:transaction_date)
          salary_slip_employees = salary_slip_employees || (!employee.is_active and resign_date and resign_date >= pay_execution.start_date.to_date and resign_date <= pay_execution.end_date.to_date)
        end
        if salary_slip_employees
          PayInvoice.generate_single_employee_invoice(employee, pay_execution)
        end
      end
    end
  end

  def self.regenerate_payroll(pay_execution)
    if not pay_execution.grade_ids.nil?
      pay_execution.pay_invoices.where(:status => true).update_all(status: false)
      EmployeeTaxableIncome.where(:status => true, :pay_invoice_id => pay_execution.pay_invoices.pluck(:id)).update_all(status: false)
      cutoff_start_date = AttendanceCutoff.find(pay_execution.attendance_cutoff_ids.split(',').map(&:to_i)).map(&:start_date).min
      struck_off_employees = Employee.where(id: EmployeeTransactionHistory.get_by_type('End of Employment').where('is_struck_off = ? AND transaction_date > ?', true, cutoff_start_date).pluck(:employee_id))
      employee_list = Employee.where(:company_id => pay_execution.company_id, :location_id => pay_execution.location_id, :grade_id => pay_execution.grade_ids.split(',').map(&:to_i), :salary_exempted => false, :hold_salary => false, is_struck_off: false)
      (struck_off_employees + employee_list).each do |employee|
        salary_slip_employees = (employee.joining_date.to_date <= pay_execution.end_date.to_date and employee.is_active)
        if cresset_instance?
          resign_date = employee.employee_transaction_histories.where(transaction_type: EmployeeTransactionHistory::TRANSACTION_TYPES[:eoe]).first.try(:transaction_date)
          salary_slip_employees = salary_slip_employees || (!employee.is_active and resign_date and resign_date >= pay_execution.start_date.to_date and resign_date <= pay_execution.end_date.to_date)
        end
        if salary_slip_employees
          PayInvoice.generate_single_employee_invoice(employee, pay_execution)
        end
      end
    end
  end

  def self.locked_payroll(pay_execution)
    transaction_month = (pay_execution.end_date.to_date.beginning_of_month).to_date.strftime("%B %Y")
    pay_execution.pay_invoices.where(:status => true).order('id ASC').each do |pay_invoice|
      pay_invoice.is_locked = true
      pay_invoice.save
      employee = pay_invoice.employee
      EmployeeLoan.mark_as_cleared(employee, transaction_month)
      EmployeeAdvance.mark_as_cleared(employee, transaction_month)
      FixedPayItem.where(:employee_id => pay_invoice.employee_id, :is_active => true, :item_type => "Once", :formated_pay_month => pay_invoice.pay_month).each do |fixed_pay_item|
        fixed_pay_item.is_active = false
        fixed_pay_item.save
      end
    end
  end

  def total_pay_days(employee)
    # if self.exclude_sunday == true
    #   my_days = [0]
    #   start_time = Time.new(employee.joining_date.to_date.year,employee.joining_date.to_date.month, employee.joining_date.to_date.day)
    #   start_date = start_time.to_date
    #   end_date = self.end_date.end_of_month.to_date
    #   joining_sunday_count = (start_date..end_date).to_a.select {|k| my_days.include?(k.wday)}.count
    #   if self.joining_exception == true
    #     if employee.joining_date.to_date.strftime("%B %Y") == self.joining_exception_formated_month
    #       return (self.joining_exception_pay_days.to_f - joining_sunday_count)      
    #     else
    #       return (self.no_of_pay_days.to_f - joining_sunday_count)
    #     end
    #   else
    #     return (self.no_of_pay_days.to_f - joining_sunday_count)
    #   end
    # else 
    #   if self.joining_exception == true
    #     if employee.joining_date.to_date.strftime("%B %Y") == self.joining_exception_formated_month
    #       return self.joining_exception_pay_days.to_f
    #     else
    #       return self.no_of_pay_days.to_f
    #     end
    #   else
    #     return self.no_of_pay_days.to_f
    #   end 
    # end

    if self.joining_exception == true
      if employee.joining_date.to_date.strftime("%B %Y") == self.joining_exception_formated_month
        return self.joining_exception_pay_days.to_f
      else
        return self.no_of_pay_days.to_f
      end
    else
      return self.no_of_pay_days.to_f
    end 
  end

  def exclude_sunday_count(employee)
    if self.exclude_sunday == true
      my_days = [0]
      start_time = Time.new(employee.joining_date.to_date.year,employee.joining_date.to_date.month, employee.joining_date.to_date.day)
      start_date = start_time.to_date
      end_date = self.end_date.end_of_month.to_date
      joining_sunday_count = (start_date..end_date).to_a.select {|k| my_days.include?(k.wday)}.count
      return joining_sunday_count
    else
      return 0
    end
  end

  def self.last_pay_execution(last_month, company_id, location_id, grade_id)
    old_pay_executions = PayExecution.where(:formated_pay_month => last_month, :company_id => company_id, :location_id => location_id)
    if old_pay_executions.present?
      old_pay_executions_temp = []
      old_pay_executions_temp << old_pay_executions.select{|s| s.grade_ids.split(',').map(&:to_i).include?(grade_id.to_i)}.map(&:id)
      old_pay_executions_temp = old_pay_executions_temp.flatten.uniq
      old_pay_executions = old_pay_executions.where(id:old_pay_executions_temp.flatten.uniq)
    end
    if old_pay_executions.count == 1
      return old_pay_executions.first  
    else
      return nil
    end
  end

  def self.cresset_instance?
    ENV['APP_URL'].include?('attendancebe.cressettech.com')
  end
end
