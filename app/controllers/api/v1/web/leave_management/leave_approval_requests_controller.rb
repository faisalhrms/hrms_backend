class Api::V1::Web::LeaveManagement::LeaveApprovalRequestsController < ApplicationController
  skip_before_action :authenticate_user_from_token!, only: [:syed_talal_leave_request]
	before_action :set_leave_approval_request, :only => [:show]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @leave_approvals = []
    if current_user.employee
      employee = current_user.employee
      @leave_approvals = ApprovalRequest.where(:company_id => employee.company_id, :request_receiver_id => employee.id).get_leave_requests.includes(requestable: :employee).order('id DESC')
    elsif current_user.is_admin
      @leave_approvals = ApprovalRequest.get_leave_requests.includes(requestable: :employee).order('id DESC')
    end
    render status:200, template: 'api/v1/web/leave_management/leave_approval_requests/index'
  end

  def show
    render status:200, template: 'api/v1/web/leave_management/leave_approval_requests/show'
  end

  def approved_request
    approval_request = ApprovalRequest.find(params[:id])
    if approval_request.requestable.present?
      if approval_request.requestable.employee.line_manager.present?
        if approval_request.requestable.employee.line_manager.employee_code == "400740"
          UserMailer.create_leave_request_notification("talal@sapphire.com.pk", "", "", "Leave Request Submitted For Approval", approval_request).deliver_now
        else
          approval_request.approval_request_status  = 'Approved'
          approval_request.is_approved = true
          if approval_request.save
            approval_request.add_impact_in_leave_request(current_user)
            render json:{}, status: :created
          else
            render json: {errors: approval_request.errors.full_messages}, status: :unprocessable_entity
          end
        end
      else
        approval_request.approval_request_status  = 'Approved'
        approval_request.is_approved = true
        if approval_request.save
          approval_request.add_impact_in_leave_request(current_user)
          render json:{}, status: :created
        else
          render json: {errors: approval_request.errors.full_messages}, status: :unprocessable_entity
        end
      end
    else
      approval_request.approval_request_status  = 'Approved'
      approval_request.is_approved = true
      if approval_request.save
        approval_request.add_impact_in_leave_request(current_user)
        render json:{}, status: :created
      else
        render json: {errors: approval_request.errors.full_messages}, status: :unprocessable_entity
      end
    end

  end

  def cancel_request
    approval_request = ApprovalRequest.find(params[:id])
    approval_request.approval_request_status = 'Rejected'
    approval_request.is_approved = false
    if approval_request.save
      approval_request.add_impact_in_leave_request(current_user)
      render json:{}, status: 200
    else
      render json: {errors: approval_request.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def syed_talal_leave_request
    approval_request = ApprovalRequest.find(params[:id])
    if params[:status].to_s == "approved"
      if approved_request.is_hod_approved == true
        render json:{alert: "Already Approved"}, status: :created
      else
        approval_request.is_hod_approved = true
        approval_request.is_hod_submitted = true
        approval_request.approval_request_status  = 'Approved'
        approval_request.is_approved = true
        if approval_request.save
          approval_request.add_impact_in_leave_request(User.find_by_email("ajaz.bhutta@sapphire.com.pk"))
          render json:{notice: "Approved"}, status: :created
        else
          render json: {errors: approval_request.errors.full_messages}, status: :unprocessable_entity
        end
      end
    else
      approval_request.is_hod_approved = false
      approval_request.is_hod_submitted = false
      if approval_request.save
        UserMailer.create_leave_request_reject_notification("ajaz.bhutta@sapphire.com.pk", "", "", "Leave Request Rejected", approval_request).deliver_now
        render json:{notice: "Rejected"}, status: :created
      else
        render json: {errors: approval_request.errors.full_messages}, status: :unprocessable_entity
      end
    end
  end

	private

	def set_leave_approval_request
    @leave_approval_request = ApprovalRequest.find(params[:id])
  end

end
