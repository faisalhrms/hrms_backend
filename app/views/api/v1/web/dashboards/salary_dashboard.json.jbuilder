department_gross_list = []
dept_wise_gross_Salary = []

departments_pf_list = []
department_pf_strength = []

department_ctc_list = []
dept_wise_ctc = []
employees_vehicle_allowance = []



if not params[:location_ids].blank?
  location_ids = params[:location_ids].map(&:to_i)
else
  location_ids = Location.where(:company_id => current_user.company_id, :is_active => true).collect(&:id).uniq
end

if not params[:branch_ids].blank?
  branch_ids = params[:branch_ids].map(&:to_i)
else
  branch_ids = Branch.where(:company_id => current_user.company_id,:location_id => location_ids, :is_active => true).collect(&:id).uniq
end

if not params[:department_id].blank?
  department_ids = params[:department_id].map(&:to_i)
else
  department_ids = Department.where(:company_id => current_user.company_id,:is_active => true ).collect(&:id).uniq
end

if not params[:grade_id].blank?
  grade_ids = params[:grade_id].map(&:to_i)
else
  grade_ids = Grade.where(:company_id => current_user.company_id, :is_active => true).collect(&:id).uniq
end

# if current_user.is_location_head == true
#   @employees = Employee.where(:location_id => current_user.employee.location_id, :excluded_from_reports => false).order('id DESC')
#   @employees = Employee.multiple_branch_data(@employees, current_user)
#   @pay_invoices = PayInvoice.where(:status => true, :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
# elsif current_user.is_branch_head == true
#   @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :excluded_from_reports => false).order('id DESC')
#   @employees = Employee.multiple_branch_data(@employees, current_user)
#   @pay_invoices = PayInvoice.where(:status => true, :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
# elsif current_user.is_department_head == true
#   @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
#   @employees = Employee.multiple_branch_data(@employees, current_user)
#   @pay_invoices = PayInvoice.where(:status => true, :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
# elsif current_user.all_company_department == true
#   @employees = Employee.where(:company_id => current_user.company_id, :depart ment_id => current_user.employee.department_id, :excluded_from_reports => false).order('id DESC')
#   @employees = Employee.multiple_branch_data(@employees, current_user)
#   @pay_invoices = PayInvoice.where(:status => true, :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
# elsif current_user.is_sub_department_head == true
#   @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id, :sub_department_id => current_user.employee.sub_department_id, :excluded_from_reports => false).order('id DESC')
#   @employees = Employee.multiple_branch_data(@employees, current_user)
#   @pay_invoices = PayInvoice.where(:status => true,:employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
# elsif not current_user.employee.nil?
#   if current_user.employee.is_line_manager == true
#     sub_ordinates_ids = []
#     employee_ids = []
#     employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
#     employee_ids = employee_ids.flatten.uniq
#     employee_ids << current_user.employee.id
#     @employees = Employee.where(:id => employee_ids.uniq, :excluded_from_reports => false).order('id DESC')
#     @employees = Employee.multiple_branch_data(@employees, current_user)
#     @pay_invoices = PayInvoice.where(:status => true, :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
#   elsif current_user.multi_branch_allowed == true
#     @employees = Employee.multiple_branch_data([], current_user)
#     @pay_invoices = PayInvoice.where(:status => true,:employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
#   end
# elsif current_user.multi_branch_allowed == true
#   @employees = Employee.multiple_branch_data([], current_user)
#   @pay_invoices = PayInvoice.where(:status => true, :employee_id => @employees.collect(&:id).uniq).order('employee_id ASC')
# end

pay_invoice = @pay_invoices.where(:status => true, :department_id => department_ids, :grade_id => grade_ids, :actual_pay_month => @start_date.to_date..@end_date.to_date).collect(&:id)

json.employees_vehicle_allowance Array.new(2).each_index do |index|
  if index == 0
    color = "##{Random.new.bytes(3).unpack('H*')[0]}"
    json.y PayInvoiceDetail.where(:pay_invoice_id => pay_invoice, :item_name => "Vehicle Allowance").sum(:amount).round(2)
    json.name "Vehicle Allowance"
    json.selected true
    json.color color
  end
end

pay_invoice_ids = @pay_invoices.where(:status => true, :actual_pay_month => @start_date.to_date..@end_date.to_date).collect(&:id)

json.employees_arrear_overtime Array.new(2).each_index do |index|
  if index == 0
    color = "#AB5A04"
    json.y PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => "Over Time").sum(:amount).round(2)
    json.name "Over Time"
    json.selected true
    json.color color
  elsif index == 1
    color = '#EC7063'
    json.y PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => "Arrears").sum(:amount).round(2)
    json.name "Arrears"
    json.selected false
    json.color color

  end
end

json.employees_by_fuel Array.new(2).each_index do |index|
  if index == 0
    color = "#73C6B6"
    json.y @employee_list.where(:fuel_allowed => "True").count
    json.name "Allowed"
    json.selected true
    json.color color
  elsif index == 1
    color = '#EC7063'
    json.y @employee_list.where(:fuel_allowed => "False").count
    json.name "Not Allowed"
    json.selected false
    json.color color
  end
end

@pf_depart.each do |department|
  departments_pf_list << department.name
  pay_invoice_ids = @pay_invoices.where(:status => true,:employee_id => @employee_list, :department_id => department.id, :grade_id => grade_ids, :actual_pay_month => @start_date.to_date..@end_date.to_date).collect(&:id)
  pay_invouce = PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Provident Fund"]).sum(:amount).round(2)
  department_pf_strength << pay_invouce
end

json.departments_pf_list departments_pf_list
json.department_pf_strength department_pf_strength

@departments_salary.each do |department|
  department_gross_list << department.name
  pay_invoice_ids = @pay_invoices.where(:status => true,:employee_id => @employee_list, :department_id => department.id,:grade_id => grade_ids, :actual_pay_month => @start_date.to_date..@end_date.to_date).collect(&:id)

  dept_gross_Salary = PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Basic Salary", "House Rent", "Utility Allowance"]).sum(:amount).round.abs
  dept_wise_gross_Salary << dept_gross_Salary
end

json.department_gross_list department_gross_list
json.dept_wise_gross_Salary dept_wise_gross_Salary

cost_to_company = []

@departments_salary.each do |department|
  pay_invoice_ids = @pay_invoices.where( :status => true,:employee_id => @employee_list, :department_id => department.id, :grade_id => grade_ids, :actual_pay_month => @start_date.to_date..@end_date.to_date).collect(&:id)

  if pay_invoice_ids.present?
    vehicle_cost = PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Vehicle Allowance"]).sum(:amount).round(2)
    opd_cost = PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Medical Allowance (OPD)"]).sum(:amount).round(2)
    travel_allowance = PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Travel Allowance"]).sum(:amount).round(2)
    performance_incentive = PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Performance Incentive"]).sum(:amount).round(2)
    maintenance_allowance = PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Maintenance Allowance"]).sum(:amount).round(2)

    gross_salary = PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Basic Salary", "House Rent", "Utility Allowance"]).sum(:amount).round(2)

    fuel = PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Fuel Allowance"]).sum(:amount).round

    provident_fund = PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Provident Fund"]).sum(:amount)

    handset_allowance = PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Handset Allowance"]).sum(:amount).round(2)

    cost_to = vehicle_cost + fuel + travel_allowance + opd_cost + gross_salary + performance_incentive + handset_allowance + maintenance_allowance + provident_fund
  end
  cost_to_company = (cost_to.to_i).round(2)

  department_ctc_list << department.name
  dept_wise_ctc << cost_to_company

end

json.department_ctc_list department_ctc_list
json.dept_wise_ctc dept_wise_ctc

cream_cost = []
overtime_cost = []

pay_invoice_ids = @pay_invoices.where(:status => true,:employee_id => @employee_list, :actual_pay_month => @start_date.to_date..@end_date.to_date).collect(&:id)

json.cream_cost Array.new(2).each_index do |index|
  if index == 0
    color = "##{Random.new.bytes(3).unpack('H*')[0]}"
    json.y PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Careem Deduction"]).sum(:amount).round(2)
    json.name "Careem Deduction"
    json.selected true
    json.color color
  end
end

pay_invoice_ids = @pay_invoices.where(:status => true,:employee_id => @employee_list, :actual_pay_month => @start_date.to_date..@end_date.to_date).collect(&:id)

json.overtime_cost Array.new(2).each_index do |index|
  if index == 0
    color = "#AB5A04"
    json.y PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => "Over Time").sum(:amount).round(2)
    json.name "Over Time"
    json.selected true
    json.color color
  end
end

json.travel_cost Array.new(2).each_index do |index|
  if index == 0
    color = "##{Random.new.bytes(3).unpack('H*')[0]}"
    json.y PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => "Travel Allowance").sum(:amount).round(2)
    json.name "Travel Allowance"
    json.selected true
    json.color color
  end
end

json.cream_employee Array.new(3).each_index do |type|
  if type == 0
    color = "##{Random.new.bytes(3).unpack('H*')[0]}"
    json.label "Male"
    json.value @employee_list.where(:id => @careem_employee, :gender => "Male").count
    json.color color
    cream_cost << color
  elsif type == 1
    color = "##{Random.new.bytes(3).unpack('H*')[0]}"
    json.label "Female"
    json.value @employee_list.where(:id => @careem_employee, :gender => "Female").count
    json.color color
    cream_cost << color
  elsif type == 2
    color = "##{Random.new.bytes(3).unpack('H*')[0]}"
    json.label "Total"
    json.value @employee_list.where(:id => @careem_employee).count
    json.color color
    cream_cost << color
  end
end

prev_date = (Time.now - 8.month).to_date
month_wise_list = []
month_wise_gross_salary = []

Array.new(8).each_index do |index|
  new_prev_date = (prev_date + index.month).beginning_of_month
  new_curr_date = (prev_date + index.month).end_of_month
  month_wise_list << new_prev_date.to_date.strftime("%B %Y")
  month_end_strength = @pay_invoices.where(['actual_pay_month >= ? AND actual_pay_month <= ?', new_prev_date, new_curr_date]).where(:status => true, :employee_id => @employee_list, :grade_id => grade_ids).sum(:payable_gross).round(2)
  month_wise_gross_salary << month_end_strength
  puts "\n Month => #{(new_prev_date.to_date - 1.day).end_of_day} \n"
  puts "\n month_end_strength => #{month_end_strength} \n"

end

json.month_wise_list month_wise_list
json.month_wise_gross_salary month_wise_gross_salary

pre_date = (Time.now - 8.month).to_date
opd_list = []
medical_data = []

Array.new(8).each_index do |index|
  new_prev_date = (pre_date + index.month).beginning_of_month
  new_curr_date = (pre_date + index.month).end_of_month
  opd_list << new_prev_date.to_date.strftime("%B %Y")
  pay_invoice_ids = @pay_invoices.where(['actual_pay_month >= ? AND actual_pay_month <= ?', new_prev_date, new_curr_date]).where(:status => true, :employee_id => @employee_list, :grade_id => grade_ids).collect(&:id)

  month_end_strength = PayInvoiceDetail.where(:pay_invoice_id => pay_invoice_ids, :item_name => ["Medical Allowance (OPD)"]).sum(:amount).round(2)
  medical_data << month_end_strength
  puts "\n Month => #{(new_prev_date.to_date - 1.day).end_of_day} \n"
  puts "\n month_end_strength => #{month_end_strength} \n"
end

json.month_opd_list opd_list
json.medical_opd_data medical_data
