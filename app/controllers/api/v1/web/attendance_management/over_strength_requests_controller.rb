class Api::V1::Web::AttendanceManagement::OverStrengthRequestsController < ApplicationController

	before_action :set_over_strength_request, :only => [:show]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if not current_user.employee.nil?
      @over_strength_requests = OverStrengthRequest.where(:employee_id => current_user.employee.id).order('id DESC')
    else
      @over_strength_requests = []
    end
    render status:200, template: 'api/v1/web/attendance_management/over_strength_requests/index'
  end

  def bulk_index
    @employees = Employee.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    filter_employee_data_on_request
    if not current_user.employee.nil?
      if current_user.is_location_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id).order('id DESC')
      elsif current_user.is_branch_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id).order('id DESC')
      elsif current_user.is_department_head == true
        @employees = Employee.where(:location_id => current_user.employee.location_id, :branch_id => current_user.employee.branch_id, :department_id => current_user.employee.department_id).order('id DESC')
      elsif current_user.employee.is_line_manager == true
        sub_ordinates_ids = []
        employee_ids = []
        employee_ids << Employee.heirarical_sub_ordinates(sub_ordinates_ids,current_user.employee.id)
        employee_ids = employee_ids.flatten.uniq
        employee_ids << current_user.employee.id
        @employees = Employee.where(:id => employee_ids.uniq).order('id DESC')
      else
        @employees = []
      end
    end
    start_date      = params[:start_date]
    end_date        = params[:end_date]
    od_status    		= params[:od_status]
    if od_status == "All"
      od_status = ["Cancelled", "Rejected", "Availed", "Waiting For Approval"]
    end
    @over_strength_requests = OverStrengthRequest.where(:company_id => params[:company_id], :request_status => od_status, :employee_id => @employees.collect(&:id)).where(['start_date >= ? AND end_date <= ?', start_date.to_date.beginning_of_day, end_date.to_date.end_of_day]).order('id DESC')
    render status:200, template: 'api/v1/web/attendance_management/over_strength_requests/index'
  end

  def verify_over_strength_request
  	if params[:employee_id].blank?
  		if not current_user.employee.nil?
        @employee      		= current_user.employee
	      start_date      	= params[:start_date].to_date.beginning_of_day
        end_date        	= params[:end_date].to_date.end_of_day
	      requested_data  	= OverStrengthRequest.verify_over_strength_request(@employee, start_date, end_date)
	      render json: {:request_count => requested_data[0], :message => requested_data[1], :company_id => @employee.company_id}, status: 200
	    else
	      render json: {errors: "Request Employee not Found in System"}, status: :unprocessable_entity
	    end
	  else
	  	@employee      		= Employee.find(params[:employee_id])
      start_date      	= params[:start_date].to_date.beginning_of_day
      end_date        	= params[:end_date].to_date.end_of_day
      requested_data  	= OverStrengthRequest.verify_over_strength_request(@employee, start_date, end_date)
      render json: {:request_count => requested_data[0], :message => requested_data[1], :company_id => @employee.company_id}, status: 200
  	end
  end

  def filter_data
    @badli_requests = OverStrengthRequest.where(:company_id => params[:company_id]).order('id DESC')
    render status:200, template: 'api/v1/web/attendance_management/over_strength_requests/index'
  end

  def create
    employee  = Employee.find(params[:employee_id])
    over_strength_request 		= OverStrengthRequest.new
    over_strength_request.company_id 					= params[:company_id]
		over_strength_request.employee_id 				= params[:employee_id]
		over_strength_request.department_id				= params[:department_id]
		over_strength_request.request_count 			= params[:request_count]
    over_strength_request.start_date      		= params[:start_date].to_date
    over_strength_request.end_date      			= params[:end_date].to_date
    over_strength_request.reason              = params[:reason]
    over_strength_request.request_sender_name = "-"
		over_strength_request.request_status    = "Availed"
		if not current_user.employee.nil?
      if current_user.employee.id == employee.id
        over_strength_request.apply_status    = "Employee"
      else
        over_strength_request.apply_status    = "#{current_user.first_name} #{current_user.last_name}"
      end
    else
      over_strength_request.apply_status      = "#{current_user.first_name} #{current_user.last_name}"
    end  
    over_strength_request.is_cancelled     		= false
    if over_strength_request.save
      render json:{}, status: :created
    else
      render json: {errors: over_strength_request.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def cancel_request
    over_strength_request = OverStrengthRequest.find(params[:id])
    over_strength_request.is_cancelled = true
    over_strength_request.request_status = "Cancelled"
    over_strength_request.save
    render json:{}, status: 200
  end

  def approved_request
    over_strength_request = OverStrengthRequest.find(params[:id])
    over_strength_request.add_impact_to_approval_request(current_user)
    render json:{}, status: 200
  end

  def show
    render status:200, template: 'api/v1/web/attendance_management/over_strength_requests/show'
  end

	private

	def set_over_strength_request
    @over_strength_request = OverStrengthRequest.find(params[:id])
  end

  def filter_employee_data_on_request
    if not params[:location_id].blank?
      @employees = Employee.location_related_employee(@employees, params[:location_id].to_i)
    end
    if not params[:branch_id].blank?
      @employees = Employee.branch_related_employee(@employees, params[:branch_id].to_i)
    end
  end

end
