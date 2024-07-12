class Api::V1::Web::OfficialDutyManagement::OfficialDutyApprovalRequestsController < ApplicationController

	before_action :set_official_duty_approval_request, :only => [:show]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    @official_duty_approvals = []
    if current_user.employee
      employee = current_user.employee
      @official_duty_approvals = ApprovalRequest.where(:company_id => employee.company_id, :requestable_type => "OfficialDuty", :request_receiver_id => employee.id).order('id DESC')
    elsif current_user.is_admin
      @official_duty_approvals = ApprovalRequest.get_od_requests.includes(requestable: :employee).order('id DESC')
    end
    render status:200, template: 'api/v1/web/official_duty_management/official_duty_approval_requests/index'
  end

  def show
    render status:200, template: 'api/v1/web/official_duty_management/official_duty_approval_requests/show'
  end

  def approved_request
    approval_request = ApprovalRequest.find(params[:id])
    approval_request.approval_request_status  = 'Approved'
    approval_request.is_approved              = true
    if approval_request.save
      approval_request.add_impact_in_official_duty_request(current_user)
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
      approval_request.add_impact_in_official_duty_request(current_user)
      render json:{}, status: 200
    else
      render json: {errors: approval_request.errors.full_messages}, status: :unprocessable_entity
    end
  end

	private

	def set_official_duty_approval_request
    @official_duty_approval_request = ApprovalRequest.find(params[:id])
  end
  
end
