class Api::V1::Web::LeaveManagement::LeaveTypesController < ApplicationController

	before_filter :set_leave_type, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @leave_types = LeaveType.all.order('sort_order ASC')
    else
      @leave_types = LeaveType.where(:company_id => current_user.company_id).order('sort_order ASC')
    end
    render status:200, template: 'api/v1/web/leave_management/leave_types/index.json.jbuilder'
  end

  def non_composite
    if current_user.is_admin == true
      @leave_types = LeaveType.where(:is_composite => false, :special_leave => false, :is_active => true).order('sort_order ASC')
    else
      @leave_types = LeaveType.where(:company_id => current_user.company_id, :is_composite => false, :special_leave => false, :is_active => true).order('sort_order ASC')
    end
    render status:200, template: 'api/v1/web/leave_management/leave_types/non_composite.json.jbuilder'
  end

  def filter_data
    @leave_types = LeaveType.where(:company_id => params[:company_id], :is_active => true).order('sort_order ASC')
    render status:200, template: 'api/v1/web/leave_management/leave_types/index.json.jbuilder'
  end

  def filter_location_data
    @leave_types = LeaveType.where(:location_id => params[:location_id], :is_active => true).order('sort_order ASC')
    render status:200, template: 'api/v1/web/leave_management/leave_types/index.json.jbuilder'
  end

  def inactive_leave_years
    @leave_years = LeaveYear.where(:company_id => current_user.company_id, is_active: false).order('id DESC')
    render status:200, template: 'api/v1/web/leave_management/leave_years/inactive_leave_years.json.jbuilder'
  end

  def filter_employee_leave_type
    leave_type_ids = LeaveAllocation.where(:employee => params[:employee_id], :is_active => true).collect(&:leave_type_id)
    @employee = Employee.find_by(id: params[:employee_id])
    @leave_types = LeaveType.where(:id => leave_type_ids, :is_active => true).order('sort_order ASC')
    render status:200, template: 'api/v1/web/leave_management/leave_types/index.json.jbuilder'
  end

  def create
    @leave_type       = LeaveType.new leave_type_params
    @leave_type.grade_ids = params[:grade_ids].try(:map, &:to_i).try(:join, ',')
    if @leave_type.save
      if @leave_type.is_composite
        save_or_update_composite_leave_type
      end
      render json:{}, status: :created
    else
      render json: {errors: @leave_type.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/leave_management/leave_types/show.json.jbuilder'
  end

  def update
    @leave_type.grade_ids = params[:grade_ids].try(:map, &:to_i).try(:join, ',')
    if @leave_type.update(leave_type_params)
      if @leave_type.is_composite == true
        save_or_update_composite_leave_type
      end
      render json: {}, status: 204
    else
      render json: {errors: @leave_type.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @leave_type.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @leave_type.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def leave_type_params
		params.permit(:company_id, :location_id, :name, :short_name, :gender, :tenure, :eligible, :encashment_applicable, :limit_request_tenure, :is_active, :is_deductible, :sandwich, :splitable, :can_apply_in_probation, :pro_rated, :can_apply_for_remaining_leave, :back_date_apply, :encashment, :carry_forward, :limit_request_in_tenure, :accumulative_count, :min_day_for_apply_leave, :min_experience_to_availed_leave, :limit_request_count, :back_date_limit, :encashment_min_limit, :encashment_max_limit, :carry_forward_min_limit, :carry_forward_max_limit, :description, :quota_allocation, :earned_quota, :sort_order, :auto_allocation, :special_leave, :earned_quota_max_limit, :no_of_years, :backdate_quota, :is_composite, :attendance_restricted, :attendance_restricted_applicable, :no_of_absent, :is_leave_without_pay, :skipped_joining_month, :experience_type, :probation_limit_request_in_tenure, :probation_limit_request_tenure, :probation_limit_request_count, :transfer_probation_balance)
	end

  def set_leave_type
    @leave_type = LeaveType.find(params[:id])
  end

  def save_or_update_composite_leave_type
    if params[:composite_leave_types].present?
      composite_leave_types = params[:composite_leave_types]
      if composite_leave_types.count > 0
        Array.new(composite_leave_types.count).each_index do |index|
          if composite_leave_types[index.to_s][:composite_leave_type_id].nil?
            composite_leave_type = @leave_type.composite_leave_types.build
            composite_leave_type.merge_leave_type_id = composite_leave_types[index.to_s][:id].to_i
            composite_leave_type.status              = composite_leave_types[index.to_s][:status]
            composite_leave_type.save
          else
            edit_composite_leave_type = @leave_type.composite_leave_types.find composite_leave_types[index.to_s][:composite_leave_type_id]
            edit_composite_leave_type.merge_leave_type_id = composite_leave_types[index.to_s][:id].to_i
            edit_composite_leave_type.status              = composite_leave_types[index.to_s][:status]
            edit_composite_leave_type.save
          end
        end
      end
    end
  end

end
