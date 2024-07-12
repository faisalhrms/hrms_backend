class Api::V1::Web::EmployeeRequest::ApprovalRequestsController < ApplicationController

  before_action :set_approval_request, :only => [:show]
  skip_before_action :authenticate_user_from_token!, only: [:approve_by_email, :reject_by_email]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if not current_user.employee.nil?
      employee = current_user.employee
      @approval_requests = ApprovalRequest.where(:company_id => employee.company_id, :request_receiver_id => employee.id).order('id DESC')
    else
      @approval_requests = []
    end
    render status:200, template: 'api/v1/web/employee_request/approval_requests/index'
  end

  def bulk_index
    @approval_requests = []
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true)
    filter_employee_data_on_request
    hierarchical_conditions = user_hierarchical_permissions
    @employees = @employees.where(hierarchical_conditions)
    approval_conditions = {company_id: params[:company_id]}
    approval_conditions[:approval_request_status] = params[:request_status] if params[:request_status].present? and params[:request_status] != 'All'
    approval_conditions[:requestable_type] = params[:request_type] if params[:request_type].present? and params[:request_type] != 'All'
    approval_conditions[:request_receiver_id] = current_user.employee.id if current_user.employee and !current_user.is_admin and !current_user.is_branch_head
    if current_user.is_admin || current_user.employee
      @approval_requests = ApprovalRequest.where(approval_conditions).where('approval_requests.created_at between ? AND ?', params[:start_date].to_date, params[:end_date].to_date.end_of_day)
                               .includes(:request_sender).where(employees: {id: @employees.ids}).order('approval_requests.id DESC')
    end
    render status:200, template: 'api/v1/web/employee_request/approval_requests/index'
  end

  def show
    render status:200, template: 'api/v1/web/employee_request/approval_requests/show'
  end

  def approved_request
    approval_request = ApprovalRequest.find(params[:id])
    approval_request.approval_request_status  = 'Approved'
    approval_request.is_approved              = true
    if approval_request.save
      if approval_request.requestable_type == "LeaveRequest"
        approval_request.add_impact_in_leave_request(current_user)
      elsif approval_request.requestable_type == 'CplEarning'
        approval_request.add_impact_in_cpl_earning(current_user)
      elsif approval_request.requestable_type == "OfficialDuty"
        request_flow = RequestFlow.find_by(:company_id => approval_request.company_id, :request_flow_type => "Official Duty Request")
        official_duty = OfficialDuty.find(approval_request.requestable_id)
        if not request_flow.nil?
          if request_flow.request_flow_details.where(:specific_condition => true,:branch_id => approval_request.request_sender.branch_id ,:department_id => approval_request.request_sender.department_id).count == 1 && official_duty.request_status == "Waiting For Approval"
            if RequestFlowDetail.request_flow_employee_id(request_flow, approval_request) != approval_request.request_receiver_id
              official_duty.request_status = "Waiting For 2nd Approval"
              official_duty.save
            else
              approval_request.add_impact_in_official_duty_request(current_user)
            end
          else
            approval_request.add_impact_in_official_duty_request(current_user)
          end
        else
          approval_request.add_impact_in_official_duty_request(current_user)
        end
      elsif approval_request.requestable_type == "RelaxationRequest"
        approval_request.add_impact_in_relaxation_request(current_user)
      end
      render json:{}, status: 200
    else
      render json: {errors: approval_request.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def cancel_request
    approval_request = ApprovalRequest.find(params[:id])
    approval_request.approval_request_status  = 'Rejected'
    approval_request.is_approved              = false
    if approval_request.save
      if approval_request.requestable_type == "LeaveRequest"
        approval_request.add_impact_in_leave_request(current_user)
      elsif approval_request.requestable_type == 'CplEarning'
        approval_request.add_impact_in_cpl_earning(current_user)
      elsif approval_request.requestable_type == "OfficialDuty"
        approval_request.add_impact_in_official_duty_request(current_user)
      elsif approval_request.requestable_type == "RelaxationRequest"
        approval_request.add_impact_in_relaxation_request(current_user)
      end
      render json:{}, status: 200
    else
      render json: {errors: approval_request.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def execute_bulk_approval
    if params[:approval_request_ids].nil?
      render json: {errors: "Please Select Requests"}, status: :unprocessable_entity
    else
      error_msg = []
      success_msg = []
      approval_request_ids = params[:approval_request_ids].map(&:to_i)
      ApprovalRequest.where(:id => approval_request_ids, :approval_request_status => ["Waiting For Approval", "Waiting For 2nd Approval"]).order('id ASC').each do |approval_request|
        approval_request.approval_request_status  = "Approved"
        approval_request.is_approved              = true
        if approval_request.save
          if approval_request.requestable_type == 'CplEarning'
            msg = "#{approval_request.requestable.employee.full_name} #{ReportFormat.date_format(approval_request.requestable.employee_attendance.attendance_date)} approved"
          else
            msg = "#{approval_request.requestable.employee.full_name} #{ReportFormat.date_format(approval_request.requestable.start_date)} approved"
          end
          success_msg.push(msg)
          if approval_request.requestable_type == "LeaveRequest"
            approval_request.add_impact_in_leave_request(current_user)
          elsif approval_request.requestable_type == 'CplEarning'
            approval_request.add_impact_in_cpl_earning(current_user)
          elsif approval_request.requestable_type == "OfficialDuty"
            request_flow = RequestFlow.find_by(:company_id => approval_request.company_id, :request_flow_type => "Official Duty Request")
            official_duty = OfficialDuty.find(approval_request.requestable_id)
            if not request_flow.nil?
              if request_flow.request_flow_details.where(:specific_condition => true, :branch_id => approval_request.request_sender.branch_id,:department_id => approval_request.request_sender.department_id).count == 1 && official_duty.request_status == "Waiting For Approval"
                if RequestFlowDetail.request_flow_employee_id(request_flow, approval_request) != approval_request.request_receiver_id
                  official_duty.request_status = "Waiting For 2nd Approval"
                  official_duty.save
                else
                  approval_request.add_impact_in_official_duty_request(current_user)
                end
              else
                approval_request.add_impact_in_official_duty_request(current_user)
              end
            else
              approval_request.add_impact_in_official_duty_request(current_user)
            end
          elsif approval_request.requestable_type == "RelaxationRequest"
            approval_request.add_impact_in_relaxation_request(current_user)
          end
        else
          msg = "#{approval_request.requestable.employee.full_name} #{ReportFormat.date_format(approval_request.requestable.start_date)} failed"
          error_msg.push(msg)
        end
      end
      if error_msg.present?
        render json: {errors: "#{success_msg.join(', ')}. #{error_msg.join(', ')}"}, status: :unprocessable_entity
      end
    end
  end

  def approve_by_email
    approval_request = ApprovalRequest.find_by_id_and_token(params[:token].split('-').first, params[:token])
    @msg = 'Request has already been processed.'
    request.format = 'html'
    if approval_request && approval_request.approval_request_status == 'Waiting For Approval'
      approval_request.approval_request_status  = 'Approved'
      approval_request.is_approved = true
      approval_request.token = nil
      if approval_request.save
        if approval_request.requestable_type == "LeaveRequest"
          approval_request.add_impact_in_leave_request(current_user)
        elsif approval_request.requestable_type == 'CplEarning'
          approval_request.add_impact_in_cpl_earning(current_user)
        elsif approval_request.requestable_type == "OfficialDuty"
          request_flow = RequestFlow.find_by(:company_id => approval_request.company_id, :request_flow_type => "Official Duty Request")
          official_duty = OfficialDuty.find(approval_request.requestable_id)
          if not request_flow.nil?
            if request_flow.request_flow_details.where(:specific_condition => true,:branch_id => approval_request.request_sender.branch_id ,:department_id => approval_request.request_sender.department_id).count == 1 && official_duty.request_status == "Waiting For Approval"
              if RequestFlowDetail.request_flow_employee_id(request_flow, approval_request) != approval_request.request_receiver_id
                official_duty.request_status = "Waiting For 2nd Approval"
                official_duty.save
              else
                approval_request.add_impact_in_official_duty_request(current_user)
              end
            else
              approval_request.add_impact_in_official_duty_request(current_user)
            end
          else
            approval_request.add_impact_in_official_duty_request(current_user)
          end
        elsif approval_request.requestable_type == "RelaxationRequest"
          approval_request.add_impact_in_relaxation_request(current_user)
        end
        @msg =  "#{approval_request.requestable_type} has been approved successfully."
      else
        @msg = 'Something went wrong.'
      end
    end
    respond_to do |format|
      format.html
    end
  end

  def reject_by_email
    approval_request = ApprovalRequest.find_by_id_and_token(params[:token].split('-').first, params[:token])
    @msg = 'Request has already been processed.'
    request.format = 'html'
    if approval_request && approval_request.approval_request_status == 'Waiting For Approval'
      approval_request.approval_request_status  = 'Rejected'
      approval_request.is_approved = false
      approval_request.token = nil
      if approval_request.save
        if approval_request.requestable_type == "LeaveRequest"
          approval_request.add_impact_in_leave_request(current_user)
        elsif approval_request.requestable_type == 'CplEarning'
          approval_request.add_impact_in_cpl_earning(current_user)
        elsif approval_request.requestable_type == "OfficialDuty"
          approval_request.add_impact_in_official_duty_request(current_user)
        elsif approval_request.requestable_type == "RelaxationRequest"
          approval_request.add_impact_in_relaxation_request(current_user)
        end
        @msg = "#{approval_request.requestable_type} has been rejected successfully."
      else
         @msg = 'Something went wrong.'
      end
    end
    respond_to do |format|
      format.html
    end
  end

  private

  def filter_employee_data_on_request
    if not params[:location_id].blank?
      @employees = Employee.location_related_employee(@employees, params[:location_id].to_i)
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
    if not params[:department_id].blank?
      @employees = Employee.department_related_employee(@employees, params[:department_id].to_i)
    end
  end

  def user_hierarchical_permissions
    hierarchical_conditions = {}
    if current_user.is_admin
      hierarchical_conditions
    elsif current_user.is_location_head
      hierarchical_conditions[:location_id] = current_user.employee.location_id
    elsif current_user.is_branch_head
      hierarchical_conditions[:location_id] = current_user.employee.location_id
      hierarchical_conditions[:branch_id] = current_user.employee.branch_id
    elsif current_user.is_department_head
      hierarchical_conditions[:location_id] = current_user.employee.location_id
      hierarchical_conditions[:branch_id] = current_user.employee.branch_id
      hierarchical_conditions[:department_id] = current_user.employee.department_id
    elsif current_user.is_sub_department_head
      hierarchical_conditions[:location_id] = current_user.employee.location_id
      hierarchical_conditions[:branch_id] = current_user.employee.branch_id
      hierarchical_conditions[:department_id] = current_user.employee.department_id
      hierarchical_conditions[:sub_department_id] = current_user.employee.sub_department_id
    elsif current_user.employee.present?
      if current_user.employee.is_line_manager
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        hierarchical_conditions[:id] = employee_ids.uniq
      else
        hierarchical_conditions[:id] = current_user.employee.id
      end
    end
    hierarchical_conditions
  end

  def set_approval_request
    @approval_request = ApprovalRequest.find(params[:id])
  end
end
