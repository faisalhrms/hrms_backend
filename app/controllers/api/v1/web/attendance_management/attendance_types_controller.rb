class Api::V1::Web::AttendanceManagement::AttendanceTypesController < ApplicationController

	before_filter :set_attendance_type, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @attendance_types = AttendanceType.all.order('sort_order ASC')
    else
      @attendance_types = AttendanceType.where(:company_id => current_user.company_id).order('sort_order ASC')
    end
    render status:200, template: 'api/v1/web/attendance_management/attendance_types/index.json.jbuilder'
  end

  def filter_data
    @attendance_types = AttendanceType.where(:company_id => params[:company_id], :is_active => true).order('sort_order ASC')
    render status:200, template: 'api/v1/web/attendance_management/attendance_types/index.json.jbuilder'
  end

  def request_enabled
    @attendance_types = AttendanceType.where(:company_id => params[:company_id], :is_active => true, :request_enable => true).order('sort_order ASC')
    render status:200, template: 'api/v1/web/attendance_management/attendance_types/index.json.jbuilder'
  end

  def employee_related_request_enabled
    employee = Employee.find (params[:employee_id])
    @attendance_types = AttendanceType.where(:company_id => employee.company_id, :is_active => true, :request_enable => true).order('sort_order ASC')
    render status:200, template: 'api/v1/web/attendance_management/attendance_types/index.json.jbuilder'
  end

  def create
    @attendance_type       = AttendanceType.new attendance_type_params
    if @attendance_type.save
      render json:{}, status: :created
    else
      render json: {errors: @attendance_type.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/attendance_management/attendance_types/show.json.jbuilder'
  end

  def update
    if @attendance_type.update(attendance_type_params)
      render json: {}, status: 204
    else
      render json: {errors: @attendance_type.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @attendance_type.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @attendance_type.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def attendance_type_params
		params.permit(:company_id, :name, :code, :sort_order, :is_active, :request_enable, :description)
	end

  def set_attendance_type
    @attendance_type = AttendanceType.find(params[:id])
  end

end
