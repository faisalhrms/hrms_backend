
department_list = []
dept_wise_strength = []

availed_leaves_departments = []
department_leave_strength = []

late_arrivals_departments = []
dept_late_strength = []

half_leaves_departments = []
half_leaves_strength = []




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
  grade_ids = Grade.where(:company_id => current_user.company_id,:is_active => true ).collect(&:id).uniq
end

json.attendance_dashboard do
  json.on_roll_strength			@on_roll_strength.count
end

annual = LeaveType.where(:is_active => true, :name => "Annual Leave", :location_id => location_ids.uniq)
causal = LeaveType.where(:is_active => true, :name => "Casual Leave", :location_id => location_ids.uniq)
sick = LeaveType.where(:is_active => true, :name => "Sick Leave", :location_id => location_ids.uniq)
casual_sick = LeaveType.where(:is_active => true, :name => "Casual/Sick", :location_id => location_ids.uniq)
compensatory = LeaveType.where(:is_active => true, :name => "Compensatory Leave", :location_id => location_ids.uniq)

json.attendance_dashboard do
  json.annual			LeaveRequest.where( :leave_type_id => annual.collect(&:id), :request_status => "Availed", :employee_id => @employee_lists.collect(&:id)).where(['start_date >= ? AND end_date <= ?', params[:start_date].to_date, params[:end_date].to_date]).sum(:request_count)
  json.causal 				LeaveRequest.where( :leave_type_id => causal.collect(&:id), :request_status => "Availed", :employee_id => @employee_lists.collect(&:id)).where(['start_date >= ? AND end_date <= ?', params[:start_date].to_date, params[:end_date].to_date]).sum(:request_count)
  json.sick 		LeaveRequest.where( :leave_type_id => sick.collect(&:id), :request_status => "Availed", :employee_id => @employee_lists.collect(&:id)).where(['start_date >= ? AND end_date <= ?', params[:start_date].to_date, params[:end_date].to_date]).sum(:request_count)
  json.casual_sick 		LeaveRequest.where( :leave_type_id => casual_sick.collect(&:id), :request_status => "Availed", :employee_id => @employee_lists.collect(&:id)).where(['start_date >= ? AND end_date <= ?', params[:start_date].to_date, params[:end_date].to_date]).sum(:request_count)
  json.absent_count 			LeaveRequest.where( :leave_type_id => annual.collect(&:id), :request_status => "Availed", :employee_id => @employee_lists.collect(&:id)).where(['start_date >= ? AND end_date <= ?', params[:start_date].to_date, params[:end_date].to_date]).sum(:request_count)
  json.compensatory 		LeaveRequest.where( :leave_type_id => compensatory.collect(&:id), :request_status => "Availed", :employee_id => @employee_lists.collect(&:id)).where(['start_date >= ? AND end_date <= ?', params[:start_date].to_date, params[:end_date].to_date]).sum(:request_count)
end


@departments_absents.each do |department|
  department_list 		<< department.name
  dept_wise_strength 	<< @employee_attendance.where(:attendance_status => "Absent", :department_id => department).count
end

json.department_list 					department_list
json.dept_wise_strength 			dept_wise_strength



@departments_absents.each do |department|
  late_arrivals_departments 		<< department.name
  dept_late_strength 	<< @employee_attendance.where(:attendance_status => "Late", :department_id => department).count
end

json.late_arrivals_departments 	late_arrivals_departments
json.dept_late_strength 			  dept_late_strength


@departments_leave.each do |department|
    employee_attendan = Employee.where(:company_id => 1, :location_id => location_ids,:id => @employee, :branch_id => branch_ids, :department_id => department ,:is_active => true).collect(&:id)
    leave_requests = LeaveRequest.where("start_date >= ? AND end_date <= ?", params[:start_date].to_date, params[:end_date].to_date).where(:is_cancelled => false, :request_status => "Availed", :employee_id => employee_attendan).sum(:request_count)

  availed_leaves_departments 		<< department.name
  department_leave_strength 	<<  leave_requests
end

json.availed_leaves_departments 					availed_leaves_departments
json.department_leave_strength           	department_leave_strength


@departments_absents.each do |department|
  half_leaves_departments	<< department.name
  half_leaves_strength 	<< @employee_attendance.where(:attendance_status => "Half Day", :department_id => department).count
end

json.half_leaves_departments 	half_leaves_departments
json.half_leaves_strength 	half_leaves_strength

pre_date = (Time.now - 8.month).to_date
attendance_list = []
month_wise_attendance = []

Array.new(8).each_index do |index|
  new_prev_date = (pre_date + index.month).beginning_of_month
  new_curr_date = (pre_date + index.month).end_of_month
  attendance_list << new_prev_date.to_date.strftime("%B %Y")

  employee_attendan = Employee.where(:company_id => 1,:id => @employee, :location_id => location_ids, :branch_id => branch_ids, :department_id => department_ids ,:is_active => true).collect(&:id)

  month_end_strength					= LeaveRequest.where("start_date >= ? AND end_date <= ?", new_prev_date, new_curr_date).where(:is_cancelled => false, :request_status => "Availed", :employee_id => employee_attendan).sum(:request_count)
  month_wise_attendance			<< month_end_strength

  puts "\n Month => #{(new_prev_date.to_date - 1.day).end_of_day} \n"
  puts "\n month_end_strength => #{month_end_strength} \n"

end



json.attendance_list 	      attendance_list
json.month_wise_attendance  	month_wise_attendance



pre_date = (Time.now - 8.month).to_date
attendance_list_late = []
month_wise_late = []

Array.new(8).each_index do |index|
  new_prev_date = (pre_date + index.month).beginning_of_month
  new_curr_date = (pre_date + index.month).end_of_month
  attendance_list_late << new_prev_date.to_date.strftime("%B %Y")

  month_end_strength		 	= EmployeeAttendance.where(['attendance_date >= ? AND attendance_date <= ?', new_prev_date, new_curr_date]).where(:id => @employee_attendances,:department_id => department_ids,:grade_id => grade_ids,:attendance_status => "Late").count

  month_wise_late			<< month_end_strength

  puts "\n Month => #{(new_prev_date.to_date - 1.day).end_of_day} \n"
  puts "\n month_end_strength => #{month_end_strength} \n"

end


json.attendance_list_late 	      attendance_list_late
json.month_wise_late            	month_wise_late

json.employees_absent_rate Array.new(2).each_index do |index|
  if @employee_attendance.present?
  present = @employee_attendance.where(:attendance_status => "Present").count
  absent = @employee_attendance.where(:attendance_status => "Absent").count
  rate = (present.to_f / absent.to_f)*100
  if index == 0
    color	= "#73C6B6"
    json.y 				present
    json.name			"Present Rate"
    json.selected true
    json.color		color
    elsif index == 1
      color	= "#AB5A09"
      json.y 				 rate
      json.name			"Absenteeism Rate"
      json.selected true
      json.color		color
  end
  end
  end
