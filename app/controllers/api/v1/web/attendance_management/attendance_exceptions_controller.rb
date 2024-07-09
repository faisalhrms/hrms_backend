class Api::V1::Web::AttendanceManagement::AttendanceExceptionsController < ApplicationController

	before_filter :set_attendance_exception, :only => [:show, :update, :destroy]
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  def index
    if current_user.is_admin == true
      @attendance_exceptions = AttendanceException.all.order('id DESC')
    else
      @attendance_exceptions = AttendanceException.where(:company_id => current_user.company_id).order('id DESC')
    end
    render status:200, template: 'api/v1/web/attendance_management/attendance_exceptions/index.json.jbuilder'
  end

  def filter_data
    @attendance_exceptions = AttendanceException.where(:company_id => params[:company_id], :is_active => true).order('id DESC')
    render status:200, template: 'api/v1/web/attendance_management/attendance_exceptions/index.json.jbuilder'
  end

  def create
    @attendance_exception       = AttendanceException.new attendance_exception_params
    update_attendance_exception_dates
    if @attendance_exception.save
      render json:{}, status: :created
    else
      render json: {errors: @attendance_exception.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def show
    render status:200, template: 'api/v1/web/attendance_management/attendance_exceptions/show.json.jbuilder'
  end

  def update
    update_attendance_exception_dates
    if @attendance_exception.update(attendance_exception_params)
      render json: {}, status: 204
    else
      render json: {errors: @attendance_exception.errors.full_messages}, status: :unprocessable_entity
    end
  end

  def destroy
  	if @attendance_exception.destroy
  		render json: {}, status: 204
  	else
  		render json: {errors: @attendance_exception.errors.full_messages}, status: :unprocessable_entity
  	end
  end

	private

	def attendance_exception_params
		params.permit(:company_id, :location_id, :branch_id, :name, :attendance_exception_type, :grace_time, :description, :salary_unit_id, :salary_unit_wise)
	end

  def set_attendance_exception
    @attendance_exception = AttendanceException.find(params[:id])
  end

  def update_attendance_exception_dates
    if params[:start_date].nil?
      @attendance_exception.start_date = nil
    else
      @attendance_exception.start_date = params[:start_date].to_date
    end
    if params[:end_date].nil?
      @attendance_exception.end_date = nil
    else
      @attendance_exception.end_date = params[:end_date].to_date
    end
  end
  
end
