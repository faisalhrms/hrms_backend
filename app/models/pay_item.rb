class PayItem < ApplicationRecord

	####### Array Serializion #########
  serialize :formula_with_code, type: Array

  ####### Validations #########
  validates :name, :uniqueness => { scope: :company_id }
  validates :code, :uniqueness => { scope: :company_id }

  ####### Relations #########
  belongs_to 	:company
  
  has_many    :fixed_pay_items,         :dependent => :restrict_with_error
  has_many    :item_execution_details,  :dependent => :restrict_with_error
  
  has_many    :employee_provident_funds, class_name: 'ProvidentFund', foreign_key: :employee_pay_item_id, :dependent => :restrict_with_error
  has_many    :employer_provident_funds, class_name: 'ProvidentFund', foreign_key: :employer_pay_item_id, :dependent => :restrict_with_error


  def self.calculate_formula(employee, single_item, pay_invoice)
    cal_array = []
    calculation_allowed = false
    if single_item.name == "EOBI" && single_item.allowance_eligibility("EOBI", employee, pay_invoice) == false
      calculation_allowed = false
    elsif single_item.name == "Provident Fund" && single_item.allowance_eligibility("PF", employee, pay_invoice) == false
      calculation_allowed = false
    else
      calculation_allowed = true
    end
    if calculation_allowed == true
      if single_item.calculation_type == "Fixed"
        cal_array << single_item.fixed_item_value(employee, single_item, pay_invoice)  
      else
        single_item.formula_with_code.each_with_index do |str, index|
        if single_item.from_formula_tool?(str)
          if ['(', ')', '+', '-', '/', '*', '.'].include?(str)
            cal_array << str
          end
        elsif ['%'].include?(str)
          cal_array << "/100*"
        elsif single_item.from_digits?(str)
          cal_array << str
        elsif ["Gross Salary"].include?(str)
          cal_array << Employee.effective_gross_salary(employee, pay_invoice)
        elsif ["Earned Gross Salary"].include?(str)
          cal_array << pay_invoice.payable_gross
        elsif ["Earned Gross Salary 2"].include?(str)
          if ENV.fetch("APP_URL").include?('dtlbe.srl.com.pk') or ENV.fetch("APP_URL").include?('localhost')
            if single_item.name == "Provident Fund"
              gross_salary = pay_invoice.payable_gross
              if employee.gross_salary.to_f >= 18053.0 and employee.gross_salary.to_f.to_f <= 27080.0
                cal_array << 18053.0
              else
                gross_salary = (gross_salary * 0.67).to_f.round(2)
                cal_array << gross_salary
              end
            else
              gross_salary = employee.gross_salary
              if gross_salary.to_f >= 18053.0 and gross_salary.to_f <= 27080.0
                cal_array << 18053.0
              else
                gross_salary = (gross_salary * 0.67).to_f.round(2)
                cal_array << gross_salary
              end
            end
          else
            cal_array << pay_invoice.payable_gross
          end
        elsif ["Earned Gross Salary House Rent"].include?(str)
          if ENV.fetch("APP_URL").include?('dtlbe.srl.com.pk') or ENV.fetch("APP_URL").include?('localhost')
            gross_salary = employee.gross_salary
            if gross_salary.to_f >= 18053.0 and gross_salary.to_f <= 27080.0
              cal_array << 0.0
            else
              gross_salary = (gross_salary * 0.3).to_f.round(2)
              cal_array << gross_salary
            end
          else
            cal_array << pay_invoice.payable_gross
          end
        elsif ["Earned Gross Salary Utility"].include?(str)
          if ENV.fetch("APP_URL").include?('dtlbe.srl.com.pk') or ENV.fetch("APP_URL").include?('localhost')
            gross_salary = employee.gross_salary
            if gross_salary.to_f >= 18053.0 and gross_salary.to_f <= 27080.0
              cal_array << gross_salary - 18053.0
            else
              house_rent = (gross_salary * 0.3).to_f.round(2)
              if gross_salary.to_f >= 18053.0 and gross_salary.to_f <= 27080.0
                basic_salary = 18053.0
              else
                basic_salary = (gross_salary * 0.67).to_f.round(2)
              end
              gross_salary = (gross_salary - (basic_salary + house_rent)).to_f.round(2)
              cal_array << gross_salary
            end
          else
            cal_array << pay_invoice.payable_gross
          end
        elsif single_item.pay_item?(str)
          item = PayItem.find(str.split('-')[1].to_i)
          if item.calculation_type == "Variable"
            cal_array << PayItem.calculate_formula(employee, item, pay_invoice)
          else
            cal_array << single_item.fixed_item_value(employee, item, pay_invoice)
          end
        elsif ['Short Joining Days'].include?(str)
          cal_array << pay_invoice.short_joining_days
        elsif ['Medical Allowance OPD'].include?(str)
          if ENV.fetch("APP_URL").include?('dtlbe.srl.com.pk') or ENV.fetch("APP_URL").include?('localhost')
            gross_salary = pay_invoice.payable_gross
            basic_salary = (gross_salary * 0.67).to_f.round(2)
            if [15,16,17,18,19,21,22,23].include?employee.grade_id
              cal_array << gross_salary * 0.02
            elsif [4,5,6,7,8,9,10,11,12,13,14].include?employee.grade.id
              cal_array << basic_salary * 0.02
            end
          end
        elsif ['EOBI Short Joining Days'].include?(str)
          cal_array << pay_invoice.eobi_short_joining_days
        elsif ['Short Confirmation Days'].include?(str)
          if pay_invoice.short_confirmation_days > 0
            if pay_invoice.short_confirmation_days < pay_invoice.pay_execution.total_pay_days(employee)
              cal_array << pay_invoice.short_confirmation_days
            else
              cal_array << pay_invoice.pay_execution.total_pay_days(employee)
            end
          else
            cal_array << pay_invoice.pay_execution.total_pay_days(employee)
          end
        elsif ['Attendance Deduction'].include?(str)
          cal_array << pay_invoice.deduction_days
        elsif ['PayRoll Month Days'].include?(str)
          cal_array << pay_invoice.pay_execution.no_of_pay_days
        elsif ['Piece Rate Allowance'].include?(str)
          piece_rate_days = pay_invoice.no_of_pay_days - pay_invoice.deduction_days
          if piece_rate_days == 26
            cal_array << 6000
          elsif piece_rate_days == 25
            cal_array << 4000
          elsif piece_rate_days == 24
            cal_array << 3000
          else
            if piece_rate_days <= 23
              cal_array << 0
            else
              cal_array << "-"
            end
          end
          cal_array << pay_invoice.pay_execution.total_pay_days(employee)
        elsif ['Last PayRoll Month Days'].include?(str)
          # cal_array << pay_invoice.pay_execution.no_of_pay_days
          last_month = (pay_invoice.actual_pay_month - 1.month).to_date.strftime("%B %Y")
          old_pay_execution = PayExecution.last_pay_execution(last_month, pay_invoice.company_id, pay_invoice.location_id, pay_invoice.grade_id)
          if old_pay_execution.nil?
            cal_array << pay_invoice.pay_execution.total_pay_days(employee)
          else
            cal_array << old_pay_execution.total_pay_days(employee)
          end
        elsif ['Actual Month Days'].include?(str)
          cal_array << pay_invoice.pay_execution.end_date.end_of_month.day
        elsif ['Vehicle Allowance Value'].include?(str)
          if employee.vehicle_allowance_allowed == true
            if single_item.allowance_eligibility("Vehicle Allowance", employee, pay_invoice) == true
              cal_array << employee.vehicle_allowance_entitlement_upto
            else
              cal_array << 0
            end
          else
            cal_array << 0
          end
        elsif ['Fuel Litre'].include?(str)
          if employee.fuel_allowed == true
            if single_item.allowance_eligibility("Fuel", employee, pay_invoice) == true
              if employee.fuel_limit == "Fix Liters"
                cal_array << employee.fuel_value
              elsif employee.fuel_limit == "Fix Amount"
                cal_array << employee.fuel_value
              else
                cal_array << 0
              end
            end
          else
            cal_array << 0
          end
        elsif ['Earned OverTime Hours'].include?(str)
          cal_array << pay_invoice.over_time_hours
        elsif ['Earned Off Days'].include?(str)
          cal_array << pay_invoice.off_day_payment
        elsif ['Special Encashable Quota'].include?(str)
          cal_array << pay_invoice.encashable_quota
        elsif ['Earned Arrears'].include?(str)
          cal_array << pay_invoice.arrears_days
        elsif ['Average Earned Gross Salary'].include?(str)
          start_date  = pay_invoice.actual_pay_month.beginning_of_year.to_date
          end_date    = pay_invoice.actual_pay_month.end_of_year.to_date
          date_range  = (start_date..end_date)
          item_value  = PayInvoice.where(:employee_id => employee.id, :status => true, :actual_pay_month => date_range).sum(:actual_salary)
          cal_array   << (item_value.to_f/12.0)
        elsif ['Average Earned Gross Salary 2'].include?(str) and employee.employee_type.try(:name) != 'Probation'
          if employee.joining_date && (pay_invoice.actual_pay_month.to_date - employee.joining_date.to_date).to_i >= 365
            item_value  = PayInvoice.where(:employee_id => employee.id, :status => true, :pay_month => "June #{Date.today.year}").first.actual_salary * 0.67
          else
            start_date = employee.joining_date.day <= 15 ? employee.joining_date.to_date : (employee.joining_date + 1.month).to_date
            end_date    = (pay_invoice.actual_pay_month - 1.month).end_of_month.to_date
            date_range  = (start_date..end_date).map{|a| a.strftime('%B %Y')}.uniq
            if date_range.count >= 12
              item_value  = PayInvoice.where(:employee_id => employee.id, :status => true, :pay_month => "June #{Date.today.year}").first.actual_salary * 0.67
            else
              item_value  = (PayInvoice.where(:employee_id => employee.id, :status => true, :pay_month => "June #{Date.today.year}").sum(:actual_salary)*0.67).round * date_range.count / 12
            end
          end
          cal_array   << item_value.to_f
        elsif ['Average Earned Basic Salary'].include?(str)
          start_date      = pay_invoice.actual_pay_month.beginning_of_year.to_date
          end_date        = pay_invoice.actual_pay_month.end_of_year.to_date
          date_range      = (start_date..end_date)
          pay_invoice_ids = PayInvoice.where(:employee_id => employee.id, :status => true, :actual_pay_month => date_range).collect(&:id)
          item_value      = PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => "Basic Salary").sum(:amount)
          cal_array       << (item_value.to_f/12.0)
        elsif ['Actual Days Served'].include?(str)
            item = PayItem.find_by_name('Eid Reward 2')
            if item.is_bonus
              item_eligible_date = item.bonus_eligibility(employee, item)
              if not item_eligible_date.nil?
                if item_eligible_date <= item.bonus_date.to_date
                  start_time = Time.new(item_eligible_date.to_date.year,item_eligible_date.to_date.month,item_eligible_date.to_date.day)
                  actual_serving_days = ReportFormat.date_in_human_readable(employee.joining_date, item.bonus_date).split('months')[0].split(',')[1].to_i
                  if actual_serving_days > 12 || ReportFormat.date_in_human_readable(employee.joining_date, item.bonus_date).split('years')[0].to_i >= 1
                    actual_serving_days = 12
                  end
                  if ReportFormat.date_in_human_readable(employee.joining_date, item.bonus_date).split('years')[0].to_i < 1
                    if employee.joining_date.to_date.day > 15
                      actual_serving_days = ReportFormat.date_in_human_readable((employee.joining_date + 1.month).beginning_of_month, item.bonus_date).split('months')[0].split(',')[1].to_i
                    else
                      actual_serving_days = ReportFormat.date_in_human_readable((employee.joining_date).beginning_of_month, item.bonus_date).split('months')[0].split(',')[1].to_i
                    end
                  end
                  cal_array << actual_serving_days
                else
                  cal_array << 0
                end
              else
                cal_array << 0
              end
            else
              cal_array << 0
            end
        elsif ['Quota Encashment'].include?(str)
          cal_array << LeaveAllocation.encashable_quota_non_probation(employee)
        elsif ['Loan Amount'].include?(str)
          transaction_month = (pay_invoice.pay_execution.end_date.to_date.beginning_of_month).to_date.strftime("%B %Y")
          cal_array << EmployeeLoan.employee_loan_amount(employee, transaction_month)
        elsif ['Advance Amount'].include?(str)
          transaction_month = (pay_invoice.pay_execution.start_date.to_date.beginning_of_month).to_date.strftime("%B %Y")
          cal_array << EmployeeAdvance.where(:employee_id => employee.id, :is_cleared => false, :pay_back_month => transaction_month).sum(&:advance_amount)
        elsif single_item.payitem_expression?(str)
          item_expression = PayitemExpression.find(str.split('-')[1].to_i)
          cal_array << item_expression.expression_value
        end
        end
      end
    end
		calculator = Dentaku::Calculator.new
    if mill_instance? and single_item.name == 'EOBI' and single_item.allowance_eligibility('EOBI', employee, pay_invoice)
      value = calculator.evaluate(cal_array.flatten.join()).to_f.round
      payable_gross_salary = 8000.0
      value = ((payable_gross_salary/26)*(PayInvoice.invoice_worked_days(pay_invoice))*0.01).to_f.round
      # payable_gross_salary = ((employee.gross_salary/26)*(26 - pay_invoice.deduction_days)).to_f
      # if payable_gross_salary <= 8000.0
      #   value = (payable_gross_salary * 0.01).to_f.round
      # else
      #   value = 80.0
      # end
      # value <= 80 ? value : 80
    else
      calculator.evaluate(cal_array.flatten.join()).to_f.round
    end
  end

  def self.prediction_calculate_formula(employee, single_item, pay_invoice)
    cal_array = []
    calculation_allowed = false
    if single_item.name == "EOBI" && single_item.allowance_eligibility("EOBI", employee, pay_invoice) == false
      calculation_allowed = false
    elsif single_item.name == "Provident Fund" && single_item.allowance_eligibility("PF", employee, pay_invoice) == false
      calculation_allowed = false
    else
      calculation_allowed = true
    end
    if calculation_allowed == true
      if single_item.calculation_type == "Fixed"
        cal_array << single_item.fixed_item_value(employee, single_item, pay_invoice)
      else
        single_item.formula_with_code.each_with_index do |str, index|
          if single_item.from_formula_tool?(str)
            if ['(', ')', '+', '-', '/', '*', '.'].include?(str)
              cal_array << str
            end
          elsif ['%'].include?(str)
            cal_array << "/100*"
          elsif single_item.from_digits?(str)
            cal_array << str
          elsif ["Gross Salary"].include?(str)
            cal_array << Employee.effective_gross_salary(employee, pay_invoice)
          elsif ["Earned Gross Salary"].include?(str)
            cal_array << pay_invoice.payable_gross
          elsif ["Earned Gross Salary 2"].include?(str)
            if ENV.fetch("APP_URL").include?('dtlbe.srl.com.pk') or ENV.fetch("APP_URL").include?('localhost')
              if single_item.name == "Provident Fund"
                gross_salary = pay_invoice.payable_gross
                if employee.gross_salary.to_f >= 18053.0 and employee.gross_salary.to_f.to_f <= 27080.0
                  cal_array << 18053.0
                else
                  gross_salary = (gross_salary * 0.67).to_f.round(2)
                  cal_array << gross_salary
                end
              else
                gross_salary = employee.gross_salary
                if gross_salary.to_f >= 18053.0 and gross_salary.to_f <= 27080.0
                  cal_array << 18053.0
                else
                  gross_salary = (gross_salary * 0.67).to_f.round(2)
                  cal_array << gross_salary
                end
              end
            else
              cal_array << pay_invoice.payable_gross
            end
          elsif ["Earned Gross Salary House Rent"].include?(str)
            if ENV.fetch("APP_URL").include?('dtlbe.srl.com.pk') or ENV.fetch("APP_URL").include?('localhost')
              gross_salary = employee.gross_salary
              if gross_salary.to_f >= 18053.0 and gross_salary.to_f <= 27080.0
                cal_array << 0.0
              else
                gross_salary = (gross_salary * 0.3).to_f.round(2)
                cal_array << gross_salary
              end
            else
              cal_array << pay_invoice.payable_gross
            end
          elsif ["Earned Gross Salary Utility"].include?(str)
            if ENV.fetch("APP_URL").include?('dtlbe.srl.com.pk') or ENV.fetch("APP_URL").include?('localhost')
              gross_salary = employee.gross_salary
              if gross_salary.to_f >= 18053.0 and gross_salary.to_f <= 27080.0
                cal_array << gross_salary - 18053.0
              else
                house_rent = (gross_salary * 0.3).to_f.round(2)
                if gross_salary.to_f >= 18053.0 and gross_salary.to_f <= 27080.0
                  basic_salary = 18053.0
                else
                  basic_salary = (gross_salary * 0.67).to_f.round(2)
                end
                gross_salary = (gross_salary - (basic_salary + house_rent)).to_f.round(2)
                cal_array << gross_salary
              end
            else
              cal_array << pay_invoice.payable_gross
            end
          elsif single_item.pay_item?(str)
            item = PayItem.find(str.split('-')[1].to_i)
            if item.calculation_type == "Variable"
              cal_array << PayItem.calculate_formula(employee, item, pay_invoice)
            else
              cal_array << single_item.fixed_item_value(employee, item, pay_invoice)
            end
          elsif ['Short Joining Days'].include?(str)
            cal_array << pay_invoice.short_joining_days
          elsif ['Medical Allowance OPD'].include?(str)
            if ENV.fetch("APP_URL").include?('dtlbe.srl.com.pk') or ENV.fetch("APP_URL").include?('localhost')
              gross_salary = pay_invoice.payable_gross
              basic_salary = (gross_salary * 0.67).to_f.round(2)
              if [15,16,17,18,19,21,22,23].include?employee.grade_id
                cal_array << gross_salary * 0.02
              elsif [4,5,6,7,8,9,10,11,12,13,14].include?employee.grade.id
                cal_array << basic_salary * 0.02
              end
            end
          elsif ['EOBI Short Joining Days'].include?(str)
            cal_array << pay_invoice.eobi_short_joining_days
          elsif ['Short Confirmation Days'].include?(str)
            if pay_invoice.short_confirmation_days > 0
              if pay_invoice.short_confirmation_days < pay_invoice.pay_execution.total_pay_days(employee)
                cal_array << pay_invoice.short_confirmation_days
              else
                cal_array << pay_invoice.pay_execution.total_pay_days(employee)
              end
            else
              cal_array << pay_invoice.pay_execution.total_pay_days(employee)
            end
          elsif ['Attendance Deduction'].include?(str)
            cal_array << pay_invoice.deduction_days
          elsif ['PayRoll Month Days'].include?(str)
            # cal_array << pay_invoice.pay_execution.no_of_pay_days
            cal_array << pay_invoice.pay_execution.total_pay_days(employee)
          elsif ['Last PayRoll Month Days'].include?(str)
            # cal_array << pay_invoice.pay_execution.no_of_pay_days
            last_month = (pay_invoice.actual_pay_month - 1.month).to_date.strftime("%B %Y")
            old_pay_execution = PayExecution.last_pay_execution(last_month, pay_invoice.company_id, pay_invoice.location_id, pay_invoice.grade_id)
            if old_pay_execution.nil?
              cal_array << pay_invoice.pay_execution.total_pay_days(employee)
            else
              cal_array << old_pay_execution.total_pay_days(employee)
            end
          elsif ['Actual Month Days'].include?(str)
            cal_array << pay_invoice.pay_execution.end_date.end_of_month.day
          elsif ['Vehicle Allowance Value'].include?(str)
            if employee.vehicle_allowance_allowed == true
              if single_item.allowance_eligibility("Vehicle Allowance", employee, pay_invoice) == true
                cal_array << employee.vehicle_allowance_entitlement_upto
              else
                cal_array << 0
              end
            else
              cal_array << 0
            end
          elsif ['Fuel Litre'].include?(str)
            if employee.fuel_allowed == true
              if single_item.allowance_eligibility("Fuel", employee, pay_invoice) == true
                if employee.fuel_limit == "Fix Liters"
                  cal_array << employee.fuel_value
                elsif employee.fuel_limit == "Fix Amount"
                  cal_array << employee.fuel_value
                else
                  cal_array << 0
                end
              end
            else
              cal_array << 0
            end
          elsif ['Earned OverTime Hours'].include?(str)
            cal_array << pay_invoice.over_time_hours
          elsif ['Earned Off Days'].include?(str)
            cal_array << pay_invoice.off_day_payment
          elsif ['Special Encashable Quota'].include?(str)
            cal_array << pay_invoice.encashable_quota
          elsif ['Earned Arrears'].include?(str)
            cal_array << pay_invoice.arrears_days
          elsif ['Average Earned Gross Salary'].include?(str)
            start_date  = pay_invoice.actual_pay_month.beginning_of_year.to_date
            end_date    = pay_invoice.actual_pay_month.end_of_year.to_date
            date_range  = (start_date..end_date)
            item_value  = PayInvoice.where(:employee_id => employee.id, :status => true, :actual_pay_month => date_range).sum(:actual_salary)
            cal_array   << (item_value.to_f/12.0)
          elsif ['Average Earned Gross Salary 2'].include?(str) and employee.employee_type.try(:name) != 'Probation'
            if employee.joining_date && (pay_invoice.actual_pay_month.to_date - employee.joining_date.to_date).to_i >= 365
              item_value  = PayInvoice.where(:employee_id => employee.id, :status => true, :pay_month => "June #{Date.today.year}").first.actual_salary * 0.67
            else
              start_date = employee.joining_date.day <= 15 ? employee.joining_date.to_date : (employee.joining_date + 1.month).to_date
              end_date    = (pay_invoice.actual_pay_month - 1.month).end_of_month.to_date
              date_range  = (start_date..end_date).map{|a| a.strftime('%B %Y')}.uniq
              if date_range.count >= 12
                item_value  = PayInvoice.where(:employee_id => employee.id, :status => true, :pay_month => "June #{Date.today.year}").first.actual_salary * 0.67
              else
                item_value  = (PayInvoice.where(:employee_id => employee.id, :status => true, :pay_month => "June #{Date.today.year}").sum(:actual_salary)*0.67).round * date_range.count / 12
              end
            end
            cal_array   << item_value.to_f
          elsif ['Average Earned Basic Salary'].include?(str)
            start_date      = pay_invoice.actual_pay_month.beginning_of_year.to_date
            end_date        = pay_invoice.actual_pay_month.end_of_year.to_date
            date_range      = (start_date..end_date)
            pay_invoice_ids = PayInvoice.where(:employee_id => employee.id, :status => true, :actual_pay_month => date_range).collect(&:id)
            item_value      = PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => "Basic Salary").sum(:amount)
            cal_array       << (item_value.to_f/12.0)
          elsif ['Actual Days Served'].include?(str)
            item = PayItem.find_by_name('Eid Reward 2')
            if item.is_bonus
              item_eligible_date = item.bonus_eligibility(employee, item)
              if not item_eligible_date.nil?
                if item_eligible_date <= item.bonus_date.to_date
                  start_time = Time.new(item_eligible_date.to_date.year,item_eligible_date.to_date.month,item_eligible_date.to_date.day)
                  actual_serving_days = ReportFormat.date_in_human_readable(employee.joining_date, item.bonus_date).split('months')[0].split(',')[1].to_i
                  if actual_serving_days > 12 || ReportFormat.date_in_human_readable(employee.joining_date, item.bonus_date).split('years')[0].to_i >= 1
                    actual_serving_days = 12
                  end
                  if ReportFormat.date_in_human_readable(employee.joining_date, item.bonus_date).split('years')[0].to_i < 1
                    if employee.joining_date.to_date.day > 15
                      actual_serving_days = ReportFormat.date_in_human_readable((employee.joining_date + 1.month).beginning_of_month, item.bonus_date).split('months')[0].split(',')[1].to_i
                    else
                      actual_serving_days = ReportFormat.date_in_human_readable((employee.joining_date).beginning_of_month, item.bonus_date).split('months')[0].split(',')[1].to_i
                    end
                  end
                  cal_array << actual_serving_days
                else
                  cal_array << 0
                end
              else
                cal_array << 0
              end
            else
              cal_array << 0
            end
          elsif ['Quota Encashment'].include?(str)
            cal_array << LeaveAllocation.encashable_quota_non_probation(employee)
          elsif ['Loan Amount'].include?(str)
            transaction_month = (pay_invoice.pay_execution.end_date.to_date.beginning_of_month).to_date.strftime("%B %Y")
            cal_array << EmployeeLoan.employee_loan_amount(employee, transaction_month)
          elsif ['Advance Amount'].include?(str)
            transaction_month = (pay_invoice.pay_execution.start_date.to_date.beginning_of_month).to_date.strftime("%B %Y")
            cal_array << EmployeeAdvance.where(:employee_id => employee.id, :is_cleared => false, :pay_back_month => transaction_month).sum(&:advance_amount)
          elsif single_item.payitem_expression?(str)
            item_expression = PayitemExpression.find(str.split('-')[1].to_i)
            cal_array << item_expression.expression_value
          end
        end
      end
    end
    calculator = Dentaku::Calculator.new
    calculator.evaluate(cal_array.flatten.join()).to_f.round
  end

  def self.actual_calculate_formula_for_slip(employee, single_item, pay_invoice)
    cal_array = []
    calculation_allowed = false
    if single_item.name == "EOBI" && single_item.allowance_eligibility("EOBI", employee, pay_invoice) == false
      calculation_allowed = false
    elsif single_item.name == "Provident Fund" && single_item.allowance_eligibility("PF", employee, pay_invoice) == false
      calculation_allowed = false
    else
      calculation_allowed = true
    end
    if calculation_allowed == true
      if single_item.calculation_type == "Fixed"
        cal_array << single_item.fixed_item_value(employee, single_item, pay_invoice)
      else
        single_item.formula_with_code.each_with_index do |str, index|
        if single_item.from_formula_tool?(str)
          if ['(', ')', '+', '-', '/', '*', '.'].include?(str)
            cal_array << str
          end
        elsif ['%'].include?(str)
          cal_array << "/100*"
        elsif single_item.from_digits?(str)
          cal_array << str
        elsif ["Gross Salary"].include?(str)
          cal_array << pay_invoice.actual_salary
        elsif ["Earned Gross Salary"].include?(str)
          cal_array << pay_invoice.actual_salary
        elsif ["Earned Gross Salary 2"].include?(str)
          if ENV.fetch("APP_URL").include?('dtlbe.srl.com.pk') or ENV.fetch("APP_URL").include?('localhost')
            if single_item.name == "Provident Fund"
              gross_salary = pay_invoice.payable_gross
              if employee.gross_salary.to_f >= 18053.0 and employee.gross_salary.to_f.to_f <= 27080.0
                cal_array << 18053.0
              else
                gross_salary = (gross_salary * 0.67).to_f.round(2)
                cal_array << gross_salary
              end
            else
              gross_salary = employee.gross_salary
              if gross_salary.to_f >= 18053.0 and gross_salary.to_f <= 27080.0
                cal_array << 18053.0
              else
                gross_salary = (gross_salary * 0.67).to_f.round(2)
                cal_array << gross_salary
              end
            end
          else
            cal_array << pay_invoice.payable_gross
          end
        elsif ["Earned Gross Salary House Rent"].include?(str)
          if ENV.fetch("APP_URL").include?('dtlbe.srl.com.pk') or ENV.fetch("APP_URL").include?('localhost')
            gross_salary = employee.gross_salary
            if gross_salary.to_f >= 18053.0 and gross_salary.to_f <= 27080.0
              cal_array << 0.0
            else
              gross_salary = (gross_salary * 0.3).to_f.round(2)
              cal_array << gross_salary
            end
          else
            cal_array << pay_invoice.payable_gross
          end
        elsif ["Earned Gross Salary Utility"].include?(str)
          if ENV.fetch("APP_URL").include?('dtlbe.srl.com.pk') or ENV.fetch("APP_URL").include?('localhost')
            gross_salary = employee.gross_salary
            if gross_salary.to_f >= 18053.0 and gross_salary.to_f <= 27080.0
              cal_array << gross_salary - 18053.0
            else
              house_rent = (gross_salary * 0.3).to_f.round(2)
              if gross_salary.to_f >= 18053.0 and gross_salary.to_f <= 27080.0
                basic_salary = 18053.0
              else
                basic_salary = (gross_salary * 0.67).to_f.round(2)
              end
              gross_salary = (gross_salary - (basic_salary + house_rent)).to_f.round(2)
              cal_array << gross_salary
            end
          else
            cal_array << pay_invoice.payable_gross
          end
        elsif single_item.pay_item?(str)
          item = PayItem.find(str.split('-')[1].to_i)
          if item.calculation_type == "Variable"
            cal_array << PayItem.actual_calculate_formula_for_slip(employee, item, pay_invoice)
          else
            cal_array << single_item.fixed_item_value(employee, item, pay_invoice)
          end
        elsif ['Short Joining Days'].include?(str)
          cal_array << pay_invoice.short_joining_days
        elsif ['Medical Allowance OPD'].include?(str)
          if ENV.fetch("APP_URL").include?('dtlbe.srl.com.pk') or ENV.fetch("APP_URL").include?('localhost')
            gross_salary = pay_invoice.payable_gross
            basic_salary = (gross_salary * 0.67).to_f.round(2)
            if [15,16,17,18,19,21,22,23].include?employee.grade_id
              cal_array << gross_salary * 0.02
            elsif [4,5,6,7,8,9,10,11,12,13,14].include?employee.grade.id
              cal_array << basic_salary * 0.02
            end
          end
        elsif ['EOBI Short Joining Days'].include?(str)
          cal_array << pay_invoice.eobi_short_joining_days
        elsif ['Short Confirmation Days'].include?(str)
          if pay_invoice.short_confirmation_days > 0
            if pay_invoice.short_confirmation_days < pay_invoice.pay_execution.total_pay_days(employee)
              cal_array << pay_invoice.short_confirmation_days
            else
              cal_array << pay_invoice.pay_execution.total_pay_days(employee)
            end
          else
            cal_array << pay_invoice.pay_execution.total_pay_days(employee)
          end
        elsif ['Attendance Deduction'].include?(str)
          cal_array << pay_invoice.deduction_days
        elsif ['PayRoll Month Days'].include?(str)
          # cal_array << pay_invoice.pay_execution.no_of_pay_days
          cal_array << pay_invoice.pay_execution.total_pay_days(employee)
        elsif ['Last PayRoll Month Days'].include?(str)
          # cal_array << pay_invoice.pay_execution.no_of_pay_days
          last_month = (pay_invoice.actual_pay_month - 1.month).to_date.strftime("%B %Y")
          old_pay_execution = PayExecution.last_pay_execution(last_month, pay_invoice.company_id, pay_invoice.location_id, pay_invoice.grade_id)
          if old_pay_execution.nil?
            cal_array << pay_invoice.pay_execution.total_pay_days(employee)
          else  
            cal_array << old_pay_execution.total_pay_days(employee)
          end
        elsif ['Actual Month Days'].include?(str)
          cal_array << pay_invoice.pay_execution.end_date.end_of_month.day
        elsif ['Vehicle Allowance Value'].include?(str)
          if employee.vehicle_allowance_allowed == true
            if single_item.allowance_eligibility("Vehicle Allowance", employee, pay_invoice) == true
              cal_array << employee.vehicle_allowance_entitlement_upto
            else            
              cal_array << 0
            end
          else
            cal_array << 0
          end
        elsif ['Fuel Litre'].include?(str)
          if employee.fuel_allowed == true
            if single_item.allowance_eligibility("Fuel", employee, pay_invoice) == true
              if employee.fuel_limit == "Fix Liters"
                cal_array << employee.fuel_value
              elsif employee.fuel_limit == "Fix Amount"
                cal_array << employee.fuel_value
              else      
                cal_array << 0
              end
            end  
          else      
            cal_array << 0
          end
        elsif ['Earned OverTime Hours'].include?(str)
          cal_array << pay_invoice.over_time_hours
        elsif ['Earned Off Days'].include?(str)
          cal_array << pay_invoice.off_day_payment
        elsif ['Special Encashable Quota'].include?(str)
          cal_array << pay_invoice.encashable_quota
        elsif ['Earned Arrears'].include?(str)
          cal_array << pay_invoice.arrears_days
        elsif ['Average Earned Gross Salary'].include?(str)
          start_date  = pay_invoice.actual_pay_month.beginning_of_year.to_date
          end_date    = pay_invoice.actual_pay_month.end_of_year.to_date
          date_range  = (start_date..end_date)
          item_value  = PayInvoice.where(:employee_id => employee.id, :status => true, :actual_pay_month => date_range).sum(:actual_salary)
          cal_array   << (item_value.to_f/12.0)
        elsif ['Average Earned Gross Salary 2'].include?(str) and employee.employee_type.try(:name) != 'Probation'
          if employee.joining_date && (pay_invoice.actual_pay_month.to_date - employee.joining_date.to_date).to_i >= 365
            item_value  = PayInvoice.where(:employee_id => employee.id, :status => true, :pay_month => "June #{Date.today.year}").first.actual_salary * 0.67
          else
            start_date = employee.joining_date.day <= 15 ? employee.joining_date.to_date : (employee.joining_date + 1.month).to_date
            end_date    = (pay_invoice.actual_pay_month - 1.month).end_of_month.to_date
            date_range  = (start_date..end_date).map{|a| a.strftime('%B %Y')}.uniq
            if date_range.count >= 12
              item_value  = PayInvoice.where(:employee_id => employee.id, :status => true, :pay_month => "June #{Date.today.year}").first.actual_salary * 0.67
            else
              item_value  = (PayInvoice.where(:employee_id => employee.id, :status => true, :pay_month => "June #{Date.today.year}").sum(:actual_salary)*0.67).round * date_range.count / 12
            end
          end
          cal_array   << item_value.to_f
        elsif ['Average Earned Basic Salary'].include?(str)
          start_date      = pay_invoice.actual_pay_month.beginning_of_year.to_date
          end_date        = pay_invoice.actual_pay_month.end_of_year.to_date
          date_range      = (start_date..end_date)
          pay_invoice_ids = PayInvoice.where(:employee_id => employee.id, :status => true, :actual_pay_month => date_range).collect(&:id)
          item_value      = PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => "Basic Salary").sum(:amount)
          cal_array       << (item_value.to_f/12.0)
        elsif ['Actual Days Served'].include?(str)
          item = PayItem.find_by_name('Eid Reward 2')
          if item.is_bonus
            item_eligible_date = item.bonus_eligibility(employee, item)
            if not item_eligible_date.nil?
              if item_eligible_date <= item.bonus_date.to_date
                start_time = Time.new(item_eligible_date.to_date.year,item_eligible_date.to_date.month,item_eligible_date.to_date.day)
                end_time = Time.new(item.bonus_date.to_date.year,item.bonus_date.to_date.month,item.bonus_date.to_date.day)
                actual_serving_days = (TimeDifference.between(start_time, end_time).in_months) - 1
                if actual_serving_days > 12
                  actual_serving_days = 12
                end
                cal_array << actual_serving_days.floor
              else
                cal_array << 0
              end
            else
              cal_array << 0
            end
          else
            cal_array << 0
          end
        elsif ['Quota Encashment'].include?(str)
          cal_array << LeaveAllocation.encashable_quota_non_probation(employee)
        elsif ['Loan Amount'].include?(str)
          transaction_month = (pay_invoice.pay_execution.end_date.to_date.beginning_of_month).to_date.strftime("%B %Y")
          cal_array << EmployeeLoan.employee_loan_amount(employee, transaction_month)
        elsif ['Advance Amount'].include?(str)
          transaction_month = (pay_invoice.pay_execution.start_date.to_date.beginning_of_month).to_date.strftime("%B %Y")
          cal_array << EmployeeAdvance.where(:employee_id => employee.id, :is_cleared => false, :pay_back_month => transaction_month).sum(&:advance_amount)
        elsif single_item.payitem_expression?(str)
          item_expression = PayitemExpression.find(str.split('-')[1].to_i)
          cal_array << item_expression.expression_value
        end
        end
      end
    end
    calculator = Dentaku::Calculator.new
    return calculator.evaluate(cal_array.flatten.join()).to_f.round
  end

  def fixed_item_value(employee, item, pay_invoice)
    fixed_item_amount = 0
    recurring_fixed_item_amount = 0
    once_fixed_item_amount = 0
    recurring_fixed_item_amount = FixedPayItem.where(:employee_id => employee.id, :pay_item_id => item.id, :is_active => true, :item_type => "Recurring").sum(&:item_amount)
    if not pay_invoice.nil?
      once_fixed_item_amount    = FixedPayItem.where(:employee_id => employee.id, :pay_item_id => item.id, :is_active => true, :item_type => "Once", :formated_pay_month => pay_invoice.pay_month).sum(&:item_amount)  
    end
    fixed_item_amount           = (recurring_fixed_item_amount + once_fixed_item_amount).to_f.round
    return fixed_item_amount
  end

  def self.calculate_item_tax(single_item, amount)
    taxable_amount = 0
    if single_item.is_taxable == true
      if single_item.exempted_tax_percentage > 0
        exempted_tax_value = (single_item.exempted_tax_percentage * amount).to_f / 100.0
        taxable_amount = amount - exempted_tax_value
      else
        taxable_amount = amount
      end
    end
    return taxable_amount
  end

  def bonus_eligibility(employee, single_item)
    item_eligible_date = nil
    if single_item.bonus_type == "Eid Ul Fitr Bonus"
      if employee.bonus1_allowed == true
        if employee.bonus1_eligibility == "Date of Joining"
          item_eligible_date = employee.joining_date
        elsif employee.bonus1_eligibility == "Date of Confirmation"
          item_eligible_date = employee.confirmation_date
        elsif employee.bonus1_eligibility == "Completion of 1 Year"
          item_eligible_date = employee.joining_date + 1.year
        end
      end
    elsif single_item.bonus_type == "Eid Ul Adha Bouns"
      if employee.bonus2_allowed == true
        if employee.bonus2_eligibility == "Date of Joining"
          item_eligible_date = employee.joining_date
        elsif employee.bonus2_eligibility == "Date of Confirmation"
          item_eligible_date = employee.confirmation_date
        elsif employee.bonus2_eligibility == "Completion of 1 Year"
          item_eligible_date = employee.joining_date + 1.year
        end
      end
    elsif single_item.bonus_type == "Annual Bonus"
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

  def allowance_eligibility(item_type, employee, pay_invoice)
    if item_type == "PF"
      if employee.provident_fund_allowed
        if employee.provident_fund_eligibility == 'Date of Joining'
          true
        elsif employee.provident_fund_eligibility == 'Other' and employee.provident_fund_other_date and Time.parse(pay_invoice.pay_month) >= employee.provident_fund_other_date.beginning_of_month
          true
        elsif employee.provident_fund_eligibility == 'Date of Confirmation'
          if pay_invoice.on_probation == false
            if not pay_invoice.confirmation_date.nil?
              true
            else
              false
            end
          else
            false
          end
        else
          false
        end
      else
        false
      end
    elsif item_type == "EOBI"
      if employee.eobi_allowed == true
        if employee.eobi_eligibility == "Date of Joining"
          return true
        elsif employee.eobi_eligibility == "Date of Confirmation"
          if pay_invoice.on_probation == false
            if not pay_invoice.confirmation_date.nil?
              return true
            else
              return false
            end
          else
            return false  
          end
        else
          return false
        end
      else
        return false
      end
    elsif item_type == "Fuel"
      if employee.fuel_allowed == true
        if employee.fuel_eligibility == "Date of Joining"
          return true
        elsif employee.fuel_eligibility == "Date of Confirmation"
          if pay_invoice.on_probation == false
            if not pay_invoice.confirmation_date.nil?
              return true
            else
              return false
            end
          else
            return false  
          end
        else
          return false
        end
      else
        return false
      end
    elsif item_type == "Vehicle Allowance"
      if employee.vehicle_allowance_allowed == true
        if employee.vehicle_allowance_eligibility == "Date of Joining"
          return true
        elsif employee.vehicle_allowance_eligibility == "Date of Confirmation"
          if pay_invoice.on_probation == false
            if not pay_invoice.confirmation_date.nil?
              return true
            else
              return false
            end
          else
            return false  
          end
        else
          return false
        end
      else
        return false
      end
    end
  end

  def remaining_month_of_bouns_year(count)
    if count == 1
      return 11
    elsif count == 2
      return 10
    elsif count == 3
      return 9
    elsif count == 4
      return 8
    elsif count == 5
      return 7
    elsif count == 6
      return 6
    elsif count == 7
      return 5
    elsif count == 8
      return 4
    elsif count == 9
      return 3
    elsif count == 10
      return 2
    elsif count == 11
      return 1
    elsif count == 12
      return 0
    else
      return 0
    end
  end

  def from_digits?(str)
    ['1','2','3','4','5','6','7','8','9','0'].include?(str)
  end

  def from_formula_tool?(str)
    ['(', ')', '+', '-', '/', '*', '.', 'Rounding', 'R_UP', 'R_DOWN'].include?(str)
  end

  def pay_item?(str)
    str.start_with?(PayItem.name)
  end

  def payitem_expression?(str)
    str.start_with?(PayitemExpression.name)
  end

  def self.mill_instance?
    ENV.fetch("APP_URL").include?('millshrmsbe.dfl.com.pk')
  end

end
