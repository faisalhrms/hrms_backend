json.departments @departments.each do |department|
  json.department_name      department.name
  depatment_wise_attendances = @employee_attendances.where(:department_id => department.id).order('employee_code ASC')
  employee_codes = depatment_wise_attendances.collect(&:employee_code).uniq.map(&:to_i).sort
  json.employee_attendances employee_codes.each do |employee_code|
    employee = Employee.find_by_employee_code(employee_code)
    if not employee.nil?
      json.employee_code      employee.employee_code
      json.employee_name      employee.full_name
      json.location_name      employee.location_name
      json.branch_name        employee.branch_name
      json.grade_name         employee.grade_name
      json.designation_name   employee.designation_name
      if params[:as_on_month] == 'false'
        if not employee.joining_date.nil?
          if employee.joining_date.to_date <= params[:start_date].to_date
            start_date  = params[:start_date].to_date
            date_range = (start_date.to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
            date_range = date_range.count
          else
            end_date = params[:end_date].to_date
            date_range = (employee.joining_date.to_date..end_date.to_date).to_a.map{|x| x.to_date}
            date_range = date_range.count
          end
        else
          start_date  = params[:start_date].to_date
          date_range = (start_date.to_date..params[:end_date].to_date).to_a.map{|x| x.to_date}
          date_range = date_range.count
        end
      else
        if not employee.joining_date.nil?
          if employee.joining_date.to_date <= params[:start_date].to_date
            date_range = params[:end_date].to_date.end_of_month.day.to_f
          else
            if employee.joining_date.to_date <= (params[:start_date].to_date).to_date
              date_range = params[:end_date].to_date.end_of_month.day.to_f
            else
              date_range = (TimeDifference.between(employee.joining_date.to_date, params[:end_date].to_date.end_of_month).in_days) + 1  
            end
          end
        else
          date_range = 0
        end
      end
      pay_deduction             = depatment_wise_attendances.where(:employee_id => employee.id, :deduction_from_salary => true).sum(:pay_deduction)
      working_days              = date_range - pay_deduction.to_f.round(2)
      json.month_days           date_range
      json.worked_days          working_days.to_f.round(2)
      json.no_of_present        depatment_wise_attendances.where(:attendance_status => "Present", :employee_id => employee.id).count
      json.no_of_absent         depatment_wise_attendances.where(:attendance_status => "Absent", :employee_id => employee.id).count
      json.no_of_late           depatment_wise_attendances.where(:attendance_status => "Late", :employee_id => employee.id).count
      json.no_of_half_day       depatment_wise_attendances.where(:attendance_status => "Half Day", :employee_id => employee.id).count 
      json.relaxation_avalied   depatment_wise_attendances.where(:is_relaxation => true, :employee_id => employee.id).count
      json.od_avalied           depatment_wise_attendances.where(:is_official_duty => true, :employee_id => employee.id).count
      json.leave_avalied        depatment_wise_attendances.where(:is_on_leave => true, :employee_id => employee.id).count
    end
  end
end