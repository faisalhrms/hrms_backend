require 'spreadsheet'
namespace :data_process do

  desc "Change shift of stml 5 employees"
  task :change_shift => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    stml_5_shifts = Shift.where(branch_id: Branch.find_by_name('STML5'))
    sheet.each do |row|
      emp_code, shift = row.to_a.first, row.to_a.last
      emp = Employee.find_by_employee_code(emp_code)
      puts "============================"
      puts "============================"
      puts "===========#{emp.employee_code}================"
      puts "Before: #{emp.shift.try(:name)}"
      emp.update(shift: stml_5_shifts.where(name: shift).last)
      puts "After: #{emp.shift.try(:name)}"
    end
  end

  desc "Change gross salary for employees ho instance to get impact on annual bonus report"
  task :change_pay_invoice_salary => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    sheet.each do |row|
      emp_code, pay_month, salary = row.to_a.first, row.to_a[1], row.to_a[2]
      emp = Employee.find_by_employee_code(emp_code)
      if row.to_a.first
        puts "Before====Employee_code==#{emp_code}=====#{emp.pay_invoices.where(pay_month: pay_month.to_date.strftime('%B %Y')).map{|a| a.actual_salary}}============="
        emp.pay_invoices.where(pay_month: pay_month.to_date.strftime('%B %Y')).update(actual_salary: salary)
        puts "After=====Employee_code==#{emp_code}=====#{emp.pay_invoices.where(pay_month: pay_month.to_date.strftime('%B %Y')).map{|a| a.actual_salary}}=============="
        puts "IDs=======#{emp.pay_invoices.where(pay_month: pay_month.to_date.strftime('%B %Y')).map{|a| a.id}}=============="
        puts "============================"
      end
    end
  end

  desc "Change gross salary for employees mill instance to get impact on annual bonus report"
  task :change_gross_salary_mill => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    sheet.each do |row|
      emp_code, salary = row.to_a.first, row.to_a[1]
      emp = Employee.find_by_employee_code(emp_code)
      if emp and row.to_a.first
        puts "============================"
        puts "Before=======#{emp.employee_code}=========#{emp.gross_salary}=============="
        puts emp.update(gross_salary: salary) if emp.gross_salary != row.to_a[1]
        puts "After=======#{emp.employee_code}=========#{emp.gross_salary}=============="
      end
    end
  end


  desc "Remove duplicated excel logs attendance"
  task :remove_duplicated_logs => :environment do
    new_book = Spreadsheet::Workbook.new
    new_sheet = new_book.create_worksheet(name: 'Attendance Changed')

    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    count = 0
    sheet.each do |row|
      emp_code, checkin_time = row.to_a.first, row.to_a.last
      if row.to_a.last
        array = checkin_time.split(' ').first.split('/')
        user_time = Time.parse("#{array[2] + "-0#{array[0]}" + "-#{array[1]}"} #{checkin_time.split(' ')[1]} #{checkin_time.split(' ')[2]}").to_s.split(' +').first.gsub(" ", 'T')
        unless AttendanceMachineLog.where("actual_attendance_date like ? AND employee_code = ?", "%#{user_time}%", emp_code.to_s).exists?
          new_sheet.row(count).push(emp_code, checkin_time)
          count = count + 1
          puts "==================#{checkin_time}===#{emp_code}======#{count}"
        end
      end
    end
    new_book.write 'new_attendance.xls'
  end

  desc "Insert missing attendance into sql"
  task :add_missing_attendance_sql => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    sheet.each do |row|
      emp_code, checkin_time = row.to_a.first, row.to_a.last
      if row.to_a.last
        puts "============================"
        array = checkin_time.split(' ').first.split('/')
        user_time = Time.parse("#{array[2] + "-0#{array[0]}" + "-#{array[1]}"} #{checkin_time.split(' ')[1]} #{checkin_time.split(' ')[2]}").to_s.split(' +').first + '.000'
        insert_sql = "INSERT INTO DailyRecord (EmpID, UserTime, DeviceID, Status, Remarks) VALUES ('#{emp_code}', '#{user_time}', '2', 'OK', 'Manual')"
        ActiveRecord::Base.connection.select_all insert_sql
        puts "=============#{emp_code}===#{checkin_time}============"
      end
    end
  end

  desc "Change employee leave allocations"
  task :change_leave_allocation => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    leave_type = LeaveType.where(name: 'Annual Leave', location_id: Location.find_by_name('Garment'))
    sheet.each do |row|
      emp_code, allocated_leaves = row.to_a.first, row.to_a.last
      emp = Employee.find_by_employee_code(emp_code)
      if row.to_a.last and emp
        leave_allocations = LeaveAllocation.where(employee_id: Employee.find_by_employee_code(emp.employee_code), leave_type_id: leave_type)
        leave_allocations.each do |leave|
          puts "Before=============Employee Code= #{emp_code}===Old allocated leaves = #{leave.allocated_quota}========OLD Remaining Quota=#{leave.remaining_quota}"
          leave.update_columns(allocated_quota: allocated_leaves, remaining_quota: 0, used_quota: 0)
          puts "After=============Employee Code= #{emp_code}===New allocated leaves = #{allocated_leaves}===========Remaining Quota=#{leave.remaining_quota}\n"
        end
      end
    end
  end

  desc "Add bank details"
  task :add_bank_details => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    emp_codes = []
    sheet.each do |row|
      emp_code, account_no = row.to_a.first, row.to_a.last
      emp = Employee.find_by_employee_code(emp_code)
      if row.to_a.last and emp
        emp_codes << emp.employee_code
        puts '================='
        puts emp.update(payment_method: 'Bank', bank_name: 'Bank Al Habib Limited', bank_account_number: account_no)
        puts "After: #{emp.employee_code} ====== #{emp.payment_method}, #{emp.bank_name}, #{emp.bank_account_number}"
      end
    end
    puts Employee.where(is_active: true).where.not(employee_code: emp_codes.map(&:to_i)).update_all(payment_method: 'Cash')
  end

  desc "change table column"
  task :change_table_column => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    model_name = sheet.first.to_a[2]
    change_column = sheet.first.to_a[1]
    sheet.each do |row|
      unless row.to_a.first == 'header'
        emp_code = row.to_a.first
        value = row.to_a.last
        emp = model_name.constantize.find_by_employee_code(emp_code)
        if emp and row.to_a.first
          puts "Before=====emp_code=#{emp_code}====#{change_column}===#{emp[change_column]}=============="
          emp[change_column] = value
          puts "Saved?==============#{emp.save!(validate: false)}"
          emp = model_name.constantize.find_by_employee_code(emp_code)
          puts "After=====emp_code=#{emp_code}====#{change_column}===#{emp[change_column]}=============="
          puts ''
        end
      end
    end
  end

  desc "change employee attendance_exempted"
  task :change_employee_attendance_exempted => :environment do
    location = Location.find_by_name("Garment")
    employees = Employee.where(:is_active => true, :location_id => location.id, :attendance_exempted => false)
    employees.update_all(attendance_exempted: true)
    puts employees.map{|a| a.employee_code}
  end

  desc "Add pay deduction to attendance cutoff via bulk adjustment"
  task :add_pay_deduction => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    # cut_off = AttendanceCutoff.last
    sheet.each do |row|
      emp_code, deduction = row.to_a.first, row.to_a.last
      emp = Employee.find_by_employee_code(emp_code)
      if emp
        finalize_att = cut_off.finalize_attendances.where(employee_id: Employee.find_by_employee_code(emp_code)).last
        puts "Before=#{emp_code}======#{finalize_att.try(:pay_deduction)}=============="
        puts finalize_att.update(pay_deduction: deduction.to_f) if finalize_att
        puts "After===#{emp_code}====#{deduction.to_f}=============="
        puts ' ========================'
        puts ''
      end
    end
  end

  desc "change probation"
  task :change_probation => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    sheet.each do |row|
      emp = Employee.find_by_employee_code(row.to_a.first)
      if row.present? and emp
        puts "============================"
        puts "===========#{emp.employee_code}================"
        emp.update(confimration_due_date: emp.joining_date + (6.month -  1.day))
        emp.update(confirmation_date: emp.joining_date + (6.month -  1.day))
        emp.update(on_probation: true)
        puts "After: #{emp.confirmation_date}"
        puts "After: #{emp.on_probation}"
      end
    end
  end

  desc "add doj and doc"
  task :add_joining_date => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    sheet.each do |row|
      joining_date = row.to_a[1]
      confirmation_date = row.to_a[2]
      emp = Employee.find_by_employee_code(row.to_a.first)
      if row.present? and emp
        puts "============================"
        puts "===========#{emp.employee_code}================"
        emp.update(confimration_due_date: confirmation_date)
        emp.update(confirmation_date: confirmation_date)
        emp.update(joining_date: joining_date)
        emp.update(on_probation: false)
        puts "After: #{emp.confirmation_date}"
        puts "After: #{emp.joining_date}"
        puts "After: #{emp.on_probation}"
      end
    end
  end

  desc "hold salary status"
  task :hold_salary_status => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    sheet.each do |row|
      emp = Employee.find_by_employee_code(row.to_a.first)
      if row.present? and emp
        puts "===========#{emp.employee_code} #{emp.hold_salary}================"
        emp.update(hold_salary: false)
        puts "After: #{emp.hold_salary}"
        puts ''
      end
    end
  end

  desc "change provident fund"
  task :change_provident_fund => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    sheet.each do |row|
      emp = Employee.find_by_employee_code(row.to_a.first)
      pf_value = row.to_a.last
      if row.present? and emp
        pay_invoice = emp.pay_invoices.last
        puts "===========#{emp.employee_code} #{emp.employee_taxable_incomes.where(pay_invoice_id: pay_invoice.id).first.try(:employeer_pf_value)}================"
        puts "===========#{emp.employee_code} #{pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").first.try(:amount)}================"
        sys_pf_value = pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").first.try(:amount)
        puts emp.employee_taxable_incomes.where(pay_invoice_id: pay_invoice.id).first.update(employeer_pf_value: pf_value)
        puts pay_invoice.pay_invoice_details.where(:item_name => "Provident Fund").first.update(amount: pf_value)
        puts pay_invoice.update(total_deduction: (pay_invoice.total_deduction - (sys_pf_value.to_f - pf_value.to_f)))
        puts ''
      end
    end
  end

  desc "Change employee taxable income"
  task :change_tax_income => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    sheet.each do |row|
      emp = Employee.find_by_employee_code(row.to_a.first)
      tax_value = row.to_a.last
      if row.present? and emp
        pay_invoice = emp.pay_invoices.last
        puts "===========#{emp.employee_code} #{emp.employee_taxable_incomes.where(pay_invoice_id: pay_invoice.id).first.try(:monthly_tax_amount)}================"
        puts "===========#{emp.employee_code} #{pay_invoice.try(:monthly_tax)}================"
        puts emp.employee_taxable_incomes.where(pay_invoice_id: pay_invoice.id).first.update(monthly_tax_amount: tax_value)
        puts pay_invoice.update(monthly_tax: tax_value)
        puts ''
      end
    end
  end

  desc "Adjust employee tax"
  task :tax_adjustment => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    sheet.each do |row|
      emp_code, amount = row.to_a.first, row.to_a.last
      emp = Employee.find_by_employee_code(emp_code)
      if emp
        employee_tax_adjustment = EmployeeTaxAdjustment.new
        employee_tax_adjustment.is_active = true
        employee_tax_adjustment.employee_id = emp.id
        employee_tax_adjustment.amount = amount
        employee_tax_adjustment.reason = 'August manual adjustment'
        employee_tax_adjustment.company_id = emp.company_id
        employee_tax_adjustment.tax_adjustment_month = (Time.now - 1.month).to_date.beginning_of_month.to_date
        employee_tax_adjustment.tax_adjustment_formatted_month = 'August 2020'
        puts "#{emp.employee_code}===========#{employee_tax_adjustment.save!}====#{employee_tax_adjustment.amount}"
        puts ''
      end
    end
  end

  desc "Add resign"
  task :add_resign => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    sheet.each do |row|
      emp_code, date = row.to_a.first, row.to_a.last
      emp = Employee.find_by_employee_code(emp_code)
      if row.to_a.last and emp
        puts '================='
        emp_history = EmployeeTransactionHistory.new
        emp_history.employee_id = emp.id
        emp_history.transaction_type = 'End of Employment'
        emp_history.transaction_date = date
        emp_history.hold_salary = true
        emp_history.left_type = 'Resignation'
        puts emp_history.save
        puts emp.update(hold_salary: true, left_type: 'Resignation', is_active: false)
      end
    end
  end

  task :change_approval_request => :environment do
    changed = ApprovalRequest.where(approval_request_status: 'Approved')
    changed.each do |approval_request|
      if approval_request.requestable.request_status == 'Waiting For Approval'
        approval_request.update_column(:approval_request_status, 'Waiting For Approval')
        puts "Line manager is #{approval_request.requestable.employee.line_manager.user.email}"
        puts "Start date of request is #{approval_request.requestable.start_date}"
        puts "End date of request is #{approval_request.requestable.end_date}"
        puts "Request type is #{approval_request.requestable_type}"
        puts "Request sender employee code is #{Employee.find(approval_request.request_sender_id).employee_code}"
        puts "========================="
      end
    end
  end

  task :bulk_update_rosters => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    start_date = Time.now.beginning_of_month.to_date
    end_date = Time.now.end_of_year.to_date
    sheet.each do |row|
      emp_code, time_slot_name, start_date, end_date, rest_day = row.to_a.first, row.to_a[1].to_s, row.to_a[2].to_s, row.to_a[3].to_s, row.to_a[4].to_s
      emp = Employee.find_by_employee_code(emp_code)
      start_date = Time.now.beginning_of_month.to_date
      end_date = Time.now.end_of_year.to_date
      puts "==========#{emp.employee_code}======="
      if emp and EmployeeRoster.where(roster_date: start_date.to_date..end_date, employee_id: emp.id).where.not(created_at: (Time.now-5.days)..Time.now).exists?
        while start_date <= end_date do
          employee_roster = EmployeeRoster.where(roster_date: start_date.to_date, employee_id: emp.id).where.not(created_at: (Time.now-5.days)..Time.now).try(:last)
          if employee_roster.present?
            employee_roster.employee_id         = emp.id
            employee_roster.company_id          = emp.company_id
            employee_roster.location_id         = emp.location_id
            employee_roster.branch_id           = emp.branch_id
            employee_roster.department_id       = emp.department_id
            employee_roster.sub_department_id   = emp.sub_department_id
            employee_roster.grade_id            = emp.grade_id
            employee_roster.joining_date        = emp.joining_date.to_date
            employee_roster.roster_date         = start_date.to_date
            employee_roster.employee_code       = emp_code
            employee_roster.employee_name       = emp.full_name
            employee_roster.location_name       = emp.location_name
            employee_roster.branch_name         = emp.branch_name
            employee_roster.department_name     = emp.department_name
            employee_roster.grade_name          = emp.grade_name
            if rest_day.downcase == "sunday"
              employee_roster.is_rest_day       = start_date.sunday? ? true : false
            end
            time_slot                           = TimeSlot.where(company_id: emp.company_id, location_id:emp.location_id, branch_id: emp.branch_id, is_active: true, name: time_slot_name).first
            employee_roster.time_slot_id        = time_slot.id
            employee_roster.is_flexi            = time_slot.is_flexi
            employee_roster.start_time          = time_slot.start_time
            employee_roster.end_time            = time_slot.end_time
            employee_roster.formated_start_time = time_slot.actual_start_time
            employee_roster.formated_end_time   = time_slot.actual_end_time
            employee_roster.start_buffer        = time_slot.start_buffer
            employee_roster.end_buffer          = time_slot.end_buffer
            puts "==================#{emp.employee_code}=======#{start_date}====#{end_date}================================================================================================="
            puts employee_roster.save
            puts '=============================================================================================================================='
          end
          start_date += 1.day
        end
      end
    end
  end

  desc "Create Roster"
  task :bulk_create_rosters => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    sheet.each do |row|
      emp_code, time_slot_name, start_date, end_date, rest_day = row.to_a.first, row.to_a[1].to_s, row.to_a[2].to_s, row.to_a[3].to_s, row.to_a[4].to_s
      emp = Employee.find_by_employee_code(emp_code)
      if emp
        start_date = Time.now.beginning_of_month.to_date
        end_date = Time.now.end_of_year.to_date
        while start_date <= end_date do
          employee_roster = EmployeeRoster.new
          employee_roster.employee_id         = emp.id
          employee_roster.company_id          = emp.company_id
          employee_roster.location_id         = emp.location_id
          employee_roster.branch_id           = emp.branch_id
          employee_roster.department_id       = emp.department_id
          employee_roster.sub_department_id   = emp.sub_department_id
          employee_roster.grade_id            = emp.grade_id
          employee_roster.joining_date        = emp.joining_date.to_date
          employee_roster.roster_date         = start_date.to_date
          employee_roster.employee_code       = emp_code
          employee_roster.employee_name       = emp.full_name
          employee_roster.location_name       = emp.location_name
          employee_roster.branch_name         = emp.branch_name
          employee_roster.department_name     = emp.department_name
          employee_roster.grade_name          = emp.grade_name
          if rest_day.downcase == "sunday"
            employee_roster.is_rest_day       = start_date.sunday? ? true : false
          elsif rest_day.downcase == "saturday"
            employee_roster.is_rest_day       = start_date.saturday? ? true : false
          elsif rest_day.downcase == "friday"
            employee_roster.is_rest_day       = start_date.friday? ? true : false
          elsif rest_day.downcase == "thursday"
            employee_roster.is_rest_day       = start_date.thursday? ? true : false
          elsif rest_day.downcase == "wednesday"
            employee_roster.is_rest_day       = start_date.wednesday? ? true : false
          elsif rest_day.downcase == "tuesday"
            employee_roster.is_rest_day       = start_date.tuesday? ? true : false
          elsif rest_day.downcase == "monday"
            employee_roster.is_rest_day       = start_date.monday? ? true : false
          end
          time_slot                           = TimeSlot.where(company_id: emp.company_id, location_id:emp.location_id, branch_id: emp.branch_id, is_active: true, name: time_slot_name).first
          employee_roster.time_slot_id        = time_slot.id
          employee_roster.is_flexi            = time_slot.is_flexi
          employee_roster.start_time          = time_slot.start_time
          employee_roster.end_time            = time_slot.end_time
          employee_roster.formated_start_time = time_slot.actual_start_time
          employee_roster.formated_end_time   = time_slot.actual_end_time
          employee_roster.start_buffer        = time_slot.start_buffer
          employee_roster.end_buffer          = time_slot.end_buffer
          puts "==================#{emp.employee_code}=======#{start_date}====#{end_date}================================================================================================="
          puts employee_roster.save
          puts '=============================================================================================================================='
          start_date += 1.day
        end
      end
    end
  end

  desc "Change HO July Monthly Tax Amount"
  task :change_july_tax_amount => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    sheet.each do |row|
      emp_code, monthly_tax = row.to_a.first, row.to_a.last
      emp = Employee.find_by_employee_code(emp_code)
      if row.to_a.last and emp
        puts '================='
        puts "=========#{emp_code}========"
        pay_invoice = emp.pay_invoices.where(pay_month: 'July 2020', status: true).last
        puts "Pay Invoice Count: #{emp.pay_invoices.where(pay_month: 'July 2020', status: true).count}"
        puts "Before update monthly_tax = #{pay_invoice.try(:monthly_tax)}"
        puts pay_invoice.update(monthly_tax: monthly_tax)
        puts "After update #{pay_invoice.monthly_tax}"
        puts "EmployeeTaxIncome count = #{EmployeeTaxableIncome.where(pay_invoice_id: pay_invoice.id).count}"
        puts "Before update monthly_tax_amount = #{EmployeeTaxableIncome.where(pay_invoice_id: pay_invoice.id).last.try(:monthly_tax_amount)}"
        puts EmployeeTaxableIncome.where(pay_invoice_id: pay_invoice.id).last.update(monthly_tax_amount: monthly_tax)
        puts '=================================='
      end
    end
  end

  task :change_sep_tax_amount => :environment do
    employees = PayInvoice.where(pay_month: 'September 2020', status: true, is_locked: true).pluck(:employee_id)
    Employee.find(employees).each do |emp|
      puts "================="
      pay_invoice = emp.pay_invoices.where(pay_month: 'September 2020', status: true).last
      pay_august = emp.pay_invoices.where(pay_month: 'August 2020', status: true).last
      pay_july = emp.pay_invoices.where(pay_month: 'July 2020', status: true).last
      last_emp_income = EmployeeTaxableIncome.where(pay_invoice_id: pay_invoice.id).last
      puts "Before=====#{emp.employee_code}=====#{last_emp_income.total_paid_tax}"
      last_emp_income.update(total_paid_tax: EmployeeTaxableIncome.where(pay_invoice_id: [pay_august.try(:id), pay_july.try(:id), pay_invoice.try(:id)].compact).sum(:monthly_tax_amount) - EmployeeTaxableIncome.where(pay_invoice_id: pay_august.try(:id)).sum(:total_paid_tax))
      puts "After=====#{emp.employee_code}=====#{last_emp_income.total_paid_tax}\n"
    end
  end

  task :add_bonus_to_july_tax_amount => :environment do
    employees = (PayInvoice.where(pay_month: 'July 2020', status: true, is_locked: true).pluck(:employee_id))
    Employee.find(employees).each do |emp|
      puts "================="
      pay_invoice = emp.pay_invoices.where(pay_month: 'July 2020', status: true, is_locked: true).last
      if pay_invoice
        last_emp_income = EmployeeTaxableIncome.where(pay_invoice_id: pay_invoice.id).last
        if emp.employee_code == '771689'
          pay_invoice.pay_invoice_details.where(item_name: 'Annual Bonus').last.update_column(:amount, 0)
        elsif emp.employee_code == '771690'
          pay_invoice.pay_invoice_details.where(item_name: 'Annual Bonus').last.update_column(:amount, 297220)
        end
        bonus = pay_invoice.pay_invoice_details.where(item_name: 'Annual Bonus').last.amount
        puts "Before=====#{emp.employee_code}  Bonus #{bonus}====current_taxable_amount=#{last_emp_income.current_taxable_amount}, taxable_amount_to_date: #{last_emp_income.taxable_amount_to_date}"
        last_emp_income.update(current_taxable_amount: last_emp_income.current_taxable_amount + bonus) if last_emp_income.current_taxable_amount > 0
        last_emp_income.update(taxable_amount_to_date: last_emp_income.taxable_amount_to_date + bonus) if last_emp_income.taxable_amount_to_date > 0
        puts "After=====#{emp.employee_code}  Bonus #{bonus}====current_taxable_amount=#{last_emp_income.current_taxable_amount}, taxable_amount_to_date: #{last_emp_income.taxable_amount_to_date}"
      end
    end
  end

  task :change_tax_details_sep => :environment do
    employees = PayInvoice.where(pay_month: 'September 2020', status: true, is_locked: true).pluck(:employee_id)
    Employee.find(employees).each do |emp|
      puts "================="
      pay_invoice = emp.pay_invoices.where(pay_month: 'September 2020', status: true).last
      pay_august = emp.pay_invoices.where(pay_month: 'August 2020', status: true).last
      pay_july = emp.pay_invoices.where(pay_month: 'July 2020', status: true).last
      august_last_emp = EmployeeTaxableIncome.where(pay_invoice_id: pay_august.try(:id)).last
      sep_emp_income = EmployeeTaxableIncome.where(pay_invoice_id: pay_invoice.try(:id)).last
      july_emp_income = EmployeeTaxableIncome.where(pay_invoice_id: pay_july.try(:id)).last
      if august_last_emp and july_emp_income
        puts "August Before=====#{emp.employee_code}=====#{august_last_emp.taxable_amount_to_date}"
        puts august_last_emp.update(taxable_amount_to_date:  july_emp_income.taxable_amount_to_date + august_last_emp.current_taxable_amount)
        puts "August After=====#{emp.employee_code}=====#{august_last_emp.taxable_amount_to_date}"
      end
      if sep_emp_income and august_last_emp
        puts "Sep Before=====#{emp.employee_code}=====#{sep_emp_income.taxable_amount_to_date}"
        puts sep_emp_income.update(taxable_amount_to_date:  august_last_emp.taxable_amount_to_date + sep_emp_income.current_taxable_amount)
        puts "Sep After=====#{emp.employee_code}=====#{sep_emp_income.taxable_amount_to_date}"
      end
    end
  end

  task :srl_tax => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    company = Company.last
    fiscal_year = FiscalYear.last
    sheet.each do |row|
      emp_code = row.to_a[0]
      tax_deducted_july, tax_deducted_aug, tax_deducted_sep = row.to_a[1], row.to_a[2], row.to_a[3]
      provident_july, provident_aug, provident_sep = row.to_a[4], row.to_a[5], row.to_a[6]
      taxable_july, taxable_aug, taxable_sep = row.to_a[7], row.to_a[8], row.to_a[9]
      emp = Employee.find_by_employee_code(emp_code)
      if emp
        july_emp_income = EmployeeTaxableIncome.new(:company_id => company.id, :employee_id => emp.id, :fiscal_year_id => fiscal_year.id, monthly_tax_amount: tax_deducted_july.to_i)
        july_emp_income.taxable_amount_to_date= taxable_july.to_i
        july_emp_income.employeer_pf_value= provident_july.to_i
        puts "#{emp.employee_code} July taxable income =  #{july_emp_income.save}"

        aug_emp_income = EmployeeTaxableIncome.new(:company_id => company.id, :employee_id => emp.id, :fiscal_year_id => fiscal_year.id, monthly_tax_amount: tax_deducted_aug.to_i)
        aug_emp_income.taxable_amount_to_date =  taxable_aug.to_i + taxable_july.to_i
        aug_emp_income.employeer_pf_value= provident_aug.to_i
        puts "#{emp.employee_code} August taxable income =  #{aug_emp_income.save}"

        sep_emp_income = EmployeeTaxableIncome.new(:company_id => company.id, :employee_id => emp.id, :fiscal_year_id => fiscal_year.id, monthly_tax_amount: tax_deducted_sep.to_i)
        sep_emp_income.taxable_amount_to_date = taxable_sep.to_i + taxable_aug.to_i + taxable_july.to_i
        sep_emp_income.employeer_pf_value= provident_sep.to_i
        puts "#{emp.employee_code} September taxable income =  #{sep_emp_income.save}"
      end
    end
  end

  task :gross_salary_change_new => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    sheet.each do |row|
      emp_code = row.to_a[0]
      new_gross_salary = row.to_a[1]
      emp = Employee.find_by_employee_code(emp_code)
      old_gross_salary = emp.gross_salary
      employee_transaction_history = emp.employee_transaction_histories.new
      if emp
        employee_transaction_history.transaction_type  = 'Gross Salary'
        employee_transaction_history.old_gross_salary  = old_gross_salary
        employee_transaction_history.new_gross_salary  = new_gross_salary
        employee_transaction_history.transaction_date  = (Time.now - 1.month).beginning_of_month
        puts "#{emp.employee_code}:    #{employee_transaction_history.save}"
      end
    end
  end

  task :update_bulk_incentive => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    sheet.each do |row|
      emp_code = row.to_a[0]
      new_amount = row.to_a[1]
      emp = Employee.find_by_employee_code(emp_code)
      pay_item = PayItem.find_by_name('Incentive')
      if emp
        incentive = emp.fixed_pay_items.find_or_create_by(pay_item_id: pay_item.id)
        puts "=============#{emp.employee_code}====#{incentive.try(:item_amount)}"
        incentive.item_amount = new_amount
        incentive.company_id = emp.company_id
        incentive.is_active = true
        puts "===#{emp.employee_code}========#{incentive.save}================"
      end
    end
  end


  task :salary_arrear_update => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    pay_execution = PayExecution.where(name: ["Head Office Nov-20", "Mill November-20", "Residence November-20"])
    pay_invoices = PayInvoice.where(pay_execution_id: [pay_execution[0].id, pay_execution[1].id, pay_execution[2].id])
    sheet.each do |row|
      emp_code = row.to_a[0].to_s
      emp = Employee.find_by_employee_code(emp_code)
      inc_value = row.to_a[4].to_f - row.to_a[3].to_f
      if emp
        pay_item = PayItem.where(name: "Increment Arrears").first
        emp_pay_invoice = pay_invoices.where(employee_id: emp.id).last
        if emp_pay_invoice.present?
          emp_pay_invoice.pay_invoice_details.where(item_name: "Increment Arrears").update(amount: inc_value)
        end
        fixed_item = emp.fixed_pay_items.new
        fixed_item.company_id = emp.company_id
        fixed_item.pay_item_id = pay_item.id
        fixed_item.item_amount = inc_value.round
        fixed_item.is_active = true
        fixed_item.pay_month = pay_execution[0].pay_month
        fixed_item.formated_pay_month = pay_execution[0].formated_pay_month
        fixed_item.item_type = "Once"
        puts "#{emp.employee_code}: #{fixed_item.save}"
      end
    end
  end

  task :pf_lwp_update => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    pay_execution = PayExecution.where(name: ["Head Office Nov-20", "Mill November-20", "Residence November-20"])
    pay_invoices = PayInvoice.where(pay_execution_id: [pay_execution[0].id, pay_execution[1].id, pay_execution[2].id])
    sheet.each do |row|
      emp_code = row.to_a[0].to_s
      pf_value = row.to_a[8].value.to_f
      lwp = row.to_a[10].value.to_f
      emp = Employee.find_by_employee_code(emp_code)
      if emp
        emp_pay_invoice = pay_invoices.where(employee_id: emp.id).last
        if emp_pay_invoice.present?
          inc_value = emp_pay_invoice.pay_invoice_details.where(item_name: "Arrears Provident Fund").last.amount + pf_value
          emp_pay_invoice.pay_invoice_details.where(item_name: "Arrears Provident Fund").update(amount: inc_value.round)
        end

        pay_item = PayItem.where(name: "Arrears Provident Fund").first
        fixed_item = emp.fixed_pay_items.new
        fixed_item.company_id = emp.company_id
        fixed_item.pay_item_id = pay_item.id
        fixed_item.item_amount = pf_value.round
        fixed_item.is_active = true
        fixed_item.pay_month = pay_execution[0].pay_month
        fixed_item.formated_pay_month = pay_execution[0].formated_pay_month
        fixed_item.item_type = "Once"
        puts "#{emp.employee_code}: #{fixed_item.save}"


        if emp_pay_invoice.present?
          inc_value = emp_pay_invoice.pay_invoice_details.where(item_name: "Salary Deduction").last.amount + lwp
          emp_pay_invoice.pay_invoice_details.where(item_name: "Salary Deduction").update(amount: inc_value.round)
        end
        pay_item = PayItem.where(name: "Salary Deduction").first
        fixed_item = emp.fixed_pay_items.new
        fixed_item.company_id = emp.company_id
        fixed_item.pay_item_id = pay_item.id
        fixed_item.item_amount = lwp.round
        fixed_item.is_active = true
        fixed_item.pay_month = pay_execution[0].pay_month
        fixed_item.formated_pay_month = pay_execution[0].formated_pay_month
        fixed_item.item_type = "Once"
        puts "#{emp.employee_code}: #{fixed_item.save}"
      end
    end
  end

  task :change_hiring_shift => :environment do
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    sheet.each do |row|
      emp = Employee.find_by_employee_code(row.to_a.first)
      if emp
        puts "============================"
        puts "===========#{emp.employee_code}================"
        puts emp.update(hiring_shift_id: GeneralType.find_by(type_name: 'hiring_shift', name: row.to_a.last).try(:id))
        puts "After: #{Employee.find_by_employee_code(row.to_a.first).hiring_shift_id}"
      end
    end
  end

  task :add_new_leave_balances => :environment do
    leave_year = LeaveYear.where(is_active: true).last
    open_book = Spreadsheet.open(ENV['NAME'])
    sheet = open_book.worksheet 0
    sheet.each do |row|
      employee = Employee.find_by_employee_code(row.to_a.first)
      if employee
        ['Casual Leave', 'Sick Leave', 'Compensatory pay Leave'].each_with_index do |name, index|
          # ['Casual Leave', 'Sick Leave'].each_with_index do |name, index|
          leave_type = LeaveType.find_by(:name => name, :location_id => employee.location_id, is_active: true)
          if leave_type
            leave_allocation = LeaveAllocation.new
            leave_allocation.company_id = employee.company_id
            leave_allocation.employee_id = employee.id
            leave_allocation.leave_type_id = leave_type.id
            leave_allocation.location_id = employee.location_id
            leave_allocation.leave_year_id = leave_year.id
            leave_allocation.leave_year_start_date = leave_year.start_date
            leave_allocation.leave_year_end_date = leave_year.end_date
            leave_allocation.is_active = true
            leave_allocation.allocated_quota = row.to_a[index+1]
            leave_allocation.used_quota = 0
            leave_allocation.remaining_quota = leave_allocation.allocated_quota
            if leave_allocation.save(:validate => false)
              puts "==========#{employee.employee_code}========Leave Name: #{name}, =====allocated_quota #{leave_allocation.allocated_quota}"
              LeaveTransactionHistory.create_leave_transaction(leave_allocation.company_id, leave_allocation.employee_id, leave_allocation.leave_type_id, nil, leave_allocation.allocated_quota, leave_allocation.remaining_quota, leave_allocation.used_quota, 0.0, "Earned", "Allocated By System", leave_allocation.leave_year_start_date, leave_allocation.leave_year_end_date, leave_allocation.id)
            end
          end
        end
      end
    end
  end

  task :auto_confirm_employees => :environment do
    SystemSetting.auto_confirmation_process
  end

  desc 'all employee except contractual salary info from pay invoices for whole current year'
  task :monthly_employees_data => :environment do
    d1 = Time.now.beginning_of_year.to_date
    d2 = Time.now.end_of_year.to_date
    months = (d1..d2).map{ |m| m.strftime("%B %Y") }.uniq
    book = Axlsx::Package.new
    wb = book.workbook
    sheet = wb.add_worksheet(name: 'Salary Register')
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
    bold_column_format = wb.styles.add_style(:bg_color => "E2C9F1", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center}, :b => true)
    header_style = sheet.styles.add_style(:border => Axlsx::STYLE_THIN_BORDER, :bg_color => "c2c7c1", :sz => 10, :height =>15, :alignment => { :horizontal=> :center }, :font_name => 'Tahoma', :b => true)
    table_header = ["Sr #", "Emp Code", "Name", "DOJ", "Month", "Basic Salary", "Gross Salary"]
    sheet.add_row table_header, :style => header_style
    row_format = wb.styles.add_style(:bg_color => "ffffff", :fg_color=> "000000", :sz => 8,  :border=> {:style => :thin, :color => "000000"}, :alignment => { :horizontal => :center, :vertical => :center})
    count = 1
    @pay_invoices = PayInvoice.where(status: true, pay_month: months).where.not(employee_type_id: EmployeeType.find_by_name('Contractual').id).includes(:employee).order('id DESC')
    employees = @pay_invoices.collect(&:employee).uniq
    grand_total_basic = 0
    grand_total_gross = 0
    employees.each do |employee|
      total_basic = 0
      total_gross = 0
      current_row_value = []
      current_row_style = []
      current_row_type = []
      current_row_value << count
      current_row_style << row_format
      current_row_type << :integer
      current_row_value << employee.employee_code
      current_row_style << row_format
      current_row_type << :string
      current_row_value << employee.full_name
      current_row_style << row_format
      current_row_type << :string
      current_row_value << ReportFormat.date_format(employee.joining_date)
      current_row_style << row_format
      current_row_type << :string
      current_row_value << ''
      current_row_style << row_format
      current_row_type << :string
      current_row_value << ''
      current_row_style << row_format
      current_row_type << :string
      current_row_value << ''
      current_row_style << row_format
      current_row_type << :string
      sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
      months.each do |month|
        pay_invoice = @pay_invoices.where(pay_month: month, employee_id: employee.id).last
        if pay_invoice.present?
          basic_salary = pay_invoice.pay_invoice_details.where(:item_name => "Basic Salary").sum(:amount).round(2)
          current_row_value = []
          current_row_style = []
          current_row_type = []
          current_row_value << ''
          current_row_style << row_format
          current_row_type << :string
          current_row_value << ''
          current_row_style << row_format
          current_row_type << :string
          current_row_value << ''
          current_row_style << row_format
          current_row_type << :string
          current_row_value << ''
          current_row_style << row_format
          current_row_type << :string
          current_row_value << month
          current_row_style << row_format
          current_row_type << :string
          current_row_value << basic_salary
          current_row_style << row_format
          current_row_type << :integer
          current_row_value << pay_invoice.actual_salary
          current_row_style << row_format
          current_row_type << :integer
          sheet.add_row current_row_value, :style => current_row_style, :types => current_row_type
          total_basic += basic_salary
          total_gross += pay_invoice.actual_salary
        end
      end
      sheet.add_row ['Total', '', '', '', '', total_basic, total_gross], :style => header_style
      count += 1
      grand_total_basic += total_basic
      grand_total_gross += total_gross
    end
    sheet.add_row ['Grand Total', '', '', '', '', grand_total_basic, grand_total_gross], :style => header_style
    file_name = "employees_salary_information"
    file_path = "/excel/#{file_name}_#{Time.now.to_i}.xlsx"
    book.serialize "#{Rails.public_path.to_s + file_path}"
  end

  # lib/tasks/import_leave_official_duty_frontend.rake
  namespace :hrms do
    def normalize_header_value(value)
      value.to_s.strip.downcase.gsub(/\s+/, " ")
    end

    def import_columns_from_header(row)
      header = row.map { |value| normalize_header_value(value) }

      code_keys = ["employee code", "emp code", "employee_code"]
      wfh_keys  = ["work from home", "wfh", "work_from_home"]

      has_code = code_keys.any? { |k| header.include?(k) }
      return nil unless has_code && header.include?("date")

      {
        employee_code:  (header.index("employee code") || header.index("emp code") || header.index("employee_code")),
        employee_name:  (header.index("employee name") || header.index("name")),
        date:           header.index("date"),
        annual_leave:   (header.index("annual leave") || header.index("annual")),
        casual_leave:   (header.index("casual leave") || header.index("casual")),
        sick_leave:     (header.index("sick leave") || header.index("sick")),
        work_from_home: (header.index("work from home") || header.index("wfh") || header.index("work_from_home")),
      }
    end

    def import_default_columns
      {
        employee_code: 0,
        employee_name: 1,
        date: 2,
        annual_leave: 3,
        casual_leave: 4,
        sick_leave: 5,
        work_from_home: 6,
      }
    end

    def parse_import_date(value)
      return value.to_date if value.respond_to?(:to_date)
      Date.parse(value.to_s)
    rescue ArgumentError
      nil
    end

    def numeric_cell_value(value)
      return 0.0 if value.nil?
      s = value.to_s.strip
      return 0.0 if s == "-" || s.empty?
      s.to_f
    end

    def combine_date_time(date, time_value)
      return nil if time_value.nil?
      return nil if date.nil?

      if time_value.respond_to?(:to_time)
        t = time_value.to_time
        return Time.zone.local(date.year, date.month, date.day, t.hour, t.min, t.sec)
      end

      time_str = time_value.to_s.strip
      return nil if time_str.empty?

      t = Time.parse(time_str)
      Time.zone.local(date.year, date.month, date.day, t.hour, t.min, t.sec)
    rescue ArgumentError
      nil
    end

    def roster_time_range(employee, date)
      return nil unless defined?(EmployeeRoster)
      roster = EmployeeRoster.find_by(employee_id: employee.id, roster_date: date)
      return nil if roster.nil? || roster.start_time.nil? || roster.end_time.nil?

      st = Time.zone.local(date.year, date.month, date.day, roster.start_time.to_time.hour, roster.start_time.to_time.min, roster.start_time.to_time.sec)
      en = Time.zone.local(date.year, date.month, date.day, roster.end_time.to_time.hour, roster.end_time.to_time.min, roster.end_time.to_time.sec)
      en += 1.day if en <= st
      [st, en]
    end

    def official_duty_time_range_full_day(employee, date, options = {})
      if options[:full_start].present? && options[:full_end].present?
        st = combine_date_time(date, options[:full_start])
        en = combine_date_time(date, options[:full_end])
        return [st, en] if st && en
      end

      roster = roster_time_range(employee, date)
      return roster if roster

      [combine_date_time(date, "09:00"), combine_date_time(date, "18:00")]
    end

    def request_flow_username(employee, flow_type)
      RequestFlow.request_flow_username(employee, flow_type)
    rescue
      "System"
    end

    def find_leave_type_for_employee(employee, base_name)
      scope = LeaveType.where(company_id: employee.company_id)
      if LeaveType.column_names.include?("location_id") && employee.respond_to?(:location_id) && employee.location_id.present?
        scope = scope.where(location_id: employee.location_id)
      end

      # try exact common patterns first
      candidates = [
        "#{base_name}- KHI",
        "#{base_name} - KHI",
        "#{base_name}-KHI",
        "#{base_name} -KHI",
      ]

      candidates.each do |n|
        lt = scope.find_by(name: n)
        return lt if lt
      end

      # fallback: starts-with base_name (works for "Annual Leave- KHI")
      scope.where("LOWER(name) LIKE ?", "#{base_name.downcase}%").order(:id).first
    end

    def existing_leave_on_date?(employee, date)
      LeaveRequest
        .where(employee_id: employee.id, is_cancelled: false, request_status: ["Waiting For Approval", "Availed", "System Deducted"])
        .where("Date(start_date) <= ? AND Date(end_date) >= ?", date, date)
        .exists?
    end

    def existing_official_duty_on_date?(employee, date)
      OfficialDuty
        .where(employee_id: employee.id, is_cancelled: false, request_status: ["Waiting For Approval", "Waiting For 2nd Approval", "Availed", "System Deducted"])
        .where("Date(start_date) <= ? AND Date(end_date) >= ?", date, date)
        .exists?
    end

    def approve_all_leave_requests!(leave_request, approver, skip_validations)
      loop do
        ar = ApprovalRequest
               .where(requestable_id: leave_request.id, requestable_type: "LeaveRequest", approval_request_status: ["Waiting For Approval", "Waiting For 2nd Approval"])
               .order("id ASC")
               .first
        break if ar.nil?

        ar.approval_request_status = "Approved" if ar.respond_to?(:approval_request_status=)
        ar.is_approved = true if ar.respond_to?(:is_approved=)

        saved = skip_validations ? ar.save(validate: false) : ar.save
        return "ApprovalRequest save failed: #{ar.errors.full_messages.join(', ')}" unless saved

        if ar.respond_to?(:add_impact_in_leave_request)
          ar.add_impact_in_leave_request(approver)
        end

        leave_request.reload
      end

      if leave_request.respond_to?(:request_status) && leave_request.request_status != "Availed"
        leave_request.request_status = "Availed"
        skip_validations ? leave_request.save(validate: false) : leave_request.save
      end

      nil
    end

    def approve_all_official_duty_requests!(official_duty, approver, skip_validations)
      loop do
        ar = ApprovalRequest
               .where(requestable_id: official_duty.id, requestable_type: "OfficialDuty", approval_request_status: ["Waiting For Approval", "Waiting For 2nd Approval"])
               .order("id ASC")
               .first
        break if ar.nil?

        ar.approval_request_status = "Approved" if ar.respond_to?(:approval_request_status=)
        ar.is_approved = true if ar.respond_to?(:is_approved=)

        saved = skip_validations ? ar.save(validate: false) : ar.save
        return "ApprovalRequest save failed: #{ar.errors.full_messages.join(', ')}" unless saved

        if ar.respond_to?(:add_impact_in_official_duty_request)
          ar.add_impact_in_official_duty_request(approver)
        end

        official_duty.reload
      end

      if official_duty.respond_to?(:request_status) && official_duty.request_status != "Availed"
        official_duty.request_status = "Availed"
        skip_validations ? official_duty.save(validate: false) : official_duty.save
      end

      nil
    end

    desc "Import Annual/Casual/Sick leaves (0.5/1.0) and OfficialDuty (WFH => FULL DAY) from .xlsx/.xls"
    task import_leave_official_duty_frontend: :environment do
      require "roo"
      require "time"

      file_path = ENV["FILE"] || ENV["NAME"]
      unless file_path.present? && File.exist?(file_path)
        puts "Provide FILE=/path/to/file.xlsx"
        next
      end

      company_id = ENV["COMPANY_ID"].to_i
      if company_id <= 0
        puts "Provide COMPANY_ID=1"
        next
      end

      approver = nil
      approver = User.find_by(id: ENV["APPROVER_ID"]) if ENV["APPROVER_ID"].present?
      approver = User.find_by(email: ENV["APPROVER_EMAIL"]) if approver.nil? && ENV["APPROVER_EMAIL"].present?
      if approver.nil?
        puts "Provide APPROVER_ID or APPROVER_EMAIL (required for proper approval impact)."
        next
      end

      User.current = approver if defined?(User) && User.respond_to?(:current=)

      skip_validations = ENV["SKIP_VALIDATIONS"].to_s.downcase == "true"
      sheet_index = (ENV["SHEET"] || 0).to_i

      leave_reason = ENV["LEAVE_REASON"].presence || "Manual import"
      od_reason    = ENV["OD_REASON"].presence || "Manual import"
      apply_status = ENV["APPLY_STATUS"].presence || (approver&.full_name || "Rake Task")

      time_options = {
        full_start: ENV["OD_FULL_START"], # optional
        full_end:   ENV["OD_FULL_END"],   # optional
      }

      workbook = Roo::Spreadsheet.open(file_path)
      sheet = workbook.sheet(sheet_index)
      if sheet.nil?
        puts "Sheet index #{sheet_index} not found"
        next
      end

      leave_type_cache = {}
      employee_cache = {}

      default_columns = import_default_columns
      columns = default_columns

      stats = {
        leave_created: 0, leave_skipped: 0,
        od_created: 0, od_skipped: 0,
        skipped_leave_and_od_same_day: 0,
      }

      last_employee_code = nil

      (1..sheet.last_row).each do |row_idx|
        row_data = sheet.row(row_idx)
        next if row_data.compact.empty?

        header_columns = import_columns_from_header(row_data)
        if header_columns
          columns = default_columns.merge(header_columns.reject { |_, v| v.nil? })
          next
        end

        employee_code = row_data[columns[:employee_code]].to_s.strip
        employee_code = last_employee_code if employee_code.empty?
        last_employee_code = employee_code if employee_code.present?
        next if employee_code.blank?

        employee = employee_cache[employee_code]
        if employee.nil?
          employee = Employee.find_by(company_id: company_id, employee_code: employee_code)
          employee_cache[employee_code] = employee
        end
        unless employee
          puts "Row #{row_idx}: employee not found for code #{employee_code}"
          stats[:leave_skipped] += 1
          stats[:od_skipped] += 1
          next
        end

        date = parse_import_date(row_data[columns[:date]])
        if date.nil?
          puts "Row #{row_idx}: invalid date for employee #{employee_code}"
          stats[:leave_skipped] += 1
          stats[:od_skipped] += 1
          next
        end

        annual = numeric_cell_value(row_data[columns[:annual_leave]])
        casual = numeric_cell_value(row_data[columns[:casual_leave]])
        sick   = numeric_cell_value(row_data[columns[:sick_leave]])
        wfh    = numeric_cell_value(row_data[columns[:work_from_home]])

        leave_values = {
          "Annual Leave" => annual,
          "Casual Leave" => casual,
          "Sick Leave"   => sick,
        }.select { |_, v| v > 0.0 }

        if leave_values.size > 1
          puts "Row #{row_idx}: multiple leave types filled for #{employee_code} on #{date} => #{leave_values.inspect}"
          stats[:leave_skipped] += 1
          next
        end

        if wfh > 0.0 && leave_values.any?
          puts "Row #{row_idx}: leave + WFH both filled for #{employee_code} on #{date} (skipping)"
          stats[:skipped_leave_and_od_same_day] += 1
          next
        end

        # =========================
        # Leaves (0.5 or 1.0)
        # =========================
        if leave_values.any?
          base_name, raw_val = leave_values.first
          unless [0.5, 1.0].include?(raw_val)
            puts "Row #{row_idx}: unsupported leave value #{raw_val} for #{base_name} (only 0.5 or 1.0)"
            stats[:leave_skipped] += 1
            next
          end

          if existing_leave_on_date?(employee, date)
            puts "Row #{row_idx}: leave already exists for #{employee_code} on #{date}"
            stats[:leave_skipped] += 1
            next
          end

          cache_key = [employee.company_id, (employee.respond_to?(:location_id) ? employee.location_id : nil), base_name]
          leave_type = leave_type_cache[cache_key]
          if leave_type.nil?
            leave_type = find_leave_type_for_employee(employee, base_name)
            leave_type_cache[cache_key] = leave_type
          end

          if leave_type.nil?
            puts "Row #{row_idx}: leave type not found for '#{base_name}' (expected e.g. '#{base_name}- KHI')"
            stats[:leave_skipped] += 1
            next
          end

          leave_allocation = LeaveAllocation.find_by(leave_type_id: leave_type.id, employee_id: employee.id, is_active: true)
          if leave_allocation.nil?
            puts "Row #{row_idx}: leave allocation missing for #{employee_code} #{leave_type.name}"
            stats[:leave_skipped] += 1
            next
          end

          leave_category = (raw_val == 0.5 ? "Half Day" : "Full Day")

          requested_data =
            if leave_type.respond_to?(:is_composite) && leave_type.is_composite == true
              LeaveRequest.calculate_composite_employee_leave(leave_type, employee, date.beginning_of_day, date.end_of_day, leave_category)
            else
              LeaveRequest.calculate_employee_leave(leave_type, employee, date.beginning_of_day, date.end_of_day, leave_category)
            end

          request_count  = requested_data[0].to_f
          sandwich_count = requested_data[1].to_f
          message        = requested_data[2].to_s

          if request_count <= 0.0
            puts "Row #{row_idx}: leave skipped for #{employee_code} #{leave_type.name} (#{message})"
            stats[:leave_skipped] += 1
            next
          end

          allocated_quota =
            if leave_allocation.respond_to?(:composite_allocated_quota) && leave_type.respond_to?(:is_composite) && leave_type.is_composite == true
              leave_allocation.composite_allocated_quota
            else
              leave_allocation.allocated_quota
            end

          used_quota =
            if leave_allocation.respond_to?(:composite_used_quota) && leave_type.respond_to?(:is_composite) && leave_type.is_composite == true
              leave_allocation.composite_used_quota
            else
              leave_allocation.used_quota
            end

          remaining_quota =
            if leave_allocation.respond_to?(:composite_remaining_quota) && leave_type.respond_to?(:is_composite) && leave_type.is_composite == true
              leave_allocation.composite_remaining_quota
            else
              leave_allocation.remaining_quota
            end

          lr = LeaveRequest.new
          lr.company_id = employee.company_id
          lr.employee_id = employee.id
          lr.leave_type_id = leave_type.id

          lr.allocated_quota = allocated_quota.to_f if lr.respond_to?(:allocated_quota=)
          lr.used_quota = used_quota.to_f if lr.respond_to?(:used_quota=)
          lr.remaining_quota = remaining_quota.to_f if lr.respond_to?(:remaining_quota=)

          lr.request_count = request_count if lr.respond_to?(:request_count=)
          lr.sandwich_count = sandwich_count if lr.respond_to?(:sandwich_count=)

          lr.min_apply_date = date if lr.respond_to?(:min_apply_date=)
          lr.start_date = date
          lr.end_date = date

          lr.reason = leave_reason if lr.respond_to?(:reason=)
          lr.leave_category = leave_category if lr.respond_to?(:leave_category=)
          lr.request_sender_name = request_flow_username(employee, "Leave Request") if lr.respond_to?(:request_sender_name=)
          lr.request_status = "Waiting For Approval" if lr.respond_to?(:request_status=)
          lr.is_composite = (leave_type.respond_to?(:is_composite) ? leave_type.is_composite : false) if lr.respond_to?(:is_composite=)
          lr.apply_status = apply_status if lr.respond_to?(:apply_status=)
          lr.is_cancelled = false if lr.respond_to?(:is_cancelled=)

          saved = skip_validations ? lr.save(validate: false) : lr.save
          unless saved
            puts "Row #{row_idx}: leave save failed for #{employee_code} #{leave_type.name} (#{lr.errors.full_messages.join(', ')})"
            stats[:leave_skipped] += 1
            next
          end

          lr.reload
          if lr.respond_to?(:request_status) && lr.request_status != "Availed"
            err = approve_all_leave_requests!(lr, approver, skip_validations)
            if err
              puts "Row #{row_idx}: leave approval failed for #{employee_code} #{leave_type.name} (#{err})"
              stats[:leave_skipped] += 1
              next
            end
          end

          stats[:leave_created] += 1
        end

        # =========================
        # Official Duty (WFH => FULL DAY ALWAYS)
        # =========================
        if wfh > 0.0
          if existing_official_duty_on_date?(employee, date)
            puts "Row #{row_idx}: official duty already exists for #{employee_code} on #{date}"
            stats[:od_skipped] += 1
            next
          end

          od_restriction = OfficialDuty.validate_od_restriction(employee, date, date)
          if od_restriction[0] == true
            puts "Row #{row_idx}: official duty skipped for #{employee_code} (#{od_restriction[1]})"
            stats[:od_skipped] += 1
            next
          end

          od_count, od_message = OfficialDuty.calculate_official_duty(employee, date, date)
          if od_count.to_f <= 0.0
            puts "Row #{row_idx}: official duty skipped for #{employee_code} (#{od_message})"
            stats[:od_skipped] += 1
            next
          end

          st, en = official_duty_time_range_full_day(employee, date, time_options)

          od = OfficialDuty.new
          od.company_id = employee.company_id
          od.employee_id = employee.id
          od.request_count = 1.0 if od.respond_to?(:request_count=) # FULL DAY always
          od.start_date = date
          od.end_date = date
          od.request_sender_name = request_flow_username(employee, "Official Duty Request") if od.respond_to?(:request_sender_name=)
          od.reason = od_reason if od.respond_to?(:reason=)
          od.is_full_day = true if od.respond_to?(:is_full_day=)
          od.request_status = "Waiting For Approval" if od.respond_to?(:request_status=)
          od.apply_status = apply_status if od.respond_to?(:apply_status=)
          od.is_cancelled = false if od.respond_to?(:is_cancelled=)
          od.start_time = st if od.respond_to?(:start_time=)
          od.end_time = en if od.respond_to?(:end_time=)

          saved = skip_validations ? od.save(validate: false) : od.save
          unless saved
            puts "Row #{row_idx}: official duty save failed for #{employee_code} (#{od.errors.full_messages.join(', ')})"
            stats[:od_skipped] += 1
            next
          end

          od.reload
          if od.respond_to?(:request_status) && od.request_status != "Availed"
            err = approve_all_official_duty_requests!(od, approver, skip_validations)
            if err
              puts "Row #{row_idx}: official duty approval failed for #{employee_code} (#{err})"
              stats[:od_skipped] += 1
              next
            end
          end

          stats[:od_created] += 1
        end
      end

      puts "Leave created: #{stats[:leave_created]}, Leave skipped: #{stats[:leave_skipped]}"
      puts "Official duty created: #{stats[:od_created]}, Official duty skipped: #{stats[:od_skipped]}"
      puts "Skipped (leave+WFH same day): #{stats[:skipped_leave_and_od_same_day]}"
    ensure
      User.current = nil if defined?(User) && User.respond_to?(:current=)
    end
  end


  task :add_missing_roster => :environment do
    attendances = EmployeeAttendance.where(attendance_date: [(Time.now - 38.days).to_date, (Time.now - 37.days).to_date, (Time.now - 36.days).to_date, (Time.now - 35.days).to_date])
    attendances.each do |data|
      if data.employee_roster.nil?
        if EmployeeRoster.where(roster_date: data.attendance_date, employee_id: data.employee_id).exists?
          puts "#{data.employee_code}==="
          puts "Before  == #{data.id}: #{data.roster_id}"
          data.roster_id = EmployeeRoster.where(roster_date: data.attendance_date, employee_id: data.employee_id).last.id
          puts "After == #{data.id}: #{data.save!}"
        end
      end
    end
  end



end