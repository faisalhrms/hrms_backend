class Api::V1::Web::AttendanceManagement::RelaxationApprovalRequestsController < ApplicationController

	before_filter :set_relaxation_approval_request, :only => [:show]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if not current_user.employee.nil?
      employee = current_user.employee
      @relaxation_approvals = ApprovalRequest.where(:company_id => employee.company_id, :requestable_type => "RelaxationRequest", :request_receiver_id => employee.id).order('id DESC')
    else
      @relaxation_approvals = []
    end
    render status:200, template: 'api/v1/web/attendance_management/relaxation_approval_requests/index.json.jbuilder'
  end

  def show
    render status:200, template: 'api/v1/web/attendance_management/relaxation_approval_requests/show.json.jbuilder'
  end

  def approved_request
    approval_request = ApprovalRequest.find(params[:id])
    approval_request.approval_request_status  = "Approved"
    approval_request.is_approved              = true
    approval_request.save
    approval_request.add_impact_in_relaxation_request(current_user)
    render json:{}, status: 200
  end

  def cancel_request
    approval_request = ApprovalRequest.find(params[:id])
    approval_request.approval_request_status  = "Rejected"
    approval_request.is_approved              = false
    approval_request.save
    approval_request.add_impact_in_relaxation_request(current_user)
    render json:{}, status: 200
  end

	private

	def set_relaxation_approval_request
    @relaxation_approval_request = ApprovalRequest.find(params[:id])
  end

end
