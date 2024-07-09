class Api::V1::Web::AttendanceManagement::AttendanceStructuresController < ApplicationController

	before_filter :set_attendance_structure, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @attendance_structures = AttendanceStructure.all.order('id DESC')
    else
      @attendance_structures = AttendanceStructure.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/attendance_management/attendance_structures/index.json.jbuilder'
  end

  def filter_data
    @attendance_structures = AttendanceStructure.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/attendance_management/attendance_structures/index.json.jbuilder'
  end

  def create
    @attendance_structure = AttendanceStructure.new attendance_structure_params
    @attendance_structure.department_ids = params[:department_ids].map(&:to_i).join(',')
    update_policy_dates
    if @attendance_structure.save
      render json:{}, status: :created
    else
      render json: {errors: @attendance_structure.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def bulk_department_allocation
    department_ids = params[:department_ids]
    if params[:attendance_structure_ids].present?
      attendance_structure_ids = params[:attendance_structure_ids].map(&:to_i)
      attendance_structure_ids.each do |single_value|
        attendance_structure = AttendanceStructure.find(single_value)
        attendance_structure.department_ids = "#{attendance_structure.department_ids},#{department_ids.join(',')}"
        attendance_structure.department_ids = attendance_structure.department_ids.split(',').map(&:to_i).uniq.join(',')
        attendance_structure.save
      end
    end
    render json: {}, status: 204
  end

  def show
    render status:200, template: 'api/v1/web/attendance_management/attendance_structures/show.json.jbuilder'
  end

  def update
  	update_policy_dates
    @attendance_structure.department_ids = params[:department_ids].map(&:to_i).join(',')
    if @attendance_structure.update(attendance_structure_params)
      render json: {}, status: 204
    else
      render json: {errors: @attendance_structure.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @attendance_structure.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @attendance_structure.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def attendance_structure_params
		params.permit(:name, :code, :company_id, :is_active, :location_id, :branch_id, :department_id, :grade_id, :absent_policy_id, :attendance_overtime_id, :attendance_relaxation_id, :early_left_id, :missing_punch_id, :description, :special_rule, :is_flexi, :serve_minutes, :total_working_minutes, :addional_minutes, :regular_overtime_exception, :regular_min_salary, :regular_max_salary, :regular_overtime_id, :holiday_overtime_exception, :holiday_min_salary, :holiday_max_salary, :holiday_overtime_id, :is_flexi_in_early_gone, :early_gone_total_working_minute)
	end

  def set_attendance_structure
    @attendance_structure = AttendanceStructure.find(params[:id])
  end

  def update_policy_dates
  	if params[:start_date].nil?
      @attendance_structure.start_date = nil
    else
      @attendance_structure.start_date = params[:start_date].to_date
    end
    if params[:end_date].nil?
      @attendance_structure.end_date = nil
    else
      @attendance_structure.end_date = params[:end_date].to_date
    end
  end

end
