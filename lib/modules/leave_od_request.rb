module LeaveOdRequest

  def index
    @resulted_data = []
    class_name = LeaveRequest
    class_name = OfficialDuty if self.class.name.include?('OfficialDuty')
    json_template = nil
    if current_user.employee
      @resulted_data = class_name.get_by_employee(current_user.employee.id).includes(:employee).order('id DESC')
    elsif current_user.is_admin
      @resulted_data = class_name.includes(:employee).order('id DESC')
    end
    if class_name.name == LeaveRequest.name
      @resulted_data = @resulted_data.includes(:leave_type)
      json_template = 'api/v1/web/leave_management/leave_requests/index'
    end
    render status:200, template: json_template || 'api/v1/web/official_duty_management/official_duty_requests/index'
  end

  def bulk_index
    conditions = {company_id: params[:company_id], is_active: true}
    Employee.filter_employee_by_params(params, conditions)
    Employee.filter_employee_data(current_user, conditions)
    start_date      = params[:start_date]
    end_date        = params[:end_date]
    request_status    = params[:leave_status].present? ?  params[:leave_status] : params[:od_status]
    if request_status == 'All'
      request_status = ["Cancelled", "Rejected", "Availed", "Waiting For Approval", "Revert"]
      params[:leave_status].present? ? request_status << 'System Deducted' : request_status << 'Waiting For 2nd Approval'
    end
    class_name = params[:leave_status].present? ? LeaveRequest : OfficialDuty
    if current_user.employee.present? and current_user.employee.is_line_manager
      sub_ordinates_ids = []
      employee_ids = []
      employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
      employee_ids = employee_ids.flatten.uniq
      employee_ids << current_user.employee.id
      @employees = Employee.where(id: employee_ids.uniq)
      filter_data_on_request
      @resulted_data = class_name.where(:company_id => params[:company_id], :request_status => request_status, :employee_id => @employees.collect(&:id)).where(['start_date >= ? AND end_date <= ?', start_date.to_date.beginning_of_day, end_date.to_date.end_of_day])
                          .includes(:employee).order("#{class_name.table_name}.id DESC")
      if params[:leave_status].present?
        @resulted_data = @resulted_data.includes(:leave_type)
      end
    else
      @resulted_data = class_name.where(:company_id => params[:company_id], :request_status => request_status).where(['start_date >= ? AND end_date <= ?', start_date.to_date.beginning_of_day, end_date.to_date.end_of_day]).includes(:employee).where(employees: conditions).order("#{class_name.table_name}.id DESC")
      if params[:leave_status].present?
        @resulted_data = @resulted_data.includes(:leave_type)
      end
    end
    template = params[:leave_status].present? ? 'api/v1/web/leave_management/leave_requests/index' : 'api/v1/web/official_duty_management/official_duty_requests/index'
    render status:200, template: template
  end

  def approved_request
    class_name = LeaveRequest
    class_name = OfficialDuty if self.class.name.include?('OfficialDuty')
    request = class_name.find(params[:id])
    if request.add_impact_to_approval_request(current_user)
      render json:{}, status: 200
    else
      allowed_days = RestrictLeave.allowed_approval_days
      status = params[:action] == 'approved_request' ? 'approve' : 'reject'
      render json:{errors: "You can only #{status} #{class_name.name.split(/(?=[A-Z])/).join(' ')} within #{allowed_days} days of leave applied"}, status: :unprocessable_entity
    end
  end

  def cancel_request
    class_name = LeaveRequest
    class_name = OfficialDuty if self.class.name.include?('OfficialDuty')
    request = class_name.find(params[:id])
    request.is_cancelled = true
    request.request_status = 'Cancelled'
    if request.save
      render json:{}, status: 200
    else
      render json: {errors: request.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def filter_data_on_request
    if params[:location_id].present?
      @employees = Employee.location_related_employee(@employees, params[:location_id].to_i)
    end
    if params[:branch_id].present?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if params[:department_id].present?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
    if params[:line_manager_id].present?
      @employees = Employee.line_manager_related_employee(@employees, params[:line_manager_id].to_i)
    end
  end
end